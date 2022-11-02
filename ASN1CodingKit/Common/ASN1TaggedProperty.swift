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

public protocol ASN1TaggedProperty: Codable, ASN1TaggedTypeRepresentable {
    static var tag: ASN1DecodedTag? { get }
    static var tagging: ASN1Tagging { get }

    associatedtype Value: Codable
    
    var wrappedValue: Value { get set }
    var projectedValue: any ASN1TaggedProperty { get }

    init(wrappedValue: Value)
}

extension ASN1TaggedProperty {
    public static var tag: ASN1DecodedTag? { return nil }
    
    public var projectedValue: any ASN1TaggedProperty {
        return self
    }
    
    public func encode(to encoder: Encoder) throws {
        precondition(!(encoder is ASN1CodingKit.ASN1EncoderImpl))
        try self.wrappedValue.encode(to: encoder)
    }
    
    public init(from decoder: Decoder) throws {
        precondition(!(decoder is ASN1CodingKit.ASN1DecoderImpl))
        try self.init(wrappedValue: Value(from: decoder))
    }
}

extension KeyedDecodingContainer {
    func decode<T: ExpressibleByNilLiteral, U: ASN1TaggedProperty>(_ type: U.Type, forKey key: K) throws -> any ASN1TaggedProperty where U.Value == T {
        if let value = try self.decodeIfPresent(type, forKey: key) {
            return value
        }
        
        return U(wrappedValue: nil)
    }
}

