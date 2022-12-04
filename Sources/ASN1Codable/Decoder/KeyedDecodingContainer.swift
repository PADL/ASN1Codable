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
    final class KeyedContainer<Key>: ASN1DecodingContainer where Key: CodingKey {
        let object: ASN1Object
        let codingPath: [CodingKey]
        let userInfo: [CodingUserInfoKey: Any]
        var context: ASN1DecodingContext

        var currentIndex: Int = 0

        init(
            object: ASN1Object,
            codingPath: [CodingKey],
            userInfo: [CodingUserInfoKey: Any],
            context: ASN1DecodingContext
        ) throws {
            self.object = object
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.context = context
        }

        func nestedCodingPath(forKey key: CodingKey) -> [CodingKey] {
            // a special case to allow for the single value decoder to deal with
            // enums with ASN1TagCoding key discriminants
            if self.context.enumCodingState == .enumCase {
                return self.codingPath
            } else {
                return self.codingPath + [key]
            }
        }
    }
}

extension ASN1Object {
    // returns true if we have a SEQUENCE/SET of context tagged items
    var containsOnlyContextTaggedItems: Bool {
        self.data.items?.allSatisfy {
            if case .taggedTag = $0.tag {
                return true
            } else {
                return false
            }
        } ?? false
    }
}

// swiftlint:disable discouraged_optional_collection
extension ASN1DecoderImpl.KeyedContainer: KeyedDecodingContainerProtocol {
    /// this serves both as an escape hatch to support Apple's component attributes
    /// certificate extension (which is a SEQUENCE of arbitrary tagged values), and
    /// also to support ASN1ImplicitTagCodingKey/ASN1ExplicitTagCodingKey which are
    /// used to improve ergonomics when mapping ASN.1 SEQUENCEs and CHOICEs with
    /// uniform tagging to Swift types
    private var contextTagCodingKeys: [Key]? {
        let keys: [Key]?

        if self.context.enumCodingState == .enum,
           case .taggedTag(let tagNo) = self.object.tag,
           let tagNo = Int(exactly: tagNo),
           let key = Key(intValue: tagNo) {
            keys = [key]
        } else if self.object.containsOnlyContextTaggedItems,
                  let items = self.object.data.items {
            keys = items.compactMap {
                guard case .taggedTag(let tagNo) = $0.tag else { return nil }
                guard let tagNo = Int(exactly: tagNo) else { return nil }
                return Key(intValue: tagNo)
            }
        } else {
            keys = nil
        }

        return keys
    }

    private func metadataCodingKeys<Key: ASN1MetadataCodingKey & CaseIterable>(_: Key.Type) -> [Key]? {
        let keys: [Key]?

        if self.context.enumCodingState == .enum {
            if self.object.tag.isUniversal {
                keys = self.currentObjectEnumKey as? [Key]
            } else if let key = Key.allCases.first(where: {
                Key.metadata(forKey: $0)?.tag == object.tag
            }) {
                keys = [key]
            } else {
                keys = nil
            }
        } else {
            // FIXME: is this code ever executed?
            keys = self.object.data.items?.compactMap { object in
                if object.tag.isUniversal {
                    return self.context.codingKey(Key.self, object: object)
                } else {
                    return Key.allCases.first {
                        Key.metadata(forKey: $0)?.tag == object.tag
                    }
                }
            }
        }

        return keys
    }

    private var currentObjectEnumKey: [Key]? {
        guard let currentObject = try? self.currentObject(),
              let enumCodingKey = self.context.codingKey(Key.self, object: currentObject) else {
            return nil
        }

        /// in this case, we know the enum coding key from reading the metadata
        return [enumCodingKey]
    }

    var allKeys: [Key] {
        let keys: [Key]?

        if Key.self is any ASN1ContextTagCodingKey.Type {
            keys = self.contextTagCodingKeys
        } else if let type = Key.self as? any(ASN1MetadataCodingKey & CaseIterable).Type {
            keys = self.metadataCodingKeys(type) as! [Key]?
        } else {
            keys = self.currentObjectEnumKey
        }

        return keys ?? []
    }

