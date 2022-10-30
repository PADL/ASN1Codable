//
//  UnkeyedEncodingContainer.swift
//  asn1bridgetest
//
//  Created by Luke Howard on 23/10/2022.
//

import Foundation
import ASN1Kit

extension ASN1EncoderImpl {
    final class UnkeyedContainer: ASN1EncodingContainer {
        private var containers: [ASN1EncodingContainer] = []

        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]
        var state: ASN1CodingState

        init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any], state: ASN1CodingState) {
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.state = state
        }

        var count: Int {
            return containers.count
        }
        
        var nestedCodingPath: [CodingKey] {
            return self.codingPath + [AnyCodingKey(intValue: self.count)!]
        }
    }
}

extension ASN1EncoderImpl.UnkeyedContainer: UnkeyedEncodingContainer {
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        let container = ASN1EncoderImpl.UnkeyedContainer(codingPath: self.nestedCodingPath,
                                                         userInfo: self.userInfo,
                                                         state: self.state)
        container.state.advanceCodingDepth()
        self.containers.append(container)
        
        return container
    }
    
    func encodeNil() throws {
        var container = self.nestedSingleValueContainer(state: ASN1CodingState())
        try container.encodeNil()
    }
    
    func encode<T>(_ value: T) throws where T : Encodable {
        let state = ASN1CodingState(depth: ASN1EncoderImpl.isEnum(value) ? 1 : 0)
        var container = self.nestedSingleValueContainer(state: state)
        try container.encode(value)
    }
    
    private func nestedSingleValueContainer(state: ASN1CodingState) -> SingleValueEncodingContainer {
        let container = ASN1EncoderImpl.SingleValueContainer(codingPath: self.nestedCodingPath, userInfo: self.userInfo, state: state)
        self.containers.append(container)

        return container
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = ASN1EncoderImpl.KeyedContainer<NestedKey>(codingPath: self.nestedCodingPath,
                                                                  userInfo: self.userInfo,
                                                                  state: self.state)
        container.state.advanceCodingDepth()
        self.containers.append(container)
        return KeyedEncodingContainer(container)
    }
    
    func superEncoder() -> Encoder {
        fatalError("not implemented")
    }
}

extension ASN1EncoderImpl.UnkeyedContainer {
    var object: ASN1Object? {
        let object: ASN1Object?

        if self.state.depth == 0 {
            let values = self.containers.compactMap { $0.object }
            
            object = ASN1Kit.create(tag: state.encodeAsSet ? .universal(.set) : .universal(.sequence),
                                    data: .constructed(values))
        } else {
            precondition(self.containers.count <= 1)
            object = self.containers.first?.object
            self.state.depth = 0
        }
        
        return object
    }
}

