//
//  BuiltinTagNumbers.swift
//  ASN1Kit
//
//  Created by Luke Howard on 27/10/2022.
//

import Foundation

// represents a tag number used to specialize a tag generic
public protocol ASN1TagNumber {
}

// extracts the tag number from the ASN1TagNumber concrete type
extension ASN1TagNumber {
    static var tagNo: UInt {
        let name = String(describing: self)
        let nameComponents = name.components(separatedBy: "$")
        precondition(nameComponents.count == 2)
        return UInt(nameComponents[1])!
    }
}

// FIXME generate these from the compiler in the module

public enum ASN1TagNumber$0: ASN1TagNumber {
}

public enum ASN1TagNumber$1: ASN1TagNumber {
}

public enum ASN1TagNumber$2: ASN1TagNumber {
}

public enum ASN1TagNumber$3: ASN1TagNumber {
}

public enum ASN1TagNumber$4: ASN1TagNumber {
}

public enum ASN1TagNumber$5: ASN1TagNumber {
}

public enum ASN1TagNumber_$6: ASN1TagNumber {
}

public enum ASN1TagNumber$7: ASN1TagNumber {
}

public enum ASN1TagNumber$8: ASN1TagNumber {
}

public enum ASN1TagNumber$9: ASN1TagNumber {
}

public enum ASN1TagNumber$10: ASN1TagNumber {
}
