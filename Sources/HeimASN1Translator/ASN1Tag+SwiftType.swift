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

extension ASN1Tag: HeimASN1SwiftTypeRepresentable {
    var swiftType: String? {
        switch self {
        case .boolean:
            return "Bool"
        case .integer:
            return "Int"
        case .bitString:
            return "BitString"
        case .octetString:
            return "Data"
        case .null:
            return "Null"
        case .objectIdentifier:
            return "ObjectIdentifier"
        case .sequence:
            return "Array"
        case .set:
            return "Set"
        case .generalizedTime,
             .utcTime,
             .printableString,
             .graphicString,
             .visibleString,
             .generalString,
             .universalString,
             .bmpString,
             .ia5String,
             .utf8String:
            let wrapped = self.wrappedSwiftType!
            return "\(wrapped.0)<\(wrapped.1)>"
        default:
            return nil
        }
    }

    var wrappedSwiftType: (String, String)? {
        switch self {
        case .generalizedTime:
            return ("GeneralizedTime", "Date")
        case .utcTime:
            return ("UTCTime", "Date")
        case .graphicString:
            return ("GraphicString", "String")
        case .visibleString:
            return ("VisibleString", "String")
        case .printableString:
            return ("PrintableString", "String")
        case .generalString:
            return ("GeneralString", "String")
        case .universalString:
            return ("UniversalString", "String")
        case .bmpString:
            return ("BMPString", "String")
        case .ia5String:
            return ("IA5String", "String")
        case .utf8String:
            return ("UTF8String", "String")
        default:
            return nil
        }
    }
}
