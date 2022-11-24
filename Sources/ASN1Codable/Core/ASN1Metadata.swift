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

/// internal defintiion of a tag and tagging environment tuple, along with
/// size and value constraints (for future use).
///
/// ASN1Metadata can be derived from a CodingKey, from a type defintion,
/// from a property wrapper, or from an automatic tagging context.
public struct ASN1Metadata: Equatable {
    /// the tag type and number
    var tag: ASN1DecodedTag?
    /// the tagging environment (IMPLICIT or EXPLICIT)
    var tagging: ASN1Tagging?
    /// size constraints restrict the length of BitString, Data, String, Array or Set
    var sizeConstraints: ClosedRange<Int>?
    /// value constraints for integer types (and, eventually, string types)
    var valueConstraints: ClosedRange<Int>?

    public init(tag: ASN1DecodedTag? = nil, tagging: ASN1Tagging? = nil) {
        self.tag = tag
        self.tagging = tagging
    }
}

extension ASN1Metadata: CustomDebugStringConvertible {
    public var debugDescription: String {
        let tagDescription: String?
        let taggingDescription: String?
        var debugDescription = ""

        if let tag = self.tag {
            switch tag {
            case .universal(let asn1Tag):
                tagDescription = "[UNIVERSAL \(asn1Tag.rawValue)]"
            case .applicationTag(let tagNo):
                tagDescription = "[APPLICATION \(tagNo)]"
            case .taggedTag(let tagNo):
                tagDescription = "[\(tagNo)]"
            case .privateTag(let tagNo):
                tagDescription = "[PRIVATE \(tagNo)]"
            }
        } else {
            tagDescription = nil
        }

        if let tagging = self.tagging {
            switch tagging {
            case .implicit:
                taggingDescription = "IMPLICIT"
            case .explicit:
                taggingDescription = "EXPLICIT"
            case .automatic:
                taggingDescription = "AUTOMATIC"
            }
        } else {
            taggingDescription = nil
        }

        if let tagDescription {
            debugDescription.append(tagDescription)
        }
        if let taggingDescription {
            if !debugDescription.isEmpty {
                debugDescription.append(" ")
            }
            debugDescription.append(taggingDescription)
        }

        return debugDescription
    }
}

extension ASN1Metadata {
    func validateSizeConstraints(_ object: ASN1Object) -> Bool {
        let validatedSizeConstraints: Bool

        if let sizeConstraints = self.sizeConstraints {
            switch object.data {
            case .primitive(let data):
                validatedSizeConstraints = sizeConstraints.contains(data.count)
            case .constructed(let items):
                validatedSizeConstraints = sizeConstraints.contains(items.count)
            }
        } else {
            validatedSizeConstraints = true
        }

        return validatedSizeConstraints
    }

    private func validateIntegerValueConstraints<T: FixedWidthInteger>(_ value: T) -> Bool {
        let validatedValueConstraints: Bool

        if let valueConstraints = self.valueConstraints {
            validatedValueConstraints = value >= Int.min && value <= Int.max && valueConstraints.contains(Int(value))
        } else {
            validatedValueConstraints = true
        }

        return validatedValueConstraints
    }

    func validateValueConstraints<T>(_ value: T) -> Bool {
        if let value = value as? any FixedWidthInteger {
            return self.validateIntegerValueConstraints(value)
        }

        return true
    }
}
