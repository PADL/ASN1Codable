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

extension CodingUserInfoKey {
    /// If `true`, require explicit extensibility markers (through conformance of the `ASN1ExtensibleType`
    /// protocol) to accept ASN.1 objects with more fields than the equivalent Swift structure.
    public static var ASN1ExplicitExtensibilityMarkerRequired: Self {
        Self(rawValue: "com.padl.ASN1Codable.ASN1ExplicitExtensibilityMarkerRequired")!
    }

    /// if `true`, disable sorting of SETs (producing BER instead of DER)
    public static var ASN1DisableSetSorting: Self {
        Self(rawValue: "com.padl.ASN1Codable.ASN1DisableSetSorting")!
    }
}
