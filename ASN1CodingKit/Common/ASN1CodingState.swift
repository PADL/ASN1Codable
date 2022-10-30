//
//  ASN1CodingState.swift
//  asn1bridgetest
//
//  Created by Luke Howard on 30/10/2022.
//

import Foundation

internal struct ASN1CodingState {
    var depth: Int
    var encodeAsSet: Bool

    init(depth: Int = 0, encodeAsSet: Bool = false) {
        self.depth = depth
        self.encodeAsSet = encodeAsSet
    }
    
    mutating func advanceCodingDepth() {
        if self.depth == 1 { // 1 means CHOICE outer
            self.depth = 2
        } else {
            self.depth = 0
        }
    }
}

protocol ASN1CodingContainer {
    var state: ASN1CodingState { get set }
}
