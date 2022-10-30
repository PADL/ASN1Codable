//
//  String.swift
//  ASN1Kit
//
//  Created by Luke Howard on 26/10/2022.
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
        if asn1.tag == .universal(.null) {
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
                                  data: ASN1Data.primitive(Data.empty))
        case .some(let value):
            return try value.asn1encode(tag: tag)
        }
    }
}

@propertyWrapper
public struct IA5String<Value: Codable & ExpressibleByString & ASN1CodableType>: Codable, Equatable, Hashable, ASN1WrappedValue {
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
public struct UTF8String<Value: Codable & ExpressibleByString & ASN1CodableType>: Codable, Equatable, Hashable, ASN1WrappedValue {
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
public struct UniveralString<Value: Codable & ExpressibleByString & ASN1CodableType>: Codable, Equatable, Hashable, ASN1WrappedValue {
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
public struct BMPString<Value: Codable & ExpressibleByString & ASN1CodableType>: Codable, Equatable, Hashable, ASN1WrappedValue {
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
public struct PrintableString<Value: Codable & ExpressibleByString & ASN1CodableType>: Codable, Equatable, Hashable, ASN1WrappedValue {
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
