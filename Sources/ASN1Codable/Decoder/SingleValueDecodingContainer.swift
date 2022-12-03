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
        let userInfo: [CodingUserInfoKey: Any]
        var context: ASN1DecodingContext

        init(
            object: ASN1Object,
            codingPath: [CodingKey],
            userInfo: [CodingUserInfoKey: Any],
            context: ASN1DecodingContext = ASN1DecodingContext()
        ) {
            self.object = object
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.context = context
        }
    }
}

extension ASN1DecoderImpl.SingleValueContainer: SingleValueDecodingContainer {
    func decodeNil() -> Bool {
        object.isNull
    }

    func decode(_ type: Bool.Type) throws -> Bool {
        try self.withDecoder(type) {
            try self.decodePrimitiveValue($0, from: $1)
        }
    }

    func decode(_ type: String.Type) throws -> String {
        try self.withDecoder(type) {
            try self.decodePrimitiveValue($0, from: $1)
        }
    }

    func decode(_: Double.Type) throws -> Double {
        let context = DecodingError.Context(codingPath: self.codingPath,
                                            debugDescription: "Decoding of doubles is not yet supported")
        throw DecodingError.typeMismatch(Double.self, context)
    }

    func decode(_: Float.Type) throws -> Float {
        let context = DecodingError.Context(codingPath: self.codingPath,
                                            debugDescription: "Decoding of floats is not yet supported")
        throw DecodingError.typeMismatch(Float.self, context)
    }

    func decode(_ type: Int.Type) throws -> Int {
        try self.withDecoder(type) {
            try self.decodeFixedWidthIntegerValue($0, from: $1)
        }
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        try self.withDecoder(type) {
            try self.decodeFixedWidthIntegerValue($0, from: $1)
        }
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        try self.withDecoder(type) {
            try self.decodeFixedWidthIntegerValue($0, from: $1)
        }
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        try self.withDecoder(type) {
            try self.decodeFixedWidthIntegerValue($0, from: $1)
        }
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        try self.withDecoder(type) {
            try self.decodeFixedWidthIntegerValue($0, from: $1)
        }
    }

    func decode(_ type: UInt.Type) throws -> UInt {
        try self.withDecoder(type) {
            try self.decodeFixedWidthIntegerValue($0, from: $1)
        }
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        try self.withDecoder(type) {
            try self.decodeFixedWidthIntegerValue($0, from: $1)
        }
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        try self.withDecoder(type) {
            try self.decodeFixedWidthIntegerValue($0, from: $1)
        }
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        try self.withDecoder(type) {
            try self.decodeFixedWidthIntegerValue($0, from: $1)
        }
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        try self.withDecoder(type) {
            try self.decodeFixedWidthIntegerValue($0, from: $1)
        }
    }

    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        try self.withDecoder(type) {
            try self.decode($0, from: $1)
        }
    }
}

