//
//  ASN1Encoder.swift
//  asn1bridgetest
//
//  Created by Luke Howard on 23/10/2022.
//

import Foundation
import ASN1Kit

open class ASN1Encoder {
    open var userInfo: [CodingUserInfoKey: Any] = [:]

    public init() {
    }
    
    open func encode<T: Encodable>(_ value: T) throws -> Data {
        let object: ASN1Object = try encodeAsASN1Object(value)
                
        return try object.serialize()
        
    }
    
    func encodeAsASN1Object<T: Encodable>(_ value: T) throws -> ASN1Object {
        let state = ASN1CodingState(depth: -1)
        
        // wrap in an array so that we can access the containing structure
        // otherwise we just get the elements
        let asn1Encoder = ASN1EncoderImpl(codingPath: [], userInfo: self.userInfo, state: state)
        try [value].encode(to: asn1Encoder)
        guard let object = asn1Encoder.object else {
            throw ASN1Error.malformedEncoding("No objects encoded")
        }
        return object
    }
}
