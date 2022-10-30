//
//  KeyedEncodingContainer.swift
//  asn1bridgetest
//
//  Created by Luke Howard on 23/10/2022.
//

import Foundation
import ASN1Kit

extension ASN1EncoderImpl {
    final class KeyedContainer<Key>: ASN1EncodingContainer where Key: CodingKey {
        private var containers: [ASN1EncodingContainer] = []

        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]
        var state: ASN1CodingState

        init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any], state: ASN1CodingState) {
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.state = state
        }
        
        func nestedCodingPath(forKey key: CodingKey) -> [CodingKey] {
            return self.codingPath + [key]
        }
    }
}

extension ASN1EncoderImpl.KeyedContainer: KeyedEncodingContainerProtocol {
    private func nestedSingleValueContainer(forKey key: Key,
                                            state: ASN1CodingState) -> SingleValueEncodingContainer {
        let container = ASN1EncoderImpl.SingleValueContainer(codingPath: self.nestedCodingPath(forKey: key),
                                                             userInfo: self.userInfo,
                                                             state: state)
        self.containers.append(container)
        return container
    }
    
    func encodeNil(forKey key: Key) throws {
        var container = self.nestedSingleValueContainer(forKey: key, state: ASN1CodingState())
        try container.encodeNil()
    }
    
    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        let state = ASN1CodingState(depth: ASN1EncoderImpl.isEnum(value) ? 1 : 0)
        var container = self.nestedSingleValueContainer(forKey: key, state: state)
        try container.encode(value)
    }
    
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let container = ASN1EncoderImpl.UnkeyedContainer(codingPath: self.nestedCodingPath(forKey: key),
                                                         userInfo: self.userInfo,
                                                         state: self.state)
        container.state.advanceCodingDepth()
        self.containers.append(container)

        return container
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type,
                                    forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = ASN1EncoderImpl.KeyedContainer<NestedKey>(codingPath: self.nestedCodingPath(forKey: key),
                                                                  userInfo: self.userInfo,
                                                                  state: self.state)
        container.state.advanceCodingDepth()
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
        
        // FIXME enum with associated values
        
        if self.state.depth == 0 {
            let values = self.containers.compactMap { $0.object }
            
            object = ASN1Kit.create(tag: state.encodeAsSet ? .universal(.set) : .universal(.sequence),
                                    data: .constructed(values))
        } else {
            precondition(self.containers.count <= 1)
            object = self.containers.first?.object
        }
        
        return object
    }
}
