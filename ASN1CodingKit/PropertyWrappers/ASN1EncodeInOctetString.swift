//
//  ASN1EncodeInOctetString.swift
//  ASN1Kit
//
//  Created by Luke Howard on 28/10/2022.
//

import Foundation

@propertyWrapper
public struct ASN1EncodeInOctetString <Value: Codable>: Codable, ASN1WrappedValue {
    public var wrappedValue: Value
    
    public static var flags: ASN1Flags {
        return ASN1Flags([.implicit])
    }
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    public init() where Value: ExpressibleByNilLiteral {
        self.wrappedValue = nil
    }
}

public protocol ASN1EncodeInOctetStringType: ASN1Type {
}
