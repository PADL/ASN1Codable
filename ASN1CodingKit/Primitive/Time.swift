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

@propertyWrapper
public struct GeneralizedTime: Codable, ASN1CodableType {
    public var wrappedValue: Date
    
    public init(wrappedValue: Date) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from asn1: ASN1Object) throws {
        if asn1.tag == .universal(.generalizedTime) {
            try self.wrappedValue = Date(from: asn1)
        } else {
            throw ASN1Error.malformedEncoding("Invalid tag \(asn1.tag) for GeneralizedTime")
        }
    }

    public func asn1encode(tag: ASN1DecodedTag?) throws -> ASN1Object {
        return try wrappedValue.asn1encode(tag: .universal(.generalizedTime))
    }
    
    public func encode(to encoder: Encoder) throws {
        precondition(!(encoder is ASN1CodingKit.ASN1EncoderImpl))
        try self.wrappedValue.encode(to: encoder)
    }
    
    public init(from decoder: Decoder) throws {
        precondition(!(decoder is ASN1CodingKit.ASN1DecoderImpl))
        self.wrappedValue = try Date(from: decoder)
    }
}

@propertyWrapper
public struct UTCTime: Codable, ASN1CodableType {
    public var wrappedValue: Date
    
    public init(wrappedValue: Date) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from asn1: ASN1Object) throws {
        if asn1.tag == .universal(.utcTime) {
            try self.wrappedValue = Date(from: asn1)
        } else {
            throw ASN1Error.malformedEncoding("Invalid tag \(asn1.tag) for UTCTime")
        }
    }

    public func asn1encode(tag: ASN1DecodedTag?) throws -> ASN1Object {
        return try wrappedValue.asn1encode(tag: .universal(.utcTime))
    }
    
    public func encode(to encoder: Encoder) throws {
        precondition(!(encoder is ASN1CodingKit.ASN1EncoderImpl))
        try self.wrappedValue.encode(to: encoder)
    }
    
    public init(from decoder: Decoder) throws {
        precondition(!(decoder is ASN1CodingKit.ASN1DecoderImpl))
        self.wrappedValue = try Date(from: decoder)
    }
}
