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

// for applying a tag/flag to an entire type rather than a member

public protocol ASN1TaggedType: ASN1TypeMetadataRepresentable, Codable {
    static var tagNumber: UInt { get }
}

// for when the entire type is implicitly tagged
public protocol ASN1ImplicitlyTaggedType {}
public protocol ASN1ExplicitlyTaggedType {}
public protocol ASN1AutomaticallyTaggedType {}

extension ASN1TaggedType {
    static var tagging: ASN1Tagging? {
        if self is ASN1ImplicitlyTaggedType.Type {
            return .implicit
        } else if self is ASN1ExplicitlyTaggedType {
            return .explicit
        } else if self is ASN1AutomaticallyTaggedType {
            return .automatic
        } else {
            return nil
        }
    }
}
