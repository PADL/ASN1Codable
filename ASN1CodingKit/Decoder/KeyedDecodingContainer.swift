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
    
    func contains(_ key: Key) -> Bool {
        return self.containers.keys.contains(key.stringValue)
    }
    
    private func currentObject(_ type: Decodable.Type?) throws -> ASN1Object {
        let object: ASN1Object
        
        if self.context.enumCodingState == .enumCase {
            object = self.object
            /*
        } else if let type = type,
           ASN1DecodingContext.enumTypeHasMember(type, tag: self.object.tag, tagging: .implicit) {
            object = self.object
             */
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
        
    private func decodingKeyedSingleValue<T>(_ type: T.Type?,
                                             forKey key: Key,
                                             object: ASN1Object,
                                             _ block: (ASN1DecoderImpl.SingleValueContainer) throws -> T) throws -> T where T : Decodable {
        var decoded: Bool = false
        let container = self.nestedSingleValueContainer(object,
                                                        forKey: key,
                                                        context: self.context.decodingSingleValue(type))

        let value = try ASN1DecoderImpl._decodingSingleValue(type, container: container, decoded: &decoded, block: block)
        
        if decoded {
            self.containers[key.stringValue] = container
            self.currentIndex += 1
        }
        
        return value
    }
    
    func decodeNil(forKey key: Key) throws -> Bool {
        let object = try self.currentObject(nil)
        
        return try decodingKeyedSingleValue(nil, forKey: key, object: object) { container in
            return container.decodeNil()
        }
    }
    
    func decodeIfPresent<T>(_ type: T.Type, forKey key: Key) throws -> T? where T : Decodable {
        let object = try self.currentObject(type)

        if object.isNull {
            // FIXME set self.containers
            self.currentIndex += 1
            return nil
        }

        return try decodingKeyedSingleValue(type, forKey: key, object: object) { container in
            return try container.decode(type)
        }
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        let object = try self.currentObject(type)

        return try decodingKeyedSingleValue(type, forKey: key, object: object) { container in
            return try container.decode(type)
        }
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        try self.validateCurrentIndex()
        let currentObject = try self.currentObject()
        try context.validateObject(currentObject, container: true, codingPath: self.codingPath)

        let container = try ASN1DecoderImpl.KeyedContainer<NestedKey>(object: currentObject,
                                                                      codingPath: self.nestedCodingPath(forKey: key),
                                                                      userInfo: self.userInfo,
                                                                      context: self.context.decodingNestedContainer())
        self.containers[key.stringValue] = container
        self.currentIndex += 1

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

