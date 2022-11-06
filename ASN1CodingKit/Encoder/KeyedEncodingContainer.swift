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

extension ASN1EncoderImpl {
    final class KeyedContainer<Key>: ASN1EncodingContainer where Key: CodingKey {
        private var containers: [ASN1EncodingContainer] = []

        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]
        var context: ASN1EncodingContext

        init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any],
             context: ASN1EncodingContext = ASN1EncodingContext()) {
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.context = context
        }
        
        func nestedCodingPath(forKey key: CodingKey) -> [CodingKey] {
            return self.codingPath + [key]
        }
    }
}

extension ASN1EncoderImpl.KeyedContainer: KeyedEncodingContainerProtocol {
    private func nestedSingleValueContainer(forKey key: Key,
                                            context: ASN1EncodingContext) -> SingleValueEncodingContainer {
        let container = ASN1EncoderImpl.SingleValueContainer(codingPath: self.nestedCodingPath(forKey: key),
                                                             userInfo: self.userInfo,
                                                             context: context)
        self.containers.append(container)
        return container
    }
    
    func encodeNil(forKey key: Key) throws {
        var container = self.nestedSingleValueContainer(forKey: key, context: ASN1EncodingContext())
        try container.encodeNil()
    }
    
    func encodeIfPresent<T>(_ value: T?, forKey key: Key) throws where T : Encodable {
        var container = self.nestedSingleValueContainer(forKey: key, context: context.encodingSingleValue(value))

        if let value = value {
            try container.encode(value)
        } else {
            try container.encodeNil()
        }
    }
    
    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        var container = self.nestedSingleValueContainer(forKey: key, context: context.encodingSingleValue(value))
        try container.encode(value)
    }
    
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let container = ASN1EncoderImpl.UnkeyedContainer(codingPath: self.nestedCodingPath(forKey: key),
                                                         userInfo: self.userInfo,
                                                         context: self.context)
        container.context.encodingNestedContainer()
        self.containers.append(container)

        return container
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type,
                                    forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = ASN1EncoderImpl.KeyedContainer<NestedKey>(codingPath: self.nestedCodingPath(forKey: key),
                                                                  userInfo: self.userInfo,
                                                                  context: self.context)
        container.context.encodingNestedContainer()
        self.containers.append(container)

        return KeyedEncodingContainer(container)
    }
    
    func superEncoder() -> Encoder {
        fatalError("Not yet implemented")
    }
    
    func superEncoder(forKey key: Key) -> Encoder {
        fatalError("Not yet implemented")
    }
}

extension ASN1EncoderImpl.KeyedContainer {
    var object: ASN1Object? {
        let object: ASN1Object?
        
        if self.context.enumCodingState != .none {
            precondition(self.containers.count <= 1)
            object = self.containers.first?.object
        } else {
            let values = self.containers.compactMap { $0.object }
            
            object = ASN1Kit.create(tag: self.context.encodeAsSet ? .universal(.set) : .universal(.sequence),
                                    data: .constructed(values))
        }
        
        return object
    }
}
