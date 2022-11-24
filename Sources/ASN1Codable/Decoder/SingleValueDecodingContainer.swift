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

extension ASN1DecoderImpl {
    final class SingleValueContainer: ASN1DecodingContainer {
        private(set) var object: ASN1Object

        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]
        var context: ASN1DecodingContext

        init(object: ASN1Object, codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any],
             context: ASN1DecodingContext = ASN1DecodingContext()) {
            self.object = object
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.context = context
        }
    }
}

extension ASN1DecoderImpl.SingleValueContainer: SingleValueDecodingContainer {
    func decodeNil() -> Bool {
        return object.isNull
    }

    func decode(_ type: Bool.Type) throws -> Bool {
        try self.withASN1Throwing {
            try self.decodePrimitiveValue(type, from: self.object)
        }
    }

    func decode(_ type: String.Type) throws -> String {
        try self.withASN1Throwing {
            try self.decodePrimitiveValue(type, from: self.object)
        }
    }

    func decode(_ type: Double.Type) throws -> Double {
        throw ASN1Error.unsupported("Not implemented yet")
    }

    func decode(_ type: Float.Type) throws -> Float {
        throw ASN1Error.unsupported("Not implemented yet")
    }

    func decode(_ type: Int.Type) throws -> Int {
        try self.decodeFixedWidthIntegerValue(type)
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        try self.decodeFixedWidthIntegerValue(type)
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        try self.decodeFixedWidthIntegerValue(type)
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        try self.decodeFixedWidthIntegerValue(type)
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        try self.decodeFixedWidthIntegerValue(type)
    }

    func decode(_ type: UInt.Type) throws -> UInt {
        try self.decodeFixedWidthIntegerValue(type)
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        try self.decodeFixedWidthIntegerValue(type)
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        try self.decodeFixedWidthIntegerValue(type)
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        try self.decodeFixedWidthIntegerValue(type)
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        try self.decodeFixedWidthIntegerValue(type)
    }

    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        try self.withASN1Throwing {
            try self.decode(type, from: self.object)
        }
    }
}

