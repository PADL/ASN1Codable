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

public protocol ASN1TagCodingKey: CodingKey {}

/// A coding key representing an explicit CONTEXT tag
public protocol ASN1ExplicitTagCodingKey: ASN1TagCodingKey {}
/// A coding key representing an implicit CONTEXT tag
public protocol ASN1ImplicitTagCodingKey: ASN1TagCodingKey {}

/// Note, currently APPLICATION, PRIVATE and UNIVERSAL tags are not supported
/// by ASN1TagCodingKey. They could be added later but they are not relevant to the
/// initial use case (PKIX) and would introduce unneeded complexity.

extension ASN1TagCodingKey {
    var asn1Type: ASN1Type {
        let tagging: ASN1Tagging
        
        if self is ASN1ImplicitTagCodingKey {
            tagging = .implicit
        } else {
            tagging = .explicit
        }
        
        precondition(self.intValue != nil && self.intValue! >= 0)
        return ASN1Type(tag: .taggedTag(UInt(self.intValue!)), tagging: tagging)
    }
}

/// The placeholder coding key is used to avoid recursing when encoding/decoding
/// tagged values.

internal struct ASN1PlaceholderCodingKey: CodingKey {
    private let wrappedValue: ASN1TagCodingKey

    init(_ wrappedValue: ASN1TagCodingKey) { self.wrappedValue = wrappedValue }
    init?(intValue: Int) { return nil }
    init?(stringValue: String) { return nil }

    var stringValue: String { return wrappedValue.stringValue }
    var intValue: Int? { return wrappedValue.intValue }
}
