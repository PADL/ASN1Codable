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
import AnyCodable

extension Certificate {
  func `extension`<T>(_ extnID: ObjectIdentifier) -> T? where T: Codable {
    self.tbsCertificate.extensions?.first { $0.extnID == extnID }?.extnValue as? T
  }

  var componentAttributes: NSDictionary? {
    guard let attributes: AppleComponentAttributes = self.extension(id_apple_ce_appleComponentAttributes) else {
      return nil
    }

    return attributes.wrappedValue.mapValues {
      $0.value as? NSObject
    } as NSDictionary
  }

  // swiftlint:disable discouraged_optional_collection
  var subjectAltName: [GeneralName]? {
    self.extension(id_x509_ce_subjectAltName)
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
    } catch {}

    return self.description
  }
}

extension AttributeTypeAndValue: CustomStringConvertible {
  var description: String {
    "\(self.type.friendlyName)=\(self.value)"
  }
}

extension Name: CustomStringConvertible {
  var description: String {
    switch self {
    case .rdnSequence(let rdns):
      return ([""] + rdns.map { $0.map { String(describing: $0) }.joined(separator: ",") }).joined(separator: "/")
    }
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

// FIXME: OpenSSL style
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

extension OtherName: CustomStringConvertible {
  public var description: String {
    "\(self.type_id.friendlyName)={\(self.value)}"
  }
}

extension HardwareModuleName: CustomStringConvertible {
  var description: String {
    "\(self.hwType.friendlyName)=\(self.hwSerialNum.base64EncodedString())"
  }
}

extension KRB5PrincipalName: CustomStringConvertible {
  public var description: String {
    "\(self.principalName.name_string.map { String(describing: $0) }.joined(separator: "/"))@\(self.realm)"
  }
}
