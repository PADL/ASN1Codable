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

public protocol ASN1ExtensibleType {}

extension CodingUserInfoKey {
    /// If `true`, require explicit extensibility markers (through conformance of the `ASN1ExtensibleType`
    /// protocol) to accept ASN.1 objects with more fields than the equivalent Swift structure.
    public static var ASN1ExplicitExtensibilityMarkerRequired: Self {
        Self(rawValue: "ASN1ExplicitExtensibilityMarkerRequired")!
    }
}
