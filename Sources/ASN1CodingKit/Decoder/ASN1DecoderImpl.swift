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

internal final class ASN1DecoderImpl {
    fileprivate var container: ASN1DecodingContainer?
    
    let object: ASN1Object
    let codingPath: [CodingKey]
    let userInfo: [CodingUserInfoKey: Any]
    let context: ASN1DecodingContext
    
    init(object: ASN1Object,
         codingPath: [CodingKey] = [],
         userInfo: [CodingUserInfoKey: Any] = [:],
         taggingEnvironment: ASN1Tagging? = nil,
         objectSetTypeDictionary: ASN1ObjectSetTypeDictionary? = nil) {
        self.object = object
        self.codingPath = codingPath
        self.userInfo = userInfo
        self.context = ASN1DecodingContext(taggingEnvironment: taggingEnvironment ?? .explicit, objectSetTypeDictionary: objectSetTypeDictionary)
    }
    
    init(object: ASN1Object,
         codingPath: [CodingKey] = [],
         userInfo: [CodingUserInfoKey: Any] = [:],
         context: ASN1DecodingContext = ASN1DecodingContext()) {
        self.object = object
        self.codingPath = codingPath
        self.userInfo = userInfo
        self.context = context
    }
}

extension ASN1DecoderImpl: Decoder {
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        precondition(self.container == nil)

        let container = try KeyedContainer<Key>(object: self.object,
                                                codingPath: self.codingPath,
                                                userInfo: self.userInfo,
                                                context: self.context)
        self.container = container
                
        return KeyedDecodingContainer(container)
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        precondition(self.container == nil)
        
        let container = try UnkeyedContainer(object: self.object,
                                             codingPath: self.codingPath,
                                             userInfo: self.userInfo,
                                             context: self.context)
        self.container = container

        return container
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        precondition(self.container == nil)

        let container = SingleValueContainer(object: self.object,
                                             codingPath: self.codingPath,
                                             userInfo: self.userInfo,
                                             context: self.context)
        self.container = container
                
        return container
    }
}

extension ASN1DecoderImpl {
    private static func isNilOrWrappedNil<T>(_ value: T) -> Bool where T : Decodable {
        let wrappedValue: any Decodable
        
        // FIXME check non-wrapped optionals? because we need to wrap them to disambiguate in ASN.1
        
        if let value = value as? any ASN1TaggedWrappedValue {
            wrappedValue = value.wrappedValue
        } else {
            wrappedValue = value
        }
        
        if let wrappedValue = wrappedValue as? ExpressibleByNilLiteral,
            let wrappedValue = wrappedValue as? Optional<Decodable>,
            case .none = wrappedValue {
            return true
        } else {
            return false
        }
    }
    
    private static func isDefaultValue<T>(_ value: T) -> Bool where T : Decodable {
        guard let value = value as? DecodableDefaultRepresentable else {
            return false
        }
        
        return value.isDefaultValue
    }
    
    static func decodingSingleValue<T>(_ type: T.Type?,
                                        container: ASN1DecoderImpl.SingleValueContainer,
                                        decoded: inout Bool,
                                        block: (ASN1DecoderImpl.SingleValueContainer) throws -> T) throws -> T where T : Decodable {
        decoded = false
        
        do {
            let value = try block(container)
            
            if !self.isNilOrWrappedNil(value) && !self.isDefaultValue(value) {
                decoded = true
            }

            return value
        } catch {
            let isOptional = type is OptionalProtocol.Type

            if isOptional, let error = error as? DecodingError, case .typeMismatch(_, _) = error {
                return () as! T
            } else {
                throw error
            }
        }
    }
}
