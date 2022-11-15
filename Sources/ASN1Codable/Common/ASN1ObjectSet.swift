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

public typealias ASN1ObjectSetTypeDictionary = [String: [AnyHashable: Codable.Type]]

/// Represents a key, typically an `Int` or `ObjectIdentifier`, that is used as a
/// discriminant in encoding an object set.
@propertyWrapper
public struct ASN1ObjectSetType<ValueType>: Codable where ValueType : Codable & Hashable {
    public var wrappedValue: ValueType

    public init(wrappedValue: ValueType) {
        self.wrappedValue = wrappedValue
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.wrappedValue)
    
        if let encoder = encoder as? ASN1EncoderImpl,
           let objectSetCodingContext = encoder.context.objectSetCodingContext {
            precondition(objectSetCodingContext.valueType == nil)
            objectSetCodingContext.valueType = self.wrappedValue
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.wrappedValue = try container.decode(ValueType.self)
        
        if let decoder = decoder as? ASN1DecoderImpl,
           let objectSetCodingContext = decoder.context.objectSetCodingContext {
            precondition(objectSetCodingContext.valueType == nil)
            objectSetCodingContext.valueType = wrappedValue
        }
    }
}

/// Represents an open typed value.
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
        
        guard let encoder = encoder as? ASN1EncoderImpl,
              let objectSetCodingContext = encoder.context.objectSetCodingContext else {
            try container.encode(AnyCodable(self.wrappedValue))
            return
        }

        // FIXME set tagging environment to EXPLICIT then restore
        do {
            if objectSetCodingContext.encodeAsOctetString {
                let innerEncoder = ASN1Encoder()
                
                let berData: Data
                if let wrappedValue = self.wrappedValue {
                    berData = try innerEncoder.encode(wrappedValue)
                } else {
                    berData = Data() // FIXME honour NULL encoding preference
                }

                try container.encode(berData)
            } else {
                if let wrappedValue = self.wrappedValue {
                    try container.encode(wrappedValue)
                } else {
                    try container.encodeNil()
                }
            }
        } catch {
            debugPrint("Failed to encode object set value \(String(describing: self.wrappedValue)): \(error)")
            throw error
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        guard let decoder = decoder as? ASN1DecoderImpl else {
            self.wrappedValue = try container.decode(AnyCodable.self)
            return
        }
        
        // FIXME set tagging environment to EXPLICIT then restore
        guard let objectSetCodingContext = decoder.context.objectSetCodingContext,
              let type = objectSetCodingContext.type(decoder) else {
            self.wrappedValue = nil
            return
        }

        do {
            if objectSetCodingContext.encodeAsOctetString {
                let berData = try container.decode(Data.self)
                let innerDecoder = ASN1Decoder()
                
                self.wrappedValue = try innerDecoder.decode(type, from: berData)
            } else {
                let value = try container.decode(type)
                
                self.wrappedValue = value
            }
        } catch {
            debugPrint("Failed to decode object set type \(type): \(error)")
            throw error
        }
    }
}

/// Represents a type-erased object set value.
@propertyWrapper
public struct ASN1AnyObjectSetValue: Codable, Hashable {
    public typealias Value = AnyCodable
    
    public var wrappedValue: Value
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    public func encode(to encoder: Encoder) throws {
        try self.wrappedValue.encode(to: encoder)
    }
    
    public init(from decoder: Decoder) throws {
        self.wrappedValue = AnyCodable(try ASN1ObjectSetValue(from: decoder))
    }
}

final class ASN1ObjectSetCodingContext {
    let objectSetType: ASN1ObjectSetCodable.Type
    let encodeAsOctetString: Bool
    var valueType: (any Codable & Hashable)?
    
    init(objectSetType: ASN1ObjectSetCodable.Type, encodeAsOctetString: Bool) {
        self.objectSetType = objectSetType
        self.encodeAsOctetString = encodeAsOctetString
    }
    
    func type(_ decoder: ASN1DecoderImpl) -> Codable.Type? {
        let type: Codable.Type?
        
        guard let valueType = self.valueType else {
            debugPrint("Object set type must come before value")
            return nil
        }
        
        let anyValueType = AnyHashable(valueType)
        
        if let typeDict = decoder.context.objectSetTypeDictionary,
           let typeDict = typeDict[String(reflecting: objectSetType)],
           let userType = typeDict[anyValueType] {
            type = userType
        } else if let knownType = objectSetType.knownTypes[anyValueType] {
            type = knownType
        } else {
            debugPrint("Unknown object set type \(valueType)")
            type = nil
        }
        return type
    }
}

public protocol ASN1ObjectSetCodable: Codable {
    static var knownTypes: [AnyHashable: Codable.Type] { get }
}

public protocol ASN1ObjectSetOctetStringCodable: ASN1ObjectSetCodable {
}
