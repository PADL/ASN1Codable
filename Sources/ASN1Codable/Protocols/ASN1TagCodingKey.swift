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

// coding key representing an explicit context tag in a struct or enum
public protocol ASN1TagCodingKey: CodingKey {}

public protocol ASN1ExplicitTagCodingKey: ASN1TagCodingKey {}
public protocol ASN1ImplicitTagCodingKey: ASN1TagCodingKey {}

extension ASN1TagCodingKey {
    var asn1Type: ASN1Type {
        let tagging: ASN1Tagging
        
        if self is ASN1ImplicitTagCodingKey {
            tagging = .implicit
        } else {
            tagging = .explicit
        }
        
        return ASN1Type(tag: .taggedTag(UInt(self.intValue!)), tagging: tagging)
    }
}

internal struct ASN1PlaceholderCodingKey: CodingKey {
    let key: ASN1TagCodingKey

    init(_ key: ASN1TagCodingKey) { self.key = key }
    init?(intValue: Int) { return nil }
    init?(stringValue: String) { return nil }

    var stringValue: String { return key.stringValue }
    var intValue: Int? { return key.intValue }
}
