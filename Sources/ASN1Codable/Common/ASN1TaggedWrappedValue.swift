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

public protocol ASN1TaggedWrappedValue: Codable, CustomStringConvertible, CustomDebugStringConvertible, ASN1TaggedTypeRepresentable {
    static var tag: ASN1DecodedTag? { get }
    static var tagging: ASN1Tagging? { get }

    associatedtype Value: Codable
    
    var wrappedValue: Value { get set }
    var projectedValue: ASN1Metatype { get }

    init(wrappedValue: Value)
}

extension ASN1TaggedWrappedValue {
    public static var tag: ASN1DecodedTag? { return nil }
    
    public var projectedValue: ASN1Metatype {
        return ASN1TagMetatype(tag: Self.tag, tagging: Self.tagging)
    }
    
    public func encode(to encoder: Encoder) throws {
        precondition(!(encoder is ASN1Codable.ASN1EncoderImpl))
        try self.wrappedValue.encode(to: encoder)
    }
    
    public init(from decoder: Decoder) throws {
        precondition(!(decoder is ASN1Codable.ASN1DecoderImpl))
        try self.init(wrappedValue: Value(from: decoder))
    }
    
    public var description: String {
        return String(describing: self.wrappedValue)
    }
    
    public var debugDescription: String {
        let tagDescription: String?
        let taggingDescription: String?
        let valueDescription: String
        var debugDescription = ""
        
        if let tag = Self.tag {
            switch tag {
            case .universal(let asn1Tag):
                tagDescription = "[UNIVERSAL \(asn1Tag.rawValue)]"
                break
            case .applicationTag(let tagNo):
                tagDescription = "[APPLICATION \(tagNo)]"
                break
            case .taggedTag(let tagNo):
                tagDescription = "[\(tagNo)]"
                break
            case .privateTag(let tagNo):
                tagDescription = "[PRIVATE \(tagNo)]"
                break
            }
        } else {
            tagDescription = nil
        }

        if let tagging = Self.tagging {
            switch tagging {
            case .implicit:
                taggingDescription = "IMPLICIT"
                break
            case .explicit:
                taggingDescription = "EXPLICIT"
                break
            case .automatic:
                taggingDescription = "AUTOMATIC"
                break
            }
        } else {
            taggingDescription = nil
        }
        
        switch self.wrappedValue {
        case is Void:
            valueDescription = "NULL"
            break
        case let wrappedValue as CustomDebugStringConvertible:
            valueDescription = wrappedValue.debugDescription
            break
        default:
            valueDescription = String(describing: self.wrappedValue)
            break
        }
        
        if let tagDescription = tagDescription {
            debugDescription.append(tagDescription)
        }
        if let taggingDescription = taggingDescription {
            if !debugDescription.isEmpty {
                debugDescription.append(" ")
            }
            debugDescription.append(taggingDescription)
        }
        if !debugDescription.isEmpty {
            debugDescription.append(" ")
        }
        debugDescription.append(valueDescription)
        return debugDescription
    }
}

extension KeyedDecodingContainer {
    func decode<T: ExpressibleByNilLiteral, U: ASN1TaggedWrappedValue>(_ type: U.Type, forKey key: K) throws -> any ASN1TaggedWrappedValue where U.Value == T {
        if let value = try self.decodeIfPresent(type, forKey: key) {
            return value
        }
        
        return U(wrappedValue: nil)
    }
}
