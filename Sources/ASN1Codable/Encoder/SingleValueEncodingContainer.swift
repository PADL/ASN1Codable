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

extension ASN1EncoderImpl {
    final class SingleValueContainer: ASN1EncodingContainer {
        private var _object: ASN1Object?

        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]
        
        var context: ASN1EncodingContext
        var didEncode: Bool = false

        private(set) var object: ASN1Object? {
            get {
                return self._object
            }
            
            set {
                preconditionCanEncodeNewValue()
                self._object = newValue
                self.didEncode = true
            }
        }
        
        init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any],
             context: ASN1EncodingContext = ASN1EncodingContext()) {
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.context = context
        }

        func preconditionCanEncodeNewValue() {
            precondition(!self.didEncode)
        }
    }
}

extension ASN1EncoderImpl.SingleValueContainer: SingleValueEncodingContainer {
    func encodeNil() throws {
        preconditionCanEncodeNewValue()
        self.didEncode = true
    }
    
    func encode(_ value: Bool) throws {
        try self.withASN1Throwing(value) {
            self.object = try value.asn1encode(tag: nil)
        }
    }
    
    func encode(_ value: String) throws {
        try self.withASN1Throwing(value) {
            self.object = try value.asn1encode(tag: nil)
        }
    }
    
    func encode(_ value: Double) throws {
        fatalError("no support for encoding floating point values")
    }
    
    func encode(_ value: Float) throws {
        fatalError("no support for encoding floating point values")
    }
    
    func encode(_ value: Int) throws {
        try self.withASN1Throwing(value) {
            self.object = try self.encodeFixedWithIntegerValue(value)
        }
    }
    
    func encode(_ value: Int8) throws {
        try self.withASN1Throwing(value) {
            self.object = try self.encodeFixedWithIntegerValue(value)
        }
    }
    
    func encode(_ value: Int16) throws {
        try self.withASN1Throwing(value) {
            self.object = try self.encodeFixedWithIntegerValue(value)
        }
    }
    
    func encode(_ value: Int32) throws {
        try self.withASN1Throwing(value) {
            self.object = try self.encodeFixedWithIntegerValue(value)
        }
    }
    
    func encode(_ value: Int64) throws {
        try self.withASN1Throwing(value) {
            self.object = try self.encodeFixedWithIntegerValue(value)
        }
    }
    
    func encode(_ value: UInt) throws {
        try self.withASN1Throwing(value) {
            self.object = try self.encodeFixedWithIntegerValue(value)
        }
    }
    
    func encode(_ value: UInt8) throws {
        try self.withASN1Throwing(value) {
            self.object = try self.encodeFixedWithIntegerValue(value)
        }
    }
    
    func encode(_ value: UInt16) throws {
        try self.withASN1Throwing(value) {
            self.object = try self.encodeFixedWithIntegerValue(value)
        }
    }
    
    func encode(_ value: UInt32) throws {
        try self.withASN1Throwing(value) {
            self.object = try self.encodeFixedWithIntegerValue(value)
        }
    }
    
    func encode(_ value: UInt64) throws {
        try self.withASN1Throwing(value) {
            self.object = try self.encodeFixedWithIntegerValue(value)
        }
    }
    
    func encode<T: Encodable>(_ value: T) throws {
        self.context = self.context.encodingSingleValue(value) // FIXME
        
        try self.withASN1Throwing(value) {
            self.object = try encode(value)
        }
    }
}

