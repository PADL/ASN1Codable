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

public protocol ExpressibleByString: Equatable, Hashable {
    init(_ string: String)
}

extension String: ExpressibleByString {
    public init(_ string: String) {
        self = string
    }
}

extension Optional: ExpressibleByString where Wrapped == String {
    public init(_ string: String) {
        self = string
    }
}

extension Optional: ASN1DecodableType where Wrapped == String {
    public init(from asn1: ASN1Object) throws {
        if asn1.isNull {
            self = nil
        } else {
            self = try Wrapped(from: asn1)
        }
    }
}

extension Optional: ASN1EncodableType where Wrapped == String {
    public func asn1encode(tag: ASN1DecodedTag?) throws -> ASN1Object {
        switch self {
        case .none:
            return ASN1Kit.create(tag: ASN1DecodedTag.universal(.null),
                                  data: ASN1Data.primitive(Data()))
        case .some(let value):
            return try value.asn1encode(tag: tag)
        }
    }
}

@propertyWrapper
public struct GeneralString<Value: Codable & ExpressibleByString & ASN1CodableType>: Codable, Equatable, Hashable, ASN1TaggedProperty {
    public var wrappedValue: Value
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    public init() where Value: ExpressibleByNilLiteral {
        self.wrappedValue = nil
    }
    
    public static var tag: ASN1DecodedTag? {
        return .universal(.generalString)
    }
}

@propertyWrapper
public struct IA5String<Value: Codable & ExpressibleByString & ASN1CodableType>: Codable, Equatable, Hashable, ASN1TaggedProperty {
    public var wrappedValue: Value
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    public init() where Value: ExpressibleByNilLiteral {
        self.wrappedValue = nil
    }
    
    public static var tag: ASN1DecodedTag? {
        return .universal(.ia5String)
    }
}

@propertyWrapper
public struct UTF8String<Value: Codable & ExpressibleByString & ASN1CodableType>: Codable, Equatable, Hashable, ASN1TaggedProperty {
    public var wrappedValue: Value
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    public init() where Value: ExpressibleByNilLiteral {
        self.wrappedValue = nil
    }
    
    public static var tag: ASN1DecodedTag? {
        return .universal(.utf8String)
    }
}

@propertyWrapper
public struct UniversalString<Value: Codable & ExpressibleByString & ASN1CodableType>: Codable, Equatable, Hashable, ASN1TaggedProperty {
    public var wrappedValue: Value
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    public init() where Value: ExpressibleByNilLiteral {
        self.wrappedValue = nil
    }
    
    public static var tag: ASN1DecodedTag? {
        return .universal(.universalString)
    }
}

@propertyWrapper
public struct BMPString<Value: Codable & ExpressibleByString & ASN1CodableType>: Codable, Equatable, Hashable, ASN1TaggedProperty {
    public var wrappedValue: Value
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    public init() where Value: ExpressibleByNilLiteral {
        self.wrappedValue = nil
    }
    
    public static var tag: ASN1DecodedTag? {
        return .universal(.bmpString)
    }
}

@propertyWrapper
public struct PrintableString<Value: Codable & ExpressibleByString & ASN1CodableType>: Codable, Equatable, Hashable, ASN1TaggedProperty {
    public var wrappedValue: Value
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    public init() where Value: ExpressibleByNilLiteral {
        self.wrappedValue = nil
    }
    
    public static var tag: ASN1DecodedTag? {
        return .universal(.printableString)
    }
}

extension GeneralString: ASN1UniversalTagRepresentable {
    static var tagNo: ASN1Tag { return .generalString }
}

extension IA5String: ASN1UniversalTagRepresentable {
    static var tagNo: ASN1Tag { return .ia5String }
}

extension UTF8String: ASN1UniversalTagRepresentable {
    static var tagNo: ASN1Tag { return .utf8String }
}

extension UniversalString: ASN1UniversalTagRepresentable {
    static var tagNo: ASN1Tag { return .universalString }
}

extension BMPString: ASN1UniversalTagRepresentable {
    static var tagNo: ASN1Tag { return .bmpString }
}

extension PrintableString: ASN1UniversalTagRepresentable {
    static var tagNo: ASN1Tag { return .printableString }
}
