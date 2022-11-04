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
import Echo

struct ASN1DecodingContext: ASN1CodingContext {
    var enumCodingState: ASN1EnumCodingState = .none
    var encodeAsSet = false
    var currentEnumType: Any.Type?
    var objectSetDecodingContext: ASN1ObjectSetDecodingContext?
    
    func tag(for type: Any.Type) -> ASN1DecodedTag {
        if let type = type as? OptionalProtocol.Type {
            return self.tag(for: type.wrappedType)
        }

        if let type = type as? ASN1UniversalTagRepresentable.Type {
            return .universal(type.tagNo)
        } else if let type = type as? ASN1TaggedTypeRepresentable.Type, let tag = type.tag {
            return tag
        } else if type is Set<AnyHashable>.Type || type is ASN1EncodeAsSetType.Type {
            return .universal(.set)
        } else {
            return .universal(.sequence)
        }
    }
    
    func enumCodingKey<Key>(_ keyType: Key.Type, object: ASN1Object) -> Key? where Key: CodingKey {
        guard let currentEnum = self.currentEnumType,
              let metadata = reflect(currentEnum) as? EnumMetadata,
              let enumCase = metadata.descriptor.fields.records.first(where: {
            guard let fieldType = metadata.type(of: $0.mangledTypeName) else {
                return false
            }

            return self.tag(for: fieldType) == object.tag
        }) else {
            return nil
        }
            
        // FIXME does not work with custom coding keys
        return Key(stringValue: enumCase.name)
    }

    private static func isEnum<T>(_ type: T.Type) -> Bool {
        return reflect(type) is EnumMetadata
    }

    func decodingSingleValue<T>(_ type: T.Type?) -> Self {
        var context = self
        context.nextEnumCodingState()

        if let type = type, Self.isEnum(type) {
            context.enumCodingState = .enum
            context.currentEnumType = type
        } else {
            context.enumCodingState = .none
            context.currentEnumType = nil
        }
        
        return context
    }
    
    func decodingNestedContainer() -> Self {
        var context = self
        context.nextEnumCodingState()
        return context
    }
    
    func validateObject(_ object: ASN1Object,
                        container: Bool = false,
                        codingPath: [CodingKey]) throws {
        guard container else {
            return
        }
                
        if object.constructed, object.tag.isUniversal {
            if self.encodeAsSet && object.tag != .universal(.set) {
                let context = DecodingError.Context(codingPath: codingPath,
                                                    debugDescription: "Expected \(ASN1DecodedTag.universal(.set)), but received tag \(object.tag)")
                throw DecodingError.dataCorrupted(context)
            } else if object.tag != .universal(.sequence) {
                let context = DecodingError.Context(codingPath: codingPath,
                                                    debugDescription: "Expected a \(ASN1DecodedTag.universal(.sequence)), but received tag \(object.tag)")
                throw DecodingError.dataCorrupted(context)
            }
        } else if self.enumCodingState != .enum {
            let context = DecodingError.Context(codingPath: codingPath,
                                                debugDescription: "Expected a set or sequence, instead received tag \(object.tag)")
            throw DecodingError.dataCorrupted(context)
        }
    }
}