extension ASN1DecoderImpl.SingleValueContainer {
    func withDecoder<T: Decodable>(
        _ type: T.Type,
        block: (_ type: T.Type, _ object: ASN1Object) throws -> T
    ) throws -> T {
        do {
            if let key = self.codingKey {
                self.demoteCodingKey()
                return try self.decodeTaggedKeyedValue(type, from: self.object, forKey: key)
            } else if self.context.automaticTaggingContext != nil {
                return try self.decodeAutomaticallyTaggedValue(type, from: self.object)
            } else {
                return try self.decode(type, from: self.object, block: block)
            }
        } catch let error as ASN1Error {
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "ASN.1 decoding error",
                                                underlyingError: error)
            throw DecodingError.dataCorrupted(context)
        }
    }

    private var codingKey: ASN1CodingKey? {
        self.codingPath.last as? ASN1CodingKey
    }

    /// avoids re-encoding tag on constructed values, by removing ASN1TagCodingKey
    /// conformance on already processed tag coding key
    /// FIXME: could this be done more elegantly?
    private func demoteCodingKey() {
        precondition(!self.codingPath.isEmpty)
        let index = self.codingPath.count - 1
        self.codingPath[index] = ASN1PlaceholderCodingKey(self.codingKey!)
    }

    // swiftlint:disable force_cast
    private func decode<T>(
        _ type: T.Type,
        from object: ASN1Object,
        skipTaggedValues: Bool = false,
        block: (_ type: T.Type, _ object: ASN1Object) throws -> T
    ) throws -> T where T: Decodable {
        let value: T

        if !skipTaggedValues, let type = type as? ASN1TaggedType.Type {
            value = try self.decodeTaggedValue(type, from: object) as! T
        } else if let type = type as? any(Decodable & ASN1TaggedValue).Type {
            value = try self.decodeTaggedWrappedValue(type, from: object) as! T
        } else {
            value = try block(type, object)
        }

        if var value = value as? ASN1PreserveBinary {
            value._save = object.originalEncoding
        }

        return value
    }

    // swiftlint:disable force_cast
    private func decode<T>(
        _ type: T.Type,
        from object: ASN1Object,
        skipTaggedValues: Bool = false
    ) throws -> T where T: Decodable {
        // FIXME: required for top-level decoders
        self.context = self.context.decodingSingleValue(type)

        return try self.decode(type, from: object, skipTaggedValues: skipTaggedValues) { type, object in
            let value: T
            if let type = type as? any FixedWidthInteger.Type {
                value = try self.decodeFixedWidthIntegerValue(type, from: object, verifiedTag: skipTaggedValues) as! T
            } else if let type = type as? ASN1DecodableType.Type {
                value = try self.decodePrimitiveValue(type, from: object, verifiedTag: skipTaggedValues) as! T
            } else if let type = type as? OptionalProtocol.Type,
                      let wrappedType = type.wrappedType as? Decodable.Type {
                value = try self.decodeIfPresent(wrappedType, from: object, skipTaggedValues: skipTaggedValues) as! T
            } else {
                value = try self.decodeConstructedValue(type, from: object)
            }
            return value
        }
    }

    /// this function is required because the Swift runtime decodeIfPresent()
    /// does not know how to handle optionals inside our tagged propertry wrappers
    /// this code mirrors decodeKeyedSingleValueIfPresent() in KeyedDecodingContainer.swift
    private func decodeIfPresent<T>(
        _: T.Type,
        from object: ASN1Object,
        skipTaggedValues: Bool = false
    ) throws -> T? where T: Decodable {
        let value: T?

        if object.isNull {
            value = nil
        } else {
            do {
                value = try self.decode(T.self, from: object, skipTaggedValues: skipTaggedValues)
            } catch {
                if let error = error as? DecodingError, case .valueNotFound = error {
                    value = nil
                } else {
                    throw error
                }
            }
        }

        return value
    }

    /// decode a fixed width integer value. Ideally, FixedWidthInteger could conform to ASN1DecodableType
    /// and this would be taken care of by decodePrimitiveValue(), but it's not possible to conform protocols
    /// (such as FixedWidthInteger) to other protocols.
    private func decodeFixedWidthIntegerValue<T>(
        _ type: T.Type,
        from object: ASN1Object,
        verifiedTag: Bool = false
    ) throws -> T where T: FixedWidthInteger {
        let expectedTag: ASN1DecodedTag

        expectedTag = self.context.enumCodingState == .enum ? .universal(.enumerated) : .universal(.integer)

        guard verifiedTag || (object.tag.isUniversal && object.tag == expectedTag) else {
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Expected \(expectedTag) when " +
                                                    "decoding \(self.object)")
            throw DecodingError.valueNotFound(type, context)
        }

        return try T(from: object)
    }

    private func decodeTaggedKeyedValue<T>(
        _ type: T.Type,
        from object: ASN1Object,
        forKey key: ASN1CodingKey
    ) throws -> T where T: Decodable {
        try self.decodeTagged(type, from: object, with: key.metadata, skipTaggedValues: false)
    }

    private func decodeTaggedValue<T>(
        _ type: T.Type,
        from object: ASN1Object
    ) throws -> T where T: Decodable & ASN1TaggedType {
        try self.decodeTagged(type, from: object, with: T.metadata, skipTaggedValues: true)
    }

    private func decodeTaggedWrappedValue<T>(
        _ type: T.Type,
        from object: ASN1Object
    ) throws -> T where T: Decodable & ASN1TaggedValue {
        let wrappedValue = try self.decodeTagged(type.Value, from: object, with: T.metadata)

        return T(wrappedValue: wrappedValue)
    }

    private func decodeAutomaticallyTaggedValue<T>(
        _ type: T.Type,
        from object: ASN1Object
    ) throws -> T where T: Decodable {
        let taggingContext = self.context.automaticTaggingContext!

        return try self.decodeTagged(type,
                                     from: object,
                                     with: taggingContext.metadataForNextTag(),
                                     skipTaggedValues: true)
    }

    private func decodePrimitiveValue<T>(
        _ type: T.Type,
        from object: ASN1Object,
        verifiedTag: Bool = false
    ) throws -> T where T: ASN1DecodableType {
        let expectedTag = ASN1DecodingContext.tag(for: type)

        guard verifiedTag || (object.tag.isUniversal && object.tag == expectedTag) else {
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Expected \(expectedTag) when " +
                                                    "decoding \(self.object)")
            throw DecodingError.valueNotFound(type, context)
        }

        return try T(from: object)
    }

    private func validateAndDecodeUnwrappedTagged<T>(
        _ type: T.Type,
        from unwrappedObject: ASN1Object,
        with metadata: ASN1Metadata,
        skipTaggedValues: Bool = false
    ) throws -> T where T: Decodable {
        if !metadata.validateSizeConstraints(unwrappedObject) {
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Value for \(object) outside of size constraint")
            throw DecodingError.dataCorrupted(context)
        }

        let verifiedUniversalTag = !unwrappedObject.constructed && (metadata.tag?.isUniversal ?? false)

        let value = try self.decode(type,
                                    from: unwrappedObject,
                                    skipTaggedValues: verifiedUniversalTag || skipTaggedValues)

        if !metadata.validateValueConstraints(value) {
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Value for \(object) outside of value constraint")
            throw DecodingError.dataCorrupted(context)
        }

        return value
    }

    private func decodeTagged<T>(
        _ type: T.Type,
        from object: ASN1Object,
        with metadata: ASN1Metadata,
        skipTaggedValues: Bool = false
    ) throws -> T where T: Decodable {
        let unwrappedObject: ASN1Object

        if let tag = metadata.tag {
            guard object.tag == tag else {
                if self.isOptionalOrWrappedOptional(type) {
                    return self.possiblyWrappedNilLiteral(type)
                } else {
                    let context = DecodingError.Context(codingPath: self.codingPath,
                                                        debugDescription: "Expected tag \(tag) " +
                                                            "but received \(object.tag)")
                    throw DecodingError.valueNotFound(type, context)
                }
            }

            var tagging = metadata.tagging ?? self.context.taggingEnvironment

            if tagging == .implicit, self.context.enumCodingState == .enum {
                /// IMPLICIT tagging of types that are CHOICE types have the tag converted to EXPLICIT
                tagging = .explicit
            }

            let innerTag = tagging == .implicit ? ASN1DecodingContext.tag(for: type) : tag

            if tagging == .implicit {
                let constructed = object.constructed || innerTag.isUniversal ? false : nil
                unwrappedObject = ASN1ImplicitlyWrappedObject(object: object, tag: innerTag, constructed: constructed)
            } else if object.constructed {
                guard let items = object.data.items,
                      items.count == 1,
                      let firstObject = items.first else {
                    let context = DecodingError.Context(codingPath: self.codingPath,
                                                        debugDescription: "Tag \(tag) for single value container " +
                                                            "must wrap a single value only")
                    throw DecodingError.dataCorrupted(context)
                }
                unwrappedObject = firstObject
            } else if innerTag.isUniversal {
                unwrappedObject = object
            } else {
                let context = DecodingError.Context(codingPath: self.codingPath,
                                                    debugDescription: "Expected universal tag \(innerTag) " +
                                                        "for primitive object \(object)")
                throw DecodingError.valueNotFound(type, context)
            }
        } else {
            unwrappedObject = object // may have size or value constraints, but no tag
        }

        return try self.validateAndDecodeUnwrappedTagged(type,
                                                         from: unwrappedObject,
                                                         with: metadata,
                                                         skipTaggedValues: skipTaggedValues)
    }

    private func decodeConstructedValue<T>(
        _ type: T.Type,
        from object: ASN1Object
    ) throws -> T where T: Decodable {
        self.context.encodeAsSet = type is Set<AnyHashable>.Type || type is ASN1SetCodable.Type
        self.context.automaticTagging(type)

        if type is IntCodingKeyRepresentableDictionary.Type ||
            type is StringCodingKeyRepresentableDictionary.Type ||
            type is AnyCodingKeyRepresentableDictionary.Type {
            self.context.isCodingKeyRepresentableDictionary = true
        } else {
            self.context.isCodingKeyRepresentableDictionary = false
        }

        if let type = type as? ASN1ObjectSetCodable.Type {
            self.context.objectSetCodingContext =
                ASN1ObjectSetCodingContext(objectSetType: type,
                                           encodeAsOctetString: type is ASN1ObjectSetOctetStringCodable.Type)
        }

        let sortedObject = self.context.encodeAsSet && !self.disableSetSorting ? object.sortedByTag : object

        let decoder = ASN1DecoderImpl(object: sortedObject,
                                      codingPath: self.codingPath,
                                      userInfo: self.userInfo,
                                      context: self.context)
        let value = try T(from: decoder)

        try self.validateExtensibility(type, from: sortedObject, with: decoder)

        return value
    }

    private var explicitExtensibilityMarkerRequired: Bool {
        (self.userInfo[CodingUserInfoKey.ASN1ExplicitExtensibilityMarkerRequired] as? Bool) ?? false
    }

    private func validateExtensibility<T>(
        _ type: T.Type,
        from _: ASN1Object,
        with decoder: ASN1DecoderImpl
    ) throws where T: Decodable {
        if self.explicitExtensibilityMarkerRequired,
           type is (any ASN1ExtensibleType).Type == false,
           let container = decoder.container,
           container.object.constructed,
           let items = container.object.data.items,
           container.currentIndex < items.count {
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Expected no more than \(container.currentIndex) " +
                                                    "items when decoding \(type); received \(items.count)")
            throw DecodingError.dataCorrupted(context)
        }
    }

    private func nilLiteral<T: OptionalProtocol>(_: T.Type) -> T {
        Decodable?.init(nilLiteral: ()) as! T
    }

    private func isWrappedOptional<T: ASN1TaggedValue>(_ type: T.Type) -> Bool {
        var wrappedType: Codable.Type = type

        while wrappedType is any ASN1TaggedValue.Type {
            wrappedType = (wrappedType as! any ASN1TaggedValue.Type).wrappedType
        }

        return wrappedType is OptionalProtocol.Type
    }

    private func isOptionalOrWrappedOptional<T: Decodable>(_ type: T.Type) -> Bool {
        if type is any OptionalProtocol.Type {
            return true
        } else if let type = type as? any ASN1TaggedValue.Type {
            return self.isWrappedOptional(type)
        } else {
            return false
        }
    }

    private func wrappedNilLiteral<T: ASN1TaggedValue>(_ type: T.Type) -> T {
        if let wrappedType = type.Value as? any ASN1TaggedValue.Type {
            return T(wrappedValue: self.wrappedNilLiteral(wrappedType) as! T.Value)
        } else if let wrappedType = type.Value as? any OptionalProtocol.Type {
            return T(wrappedValue: self.nilLiteral(wrappedType) as! T.Value)
        } else {
            fatalError("Non-optional final type passed to wrappedNilLiteral")
        }
    }

    private func possiblyWrappedNilLiteral<T: Decodable>(_ type: T.Type) -> T {
        if let type = type as? any ASN1TaggedValue.Type {
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
        get {
            0
        }
        // swiftlint:disable unused_setter_value
        set {}
    }
}
