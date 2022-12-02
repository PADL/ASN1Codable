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
            } else if self.context.isCodingKeyRepresentableDictionary,
                      let keyValue = key.intValue,
                      let key = ASN1TaggedDictionaryCodingKey(intValue: keyValue) {
                return self.codingPath + [key]
            } else {
                return self.codingPath + [key]
            }
        }
    }
}

extension ASN1Object {
    // returns true if we have a SEQUENCE/SET of context tagged items
    var containsOnlyTaggedItems: Bool {
        guard let items = self.data.items else {
            return false
        }

        return items.allSatisfy {
            if case .taggedTag = $0.tag {
                return true
            } else {
                return false
            }
        }
    }

    func dictionaryTuples<Key: CodingKey>(_: Key.Type) -> [(Key, ASN1Object)]? {
        guard let items = self.data.items, items.count % 2 == 0 else { return nil }

        var tuples = [(Key, ASN1Object)]()
        for i in 0 ..< items.count / 2 {
            let key = items[i * 2]
            let object = items[i * 2 + 1]

            do {
                let string = try String(from: key)
                guard let key = Key(stringValue: string) else { return nil }
                tuples.append((key, object))
            } catch {
                return nil
            }
        }

        return tuples
    }
}

extension ASN1DecoderImpl.KeyedContainer: KeyedDecodingContainerProtocol {
    private var unsafelyUnwrappedItems: [ASN1Object] {
        self.object.data.items!
    }

    /// this serves both as an escape hatch to support Apple's component attributes
    /// certificate extension (which is a SEQUENCE of arbitrary tagged values), and
    /// also to support ASN1ImplicitTagCodingKey/ASN1ExplicitTagCodingKey which are
    /// used to improve ergonomics when mapping ASN.1 SEQUENCEs and CHOICEs with
    /// uniform tagging to Swift types
    private var contextTagCodingKeys: [Key]? {
        let keys: [Key]?

        if self.context.enumCodingState == .enum,
           case .taggedTag(let tagNo) = self.object.tag,
           let key = Key(intValue: Int(tagNo)) {
            keys = [key]
        } else if self.object.containsOnlyTaggedItems {
            keys = self.unsafelyUnwrappedItems.compactMap {
                guard case .taggedTag(let tagNo) = $0.tag else { return nil }
                return Key(intValue: Int(tagNo))
            }
        } else {
            keys = []
        }

        return keys
    }

    /// returns even indexed objects representing keys for Int or String
    /// keyed dictionaries
    private var codingKeyRepresentableDictionaryKeys: [Key]? {
        self.object.containsOnlyTaggedItems ? self.contextTagCodingKeys : self.object.dictionaryTuples(Key.self)?.map(\.0)
    }

    private var currentObjectEnumKey: [Key]? {
        let currentObject: ASN1Object

        do {
            currentObject = try self.currentObject()
        } catch {
            return nil
        }

        if let enumCodingKey = self.context.codingKey(Key.self, object: currentObject) {
            /// in this case, we know the enum coding key from reading the metadata
            return [enumCodingKey]
        }

        return nil
    }

    var allKeys: [Key] {
        let keys: [Key]?

        if Key.self is any ASN1ContextTagCodingKey.Type {
            keys = self.contextTagCodingKeys
        } else if self.context.isCodingKeyRepresentableDictionary {
            keys = self.codingKeyRepresentableDictionaryKeys
        } else {
            keys = self.currentObjectEnumKey
        }

        return keys ?? []
    }

    private func containsContextTagCodingKey(_ key: any ASN1ContextTagCodingKey) -> Bool {
        if self.context.enumCodingState == .enum,
           case .taggedTag(let tagNo) = self.object.tag,
           let keyValue = key.intValue {
            return keyValue == tagNo
        } else if self.object.containsOnlyTaggedItems,
            let keyValue = key.intValue,
            let keyValue = UInt(exactly: keyValue) {
            /// per the similar code path in allKeys, this returns true if we have a uniformly
            /// tagged structure and the tag represented by `key` is present
            return self.unsafelyUnwrappedItems.contains {
                $0.tag == .taggedTag(keyValue)
            }
        } else {
            return false
        }
    }

    private func containsMetadataCodingKey(_ key: any ASN1MetadataCodingKey) -> Bool {
        if self.context.enumCodingState == .enum {
            return self.object.tag == key.metadata.tag
        } else {
            return self.object.data.items?.contains(where: { $0.tag == key.metadata.tag }) ?? false
        }
    }

    private func containsCodingKeyRepresentableDictionaryKey(_ key: Key) -> Bool {
        if let keyValue = key.intValue, let key = ASN1TaggedDictionaryCodingKey(intValue: keyValue) {
            return self.containsContextTagCodingKey(key)
        } else {
            return self.object.dictionaryTuples(Key.self)?.contains {
                $0.0.stringValue == key.stringValue
            } ?? false
        }
    }

    private func containsCurrentObjectEnumKey(_ key: Key) -> Bool {
        let currentObject: ASN1Object

        do {
            currentObject = try self.currentObject()
        } catch {
            return false
        }

        if self.context.enumCodingState == .enum {
            return self.context.codingKey(Key.self, object: currentObject)?.stringValue == key.stringValue
        } else {
            return true /// at this point, we have to optimistically assume the key exists
        }
    }

    func contains(_ key: Key) -> Bool {
        if let key = key as? any ASN1ContextTagCodingKey {
            return self.containsContextTagCodingKey(key)
        } else if let key = key as? any ASN1MetadataCodingKey {
            return self.containsMetadataCodingKey(key)
        } else if self.context.isCodingKeyRepresentableDictionary {
            return self.containsCodingKeyRepresentableDictionaryKey(key)
        } else {
            return self.containsCurrentObjectEnumKey(key)
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

    private func decodeKeyedSingleValue<T>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
        let container = self.nestedSingleValueContainer(try self.currentObject(for: type, key: key),
                                                        forKey: key,
                                                        context: self.context.decodingSingleValue(type))
        let value = try container.decode(type)

        if !ASN1DecoderImpl.isNilOrWrappedNil(value) {
            self.currentIndex += 1
        }

        return value
    }

    private func decodeKeyedSingleValueIfPresent<T>(_ type: T.Type, forKey key: Key) throws -> T? where T: Decodable {
        let container = self.nestedSingleValueContainer(try self.currentObject(for: type, key: key),
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
                if let error = error as? DecodingError, case .typeMismatch = error {
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
