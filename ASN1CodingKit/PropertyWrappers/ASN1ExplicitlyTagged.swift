//
//  ASN1ExplicitlyTagged.swift
//  ASN1CodingKit
//
//  Created by Luke Howard on 31/10/2022.
//

import Foundation
import ASN1Kit

// FIXME do we need this?

/*
@propertyWrapper
public struct ASN1ExplicitlyTagged <Tagging, Value>: Codable, ASN1TaggedProperty where Tagging: ASN1TaggingRepresentable, Value: Codable {
    public static var tag: ASN1DecodedTag? { return nil }
    public static var tagging: ASN1Tagging { return Tagging.tagging }

    public var wrappedValue: Value
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    public init() where Value: ExpressibleByNilLiteral {
        self.wrappedValue = nil
    }
}
 */

public protocol ASN1ExplicitlyTaggedType: ASN1TaggedType {
}
