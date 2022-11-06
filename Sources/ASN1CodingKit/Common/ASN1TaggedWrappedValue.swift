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

public protocol ASN1TaggedWrappedValue: Codable, ASN1TaggedTypeRepresentable {
    static var tag: ASN1DecodedTag? { get }
    static var tagging: ASN1Tagging? { get }

    associatedtype Value: Codable
    
    var wrappedValue: Value { get set }
    var projectedValue: any ASN1TaggedWrappedValue { get }

    init(wrappedValue: Value)
}

extension ASN1TaggedWrappedValue {
    public static var tag: ASN1DecodedTag? { return nil }
    
    public var projectedValue: any ASN1TaggedWrappedValue {
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
    func decode<T: ExpressibleByNilLiteral, U: ASN1TaggedWrappedValue>(_ type: U.Type, forKey key: K) throws -> any ASN1TaggedWrappedValue where U.Value == T {
        if let value = try self.decodeIfPresent(type, forKey: key) {
            return value
        }
        
        return U(wrappedValue: nil)
    }
}