    func contains(_ key: Key) -> Bool {
        let allKeys = self.allKeys

        if let key = key as? ASN1CodingKey,
           let keys = allKeys as? [ASN1CodingKey] {
            return keys.contains { $0.metadata == key.metadata }
        } else {
            return allKeys.contains { $0.stringValue == key.stringValue }
        }
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        let container = self.nestedSingleValueContainer(try self.currentObject(),
                                                        forKey: key,
                                                        context: self.context)
        let isNil = container.decodeNil()

        if isNil {
            self.currentIndex += 1
        }

        return isNil
    }

    func decodeIfPresent(_ type: Bool.Type, forKey key: Key) throws -> Bool? {
        try self.decodeKeyedSingleValueIfPresent(type, forKey: key)
    }

    func decodeIfPresent(_ type: String.Type, forKey key: Key) throws -> String? {
        try self.decodeKeyedSingleValueIfPresent(type, forKey: key)
    }

    func decodeIfPresent(_ type: Double.Type, forKey key: Key) throws -> Double? {
        try self.decodeKeyedSingleValueIfPresent(type, forKey: key)
    }

    func decodeIfPresent(_ type: Float.Type, forKey key: Key) throws -> Float? {
        try self.decodeKeyedSingleValueIfPresent(type, forKey: key)
    }

    func decodeIfPresent(_ type: Int.Type, forKey key: Key) throws -> Int? {
        try self.decodeKeyedSingleValueIfPresent(type, forKey: key)
    }

    func decodeIfPresent(_ type: Int8.Type, forKey key: Key) throws -> Int8? {
        try self.decodeKeyedSingleValueIfPresent(type, forKey: key)
    }

    func decodeIfPresent(_ type: Int16.Type, forKey key: Key) throws -> Int16? {
        try self.decodeKeyedSingleValueIfPresent(type, forKey: key)
    }

    func decodeIfPresent(_ type: Int32.Type, forKey key: Key) throws -> Int32? {
        try self.decodeKeyedSingleValueIfPresent(type, forKey: key)
    }

    func decodeIfPresent(_ type: Int64.Type, forKey key: Key) throws -> Int64? {
        try self.decodeKeyedSingleValueIfPresent(type, forKey: key)
    }

    func decodeIfPresent(_ type: UInt.Type, forKey key: Key) throws -> UInt? {
        try self.decodeKeyedSingleValueIfPresent(type, forKey: key)
    }

    func decodeIfPresent(_ type: UInt8.Type, forKey key: Key) throws -> UInt8? {
        try self.decodeKeyedSingleValueIfPresent(type, forKey: key)
    }

    func decodeIfPresent(_ type: UInt16.Type, forKey key: Key) throws -> UInt16? {
        try self.decodeKeyedSingleValueIfPresent(type, forKey: key)
    }

    func decodeIfPresent(_ type: UInt32.Type, forKey key: Key) throws -> UInt32? {
        try self.decodeKeyedSingleValueIfPresent(type, forKey: key)
    }

    func decodeIfPresent(_ type: UInt64.Type, forKey key: Key) throws -> UInt64? {
        try self.decodeKeyedSingleValueIfPresent(type, forKey: key)
    }

