//
//  ASN1EncodingContext.swift
//  ASN1CodingKit
//
//  Created by Luke Howard on 1/11/2022.
//

import Foundation
import ASN1Kit

struct ASN1EncodingContext: ASN1CodingContext {
    var depth: ASN1CodingDepth = .none
    var encodeAsSet = false
    
    mutating func encodingSingleValue<T>(_ value: T) {
        if ASN1EncoderImpl.isEnum(value) {
            self.depth = .enum
        } else {
            self.depth = .none
        }
    }
    
    mutating func encodingNestedContainer() {
        self.advanceCodingDepth()
    }
}

