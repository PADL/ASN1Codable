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
            objectSetDecodingContext.oid = wrappedValue
        }
    }
}

@propertyWrapper
public struct ASN1ObjectSetValue: Codable {
    public typealias Value = Any
    
    public var wrappedValue: Value

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        if let wrappedValue = self.wrappedValue as? Encodable {
            try container.encode(wrappedValue)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let decoder = decoder as? ASN1DecoderImpl,
           let objectSetDecodingContext = decoder.context.objectSetDecodingContext {
            let berData = try container.decode(Data.self)
            let innerDecoder = ASN1Decoder()
            let value: any Codable
            
            defer { decoder.context.objectSetDecodingContext = nil }
            
            if let type = objectSetDecodingContext.type(decoder) {
                value = try innerDecoder.decode(type, from: berData)
            } else {
                value = berData
            }
                        
            self.wrappedValue = value
        } else {
            self.wrappedValue = try container.decode(Data.self)
        }
    }
}

class ASN1ObjectSetDecodingContext {
    let objectSetType: ASN1ObjectSetRepresentable.Type
    var oid: ObjectIdentifier?
    
    init(objectSetType: ASN1ObjectSetRepresentable.Type) {
        self.objectSetType = objectSetType
    }
    
    func type(_ decoder: ASN1DecoderImpl) -> Codable.Type? {
        let type: Codable.Type?
        
        guard let oid = self.oid else {
            return nil
        }
        
        if let typeDict = decoder.userInfo[CodingUserInfoKey.ASN1ObjectSetTypeDictionary] as? ASN1ObjectSetTypeDictionary,
           let typeDict = typeDict[String(reflecting: objectSetType)],
           let userType = typeDict[oid] {
            type = userType
        } else if let knownType = objectSetType.knownTypes[oid] {
            type = knownType
        } else {
            type = nil
        }
        return type
    }
}

// this tells the encoder to encoder in an OCTET STRING
public protocol ASN1ObjectSetRepresentable: Codable {
    static var knownTypes: [ObjectIdentifier: Codable.Type] { get }
}

public protocol ASN1ObjectSetCodable: Codable {
}

