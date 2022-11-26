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
        var didEncode = false

        private(set) var object: ASN1Object? {
            get {
                self._object
            }

            set {
                self.preconditionCanEncodeNewValue()
                self._object = newValue
                self.didEncode = true
            }
        }

        init(
            codingPath: [CodingKey],
            userInfo: [CodingUserInfoKey: Any],
            context: ASN1EncodingContext = ASN1EncodingContext()
        ) {
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
            try value.asn1encode(tag: nil)
        }
    }

    func encode(_ value: String) throws {
        try self.withASN1Throwing(value) {
            try value.asn1encode(tag: nil)
        }
    }

    func encode(_: Double) throws {
        fatalError("no support for encoding floating point values")
    }

    func encode(_: Float) throws {
        fatalError("no support for encoding floating point values")
    }

    func encode(_ value: Int) throws {
        try self.withASN1Throwing(value) {
            try self.encodeFixedWithIntegerValue(value)
        }
    }

    func encode(_ value: Int8) throws {
        try self.withASN1Throwing(value) {
            try self.encodeFixedWithIntegerValue(value)
        }
    }

    func encode(_ value: Int16) throws {
        try self.withASN1Throwing(value) {
            try self.encodeFixedWithIntegerValue(value)
        }
    }

    func encode(_ value: Int32) throws {
        try self.withASN1Throwing(value) {
            try self.encodeFixedWithIntegerValue(value)
        }
    }

    func encode(_ value: Int64) throws {
        try self.withASN1Throwing(value) {
            try self.encodeFixedWithIntegerValue(value)
        }
    }

    func encode(_ value: UInt) throws {
        try self.withASN1Throwing(value) {
            try self.encodeFixedWithIntegerValue(value)
        }
    }

    func encode(_ value: UInt8) throws {
        try self.withASN1Throwing(value) {
            try self.encodeFixedWithIntegerValue(value)
        }
    }

    func encode(_ value: UInt16) throws {
        try self.withASN1Throwing(value) {
            try self.encodeFixedWithIntegerValue(value)
        }
    }

    func encode(_ value: UInt32) throws {
        try self.withASN1Throwing(value) {
            try self.encodeFixedWithIntegerValue(value)
        }
    }

    func encode(_ value: UInt64) throws {
        try self.withASN1Throwing(value) {
            try self.encodeFixedWithIntegerValue(value)
        }
    }

    func encode<T: Encodable>(_ value: T) throws {
        // FIXME: this appeares necessary to handle top-level enums
        self.context = self.context.encodingSingleValue(value)

        try self.withASN1Throwing(value) {
            try encode(value)
        }
    }
}

extension ASN1EncoderImpl.SingleValueContainer {
    private var tagCodingKey: ASN1TagCodingKey? {
        self.codingPath.last as? ASN1TagCodingKey
    }

    // avoids re-encoding tag on constructed values, by removing ASN1TagCodingKey
    // conformance on already processed tag coding key
    private func demoteTagCodingKey() {
        precondition(!self.codingPath.isEmpty)
        let index = self.codingPath.count - 1
        self.codingPath[index] = ASN1PlaceholderCodingKey(self.tagCodingKey!)
    }

    private func withASN1Throwing<T: Encodable>(_ value: T, _ block: () throws -> ASN1Object?) throws {
        do {
            // FIXME: this is asymettric with decoding
            if self.tagCodingKey != nil || self.context.automaticTaggingContext != nil {
                self.object = try self.encode(value, skipTaggedValues: false)
            } else {
                self.object = try block()
            }
        } catch let error as ASN1Error {
            let context = EncodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "ASN.1 encoding error",
                                                underlyingError: error)
            throw EncodingError.invalidValue(value, context)
        }
    }

    private func encode<T: Encodable>(_ value: T, skipTaggedValues: Bool = false) throws -> ASN1Object? {
        let object: ASN1Object?

        if let key = self.tagCodingKey {
            self.demoteTagCodingKey()
            object = try self.encodeTaggedKeyedValue(value, forKey: key)
        } else if !skipTaggedValues, let value = value as? ASN1TaggedType {
            object = try self.encodeTaggedValue(value)
        } else if let value = value as? any(Encodable & ASN1TaggedValue) {
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

    private func encodeTagged<T: Encodable>(
        _ value: T,
        with metadata: ASN1Metadata,
        skipTaggedValues: Bool = false
    ) throws -> ASN1Object? {
        if !metadata.validateValueConstraints(value) {
            let context = EncodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Value \(value) outside of value constraint")
            throw EncodingError.invalidValue(value, context)
        }

        let wrappedObject: ASN1Object?

        if let tag = metadata.tag, tag.isUniversal, let value = value as? ASN1EncodableType {
            wrappedObject = try value.asn1encode(tag: tag)
        } else {
            var tagging = metadata.tagging ?? self.context.taggingEnvironment
            if tagging == .implicit, self.context.enumCodingState == .enum {
                /// IMPLICIT tagging of types that are CHOICE types have the tag converted to EXPLICIT
                tagging = .explicit
            }

            let object = try self.encode(value, skipTaggedValues: skipTaggedValues)

            if let object, let tag = metadata.tag {
                if tagging == .implicit, self.context.enumCodingState == .enum {
                    wrappedObject = ASN1ImplicitlyWrappedObject(object: object, tag: tag)
                } else {
                    wrappedObject = object.wrap(with: tag, constructed: tagging != .implicit)
                }
            } else {
                wrappedObject = object
            }
        }

        if let wrappedObject, !metadata.validateSizeConstraints(wrappedObject) {
            let context = EncodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Value for \(wrappedObject) outside " +
                                                                   "of size constraint")
            throw EncodingError.invalidValue(value, context)
        }

        return wrappedObject
    }

    private func encodeTaggedKeyedValue<T: Encodable>(_ value: T, forKey key: ASN1TagCodingKey) throws -> ASN1Object? {
        try self.encodeTagged(value, with: key.metadata, skipTaggedValues: false)
    }

    private func encodeTaggedValue<T: Encodable & ASN1TaggedType>(_ value: T) throws -> ASN1Object? {
        try self.encodeTagged(value, with: T.metadata, skipTaggedValues: true)
    }

    private func encodeTaggedWrappedValue<T: Encodable & ASN1TaggedValue>(_ value: T) throws -> ASN1Object? {
        try self.encodeTagged(value.wrappedValue, with: T.metadata)
    }

    private func encodeAutomaticallyTaggedValue<T: Encodable>(_ value: T) throws -> ASN1Object? {
        let taggingContext = self.context.automaticTaggingContext!
        return try self.encodeTagged(value, with: taggingContext.metadataForNextTag(), skipTaggedValues: true)
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
            let encodeAsOctetString = type is ASN1ObjectSetOctetStringCodable.Type
            self.context.objectSetCodingContext = ASN1ObjectSetCodingContext(objectSetType: type,
                                                                             encodeAsOctetString: encodeAsOctetString)
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
