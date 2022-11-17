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
    var taggingEnvironment: ASN1Tagging = .explicit
    var objectSetTypeDictionary: ASN1ObjectSetTypeDictionary? = nil
    
    var enumCodingState: ASN1EnumCodingState = .none
    var encodeAsSet = false
    var currentEnumType: Any.Type?
    var currentTag: ASN1DecodedTag? = nil
    var objectSetCodingContext: ASN1ObjectSetCodingContext?
    var automaticTaggingContext: ASN1AutomaticTaggingContext?

    static func tag(for type: Any.Type) -> ASN1DecodedTag {
        let type = lookThroughOptional(type)

        let tag: ASN1DecodedTag
        
        if let type = type as? ASN1TaggedTypeRepresentable.Type, let typeTag = type.tag {
            tag = typeTag
        } else if let type = type as? ASN1UniversalTagRepresentable.Type {
            tag = .universal(type.tagNo)
        } else if type is Set<AnyHashable>.Type || type is ASN1SetCodable.Type {
            tag = .universal(.set)
        } else {
            tag = .universal(.sequence)
        }
        
        return tag
    }
    
    private static func lookThroughOptional(_ type: Any.Type) -> Any.Type {
        let unwrappedType: Any.Type

        // look through optional
        if let wrappedType = type as? OptionalProtocol.Type {
            unwrappedType = wrappedType.wrappedType
        } else {
            unwrappedType = type
        }

        return unwrappedType
    }
    
    static func enumTypeHasMember<T>(_ type: T.Type, tag: ASN1DecodedTag, tagging: ASN1Tagging? = nil) -> Bool where T: Decodable {
        guard let metadata = reflect(Self.lookThroughOptional(type)) as? EnumMetadata else {
            return false
        }
        
        return metadata.descriptor.fields.records.contains {
              guard let fieldType = metadata.type(of: $0.mangledTypeName),
                    let wrappedFieldType = fieldType as? any ASN1TaggedWrappedValue.Type else {
                  return false
              }
            
            if let tagging = tagging, wrappedFieldType.tagging != tagging {
                return false
            }
            
            return tag == wrappedFieldType.tag
        }
    }
    
    func enumCodingKey<Key>(_ keyType: Key.Type, object: ASN1Object) -> Key? where Key: CodingKey {
        if let currentEnum = self.currentEnumType,
              let metadata = reflect(Self.lookThroughOptional(currentEnum)) as? EnumMetadata,
           let enumCase = metadata.descriptor.fields.records.first(where: {
               guard let fieldType = metadata.type(of: $0.mangledTypeName) else {
                   return false
               }
               
               return Self.tag(for: fieldType) == object.tag
           }) {
            // FIXME does not work with custom coding keys
            return Key(stringValue: enumCase.name)
        } else if let taggingContext = self.automaticTaggingContext {
            return taggingContext.selectTag(object.tag)
        } else {
            return nil
        }
    }

    static func isEnum<T>(_ type: T.Type) -> Bool {
        return reflect(lookThroughOptional(type)) is EnumMetadata
    }

    func decodingSingleValue<T>(_ type: T.Type?) -> Self where T: Decodable {
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
        // FIXME check constructed anyway?
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
                                                debugDescription: "Expected a constructed type, instead received tag \(object.tag)")
            throw DecodingError.dataCorrupted(context)
        }
    }
}
