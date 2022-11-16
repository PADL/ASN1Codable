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
import Network
import ASN1Codable

extension Certificate {
  func `extension`<T>(_ extnID: ObjectIdentifier) -> T? where T: Codable {
      return self.tbsCertificate.extensions?.first(where: { $0.extnID == extnID })?.extnValue as? T
  }
}

extension DirectoryString: CustomStringConvertible {
    var description: String {
        switch self {
        case .ia5String(let ia5String):
            return String(describing: ia5String)
        case .printableString(let printableString):
            return String(describing: printableString)
        case .universalString(let universalString):
            return String(describing: universalString)
        case .utf8String(let utf8String):
            return String(describing: utf8String)
        case .bmpString(let bmpString):
            return String(describing: bmpString)
        }
    }
}


extension ObjectIdentifier {
    static var securityBundle = Bundle(path: "/System/Library/Frameworks/Security.framework")

    var friendlyName: String {
        do {
            let asn1 = try self.asn1encode(tag: nil).serialize().hexString(separator: " ")
            if let securityBundle = Self.securityBundle {
               return securityBundle.localizedString(forKey: asn1, value: nil, table: "OID")
            }
        } catch {
        }
        return self.description
    }
}

extension AttributeTypeAndValue: CustomStringConvertible {
    var description: String {
        return "\(self.type.friendlyName)=\(self.value)"
    }
}

extension Name: CustomStringConvertible {
    var description: String {
        switch self {
        case .rdnSequence(let rdns):
            return rdns.reversed().map { relativeDistinguishedName in
                relativeDistinguishedName.map { attributeValueAssertion in
                    String(describing: attributeValueAssertion)
                }.joined(separator: "+")
            }.joined(separator: ",")
        }

    }
}
extension GeneralName: CustomStringConvertible {
    var description: String {
        switch self {
        case .otherName(let otherName):
            return String(describing: otherName)
        case .rfc822Name(let rfc822Name):
            return String(describing: rfc822Name)
        case .dNSName(let dNSName):
            return String(describing: dNSName)
        case .directoryName(let directoryName):
            return String(describing: directoryName)
        case .uniformResourceIdentifier(let uri):
            return String(describing: uri)
        case .iPAddress(let ipAddress):
            if let ipv4Address = IPv4Address(ipAddress.wrappedValue) {
                return String(describing: ipv4Address)
            } else if let ipv6Address = IPv6Address(ipAddress.wrappedValue) {
                return String(describing: ipv6Address)
            } else {
                return String(describing: ipAddress.wrappedValue)
            }
        case .registeredID(let oid):
            return "\(oid.wrappedValue)"
        }
    }
}
