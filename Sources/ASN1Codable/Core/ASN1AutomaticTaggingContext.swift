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
        // this is expensive, so use automatic tags sparingly, or have the compiler do the job
        if let metadata = reflect(type) as? StructMetadata {
            let hasTaggedFields = metadata.descriptor.fields.records.contains {
                guard let fieldType = metadata.type(of: $0.mangledTypeName),
                      let wrappedFieldType = fieldType as? any ASN1TaggedWrappedValue.Type else {
                    return false
                }
                return wrappedFieldType.metadata.tag != nil
            }

            guard !hasTaggedFields else {
                return nil
            }
        } else if let metadata = reflect(type) as? EnumMetadata {
            let hasTaggedFields = metadata.descriptor.fields.records.contains {
                guard let fieldType = metadata.type(of: $0.mangledTypeName),
                      let wrappedFieldType = fieldType as? any ASN1TaggedWrappedValue.Type else {
                    return false
                }
                return wrappedFieldType.metadata.tag != nil
            }

            guard !hasTaggedFields else {
                return nil
            }

            self.enumMetadata = metadata
        }

        self.tagNo = 0
    }

    func selectTag<Key>(_ key: Key) where Key : CodingKey {
        guard let metadata = self.enumMetadata else {
            return
        }

        precondition(self.tagNo == 0)

        guard let index = metadata.descriptor.fields.records.firstIndex(where: { $0.name == key.stringValue }) else {
            return
        }

        self.tagNo = UInt(index)
    }

    func selectTag<Key>(_ tag: ASN1DecodedTag) -> Key? where Key : CodingKey {
        guard let metadata = self.enumMetadata else {
            return nil
        }

        precondition(self.tagNo == 0)

        guard case .taggedTag(let tagNo) = tag else {
            return nil
        }

        guard tagNo < metadata.descriptor.fields.records.count else {
            return nil
        }

        self.tagNo = tagNo
        return Key(stringValue: metadata.descriptor.fields.records[Int(tagNo)].name)
    }

    private func nextTag() -> ASN1DecodedTag {
        defer { self.tagNo += 1 }
        return .taggedTag(self.tagNo)
    }

    private var tagging: ASN1Tagging {
        return self.enumMetadata != nil ? .explicit : .implicit
    }

    func metadataForNextTag() -> ASN1Metadata {
        return ASN1Metadata(tag: self.nextTag(), tagging: self.tagging)
    }

    var description: String {
        return "ASN1AutomaticTaggingContext(tagNo: \(self.tagNo))"
    }
}
