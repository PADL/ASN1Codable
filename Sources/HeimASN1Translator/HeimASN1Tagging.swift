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

enum HeimASN1TaggingEnvironment: String, Codable, HeimASN1SwiftTypeRepresentable {
  case explicit = "EXPLICIT"
  case implicit = "IMPLICIT"
  case automatic = "AUTOMATIC"

  var swiftType: String? {
    switch self {
    case .explicit:
      return "ASN1Codable.ASN1ExplicitTagging"
    case .implicit:
      return "ASN1Codable.ASN1ImplicitTagging"
    default:
      return "ASN1Codable.ASN1DefaultTagging"
    }
  }

  var initializer: String {
    switch self {
    case .explicit:
      return ".explicit"
    case .implicit:
      return ".implicit"
    case .automatic:
      return ".automatic"
    }
  }
}

protocol HeimASN1TagRepresentable {
  var tag: ASN1DecodedTag? { get }
}

enum HeimASN1TagClass: String, Codable {
  case universal = "UNIVERSAL"
  case application = "APPLICATION"
  case context = "CONTEXT"
  case `private` = "PRIVATE"
}
