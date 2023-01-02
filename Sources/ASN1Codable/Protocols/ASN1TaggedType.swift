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

/// type itself is tagged
public protocol ASN1TaggedType: ASN1TypeMetadataRepresentable, Codable {}

public protocol ASN1TaggedTypeTagging: ASN1TaggedType {}

/// type itself is implicitly tagged
public protocol ASN1ImplicitlyTaggedType: ASN1TaggedTypeTagging {}
/// type itself is explicitly tagged
public protocol ASN1ExplicitlyTaggedType: ASN1TaggedTypeTagging {}

extension ASN1TaggedTypeTagging {
    static var tagging: ASN1Tagging? {
        if self is ASN1ImplicitlyTaggedType.Type {
            return .implicit
        } else if self is ASN1ExplicitlyTaggedType.Type {
            return .explicit
        } else {
            return nil
        }
    }
}

/// type members are automatically tagged
public protocol ASN1AutomaticallyTaggedType {}
