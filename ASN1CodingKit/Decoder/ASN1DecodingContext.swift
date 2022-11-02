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

struct ASN1DecodingContext: ASN1CodingContext {
    var enumCodingState: ASN1EnumCodingState = .none
    var encodeAsSet = false
    var currentEnumType: Any.Type?
    
    private func tag(for type: Any.Type) -> ASN1DecodedTag {
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
    
    func enumCodingKey(_ object: ASN1Object) -> CodingKey? {
        guard let currentEnum = self.currentEnumType as? ASN1ChoiceCodable.Type else {
            return nil
        }

        guard let codingKey = currentEnum.allCodingKeys.first(where: {
            guard let innerType = currentEnum.type(for: $0) else {
                return false
            }
            
            let tag = self.tag(for: innerType)
            return tag == object.tag
        }) else {
            return nil
        }
        
        return codingKey
    }

    /*
     Consider a CHOICE such as
     
             Time ::= CHOICE {
                  utcTime        UTCTime,
                  generalTime    GeneralizedTime
             }
     
     or
     
             TESTChoice1 ::= CHOICE {
                     i1[1]   INTEGER (-2147483648..2147483647),
                     i2[2]   INTEGER (-2147483648..2147483647),
                     ...
             }

     CHOICE is encoded as the selected type with the discriminant implied by
     the tag of the encoded item (which must be unique).
     
             public enum Time: Codable {
                 case utcTime(UTCTime)
                 case generalTime(GeneralizedTime)
             }

     We need to map the tag to both the coding key (e.g. utcTime above) and the
     type (UTCTime).
     
     We could enhance codingKeys on enum types to return a custom coding key,
     for example:

        struct ASN1CodingKey: CodingKey {
            var type: Any.Type
        }
     
        enum CodingKey: CodingKeys {
            case utcTime = ASN1CodingKey(type: UTCTime.self, stringValue: "utcTime")
            case generalTime = ASN1CodingKey(type: GeneralizedTime.self, stringValue: "generalTime")
        }
     
     i.e. we need to take type T and look at mirror.children and for each label and type
     
     */

    func decodingSingleValue<T>(_ type: T.Type) -> Self {
        var context = self
        context.nextEnumCodingState()

        if ASN1DecoderImpl.isEnum(type) {
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
        
        if object.constructed {
            if self.encodeAsSet && object.tag != .universal(.set) {
                let context = DecodingError.Context(codingPath: codingPath,
                                                    debugDescription: "Expected a SET, but received tag \(object.tag)")
                throw DecodingError.dataCorrupted(context)
            } else if object.tag != .universal(.sequence) {
                let context = DecodingError.Context(codingPath: codingPath,
                                                    debugDescription: "Expected a SEQUENCE, but received tag \(object.tag)")
                throw DecodingError.dataCorrupted(context)
            }
        } else if self.enumCodingState != .enum {
            let context = DecodingError.Context(codingPath: codingPath,
                                                debugDescription: "Expected a SET or SEQUENCE, instead received tag \(object.tag)")
            throw DecodingError.dataCorrupted(context)
        }
    }
}
