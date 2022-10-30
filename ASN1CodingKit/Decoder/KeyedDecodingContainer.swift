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
    
    var isAtEnd: Bool {
        guard let count = self.count else {
            return true
        }
        
        return self.currentIndex >= count
    }

    private func validateCurrentIndex() throws {
        if self.isAtEnd {
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Already at end of ASN.1 object")
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
    
    var allKeys: [Key] {
        if let enumCodingKey = self.context.enumCodingKey(self.currentObject) {
            return [enumCodingKey as! Key]
        }
        
        return self.containers.keys.map { Key(stringValue: $0)! }
    }
    
    func contains(_ key: Key) -> Bool {
        return self.containers.keys.contains(key.stringValue)
    }
    
    func decodeNil(forKey key: Key) throws -> Bool {
        try self.validateCurrentIndex()
        
        try context.validateObject(self.currentObject, codingPath: self.codingPath)

        let container = self.nestedSingleValueContainer(object, forKey: key, context: ASN1DecodingContext())
        
        self.containers[key.stringValue] = container
        self.currentIndex += 1

        return container.decodeNil()
    }
    
    private func _isNilOrWrappedNil<T>(_ value: T) -> Bool where T : Decodable {
        let wrappedValue: any Decodable
        
        // FIXME check non-wrapped optionals? because we need to wrap them to disambiguate in ASN.1
        
        if let value = value as? any ASN1TaggedProperty {
            wrappedValue = value.wrappedValue
        } else {
            wrappedValue = value
        }
        
        if let wrappedValue = wrappedValue as? ExpressibleByNilLiteral,
            let wrappedValue = wrappedValue as? Optional<Decodable>,
            case .none = wrappedValue {
            return true
        }
        
        return false
    }
    
    // FIXME do we need decodeIfPresent? perhaps not if OPTIONAL values must be tagged
    // but perhaps if the last value is OPTIONAL
    
    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        let object: ASN1Object
        
        if self.isAtEnd {
            object = ASN1NullObject()
        } else {
            try self.validateCurrentIndex()
            try self.context.validateObject(self.currentObject, codingPath: self.codingPath)
            object = self.currentObject
        }
        
        let container = self.nestedSingleValueContainer(object,
                                                        forKey: key,
                                                        context: self.context.decodingSingleValue(type))

        let value = try container.decode(type)

        // ignore OPTIONAL values
        if !self._isNilOrWrappedNil(value) {
            self.containers[key.stringValue] = container
            self.currentIndex += 1
        }
        
        return value
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        try self.validateCurrentIndex()
        try context.validateObject(self.currentObject, container: true, codingPath: self.codingPath)

        let container = try ASN1DecoderImpl.KeyedContainer<NestedKey>(object: self.currentObject,
                                                                      codingPath: self.nestedCodingPath(forKey: key),
                                                                      userInfo: self.userInfo,
                                                                      context: self.context.decodingNestedContainer())
        self.containers[key.stringValue] = container
        self.currentIndex += 1

        return KeyedDecodingContainer(container)
    }
    
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        try self.validateCurrentIndex()
        try context.validateObject(self.currentObject, container: true, codingPath: self.codingPath)

        defer { self.currentIndex += 1 }

        let container = try ASN1DecoderImpl.UnkeyedContainer(object: self.currentObject,
                                                             codingPath: self.nestedCodingPath(forKey: key),
                                                             userInfo: self.userInfo,
                                                             context: self.context.decodingNestedContainer())
        self.containers[key.stringValue] = container
        self.currentIndex += 1

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

