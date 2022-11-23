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

    var componentAttributes: NSDictionary? {
        guard let attributes: ASN1TaggedDictionary = self.extension(id_apple_ce_appleComponentAttributes) else {
            return nil
        }

        return attributes._bridgeToObjectiveC()
    }
    
    var subjectAltName: [GeneralName]? {
        return self.extension(id_x509_ce_subjectAltName)
    }
    
    var serialNumberData: CFData? {
        do {
            return try ASN1Encoder().encode(self.tbsCertificate.serialNumber) as CFData
        } catch {
            return nil
        }
    }
}

extension ObjectIdentifier {
    static var securityBundle = Bundle(path: "/System/Library/Frameworks/Security.framework")

    var friendlyName: String {
        do {
            let asn1 = try self.asn1encode(tag: nil).serialize().hexString(separator: " ")
            if let securityBundle = Self.securityBundle {
                let friendlyName = securityBundle.localizedString(forKey: asn1, value: nil, table: "OID")
                if friendlyName != asn1 {
                    return friendlyName
                }
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

extension OtherName: CustomStringConvertible {
    public var description: String {
        return "\(self.type_id.friendlyName)={\(self.value)}"
    }
}

extension Name: CustomStringConvertible {
    var description: String {
        switch self {
        case .rdnSequence(let rdns):
            return ([""] + rdns.map { relativeDistinguishedName in
                relativeDistinguishedName.map { attributeValueAssertion in
                    String(describing: attributeValueAssertion)
                }.joined(separator: ",")
            }).joined(separator: "/")
        }

    }
}

// FIXME add synthesis of these to the translator

extension Name: Equatable {
    static func == (lhs: Name, rhs: Name) -> Bool {
        if case .rdnSequence(let lhs) = lhs,
           case .rdnSequence(let rhs) = rhs {
            return lhs == rhs
        } else {
            return false
        }
    }
}

extension Name: Hashable {
    func hash(into hasher: inout Hasher) {
        if case .rdnSequence(let self) = self {
            hasher.combine(self)
        }
    }
}

// FIXME OpenSSL style
extension GeneralName: CustomStringConvertible {
    var description: String {
        switch self {
        case .otherName(let otherName):
            return "OtherName:\(otherName)"
        case .rfc822Name(let rfc822Name):
            return "email:\(rfc822Name)"
        case .dNSName(let dNSName):
            return "DNS:\(dNSName)"
        case .directoryName(let directoryName):
            return "DirName:\(directoryName)"
        case .uniformResourceIdentifier(let uri):
            return "URI:\(uri)"
        case .iPAddress(let ipAddress):
            if let ipv4Address = IPv4Address(ipAddress) {
                return "IP Address:\(ipv4Address)"
            } else if let ipv6Address = IPv6Address(ipAddress) {
                return "IP Address:\(ipv6Address)"
            } else {
                return "IP Address:<unknown>"
            }
        case .registeredID(let rid):
            return "RID:\(rid.friendlyName)"
        }
    }
}

extension HardwareModuleName: CustomStringConvertible {
    var description: String {
        return "\(self.hwType.friendlyName)=\(self.hwSerialNum.base64EncodedString())"
    }
}