    func decodeIfPresent<T>(_ type: T.Type, forKey key: Key) throws -> T? where T: Decodable {
        try self.decodeKeyedSingleValueIfPresent(type, forKey: key)
    }

    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        try self.decodeKeyedSingleValue(type, forKey: key)
    }

    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        try self.decodeKeyedSingleValue(type, forKey: key)
    }

    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        try self.decodeKeyedSingleValue(type, forKey: key)
    }

    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        try self.decodeKeyedSingleValue(type, forKey: key)
    }

    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        try self.decodeKeyedSingleValue(type, forKey: key)
    }

    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        try self.decodeKeyedSingleValue(type, forKey: key)
    }

    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        try self.decodeKeyedSingleValue(type, forKey: key)
    }

    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        try self.decodeKeyedSingleValue(type, forKey: key)
    }

    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        try self.decodeKeyedSingleValue(type, forKey: key)
    }

    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        try self.decodeKeyedSingleValue(type, forKey: key)
    }

    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        try self.decodeKeyedSingleValue(type, forKey: key)
    }

    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        try self.decodeKeyedSingleValue(type, forKey: key)
    }

    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        try self.decodeKeyedSingleValue(type, forKey: key)
    }

    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        try self.decodeKeyedSingleValue(type, forKey: key)
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
        try self.decodeKeyedSingleValue(type, forKey: key)
    }

    func nestedContainer<NestedKey>(
        keyedBy _: NestedKey.Type,
        forKey key: Key
    ) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        let currentObject = try self.currentObject(nestedContainer: true)
        let container = try ASN1DecoderImpl.KeyedContainer<NestedKey>(object: currentObject,
                                                                      codingPath: self.nestedCodingPath(forKey: key),
                                                                      userInfo: self.userInfo,
                                                                      context: self.context.decodingNestedContainer())

        self.currentIndex += 1

        return KeyedDecodingContainer(container)
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        let currentObject = try self.currentObject(nestedContainer: true)
        let container = try ASN1DecoderImpl.UnkeyedContainer(object: currentObject,
                                                             codingPath: self.nestedCodingPath(forKey: key),
                                                             userInfo: self.userInfo,
                                                             context: self.context.decodingNestedContainer())

        self.currentIndex += 1

        return container
    }

    func superDecoder() throws -> Decoder {
        ASN1DecoderImpl.ReferencingDecoder(self, key: ASN1Key.super)
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        ASN1DecoderImpl.ReferencingDecoder(self, key: key)
    }
}

extension ASN1DecoderImpl.KeyedContainer {
    private func decodeKeyedSingleValue<T>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
        let container = self.nestedSingleValueContainer(try self.currentObject(for: type),
                                                        forKey: key,
                                                        context: self.context.decodingSingleValue(type))

        if let codingKey = self.codingPath.last, codingKey is any ASN1CodingKey {
            // predefined keys are incompatible with automatic tagging
            self.context.automaticTaggingContext = nil
        }

        let value = try container.decode(type)

        if !ASN1DecoderImpl.isNilOrWrappedNil(value) {
            self.currentIndex += 1
        }

        return value
    }

    private func decodeKeyedSingleValueIfPresent<T>(_ type: T.Type, forKey key: Key) throws -> T? where T: Decodable {
        let container = self.nestedSingleValueContainer(try self.currentObject(for: type),
                                                        forKey: key,
                                                        context: self.context.decodingSingleValue(type))
        let value: T?

        if object.isNull {
            value = nil
        } else {
            do {
                value = try container.decode(type)
                if isNullAnyCodable(value) { return nil } // FIXME: abstraction violation
            } catch {
                if let error = error as? DecodingError, case .valueNotFound = error {
                    return nil
                } else {
                    throw error
                }
            }
        }

        // value was explicit NULL or was successfully decoded
        self.currentIndex += 1

        return value
    }

    private func nestedSingleValueContainer(
        _ object: ASN1Object,
        forKey key: Key,
        context: ASN1DecodingContext
    ) -> ASN1DecoderImpl.SingleValueContainer {
        let container = ASN1DecoderImpl.SingleValueContainer(object: object,
                                                             codingPath: self.nestedCodingPath(forKey: key),
                                                             userInfo: self.userInfo,
                                                             context: context)

        return container
    }
}

extension KeyedDecodingContainer {
    func decode<T: ExpressibleByNilLiteral, U: ASN1TaggedValue>(_ type: U.Type, forKey key: K) throws ->
        any ASN1TaggedValue where U.Value == T {
        if let value = try self.decodeIfPresent(type, forKey: key) {
            return value
        }

        return U(wrappedValue: nil)
    }
}
