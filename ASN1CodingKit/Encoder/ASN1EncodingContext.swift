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
    var enumCodingState: ASN1EnumCodingState = .none
    var encodeAsSet = false
    var objectSetEncodingContext: ASN1ObjectSetEncodingContext?

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

