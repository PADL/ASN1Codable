//
//  Null.swift
//  ASN1CodingKit
//
//  Created by Luke Howard on 7/11/2022.
//

import Foundation

public struct Null {
}

extension Null: ASN1DecodableType, Codable {
    public init(from asn1: ASN1Object) throws {
        guard asn1.tag == .universal(.null) else {
            throw ASN1Error.malformedEncoding("ASN.1 object has incorret tag \(asn1.tag)")
        }
    }
}

extension Null: ASN1EncodableType {
    public func asn1encode(tag: ASN1DecodedTag?) throws -> ASN1Object {
        return ASN1NullObject
    }
}

extension Null: ASN1UniversalTagRepresentable {
    static var tagNo: ASN1Tag { return .null }
}
