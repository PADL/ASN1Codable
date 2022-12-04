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

// swiftlint:disable discouraged_optional_collection
extension ASN1DecoderImpl.KeyedContainer: KeyedDecodingContainerProtocol {
    /// this serves both as an escape hatch to support Apple's component attributes
    /// certificate extension (which is a SEQUENCE of arbitrary tagged values), and
    /// also to support `ASN1ImplicitTagCodingKey` and `ASN1ExplicitTagCodingKey`
    /// which are used to improve ergonomics when mapping ASN.1 SEQUENCEs and CHOICEs
    /// with uniform tagging to Swift types. (The same can be achieved with `ASN1MetadataCodingKey`
    /// but this approach results in smaller code size as the tag number is encapsulated in the raw
    /// representable type itself.)
    private func contextTagCodingKeys<Key: ASN1ContextTagCodingKey>(
        _: Key.Type,
        _ objects: [ASN1Object]
    ) -> [Key] {
        guard objects.allSatisfy(\.tag.isContextSpecific) else {
            return []
        }

        return objects.compactMap {
            if case .taggedTag(let tagNo) = $0.tag,
               let tagNo = Int(exactly: tagNo) {
                return Key(intValue: tagNo)
            } else {
                return nil
            }
        }
    }

    /// types with `ASN1MetadataCodingKey` conforming coding keys provide a `metadata(forKey:)`
    /// function that maps a key to a non-universal tag and tagging environment.
    private func metadataCodingKeys<Key: ASN1MetadataCodingKey>(
        _ type: Key.Type,
        _ objects: [ASN1Object]
    ) -> [Key] {
        objects.compactMap { object in
            object.tag.isUniversal ? self.context.codingKey(type, object: object)
                : Key.allCases.first { Key.metadata(forKey: $0)?.tag == object.tag }
        }
    }

    /// for a regular `CodingKey` we use reflection to map the tag to a field name. This does assume that
    /// the key name matches the field name. This is the only strategy that works with universal tags.
    private func codingKeys<Key: CodingKey>(
        _ type: Key.Type,
        _ objects: [ASN1Object]
    ) -> [Key] {
        objects.compactMap {
            self.context.codingKey(type, object: $0)
        }
    }

    /// `allKeys` is used principally to determine the discriminant when decoding an `enum` from an ASN.1
    /// CHOICE. It would also be used when decoding string and integer-keyed `Dictionary` values, were
    /// it not for the fact that those are promoted to `Set<KeyValue>`. The final use case is to support
    /// `ASN1TaggedDictionary` which is a is dictionary where the keys are ASN.1 context tags.
    ///
    /// There are three strategies to map an ASN.1 object to a `Key`, which are tried in order of expense.
    /// The first assumes the key conforms to `ASN1ContextTagCodingKey` and, after checking that
    /// all values in the object are tagged with context tags, attempts to initialise the key with the tag number.
    ///
    /// The second assumes the key conforms to `ASN1MetadataCodingKey`, which is `CaseIterable`.
    /// It enumerates all the cases, calling the `metadata(forKey:)` function for each, until one is found
    /// that produces metadata with a (non-universal) tag matching the ASN.1 object. For a SEQUENCE or SET
    /// (as opposed to a CHOICE) this is attempted for all objects.
    ///
    /// The final, and most expensive, is used for universal types and uses reflection to find the field where
    /// the Swift type matches the tag. It assumes that no custom coding keys are used.
    var allKeys: [Key] {
        let keys: [Key]
        let objects: [ASN1Object]?

        if self.context.enumCodingState == .enum, let currentObject = try? self.currentObject() {
            objects = [currentObject]
        } else {
            objects = self.object.data.items
        }

        guard let objects else {
            return []
        }

        if let type = Key.self as? any ASN1ContextTagCodingKey.Type {
            keys = self.contextTagCodingKeys(type, objects) as! [Key]
        } else if let type = Key.self as? any ASN1MetadataCodingKey.Type {
            keys = self.metadataCodingKeys(type, objects) as! [Key]
        } else {
            keys = self.codingKeys(Key.self, objects)
        }

        return keys
    }

    /// enumerate `allKeys` for one matching `key`. Note that `Key` is not `Equatable` so we
    /// need to compare the ASN.1 metadata directly, or the string value.
    func contains(_ key: Key) -> Bool {
        if let key = key as? ASN1CodingKey,
           let keys = self.allKeys as? [ASN1CodingKey] {
            return keys.contains { $0.metadata == key.metadata }
        } else {
            return self.allKeys.contains { $0.stringValue == key.stringValue }
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
