//
//  RDNSequence.swift
//  asn1bridgetest
//
//  Created by Luke Howard on 30/10/2022.
//

import Foundation
import ASN1Kit
import ASN1CodingKit

// extensions

public extension RDNSequence {
    static func parse(dn: String) throws -> RDNSequence {
        let dnComponents = dn.components(separatedBy: "/")

        if dnComponents.count < 1 {
            throw ASN1Error.malformedEncoding("Malformed DN")
        }
        
        let rdnSequence: [RelativeDistinguishedName] = try dnComponents[1...].map {
            let rdnComponents = $0.components(separatedBy: "=")
            guard rdnComponents.count == 2 else {
                throw ASN1Error.malformedEncoding("Malformed RDN")
            }
            let oid = try ObjectIdentifier.from(string: rdnComponents[0])
            let ava = AttributeTypeAndValue(type: oid, value: DirectoryString.ia5String(IA5String(wrappedValue: rdnComponents[1])))

            return RelativeDistinguishedName([ava])
        }
        
        return rdnSequence
    }
}
