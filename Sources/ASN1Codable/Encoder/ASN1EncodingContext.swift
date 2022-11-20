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

struct ASN1EncodingContext: ASN1CodingContext {
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

    private static func isEnum<T>(_ value: T) -> Bool {
        let reflection = Mirror(reflecting: value)
        return reflection.displayStyle == .enum
    }

    func encodingSingleValue<T>(_ value: T) -> Self {
        var context = self

        if Self.isEnum(value) {
            context.enumCodingState = .enum
        } else {
            context.enumCodingState = .none
        }
        
        return context
    }
    
    mutating func encodingNestedContainer() {
        self.nextEnumCodingState()
    }
}