extension ASN1DecoderImpl.SingleValueContainer {
    private func withASN1Throwing<T: Decodable>(_ block: () throws -> T) throws -> T {
        do {
            return try block()
        } catch let error as ASN1Error {
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "ASN.1 decoding error",
                                                underlyingError: error)
            throw DecodingError.dataCorrupted(context)
        }
    }

    private var tagCodingKey: ASN1TagCodingKey? {
        return self.codingPath.last as? ASN1TagCodingKey
    }

    /// avoids re-encoding tag on constructed values, by removing ASN1TagCodingKey
    /// conformance on already processed tag coding key
    /// FIXME: could this be done more elegantly?
    private func demoteTagCodingKey() {
        precondition(!self.codingPath.isEmpty)
        let index = self.codingPath.count - 1
        self.codingPath[index] = ASN1PlaceholderCodingKey(self.tagCodingKey!)
    }

    private func decode<T>(_ type: T.Type, from object: ASN1Object, skipTaggedValues: Bool = false) throws -> T where T: Decodable {
        let value: T

        // FIXME required for top-level decoders
        self.context = self.context.decodingSingleValue(type)

        if let key = self.tagCodingKey {
            self.demoteTagCodingKey()
            value = try self.decodeTaggedKeyedValue(type, from: object, forKey: key)
        } else if !skipTaggedValues, let type = type as? ASN1TaggedType.Type {
            value = try self.decodeTaggedValue(type, from: object) as! T
        } else if let type = type as? any (Decodable & ASN1TaggedWrappedValue).Type {
            value = try self.decodeTaggedWrappedValue(type, from: object) as! T
        } else if !skipTaggedValues, self.context.automaticTaggingContext != nil {
            value = try self.decodeAutomaticallyTaggedValue(type, from: object)
        } else if let type = type as? ASN1DecodableType.Type {
            value = try decodePrimitiveValue(type, from: object, verifiedTag: skipTaggedValues) as! T
        } else if let type = type as? OptionalProtocol.Type,
                  let wrappedType = type.wrappedType as? Decodable.Type {
            value = try decodeIfPresent(wrappedType, from: object, skipTaggedValues: skipTaggedValues) as! T
        } else {
            value = try self.decodeConstructedValue(type, from: object)
        }

        return value
    }

    /// this function is required because the Swift runtime decodeIfPresent()
    /// does not know how to handle optionals inside our tagged propertry wrappers
    /// this code mirrors decodeKeyedSingleValueIfPresent() in KeyedDecodingContainer.swift
    private func decodeIfPresent<T>(_ type: T.Type, from object: ASN1Object, skipTaggedValues: Bool = false) throws -> T? where T: Decodable {
        let value: T?

        if object.isNull {
            value = nil
        } else {
            do {
                value = try self.decode(T.self, from: object, skipTaggedValues: skipTaggedValues)
            } catch {
                if let error = error as? DecodingError, case .typeMismatch = error {
                    value = nil
                } else {
                    throw error
                }
            }
        }

        return value
    }

    private func decodeFixedWidthIntegerValue<T>(_ type: T.Type, verifiedTag: Bool = false) throws -> T where T: FixedWidthInteger {
        // NB withASN1Throwing is not needed here because decodeFixedWidthIntegerValue()
        // does not call into any exception-throwing ASNKit APIs

        let expectedTag: ASN1DecodedTag = self.context.enumCodingState == .enum ? .universal(.enumerated) : .universal(.integer)

        guard verifiedTag || (object.tag.isUniversal && object.tag == expectedTag) else {
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Expected \(expectedTag) when decoding \(self.object)")
            throw DecodingError.typeMismatch(type, context)
        }

        guard let data = object.data.primitive, !data.isEmpty else {
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Missing data for object \(self.object)")
            throw DecodingError.dataCorrupted(context)
        }

        guard type.bitWidth >= data.count * 8 else {
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Integer encoded in \(self.object) too large for \(type.bitWidth)-bit integer")
            throw DecodingError.dataCorrupted(context)
        }

        // FIXME can FixedWidthInteger be larger than platform integer?
        if T.isSigned {
            guard let value = data.asn1integer else {
                let context = DecodingError.Context(codingPath: self.codingPath,
                                                    debugDescription: "Integer encoded in \(self.object) too large for platform signed integer")
                throw DecodingError.dataCorrupted(context)
            }
            return T(value)
        } else {
            guard let value = data.unsignedIntValue else {
                let context = DecodingError.Context(codingPath: self.codingPath,
                                                    debugDescription: "Integer encoded in \(self.object) too large for platform unsigned integer")
                throw DecodingError.dataCorrupted(context)
            }
            return T(value)
        }
    }

    private func decodeTaggedKeyedValue<T>(_ type: T.Type, from object: ASN1Object, forKey key: ASN1TagCodingKey) throws -> T where T: Decodable {
        return try self.decodeTagged(type, from: object, with: key.metadata, skipTaggedValues: false)
    }

    private func decodeTaggedValue<T>(_ type: T.Type, from object: ASN1Object) throws -> T where T: Decodable & ASN1TaggedType {
        return try self.decodeTagged(type, from: object, with: T.metadata, skipTaggedValues: true)
    }

    private func decodeTaggedWrappedValue<T>(_ type: T.Type, from object: ASN1Object) throws -> T where T: Decodable & ASN1TaggedWrappedValue {
        let wrappedValue = try self.decodeTagged(type.Value, from: object, with: T.metadata)

        return T(wrappedValue: wrappedValue)
    }

    private func decodeAutomaticallyTaggedValue<T>(_ type: T.Type, from object: ASN1Object) throws -> T where T: Decodable {
        let taggingContext = self.context.automaticTaggingContext!

        return try self.decodeTagged(type, from: object, with: taggingContext.metadataForNextTag(), skipTaggedValues: true)
    }

    private func decodePrimitiveValue<T>(_ type: T.Type, from object: ASN1Object, verifiedTag: Bool = false) throws -> T where T: ASN1DecodableType {
        let expectedTag = ASN1DecodingContext.tag(for: type)
        var verifiedTag = verifiedTag

        /// if an untagged String is being decoded, then accept any ASN.1 string type. This
        /// allows DirectoryString to be a typealias of String rather than a cumbersome enum
        /// which requires the caller to explicitly unwrap values (at the expense of somes
        /// additional state to note the current tag).
        if !verifiedTag, type is String.Type, object.tag.isString,
           !(self.context.currentTag?.isString ?? false) { // tag is empty or not a string
            precondition(expectedTag.isString)
            verifiedTag = true
        }

        guard verifiedTag || (object.tag.isUniversal && object.tag == expectedTag) else {
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Expected \(expectedTag) when decoding \(self.object)")
            throw DecodingError.typeMismatch(type, context)
        }

        if let type = type as? any FixedWidthInteger.Type {
            return try self.decodeFixedWidthIntegerValue(type, verifiedTag: true) as! T
        }

        return try T(from: object)
    }

    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length
    private func decodeTagged<T>(_ type: T.Type,
                                 from object: ASN1Object,
                                 with metadata: ASN1Metadata,
                                 skipTaggedValues: Bool = false) throws -> T where T: Decodable {
        guard let tag = metadata.tag else {
            // FIXME should this happen? precondition check? (perhaps if only size constraints?)
            return try self.decode(type, from: object, skipTaggedValues: skipTaggedValues)
        }

        guard object.tag == tag else {
            if self.isOptionalOrWrappedOptional(type) {
                return self.possiblyWrappedNilLiteral(type)
            } else {
                let context = DecodingError.Context(codingPath: self.codingPath,
                                                    debugDescription: "Expected tag \(tag) but received \(object.tag)")
                throw DecodingError.typeMismatch(type, context)
            }
        }

        let unwrappedObject: ASN1Object
        var tagging = metadata.tagging ?? self.context.taggingEnvironment

        if tagging == .implicit && self.context.enumCodingState == .enum {
            /// IMPLICIT tagging of types that are CHOICE types have the tag converted to EXPLICIT
            tagging = .explicit
        }

        let innerTag = tagging == .implicit ? ASN1DecodingContext.tag(for: type) : tag

        if object.constructed {
            if tagging == .implicit {
                // FIXME propagate originalEncoding
                unwrappedObject = ASN1Kit.create(tag: innerTag, data: object.data)
            } else {
                guard let items = object.data.items,
                      items.count == 1,
                      let firstObject = object.data.items!.first else {
                    let context = DecodingError.Context(codingPath: self.codingPath,
                                                        debugDescription: "Tag \(tag) for single value container must wrap a single value only")
                    throw DecodingError.typeMismatch(type, context)
                }
                unwrappedObject = firstObject
            }
        } else if innerTag.isUniversal {
            if tagging == .implicit {
                // FIXME propagate originalEncoding
                unwrappedObject = ASN1Kit.create(tag: innerTag, data: object.data)
            } else {
                unwrappedObject = object
            }
        } else {
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Expected universal tag \(innerTag) for primitive object \(object)")
            throw DecodingError.typeMismatch(type, context)
        }

        if !metadata.validateSizeConstraints(unwrappedObject) {
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Value for \(object) outside of size constraint")
            throw DecodingError.dataCorrupted(context)
        }

        let verifiedUniversalTag = !object.constructed && tag.isUniversal

        self.context.currentTag = tag

        let value = try self.decode(type, from: unwrappedObject, skipTaggedValues: verifiedUniversalTag || skipTaggedValues)

        if !metadata.validateValueConstraints(value) {
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Value for \(object) outside of value constraint")
            throw DecodingError.dataCorrupted(context)
        }

        return value
    }

    private func decodeConstructedValue<T>(_ type: T.Type, from object: ASN1Object) throws -> T where T: Decodable {
        self.context.encodeAsSet = type is Set<AnyHashable>.Type || type is ASN1SetCodable.Type

        if self.context.taggingEnvironment == .automatic {
            self.context.automaticTaggingContext = ASN1AutomaticTaggingContext(type)
        } else {
            self.context.automaticTaggingContext = nil
        }

        if let type = type as? ASN1ObjectSetCodable.Type {
            self.context.objectSetCodingContext = ASN1ObjectSetCodingContext(objectSetType: type,
                                                                             encodeAsOctetString: type is ASN1ObjectSetOctetStringCodable.Type)
        }

        let sortedObject = self.context.encodeAsSet ? object.sortedByTag : object

        let decoder = ASN1DecoderImpl(object: sortedObject,
                                      codingPath: self.codingPath,
                                      userInfo: self.userInfo,
                                      context: self.context)
        let value = try T(from: decoder)

        try self.validateExtensibility(type, from: sortedObject, with: decoder)

        if var value = value as? ASN1PreserveBinary {
            value._save = sortedObject.originalEncoding
        }

        return value
    }

    private var explicitExtensibilityMarkerRequired: Bool {
        return (self.userInfo[CodingUserInfoKey.ASN1ExplicitExtensibilityMarkerRequired] as? Bool) ?? false
    }

    private func validateExtensibility<T>(_ type: T.Type, from object: ASN1Object, with decoder: ASN1DecoderImpl) throws where T: Decodable {
        if self.explicitExtensibilityMarkerRequired,
           type is (any ASN1ExtensibleType).Type == false,
           let container = decoder.container,
           container.object.constructed,
           let items = container.object.data.items,
           container.currentIndex < items.count {
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Expected no more than \(container.currentIndex) items when decoding \(type); received \(items.count)")
            throw DecodingError.typeMismatch(type, context)
        }
    }

    private func nilLiteral<T: OptionalProtocol>(_ type: T.Type) -> T {
        return Decodable?.init(nilLiteral: ()) as! T
    }

    private func isWrappedOptional<T: ASN1TaggedWrappedValue>(_ type: T.Type) -> Bool {
        var wrappedType: Codable.Type = type

        while wrappedType is any ASN1TaggedWrappedValue.Type {
            wrappedType = (wrappedType as! any ASN1TaggedWrappedValue.Type).wrappedType
        }

        return wrappedType is OptionalProtocol.Type
    }

    private func isOptionalOrWrappedOptional<T: Decodable>(_ type: T.Type) -> Bool {
        if type is any OptionalProtocol.Type {
            return true
        } else if let type = type as? any ASN1TaggedWrappedValue.Type {
            return self.isWrappedOptional(type)
        } else {
            return false
        }
    }

    private func wrappedNilLiteral<T: ASN1TaggedWrappedValue>(_ type: T.Type) -> T {
        if let wrappedType = type.Value as? any ASN1TaggedWrappedValue.Type {
            return T(wrappedValue: self.wrappedNilLiteral(wrappedType) as! T.Value)
        } else if let wrappedType = type.Value as? any OptionalProtocol.Type {
            return T(wrappedValue: self.nilLiteral(wrappedType) as! T.Value)
        } else {
            fatalError("Non-optional final type passed to wrappedNilLiteral")
        }
    }

    private func possiblyWrappedNilLiteral<T: Decodable>(_ type: T.Type) -> T {
        if let type = type as? any ASN1TaggedWrappedValue.Type {
            return self.wrappedNilLiteral(type) as! T
        } else if let type = type as? any OptionalProtocol.Type {
            return self.nilLiteral(type) as! T
        } else {
            fatalError("possiblyWrappedNilLiteral() called with non-optional type hierarchy")
        }
    }
}

// meaningless but allows us to conform to the rest of the protocol
extension ASN1DecoderImpl.SingleValueContainer {
    var currentIndex: Int {
        return 0
    }
}
