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

enum ASN1EnumCodingState {
    case none
    case `enum`
    case enumCase
}

/// A protocol containing context for encoding or decoding a type, that is shared between
/// diffferent types of encoding or decoding containers. This is implemented as a value type.
protocol ASN1CodingContext {
    var taggingEnvironment: ASN1Tagging { get }
    var objectSetTypeDictionary: ASN1ObjectSetTypeDictionary? { get }

    var enumCodingState: ASN1EnumCodingState { get set }
    var encodeAsSet: Bool { get set }
    var objectSetCodingContext: ASN1ObjectSetCodingContext? { get set }
    var automaticTaggingContext: ASN1AutomaticTaggingContext? { get set }
}

extension ASN1CodingContext {
    mutating func nextEnumCodingState() {
        if self.enumCodingState == .enum {
            self.enumCodingState = .enumCase
        } else {
            self.enumCodingState = .none
        }
    }

    mutating func automaticTagging<T>(_ type: T.Type) {
        if self.taggingEnvironment == .automatic {
            self.automaticTaggingContext = ASN1AutomaticTaggingContext(T.self)
        } else {
            self.automaticTaggingContext = nil
        }
    }
}
