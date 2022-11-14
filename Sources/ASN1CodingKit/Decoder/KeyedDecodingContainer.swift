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
        private var containers: [String: ASN1DecodingContainer] = [:]

        var object: ASN1Object
        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]
        var context: ASN1DecodingContext

        var currentIndex: Int = 0

        init(object: ASN1Object,
             codingPath: [CodingKey],
             userInfo: [CodingUserInfoKey : Any],
             context: ASN1DecodingContext) throws {
            self.object = object
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.context = context
        }

        func nestedCodingPath(forKey key: CodingKey) -> [CodingKey] {
            return self.codingPath + [key]
        }
    }
}

extension ASN1DecoderImpl.KeyedContainer: KeyedDecodingContainerProtocol {
    var count: Int? {
        return self.object.data.fold({ primitive in
            return 1
        }, { items in
            return items.count
        })
    }

    var numberOfKeyedObjectsDecoded: Int? {
        return self.count
    }
    
    var allKeys: [Key] {
        let keys: [Key]
        let currentObject: ASN1Object
        
        do {
            try self.validateCurrentIndex()
            currentObject = try self.currentObject()
        } catch {
            return []
        }
        
        if let enumCodingKey = self.context.enumCodingKey(Key.self, object: currentObject) {
            keys = [enumCodingKey]
        } else {
            keys = self.containers.keys.map { Key(stringValue: $0)! }
        }

        return keys
    }

    // FIXME we don't know the keys ahead of time so we can't answer this except in the enum case
    func contains(_ key: Key) -> Bool {
        let currentObject: ASN1Object
        
        do {
            try self.validateCurrentIndex()
            currentObject = try self.currentObject()
        } catch {
            return false
        }
        
        if self.context.enumCodingState == .enum {
            return self.context.enumCodingKey(Key.self, object: currentObject)?.stringValue == key.stringValue
        } else {
            return true // let's optimistically try
        }
    }
    
    func decodeNil(forKey key: Key) throws -> Bool {
        let object = try self.currentObject(for: nil)
        let container = self.nestedSingleValueContainer(object,
                                                        forKey: key,
                                                        context: self.context)
        let isNil = container.decodeNil()

        if isNil {
            self.addContainer(container, forKey: key)
        }
        
        return isNil
    }
    
    func decodeIfPresent(_ type: Bool.Type, forKey key: Key) throws -> Bool? {
        return try self.decodeKeyedSingleValueIfPresent(type, forKey: key)
    }
    
    func decodeIfPresent(_ type: String.Type, forKey key: Key) throws -> String? {
        return try self.decodeKeyedSingleValueIfPresent(type, forKey: key)
    }
    
    func decodeIfPresent(_ type: Double.Type, forKey key: Key) throws -> Double? {
        return try self.decodeKeyedSingleValueIfPresent(type, forKey: key)
    }
    
    func decodeIfPresent(_ type: Float.Type, forKey key: Key) throws -> Float? {
        return try self.decodeKeyedSingleValueIfPresent(type, forKey: key)
    }

    func decodeIfPresent(_ type: Int.Type, forKey key: Key) throws -> Int? {
        return try self.decodeKeyedSingleValueIfPresent(type, forKey: key)
    }
    
    func decodeIfPresent(_ type: Int8.Type, forKey key: Key) throws -> Int8? {
        return try self.decodeKeyedSingleValueIfPresent(type, forKey: key)
    }
    
    func decodeIfPresent(_ type: Int16.Type, forKey key: Key) throws -> Int16? {
        return try self.decodeKeyedSingleValueIfPresent(type, forKey: key)
    }
    
    func decodeIfPresent(_ type: Int32.Type, forKey key: Key) throws -> Int32? {
        return try self.decodeKeyedSingleValueIfPresent(type, forKey: key)
    }
    
    func decodeIfPresent(_ type: Int64.Type, forKey key: Key) throws -> Int64? {
        return try self.decodeKeyedSingleValueIfPresent(type, forKey: key)
    }
    
    func decodeIfPresent(_ type: UInt.Type, forKey key: Key) throws -> UInt? {
        return try self.decodeKeyedSingleValueIfPresent(type, forKey: key)
    }
    
    func decodeIfPresent(_ type: UInt8.Type, forKey key: Key) throws -> UInt8? {
        return try self.decodeKeyedSingleValueIfPresent(type, forKey: key)
    }
    
    func decodeIfPresent(_ type: UInt16.Type, forKey key: Key) throws -> UInt16? {
        return try self.decodeKeyedSingleValueIfPresent(type, forKey: key)
    }
    
    func decodeIfPresent(_ type: UInt32.Type, forKey key: Key) throws -> UInt32? {
        return try self.decodeKeyedSingleValueIfPresent(type, forKey: key)
    }
    
    func decodeIfPresent(_ type: UInt64.Type, forKey key: Key) throws -> UInt64? {
        return try self.decodeKeyedSingleValueIfPresent(type, forKey: key)
    }
    
