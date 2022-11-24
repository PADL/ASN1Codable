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
    case t61String = "T61String"
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
        return self.asn1Tag.swiftType
    }

    var tag: ASN1DecodedTag? {
        return .universal(self.asn1Tag)
    }

    private var asn1Tag: ASN1Tag {
        let tag: ASN1Tag

        switch self {
        case .implicit:
            tag = .implicit
            break
        case .boolean:
            tag = .boolean
            break
        case .integer:
            tag = .integer
            break
        case .bitString:
            tag = .bitString
            break
        case .octetString:
            tag = .octetString
            break
        case .null:
            tag = .null
            break
        case .objectIdentifier:
            tag = .objectIdentifier
            break
        case .external:
            tag = .external
            break
        case .enumerated:
            tag = .enumerated
            break
        case .sequence:
            fallthrough
        case .sequenceOf:
            tag = .sequence
            break
        case .set:
            fallthrough
        case .setOf:
            tag = .set
            break
        case .numericString:
            tag = .numericString
            break
        case .printableString:
            tag = .printableString
            break
        case .generalString:
            tag = .generalString
            break
        case .utcTime:
            tag = .utcTime
            break
        case .generalizedTime:
            tag = .generalizedTime
            break
        case .universalString:
            tag = .universalString
            break
        case .ia5String:
            tag = .ia5String
            break
        case .utf8String:
            tag = .utf8String
            break
        case .bmpString:
            tag = .bmpString
            break
        case .choice:
            tag = .implicit
            break
        default:
            fatalError("unsupported tag \(self)")
            break
        }
        return tag
    }
}

