//
// Copyright (c) 2022 PADL Software Pty Ltd
//
// Licensed under the Apache License, Version 2.0 (the License);
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an 'AS IS' BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import ASN1Kit
import Echo

/// A class that tracks state when automatic tagging is used.
///
/// Automatic tagging assigns a new implicit tag for each structure
/// or enum field.
final class ASN1AutomaticTaggingContext: CustomStringConvertible {
    private var tagNo: UInt
    private var enumMetadata: EnumMetadata?

    init?<T>(_ type: T.Type) {
        let hasTaggedFields: Bool

        // this is expensive, so use automatic tags sparingly, or have the compiler do the job
        if let metadata = reflect(type) as? StructMetadata {
            hasTaggedFields = metadata.descriptor.fields.hasTaggedFields(metadata)
        } else if let metadata = reflect(type) as? ClassMetadata {
            hasTaggedFields = metadata.descriptor.fields.hasTaggedFields(metadata)
        } else if let metadata = reflect(type) as? EnumMetadata {
            hasTaggedFields = metadata.descriptor.fields.hasTaggedFields(metadata)
            self.enumMetadata = metadata
        } else {
            hasTaggedFields = false
        }

        guard !hasTaggedFields else {
            return nil
        }

        self.tagNo = 0
    }

    private func tagNumber<Key: CaseIterable & CodingKey>(_ key: Key) -> UInt? {
        let allCases = Key.allCases

        guard let firstIndex = allCases.firstIndex(where: {
            $0.stringValue == key.stringValue
        }) else {
            return nil
        }

        let distance: Int = allCases.distance(from: allCases.startIndex, to: firstIndex)
        return UInt(exactly: distance)
    }

    private func tagNumber<Key: CodingKey>(_ key: Key) -> UInt? {
        guard let metadata = self.enumMetadata else {
            return nil
        }

        guard let index = metadata.descriptor.fields.records.firstIndex(where: { $0.name == key.stringValue }) else {
            return nil
        }

        return UInt(exactly: index)
    }

    func selectTag<Key>(_ key: Key) where Key: CodingKey {
        precondition(self.tagNo == 0)

        let tagNo: UInt?
        if let key = key as? any(CaseIterable & CodingKey) {
            tagNo = self.tagNumber(key)
        } else {
            tagNo = self.tagNumber(key)
        }

        guard let tagNo else {
            return
        }

        self.tagNo = tagNo
    }

    private func caseIterableCodingKey<Key: CaseIterable & CodingKey>(
        _: Key.Type,
        fromContextTag tagNo: UInt
    ) -> Key? {
        guard tagNo < Key.allCases.count, let index = Int(exactly: tagNo) else {
            return nil
        }

        // swiftlint:disable force_cast
        return Key.allCases[index as! Key.AllCases.Index]
    }

    private func codingKey<Key: CodingKey>(fromContextTag tagNo: UInt) -> Key? {
        guard let metadata = self.enumMetadata else {
            return nil
        }

        guard tagNo < metadata.descriptor.fields.records.count,
              let index = Int(exactly: tagNo) else {
            return nil
        }

        return Key(stringValue: metadata.descriptor.fields.records[index].name)
    }

    func selectTag<Key>(_ tag: ASN1DecodedTag) -> Key? where Key: CodingKey {
        guard case .taggedTag(let tagNo) = tag else {
            return nil
        }

        let key: Key?

        if let type = Key.self as? any(CaseIterable & CodingKey).Type {
            // swiftlint:disable force_cast
            key = self.caseIterableCodingKey(type, fromContextTag: tagNo) as! Key?
        } else {
            key = self.codingKey(fromContextTag: tagNo)
        }

        if key != nil {
            self.tagNo = tagNo
        }

        return key
    }

    private func nextTag() -> ASN1DecodedTag {
        defer { self.tagNo += 1 }
        return .taggedTag(self.tagNo)
    }

    func metadataForNextTag() -> ASN1Metadata {
        ASN1Metadata(tag: self.nextTag(), tagging: .implicit)
    }

    var description: String {
        "ASN1AutomaticTaggingContext(tagNo: \(self.tagNo))"
    }
}

extension FieldDescriptor {
    fileprivate func hasTaggedFields(_ metadata: TypeMetadata) -> Bool {
        self.records.contains {
            guard let fieldType = metadata.type(of: $0.mangledTypeName),
                  let wrappedFieldType = fieldType as? any ASN1TaggedValue.Type,
                  !(wrappedFieldType is any ASN1UniversalTaggedValue.Type) else {
                return false
            }
            return wrappedFieldType.metadata.tag != nil
        }
    }
}
