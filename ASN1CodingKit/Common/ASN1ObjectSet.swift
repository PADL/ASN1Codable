//
// Copyright (c) 2022 PADL Software Pty Ltd
//
// Licensed under the Apache License, Version 2.0 (the License);
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an 'AS IS' BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import ASN1Kit
import AnyCodable

private typealias ASN1ObjectSetTypeDictionary = [String: [ObjectIdentifier: Codable.Type]]

@propertyWrapper
public struct ASN1ObjectSetType: Codable {
    public var wrappedValue: ObjectIdentifier

    public init(wrappedValue: ObjectIdentifier) {
        self.wrappedValue = wrappedValue
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.wrappedValue = try container.decode(ObjectIdentifier.self)
        
        if let decoder = decoder as? ASN1DecoderImpl,
           let objectSetDecodingContext = decoder.context.objectSetDecodingContext {
            precondition(objectSetDecodingContext.oid == nil)
            objectSetDecodingContext.oid = wrappedValue
        }
    }
}

@propertyWrapper
public struct ASN1ObjectSetValue: Codable {
    public typealias Value = (any Codable)?
    
    public var wrappedValue: Value

    public init() {
        self.wrappedValue = nil
    }
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        if let wrappedValue = self.wrappedValue {
            try container.encode(wrappedValue)
        } else {
            try container.encodeNil()
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        guard let decoder = decoder as? ASN1DecoderImpl else {
            self.wrappedValue = try container.decode(AnyCodable.self)
            return
        }
        
        guard let objectSetDecodingContext = decoder.context.objectSetDecodingContext,
              let type = objectSetDecodingContext.type(decoder) else {
            self.wrappedValue = nil
            return
        }
        
        if objectSetDecodingContext.encodeAsOctetString {
            let berData = try container.decode(Data.self)
            let innerDecoder = ASN1Decoder()
                
            self.wrappedValue = try innerDecoder.decode(type, from: berData)
        } else {
            let value = try container.decode(type)
            
            self.wrappedValue = value
        }
        
        decoder.context.objectSetDecodingContext = nil
    }
}

@propertyWrapper
public struct ASN1AnyObjectSetValue: Codable, Hashable {
    public typealias Value = AnyCodable
    
    public var wrappedValue: Value
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.wrappedValue)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.wrappedValue = AnyCodable(try container.decode(ASN1ObjectSetValue.self))
    }
}

class ASN1ObjectSetDecodingContext {
    let objectSetType: ASN1ObjectSetCodable.Type
    var oid: ObjectIdentifier?
    let encodeAsOctetString: Bool
    
    init(objectSetType: ASN1ObjectSetCodable.Type, encodeAsOctetString: Bool) {
        self.objectSetType = objectSetType
        self.encodeAsOctetString = encodeAsOctetString
    }
    
    func type(_ decoder: ASN1DecoderImpl) -> Codable.Type? {
        let type: Codable.Type?
        
        guard let oid = self.oid else {
            debugPrint("Object set type must come before value")
            return nil
        }
        
        if let typeDict = decoder.userInfo[CodingUserInfoKey.ASN1ObjectSetTypeDictionary] as? ASN1ObjectSetTypeDictionary,
           let typeDict = typeDict[String(reflecting: objectSetType)],
           let userType = typeDict[oid] {
            type = userType
        } else if let knownType = objectSetType.knownTypes[oid] {
            type = knownType
        } else {
            debugPrint("Unknown object set OID \(oid)")
            type = nil
        }
        return type
    }
}

// this tells the encoder to encoder in an OCTET STRING
public protocol ASN1ObjectSetCodable: Codable {
    static var knownTypes: [ObjectIdentifier: Codable.Type] { get }
}

public protocol ASN1ObjectSetOctetStringCodable: ASN1ObjectSetCodable {
}
