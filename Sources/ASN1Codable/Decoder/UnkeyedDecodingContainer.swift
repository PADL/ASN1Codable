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

extension ASN1DecoderImpl {
    final class UnkeyedContainer: ASN1DecodingContainer {
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
            // there's no point sorting SET OF on decode because the Swift type is unordered
            self.object = object
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.context = context
        }

        var nestedCodingPath: [CodingKey] {
            self.codingPath + [ASN1Key(index: self.currentIndex)]
        }
    }
}

extension ASN1DecoderImpl.UnkeyedContainer: UnkeyedDecodingContainer {
    func decodeNil() throws -> Bool {
        let container = self.nestedSingleValueContainer(try self.currentObject(), context: self.context)
        let isNil = container.decodeNil()

        if isNil {
            self.currentIndex += 1
        }

        return isNil
    }

    func decodeIfPresent(_ type: Bool.Type) throws -> Bool? {
        try self.decodeUnkeyedSingleValueIfPresent(type)
    }

    func decodeIfPresent(_ type: String.Type) throws -> String? {
        try self.decodeUnkeyedSingleValueIfPresent(type)
    }

    func decodeIfPresent(_ type: Double.Type) throws -> Double? {
        try self.decodeUnkeyedSingleValueIfPresent(type)
    }

    func decodeIfPresent(_ type: Float.Type) throws -> Float? {
        try self.decodeUnkeyedSingleValueIfPresent(type)
    }

    func decodeIfPresent(_ type: Int.Type) throws -> Int? {
        try self.decodeUnkeyedSingleValueIfPresent(type)
    }

    func decodeIfPresent(_ type: Int8.Type) throws -> Int8? {
        try self.decodeUnkeyedSingleValueIfPresent(type)
    }

    func decodeIfPresent(_ type: Int16.Type) throws -> Int16? {
        try self.decodeUnkeyedSingleValueIfPresent(type)
    }

    func decodeIfPresent(_ type: Int32.Type) throws -> Int32? {
        try self.decodeUnkeyedSingleValueIfPresent(type)
    }

    func decodeIfPresent(_ type: Int64.Type) throws -> Int64? {
        try self.decodeUnkeyedSingleValueIfPresent(type)
    }

    func decodeIfPresent(_ type: UInt.Type) throws -> UInt? {
        try self.decodeUnkeyedSingleValueIfPresent(type)
    }

    func decodeIfPresent(_ type: UInt8.Type) throws -> UInt8? {
        try self.decodeUnkeyedSingleValueIfPresent(type)
    }

    func decodeIfPresent(_ type: UInt16.Type) throws -> UInt16? {
        try self.decodeUnkeyedSingleValueIfPresent(type)
    }

    func decodeIfPresent(_ type: UInt32.Type) throws -> UInt32? {
        try self.decodeUnkeyedSingleValueIfPresent(type)
    }

    func decodeIfPresent(_ type: UInt64.Type) throws -> UInt64? {
        try self.decodeUnkeyedSingleValueIfPresent(type)
    }

    func decodeIfPresent<T>(_ type: T.Type) throws -> T? where T: Decodable {
        try self.decodeUnkeyedSingleValueIfPresent(type)
    }

    func decode(_ type: Bool.Type) throws -> Bool {
        try self.decodeUnkeyedSingleValue(type)
    }

    func decode(_ type: String.Type) throws -> String {
        try self.decodeUnkeyedSingleValue(type)
    }

    func decode(_ type: Double.Type) throws -> Double {
        try self.decodeUnkeyedSingleValue(type)
    }

    func decode(_ type: Float.Type) throws -> Float {
        try self.decodeUnkeyedSingleValue(type)
    }

    func decode(_ type: Int.Type) throws -> Int {
        try self.decodeUnkeyedSingleValue(type)
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        try self.decodeUnkeyedSingleValue(type)
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        try self.decodeUnkeyedSingleValue(type)
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        try self.decodeUnkeyedSingleValue(type)
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        try self.decodeUnkeyedSingleValue(type)
    }

    func decode(_ type: UInt.Type) throws -> UInt {
        try self.decodeUnkeyedSingleValue(type)
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        try self.decodeUnkeyedSingleValue(type)
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        try self.decodeUnkeyedSingleValue(type)
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        try self.decodeUnkeyedSingleValue(type)
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        try self.decodeUnkeyedSingleValue(type)
    }

    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        try self.decodeUnkeyedSingleValue(type)
    }

    func nestedContainer<NestedKey>(
        keyedBy _: NestedKey.Type
    ) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        let currentObject = try self.currentObject(nestedContainer: true)
        let container = try ASN1DecoderImpl.KeyedContainer<NestedKey>(object: currentObject,
                                                                      codingPath: self.nestedCodingPath,
                                                                      userInfo: self.userInfo,
                                                                      context: self.context.decodingNestedContainer())

        self.currentIndex += 1

        return KeyedDecodingContainer(container)
    }

    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        let currentObject = try self.currentObject(nestedContainer: true)
        let container = try ASN1DecoderImpl.UnkeyedContainer(object: currentObject,
                                                             codingPath: self.nestedCodingPath,
                                                             userInfo: self.userInfo,
                                                             context: self.context.decodingNestedContainer())

        self.currentIndex += 1

        return container
    }

    func superDecoder() throws -> Decoder {
        ASN1DecoderImpl.ReferencingDecoder(self, at: self.currentIndex)
    }
}

extension ASN1DecoderImpl.UnkeyedContainer {
    private func nestedSingleValueContainer(
        _ object: ASN1Object,
        context: ASN1DecodingContext
    ) -> ASN1DecoderImpl.SingleValueContainer {
        let container = ASN1DecoderImpl.SingleValueContainer(object: object,
                                                             codingPath: self.nestedCodingPath,
                                                             userInfo: self.userInfo,
                                                             context: context)

        return container
    }

    private func decodeUnkeyedSingleValue<T>(_ type: T.Type) throws -> T where T: Decodable {
        let container = self.nestedSingleValueContainer(try self.currentObject(for: type),
                                                        context: self.context.decodingSingleValue(type))

        let value = try container.decode(type)

        if !ASN1DecoderImpl.isNilOrWrappedNil(value) {
            self.currentIndex += 1
        }

        return value
    }

    private func decodeUnkeyedSingleValueIfPresent<T>(_ type: T.Type) throws -> T? where T: Decodable {
        let container = self.nestedSingleValueContainer(try self.currentObject(for: type),
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
