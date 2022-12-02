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
    var objectSetTypeDictionary: ASN1ObjectSetTypeDictionary?
    /// whether we are decoding an enumerated type
    var enumCodingState: ASN1EnumCodingState = .none
    /// whether we are decoding a struct that is has SET instead of SEQUENCE encoding
    var encodeAsSet = false
    /// the current enum type being decoded
    var currentEnumType: Any.Type?
    /// state for open type decoding
    var objectSetCodingContext: ASN1ObjectSetCodingContext?
    /// state for AUTOMATIC tagging
    var automaticTaggingContext: ASN1AutomaticTaggingContext?
    /// whether we are encoding a string-keyed Dictionary, for which keys should be written
    var isCodingKeyRepresentableDictionary = false

    /// returns the expected tag for a given type. Property wrappers can return their own type,
    /// UNIVERSAL types are represented by the tagNo property on ASN1UniversalTagRepresentable,
    /// everything else is a SET or a SEQUENCE
    static func tag(for type: Any.Type) -> ASN1DecodedTag {
        let type = self.lookThroughOptional(type)

        let tag: ASN1DecodedTag

        if let type = type as? ASN1TypeMetadataRepresentable.Type, let typeTag = type.metadata.tag {
            tag = typeTag
        } else if let type = type as? ASN1UniversalTagRepresentable.Type {
            tag = .universal(type.tagNo)
        } else if type is any BitStringOptionSet.Type {
            // FIXME: would be better to be able to make this ASN1UniversalTagRepresentable
            tag = .universal(.bitString)
        } else if type is ASN1SetCodable.Type {
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

    /*
       /// returns true if an enum type has a member with a particular tag
       static func enumTypeHasMember<T>(_ type: T.Type, with metadata: ASN1Metadata) -> Bool where T: Decodable {
           guard let enumMetadata = reflect(Self.lookThroughOptional(type)) as? EnumMetadata else {
               return false
           }

           return enumMetadata.descriptor.fields.records.contains {
                 guard let fieldType = enumMetadata.type(of: $0.mangledTypeName),
                       let wrappedFieldType = fieldType as? any ASN1TaggedWrappedValue.Type else {
                     return false
                 }

               return metadata == wrappedFieldType.metadata
           }
       }
     */

    /// synthesizes an CodingKey from a reflected enum case name
    ///
    /// only works with custom coding keys that conform to ASN1TagCodingKey and contain
    /// the tag number
    func codingKey<Key>(_: Key.Type, object: ASN1Object) -> Key? where Key: CodingKey {
        if let currentEnum = self.currentEnumType,
           let enumMetadata = reflect(Self.lookThroughOptional(currentEnum)) as? EnumMetadata,
           let enumCase = enumMetadata.descriptor.fields.records.first(where: {
               guard let fieldType = enumMetadata.type(of: $0.mangledTypeName) else {
                   return false
               }

               return Self.tag(for: fieldType) == object.tag
           }) {
            // FIXME: does not work with custom coding keys
            return Key(stringValue: enumCase.name)
        } else if let taggingContext = self.automaticTaggingContext {
            return taggingContext.selectTag(object.tag)
        } else {
            return nil
        }
    }

    /// returns true if the type is an enumearted type
    static func isEnum<T>(_ type: T.Type) -> Bool {
        reflect(self.lookThroughOptional(type)) is EnumMetadata
    }

    /// called before decoding a single value, maintains enum type state
    func decodingSingleValue<T>(_ type: T.Type) -> Self where T: Decodable {
        var context = self

        if Self.isEnum(type) {
            context.enumCodingState = .enum
            context.currentEnumType = type
        } else {
            context.nextEnumCodingState()
        }

        if context.enumCodingState == .none {
            context.currentEnumType = nil
        }

        return context
    }

    /// called before decoding a nested container
    func decodingNestedContainer() -> Self {
        var context = self
        context.nextEnumCodingState()
        return context
    }
}
