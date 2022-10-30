//
//  ASN1Tagged.swift
//  ASN1Kit
//
//  Created by Luke Howard on 24/10/2022.
//

import Foundation
import ASN1Kit

public protocol ASN1CodableOptions {
    static var tag: ASN1DecodedTag? { get }
    static var taggingMode: ASN1TaggingMode? { get }
}

public extension ASN1CodableOptions {
    static var tag: ASN1DecodedTag? { return nil }
    static var taggingMode: ASN1TaggingMode? { return nil }
}