    func decodeIfPresent<T>(_ type: T.Type, forKey key: Key) throws -> T? where T : Decodable {
        return try self.decodeKeyedSingleValueIfPresent(type, forKey: key)
    }

    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        return try self.decodeKeyedSingleValue(type, forKey: key)
    }
    
    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        return try self.decodeKeyedSingleValue(type, forKey: key)
    }
    
    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        return try self.decodeKeyedSingleValue(type, forKey: key)
    }
    
    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        return try self.decodeKeyedSingleValue(type, forKey: key)
    }

    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        return try self.decodeKeyedSingleValue(type, forKey: key)
    }
    
    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        return try self.decodeKeyedSingleValue(type, forKey: key)
    }
    
    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        return try self.decodeKeyedSingleValue(type, forKey: key)
    }
    
    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        return try self.decodeKeyedSingleValue(type, forKey: key)
    }
    
    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        return try self.decodeKeyedSingleValue(type, forKey: key)
    }
    
    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        return try self.decodeKeyedSingleValue(type, forKey: key)
    }
    
    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        return try self.decodeKeyedSingleValue(type, forKey: key)
    }
    
    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        return try self.decodeKeyedSingleValue(type, forKey: key)
    }
    
    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        return try self.decodeKeyedSingleValue(type, forKey: key)
    }
    
    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        return try self.decodeKeyedSingleValue(type, forKey: key)
    }
    
    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        return try self.decodeKeyedSingleValue(type, forKey: key)
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        try self.validateCurrentIndex()
        let currentObject = try self.currentObject()
        try context.validateObject(currentObject, container: true, codingPath: self.codingPath)

        let container = try ASN1DecoderImpl.KeyedContainer<NestedKey>(object: currentObject,
                                                                      codingPath: self.nestedCodingPath(forKey: key),
                                                                      userInfo: self.userInfo,
                                                                      context: self.context.decodingNestedContainer())
        
        self.addContainer(container, forKey: key)

        return KeyedDecodingContainer(container)
    }
    
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        try self.validateCurrentIndex()
        let currentObject = try self.currentObject()
        try context.validateObject(try self.currentObject(), container: true, codingPath: self.codingPath)

        let container = try ASN1DecoderImpl.UnkeyedContainer(object: currentObject,
                                                             codingPath: self.nestedCodingPath(forKey: key),
                                                             userInfo: self.userInfo,
                                                             context: self.context.decodingNestedContainer())

        self.addContainer(container, forKey: key)

        return container
    }
    
    func superDecoder() throws -> Decoder {
        let context = DecodingError.Context(codingPath: self.codingPath,
                                            debugDescription: "ASN1DecoderImpl.KeyedContainer does not yet support super decoders")
        throw DecodingError.dataCorrupted(context)
    }
    
    func superDecoder(forKey key: Key) throws -> Decoder {
        throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "ASN1DecoderImpl.KeyedContainer does not yet support super decoders")
    }
}

extension ASN1DecoderImpl.KeyedContainer {
    private var isEmptySequence: Bool {
        return self.object.constructed && self.object.data.items?.count == 0
    }
    
    private var isAtEnd: Bool {
        guard let count = self.count else {
            return true
        }
        
        return self.currentIndex >= count
    }


    private func validateCurrentIndex() throws {
        if !self.object.constructed && self.context.enumCodingState == .none && !self.object.isNull {
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Keyed container expected constructed object")
            throw DecodingError.dataCorrupted(context)
        }

        if !self.isEmptySequence, self.isAtEnd {
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Keyed container already at end of ASN.1 object")
            throw DecodingError.dataCorrupted(context)
        }
    }
    
    private func nestedSingleValueContainer(_ object: ASN1Object,
                                            forKey key: Key,
                                            context: ASN1DecodingContext) -> ASN1DecoderImpl.SingleValueContainer {
        let container = ASN1DecoderImpl.SingleValueContainer(object: object,
                                                             codingPath: self.nestedCodingPath(forKey: key),
                                                             userInfo: self.userInfo,
                                                             context: context)
                
        return container
    }
    
    private func currentObject(for type: Decodable.Type?) throws -> ASN1Object {
        let object: ASN1Object
        
        if self.context.enumCodingState == .enumCase {
            object = self.object
        } else if self.isAtEnd {
            // if we've reached the end of the SEQUENCE or SET, we still need to initialise
            // the remaining wrapped objects; pad the object set with null instances.
            object = ASN1NullObject
        } else {
            // return object at current index
            object = try self.currentObject()
            try self.validateCurrentIndex()
            try self.context.validateObject(object, codingPath: self.codingPath)
        }

        return object
    }
    
    private func addContainer(_ container: ASN1DecodingContainer, forKey key: Key) {
        self.containers[key.stringValue] = container
        self.currentIndex += 1
    }
    
    private func decodeKeyedSingleValue<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        let object = try self.currentObject(for: type)
        let container = self.nestedSingleValueContainer(object,
                                                        forKey: key,
                                                        context: self.context.decodingSingleValue(type))
        let value: T

        value = try container.decode(type)
        if !ASN1DecoderImpl.isNilOrWrappedNil(value) {
            self.addContainer(container, forKey: key)
        }
        
        return value
    }
    
    private func decodeKeyedSingleValueIfPresent<T>(_ type: T.Type, forKey key: Key) throws -> T? where T : Decodable {
        let object = try self.currentObject(for: type)
        let container = self.nestedSingleValueContainer(object,
                                                        forKey: key,
                                                        context: self.context.decodingSingleValue(type))
        let value: T?

        if object.isNull {
            value = nil
        } else {
            do {
                value = try container.decode(type)
            } catch {
                if let error = error as? DecodingError, case .typeMismatch(_, _) = error {
                    value = nil
                } else {
                    throw error
                }
            }
        }
        
        if value != nil {
            self.addContainer(container, forKey: key)
        }
        
        return value
    }
}