extension ASN1EncoderImpl.SingleValueContainer {
    private func withASN1Throwing<T>(_ value: T, _ block: () throws -> ()) throws {
        do {
            try block()
        } catch let error as ASN1Error {
            let context = EncodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "ASN.1 encoding error",
                                                underlyingError: error)
            throw EncodingError.invalidValue(value, context)
        }
    }
    
    private func encode<T: Encodable>(_ value: T, skipTaggedValues: Bool = false) throws -> ASN1Object? {
        let object: ASN1Object?
        
        if !skipTaggedValues, let value = value as? ASN1TaggedType {
            object = try self.encodeTaggedValue(value)
        } else if let value = value as? any (Encodable & ASN1TaggedWrappedValue) {
            object = try self.encodeTaggedWrappedValue(value)
        } else if !skipTaggedValues, self.context.automaticTaggingContext != nil {
            object = try self.encodeAutomaticallyTaggedValue(value)
        } else if let value = value as? ASN1EncodableType {
            object = try self.encodePrimitiveValue(value)
        } else {
            object = try self.encodeConstructedValue(value)
        }
        
        return object
    }
    
    private func encodeTagged<T: Encodable>(_ value: T, tag: ASN1DecodedTag?, tagging: ASN1Tagging?, skipTaggedValues: Bool = false) throws -> ASN1Object? {
        let object = try self.encode(value, skipTaggedValues: skipTaggedValues)
        let tagging = tagging ?? self.context.taggingEnvironment
        
        if let object = object, let tag = tag {
            let wrappedObject: ASN1Object
            
            if tag.isUniversal {
                precondition(value is ASN1EncodableType)
                wrappedObject = try (value as! ASN1EncodableType).asn1encode(tag: tag)
            } else if tagging == .implicit, ASN1DecodingContext.isEnum(type(of: value)) {
                wrappedObject = ASN1ImplicitlyWrappedObject(object: object, tag: tag)
            } else {
                wrappedObject = object.wrap(with: tag, constructed: tagging != .implicit)
            }
            
            return wrappedObject
        } else {
            return object
        }
    }
    
    private func encodeTaggedValue<T: Encodable & ASN1TaggedType>(_ value: T) throws -> ASN1Object? {
        return try self.encodeTagged(value, tag: T.tag, tagging: T.tagging, skipTaggedValues: true)
    }
    
    private func encodeTaggedWrappedValue<T: Encodable & ASN1TaggedWrappedValue>(_ value: T) throws -> ASN1Object? {
        return try self.encodeTagged(value.wrappedValue, tag: T.tag, tagging: T.tagging)
    }
    
    private func encodeAutomaticallyTaggedValue<T: Encodable>(_ value: T) throws -> ASN1Object? {
        let taggingContext = self.context.automaticTaggingContext!
        return try self.encodeTagged(value, tag: taggingContext.nextTag(), tagging: taggingContext.tagging, skipTaggedValues: true)
    }
    
    private func encodeFixedWithIntegerValue<T>(_ value: T) throws -> ASN1Object? where T: FixedWidthInteger {
        let tag: ASN1DecodedTag = self.context.enumCodingState == .enum ? .universal(.enumerated) : .universal(.integer)
        return T.isSigned ? try Int(value).asn1encode(tag: tag) : try UInt(value).asn1encode(tag: tag)
    }

    private func encodePrimitiveValue<T: ASN1EncodableType>(_ value: T) throws -> ASN1Object? {
        if let value = value as? any FixedWidthInteger {
            return try self.encodeFixedWithIntegerValue(value)
        }
        return try value.asn1encode(tag: nil)
    }
    
    private func encodeConstructedValue<T: Encodable>(_ value: T) throws -> ASN1Object? {
        self.context.encodeAsSet = value is Set<AnyHashable> || value is ASN1SetCodable
        
        if self.context.taggingEnvironment == .automatic {
            self.context.automaticTaggingContext = ASN1AutomaticTaggingContext(type(of: value))
        } else {
            self.context.automaticTaggingContext = nil
        }
        
        if let value = value as? ASN1ObjectSetCodable {
            let type = type(of: value)
            self.context.objectSetCodingContext = ASN1ObjectSetCodingContext(objectSetType: type,
                                                                             encodeAsOctetString: type is ASN1ObjectSetOctetStringCodable.Type)
        }

        let encoder = ASN1EncoderImpl(codingPath: self.codingPath,
                                      userInfo: self.userInfo,
                                      context: self.context)
        try value.encode(to: encoder)
        
        if let object = encoder.object, var value = value as? ASN1PreserveBinary {
            // Note this requires the value to be a class
            value._save = try object.serialize()
        }
        
        if self.context.encodeAsSet {
            return encoder.object?.sortedByTag
        } else {
            return encoder.object
        }
    }
}
