//
//  Time.swift
//  ASN1Kit
//
//  Created by Luke Howard on 26/10/2022.
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
}
