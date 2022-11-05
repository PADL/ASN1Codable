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
    final class UnkeyedContainer: ASN1DecodingContainer {
        private var containers: [ASN1DecodingContainer] = []
        
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
        
        struct Index: CodingKey {
            var stringValue: String {
                return "\(self.intValue!)"
            }
            
            var intValue: Int?
            
            init?(stringValue: String) {
                return nil
            }
            
            init?(intValue: Int) {
                self.intValue = intValue
            }
        }
        
        var nestedCodingPath: [CodingKey] {
            return self.codingPath + [Index(intValue: self.count!)!]
        }
    }
}

extension ASN1DecoderImpl.UnkeyedContainer: UnkeyedDecodingContainer {
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
        if !self.object.constructed && self.context.enumCodingState == .none {
            throw DecodingError.dataCorruptedError(in: self, debugDescription: "Expected constructed object")
        }
        if self.isAtEnd {
            throw DecodingError.dataCorruptedError(in: self, debugDescription: "Already at end of ASN.1 object")
        }
    }
    
    private func nestedSingleValueContainer(_ object: ASN1Object, context: ASN1DecodingContext) -> ASN1DecoderImpl.SingleValueContainer {
        let container = ASN1DecoderImpl.SingleValueContainer(object: object,
                                                             codingPath: self.nestedCodingPath,
                                                             userInfo: self.userInfo,
                                                             context: context)
                
        return container
    }
    
    private func _currentObject(_ type: Decodable.Type?) throws -> ASN1Object {
        let object: ASN1Object
        
        // if we've reached the end of the SEQUENCE or SET, we still need to initialise
        // the remaining wrapped objects; pad the object set with null instances.
        if self.isAtEnd {
            object = ASN1NullObject
        } else {
            if let type = type, ASN1DecodingContext.enumTypeHasMember(type, tag: self.object.tag, tagging: .implicit) {
                object = self.object
            } else {
                try self.validateCurrentIndex()
                object = try self.currentObject()
            }
            try self.validateCurrentIndex()
            try self.context.validateObject(object, codingPath: self.codingPath)
        }

        return object
    }

    private func _decodingUnkeyedSingleValue<T>(_ type: T.Type?,
                                                object: ASN1Object,
                                                _ block: (ASN1DecoderImpl.SingleValueContainer) throws -> T) throws -> T where T : Decodable {
        var decoded: Bool = false
        let container = self.nestedSingleValueContainer(object,
                                                        context: self.context.decodingSingleValue(type))
                
        let value = try ASN1DecoderImpl._decodingSingleValue(type, container: container, decoded: &decoded, block: block)
        
        if decoded {
            self.containers.append(container)
            self.currentIndex += 1
        }
        
        return value
    }

    func decodeNil() throws -> Bool {
        let object = try self._currentObject(nil)

        return try self._decodingUnkeyedSingleValue(nil, object: object) { container in
            return container.decodeNil()
        }
    }
    
    /*
    func decodeIfPresent<T>(_ type: T.Type) throws -> T? where T : Decodable {
        let object = try self._currentObject(type)

        if object.isNull || (object.constructed && object.data.items?.count == 0) {
            // FIXME set self.containers
            self.currentIndex += 1
            return nil
        }

        return try self._decodingUnkeyedSingleValue(type, object: object) { container in
            return try container.decode(type)
        }
    }
     */
    
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        let object = try self._currentObject(type)

        return try self._decodingUnkeyedSingleValue(type, object: object) { container in
            return try container.decode(type)
        }
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        try self.validateCurrentIndex()
        let currentObject = try self.currentObject()
        try self.context.validateObject(currentObject, container: true, codingPath: self.codingPath)

        let container = try ASN1DecoderImpl.KeyedContainer<NestedKey>(object: currentObject,
                                                                      codingPath: self.nestedCodingPath,
                                                                      userInfo: self.userInfo,
                                                                      context: self.context.decodingNestedContainer())
        
        self.containers.append(container)
        self.currentIndex += 1

        return KeyedDecodingContainer(container)
    }
    
    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        try self.validateCurrentIndex()
        let currentObject = try self.currentObject()
        try self.context.validateObject(currentObject, container: true, codingPath: self.codingPath)

        let container = try ASN1DecoderImpl.UnkeyedContainer(object: currentObject,
                                                             codingPath: self.nestedCodingPath,
                                                             userInfo: self.userInfo,
                                                             context: self.context.decodingNestedContainer())
        self.containers.append(container)
        self.currentIndex += 1

        return container
    }
    
    func superDecoder() throws -> Decoder {
        let context = DecodingError.Context(codingPath: self.codingPath,
                                            debugDescription: "ASN1DecoderImpl.UnkeyedContainer does not yet support super decoders")
        throw DecodingError.dataCorrupted(context)
    }
}
