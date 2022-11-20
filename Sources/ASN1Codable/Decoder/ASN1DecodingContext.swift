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
    /// default tagging environment
    var taggingEnvironment: ASN1Tagging = .explicit
    /// custom object set type dictionary
    var objectSetTypeDictionary: ASN1ObjectSetTypeDictionary? = nil
    /// whether we are decoding an enumerated type
    var enumCodingState: ASN1EnumCodingState = .none
    /// whether we are decoding a struct that is has SET instead of SEQUENCE encoding
    var encodeAsSet = false
    /// the current enum type being decoded
    var currentEnumType: Any.Type?
    /// the innermost decoded tag: this is used for allowing any string type to be represented by an untagged String
    var currentTag: ASN1DecodedTag? = nil
    /// state for open type decoding
    var objectSetCodingContext: ASN1ObjectSetCodingContext?
    /// state for AUTOMATIC tagging
    var automaticTaggingContext: ASN1AutomaticTaggingContext?

    /// returns the expected tag for a given type. Property wrappers can return their own type,
    /// UNIVERSAL types are represented by the tagNo property on ASN1UniversalTagRepresentable,
    /// everything else is a SET or a SEQUENCE
    static func tag(for type: Any.Type) -> ASN1DecodedTag {
        let type = lookThroughOptional(type)

        let tag: ASN1DecodedTag
        
        if let type = type as? ASN1TaggedTypeRepresentable.Type, let typeTag = type.metatype.tag {
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
    
    /// looks through an optional type to return the wrapped type
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
    
    /// returns true if an enum type has a member with a particular tag
    static func enumTypeHasMember<T>(_ type: T.Type, with metatype: ASN1Metatype) -> Bool where T: Decodable {
        guard let metadata = reflect(Self.lookThroughOptional(type)) as? EnumMetadata else {
            return false
        }
        
        return metadata.descriptor.fields.records.contains {
              guard let fieldType = metadata.type(of: $0.mangledTypeName),
                    let wrappedFieldType = fieldType as? any ASN1TaggedWrappedValue.Type else {
                  return false
              }
            
            return metatype == wrappedFieldType.metatype
        }
    }
    
    /// synthesizes an CodingKey from a reflected enum case name. Does not work with custom coding keys.
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

    /// returns true if the type is an enumearted type
    static func isEnum<T>(_ type: T.Type) -> Bool {
        return reflect(lookThroughOptional(type)) is EnumMetadata
    }

    /// called before decoding a single value, maintains enum type state
    func decodingSingleValue<T>(_ type: T.Type) -> Self where T: Decodable {
        var context = self
        context.nextEnumCodingState()

        if Self.isEnum(type) {
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
