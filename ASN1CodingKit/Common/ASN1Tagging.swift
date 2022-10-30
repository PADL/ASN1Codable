//
//  ASN1Tagging.swift
//  ASN1CodingKit
//
//  Created by Luke Howard on 31/10/2022.
//

import Foundation

public enum ASN1Tagging {
    case explicit
    case implicit
    case automatic
}

public protocol ASN1TaggingRepresentable {
    static var tagging: ASN1Tagging { get }
}

public enum ASN1ExplicitTagging: ASN1TaggingRepresentable {
    public static var tagging: ASN1Tagging { return .explicit }
}

public enum ASN1ImplicitTagging: ASN1TaggingRepresentable {
    public static var tagging: ASN1Tagging { return .implicit }
}

public enum ASN1AutomaticTagging: ASN1TaggingRepresentable {
    public static var tagging: ASN1Tagging { return .automatic }
}
