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
    private func mappingASN1Error<T>(_ value: T, _ block: () throws -> ()) throws {
        do {
            try block()
        } catch let error as ASN1Error {
            let context = EncodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "ASN.1 encoding error",
                                                underlyingError: error)
            throw EncodingError.invalidValue(value, context)
        }
    }
        
    func encodeNil() throws {
        preconditionCanEncodeNewValue()
        self.didEncode = true
    }
        
    func encode(_ value: Bool) throws {
        try self.mappingASN1Error(value) {
            let object: ASN1Object = try value.asn1encode(tag: nil)
            self.object = object
        }
    }
    
    func encode(_ value: String) throws {
        try self.mappingASN1Error(value) {
            let object: ASN1Object = try value.asn1encode(tag: nil)
            self.object = object
        }
    }
    
    func encode(_ value: Double) throws {
        fatalError("no support for encoding floating point values")
    }
    
    func encode(_ value: Float) throws {
        fatalError("no support for encoding floating point values")
    }
    
    private func encodeFixedWithInteger<T>(_ value: T) throws where T: FixedWidthInteger {
        try self.mappingASN1Error(value) {
            let object = T.isSigned ?
            try Int(value).asn1encode(tag: nil) : try UInt(value).asn1encode(tag: nil)
            self.object = object
        }
    }

    func encode(_ value: Int) throws {
        try self.encodeFixedWithInteger(value)
    }
    
    func encode(_ value: Int8) throws {
        try self.encodeFixedWithInteger(value)
    }
    
    func encode(_ value: Int16) throws {
        try self.encodeFixedWithInteger(value)
    }
    
    func encode(_ value: Int32) throws {
        try self.encodeFixedWithInteger(value)
    }
    
    func encode(_ value: Int64) throws {
        try self.encodeFixedWithInteger(value)
    }
    
    func encode(_ value: UInt) throws {
        try self.encodeFixedWithInteger(value)
    }
    
    func encode(_ value: UInt8) throws {
        try self.encodeFixedWithInteger(value)
    }
    
    func encode(_ value: UInt16) throws {
        try self.encodeFixedWithInteger(value)
    }
    
    func encode(_ value: UInt32) throws {
        try self.encodeFixedWithInteger(value)
    }
    
    func encode(_ value: UInt64) throws {
        try self.encodeFixedWithInteger(value)
    }
    
    func encode<T: Encodable>(_ value: T) throws {
        self.context = self.context.encodingSingleValue(value) // FIXME

        return try self.mappingASN1Error(value) {
            self.object = try encode(value)
        }
    }
    
    private func encode<T: Encodable>(_ value: T, skipTaggedValues: Bool = false) throws -> ASN1Object? {
        let object: ASN1Object?
        
        if !skipTaggedValues, let value = value as? ASN1TaggedType {
            object = try self.encodeTaggedValue(value)
        } else if let value = value as? any (Encodable & ASN1TaggedWrappedValue) {
            object = try self.encodeTaggedWrappedValue(value)
        } else if let value = value as? ASN1EncodableType {
            object = try self.encodePrimitiveValue(value)
        } else {
            object = try self.encodeConstructedValue(value)
        }
        
        return object
    }
    
    private func encodeTagged<T: Encodable>(_ value: T, tag: ASN1DecodedTag?, tagging: ASN1Tagging, skipTaggedValues: Bool = false) throws -> ASN1Object? {
        let object = try self.encode(value, skipTaggedValues: skipTaggedValues)
        let tagging = tagging == .default ? self.context.taggingEnvironment : tagging

        if let object = object, let tag = tag {
            if tag.isUniversal {
                precondition(value is ASN1EncodableType)
                return try (value as! ASN1EncodableType).asn1encode(tag: tag)
            } else if tagging == .implicit, ASN1DecodingContext.isEnum(type(of: value)) {
                // FIXME something is very wrong here
                precondition(object.data.items?.count == 1)
                return object.data.items!.first!.wrap(with: tag, constructed: false)
            } else {
                return object.wrap(with: tag, constructed: tagging != .implicit)
            }
        }
        
        return object
    }
    
    private func encodeTaggedValue<T: Encodable & ASN1TaggedType>(_ value: T) throws -> ASN1Object? {
        return try self.encodeTagged(value, tag: T.tag, tagging: T.tagging, skipTaggedValues: true)
    }
    
    private func encodeTaggedWrappedValue<T: Encodable & ASN1TaggedWrappedValue>(_ value: T) throws -> ASN1Object? {
        return try self.encodeTagged(value.wrappedValue, tag: T.tag, tagging: T.tagging)
    }
    
    private func encodePrimitiveValue<T: ASN1EncodableType>(_ value: T) throws -> ASN1Object? {
        return try value.asn1encode(tag: nil)
    }
    
    private func encodeConstructedValue<T: Encodable>(_ value: T) throws -> ASN1Object? {
        // FIXME sort struct set fields by encoding
        self.context.encodeAsSet = value is Set<AnyHashable> || value is ASN1EncodeAsSetType
        
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
    
        return encoder.object
    }
}
