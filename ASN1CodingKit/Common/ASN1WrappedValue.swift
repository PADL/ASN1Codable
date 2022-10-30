//
//  ASN1WrappedValue.swift
//  ASN1Kit
//
//  Created by Luke Howard on 26/10/2022.
//

import Foundation
import ASN1Kit

public protocol ASN1WrappedValue: Codable, ASN1CodableOptions {
    static var tag: ASN1DecodedTag? { get }
    static var taggingMode: ASN1TaggingMode? { get }

    associatedtype Value: Codable
    
    var wrappedValue: Value { get set }
    var projectedValue: any ASN1WrappedValue { get }

    init(wrappedValue: Value)
}

extension ASN1WrappedValue {
    public static var tag: ASN1DecodedTag? { return nil }
    public static var taggingMode: ASN1TaggingMode? { return nil }

    /*
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ASN1CodingKeys.self)
        //let tag = try container.decodeIfPresent(ASN1DecodedTag.self, forKey: ASN1CodingKeys.tag)
        //let _ = try container.decode(ASN1TaggingMode.self, forKey: ASN1CodingKeys.taggingMode)
        
        let wrappedValue = try container.decode(Value.self, forKey: ASN1CodingKeys.wrappedValue)
        
        self.init(wrappedValue: wrappedValue)

        if tag != Self.tag {
            throw ASN1Error.malformedEncoding("ASN.1 tag \(String(describing: tag)) does not match expected tag \(String(describing: tag))")
        }
    }
    */

    public func encode(to encoder: Encoder) throws {
        if let encoder = encoder as? ASN1EncoderImpl,
           let container = encoder.singleValueContainer() as? ASN1EncoderImpl.SingleValueContainer {
            var concreteValue: any Encodable = self.wrappedValue
            var wrappedValue: (any ASN1WrappedValue)? = self.wrappedValue as? any ASN1WrappedValue & Encodable
                        
            if let tag = Self.tag {
                container.tags.append(tag)
            }
            if let taggingMode = Self.taggingMode {
                container.taggingModes.append(taggingMode)
            }
            
            while let _wrappedValue = wrappedValue {
                let type = type(of: _wrappedValue)
                if let tag = type.tag {
                    container.tags.append(tag)
                }
                if let taggingMode = type.taggingMode {
                    container.taggingModes.append(taggingMode)
                }
                concreteValue = _wrappedValue.wrappedValue
                wrappedValue = _wrappedValue.wrappedValue as? any ASN1WrappedValue
            }
            
            try container.encode(concreteValue)
        } else {
            var container = encoder.container(keyedBy: ASN1CodingKeys.self)
            try container.encode(self.wrappedValue, forKey: ASN1CodingKeys.wrappedValue)
        }
    }
    
    public var projectedValue: any ASN1WrappedValue {
        return self
    }
}

extension KeyedDecodingContainer {
    func decode<T: ExpressibleByNilLiteral, U: ASN1WrappedValue>(_ type: U.Type, forKey key: K) throws -> any ASN1WrappedValue where U.Value == T {
        if let value = try self.decodeIfPresent(type, forKey: key) {
            return value
        }
        
        return U(wrappedValue: nil)
    }
}
