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

@propertyWrapper
public struct ASN1PrivateTagged<Tag, Tagging, Value>: Codable, ASN1TaggedValue
    where Tag: ASN1TagNumberRepresentable,
    Tagging: ASN1TaggingRepresentable,
    Value: Codable {
    public static var tagNumber: Tag.Type { Tag.self }

    public var wrappedValue: Value

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public init() where Value: ExpressibleByNilLiteral {
        self.wrappedValue = nil
    }

    public static var metadata: ASN1Metadata {
        ASN1Metadata(tag: .privateTag(tagNumber.tagNo), tagging: Tagging.tagging)
    }
}

extension ASN1PrivateTagged: Equatable where Value: Equatable {}

extension ASN1PrivateTagged: Hashable where Value: Hashable {}

public protocol ASN1PrivateTaggedType: ASN1TaggedType {}

extension ASN1PrivateTaggedType {
    public static var metadata: ASN1Metadata {
        ASN1Metadata(tag: .privateTag(self.tagNumber),
                     tagging: self is ASN1ImplicitlyTaggedType.Type ? .implicit : nil)
    }
}
