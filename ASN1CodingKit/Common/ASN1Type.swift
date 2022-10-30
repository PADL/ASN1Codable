//
//  ASN1TaggedType.swift
//  ASN1Kit
//
//  Created by Luke Howard on 24/10/2022.
//

import Foundation
import ASN1Kit

// for applying a tag/flag to an entire type rather than a member

public protocol ASN1Type: ASN1CodableOptions, Codable {    
    static var tagNumber: ASN1TagNumber.Type? { get }
}

public protocol ASN1EncodeAsSetType: ASN1Type {
}

// FIXME make internal
public extension ASN1Type {
    static var tagNumber: ASN1TagNumber.Type? {
        return nil
    }
    
    static var tag: ASN1DecodedTag? {
        guard let tagNumber = self.tagNumber else {
            return nil
        }
        
        return ASN1DecodedTag.taggedTag(tagNumber.tagNo)
    }
    
    static var taggingMode: ASN1TaggingMode? {
        if self is any ASN1ImplicitlyTaggedType.Type {
            return .implicit
        } else if self is any ASN1ExplicitlyTaggedType.Type {
            return .explicit
        } else {
            return nil
        }
    }
}
