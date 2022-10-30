//
//  ASN1EncodingContainer.swift
//  ASN1CodingKit
//
//  Created by Luke Howard on 30/10/2022.
//

import Foundation
import ASN1Kit

protocol ASN1EncodingContainer: ASN1CodingContainer {
    var object: ASN1Object? { get }
}

