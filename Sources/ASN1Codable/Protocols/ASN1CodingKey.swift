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

public protocol ASN1CodingKey: CodingKey {
    var metadata: ASN1Metadata { get }
}

public protocol ASN1ContextTagCodingKey: ASN1CodingKey {}

/// A coding key representing an explicit CONTEXT tag
public protocol ASN1ExplicitTagCodingKey: ASN1ContextTagCodingKey {}

extension ASN1ExplicitTagCodingKey {
    public var metadata: ASN1Metadata {
        ASN1Metadata(tag: .taggedTag(UInt(self.intValue!)), tagging: .explicit)
    }
}

/// A coding key representing an implicit CONTEXT tag
public protocol ASN1ImplicitTagCodingKey: ASN1ContextTagCodingKey {}

extension ASN1ImplicitTagCodingKey {
    public var metadata: ASN1Metadata {
        ASN1Metadata(tag: .taggedTag(UInt(self.intValue!)), tagging: .implicit)
    }
}

/// A coding key representing any kind of tag or metadata
public protocol ASN1MetadataCodingKey: ASN1CodingKey {
    static func metadata(forKey key: Self) -> ASN1Metadata?
}

extension ASN1MetadataCodingKey {
    public var metadata: ASN1Metadata {
        Self.metadata(forKey: self) ?? ASN1Metadata(tag: nil)
    }
}

/// The placeholder coding key is used to avoid recursing when encoding/decoding
/// tagged values.

struct ASN1PlaceholderCodingKey: CodingKey {
    private let wrappedValue: ASN1CodingKey

    init(_ wrappedValue: ASN1CodingKey) { self.wrappedValue = wrappedValue }
    init?(intValue _: Int) { nil }
    init?(stringValue _: String) { nil }

    var stringValue: String { self.wrappedValue.stringValue }
    var intValue: Int? { self.wrappedValue.intValue }
}

struct ASN1MetadataPlaceholderCodingKey: ASN1CodingKey {
    let metadata: ASN1Metadata
    var intValue: Int?

    init(metadata: ASN1Metadata) {
        self.metadata = metadata
    }

    init(tag: ASN1DecodedTag) {
        self.metadata = ASN1Metadata(tag: tag)
    }

    init?(intValue: Int) {
        self.intValue = intValue
        self.metadata = ASN1Metadata(tag: .taggedTag(UInt(intValue)))
    }

    init?(stringValue: String) {
        let tag = ASN1DecodedTag(tagString: stringValue)
        self.metadata = ASN1Metadata(tag: tag)
    }

    var stringValue: String {
        self.metadata.tag!.tagString
    }
}
