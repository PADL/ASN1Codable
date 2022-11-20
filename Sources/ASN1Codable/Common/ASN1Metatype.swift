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

/// internal defintiion of a tag and tagging environment tuple. In the future this could also contain things
/// like range limits and default values. Currently synthesised from property wrapper Swift type metadata
/// but could also be associated with coding keys
public struct ASN1Metatype: Equatable {
    var tag: ASN1DecodedTag?
    var tagging: ASN1Tagging?
}
