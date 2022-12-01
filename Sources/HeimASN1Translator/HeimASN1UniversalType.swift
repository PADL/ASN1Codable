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

enum HeimASN1UniversalType: String, Codable, HeimASN1SwiftTypeRepresentable, HeimASN1TagRepresentable {
    case implicit = "IMPLICIT"
    case boolean = "BOOLEAN"
    case integer = "INTEGER"
    case bitString = "BIT STRING"
    case octetString = "OCTET STRING"
    case null = "NULL"
    case objectIdentifier = "OBJECT IDENTIFIER"
    case external = "EXTERNAL"
    case enumerated = "ENUMERATED"
    case sequence = "SEQUENCE"
    case set = "SET"
    case sequenceOf = "SEQUENCE OF"
    case setOf = "SET OF"
    case numericString = "NumericString"
    case printableString = "PrintableString"
    case teletexString = "TeletexString"
    case videotexString = "VideotexString"
    case ia5String = "IA5String"
    case utcTime = "UTCTime"
    case generalizedTime = "GeneralizedTime"
    case graphicString = "GraphicString"
    case visibleString = "VisibleString"
    case generalString = "GeneralString"
    case universalString = "UniversalString"
    case bmpString = "BMPString"
    case utf8String = "UTF8String"
    case choice = "CHOICE"

    var swiftType: String? {
        self.asn1Tag.swiftType
    }

    var tag: ASN1DecodedTag? {
        .universal(self.asn1Tag)
    }

    private var asn1Tag: ASN1Tag {
        let tag: ASN1Tag

        switch self {
        case .implicit:
            tag = .implicit
        case .boolean:
            tag = .boolean
        case .integer:
            tag = .integer
        case .bitString:
            tag = .bitString
        case .octetString:
            tag = .octetString
        case .null:
            tag = .null
        case .objectIdentifier:
            tag = .objectIdentifier
        case .external:
            tag = .external
        case .enumerated:
            tag = .enumerated
        case .sequence, .sequenceOf:
            tag = .sequence
        case .set, .setOf:
            tag = .set
        case .numericString:
            tag = .numericString
        case .printableString:
            tag = .printableString
        case .teletexString:
            tag = .t61String
        case .generalString:
            tag = .generalString
        case .utcTime:
            tag = .utcTime
        case .generalizedTime:
            tag = .generalizedTime
        case .universalString:
            tag = .universalString
        case .ia5String:
            tag = .ia5String
        case .utf8String:
            tag = .utf8String
        case .bmpString:
            tag = .bmpString
        case .visibleString:
            tag = .visibleString
        case .choice:
            tag = .implicit
        default:
            fatalError("unsupported tag \(self)")
        }
        return tag
    }
}
