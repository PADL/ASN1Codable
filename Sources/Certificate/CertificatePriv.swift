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
import ASN1Codable
import Network

@_cdecl("CertificateCreateWithBytes")
public func CertificateCreateWithBytes(_ allocator: CFAllocator!,
                                       _ bytes: [UInt8],
                                       _ der_length: CFIndex) -> CertificateRef? {
    let data = Data(bytes: bytes, count: der_length)
    return Certificate.create(with: data)
}

@_cdecl("CertificateCreateWithKeychainItem")
public func CertificateCreateWithKeychainItem(_ allocator: CFAllocator!,
                                              _ der_certificate: CFData,
                                              _ keychain_item: CFTypeRef) -> CertificateRef? {
    guard let certificate: CertificateRef = Certificate.create(with: der_certificate as Data) else {
        return nil
    }
    (Certificate._fromCertificateRef(certificate))!._keychain_item = keychain_item
    return certificate
}

@_cdecl("CertificateCopyComponentAttributes")
public func CertificateCopyComponentAttributes(_ certificate: CertificateRef?) -> CFDictionary? {
    guard let certificate = Certificate._fromCertificateRef(certificate) else { return nil }

    return certificate.componentAttributes
}

@_cdecl("CertificateGetSubjectKeyID")
public func CertificateGetSubjectKeyID(_ certificate: CertificateRef?) -> CFData? {
    guard let certificate = Certificate._fromCertificateRef(certificate) else { return nil }
    guard let subjectKeyID: Data = certificate.extension(id_x509_ce_subjectKeyIdentifier) else { return nil }

    return subjectKeyID as CFData
}

@_cdecl("CertificateSetKeychainItem")
public func CertificateSetKeychainItem(_ certificate: CertificateRef?, _ keychain_item: CFTypeRef) -> OSStatus {
    guard let certificate = Certificate._fromCertificateRef(certificate) else { return errSecParam }
    certificate._keychain_item = keychain_item
    return errSecSuccess
}

@_cdecl("CertificateGetLength")
public func CertificateGetLength(_ certificate: CertificateRef) -> CFIndex {
    guard let certificate = Certificate._fromCertificateRef(certificate) else { return 0 }
    return certificate._save?.count ?? 0
}

@_cdecl("CertificateCopyIPAddresses")
public func CertificateCopyIPAddresses(_ certificate: CertificateRef) -> CFArray? {
    guard let certificate = Certificate._fromCertificateRef(certificate) else { return nil }
    guard let datas = certificate.subjectAltName?.compactMap({
        if case .iPAddress(let ipAddress) = $0 {
            if let ipv4Address = IPv4Address(ipAddress) {
                return String(describing: ipv4Address)
            } else if let ipv6Address = IPv6Address(ipAddress) {
                return String(describing: ipv6Address)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }), !datas.isEmpty else {
        return nil
    }
    return datas as CFArray
}

@_cdecl("CertificateCopyRFC822Names")
public func CertificateCopyRFC822Names(_ certificate: CertificateRef) -> CFArray? {
    guard let certificate = Certificate._fromCertificateRef(certificate) else { return nil }

    var names = [String]()

    if let san = certificate.subjectAltName {
        names.append(contentsOf: san.compactMap({
            if case .rfc822Name(let rfc822Name) = $0 {
                return String(describing: rfc822Name)
            } else {
                return nil
            }
        }))
    } else if let rdns = certificate.rdns(identifiedBy: id_at_emailAddress) {
        names.append(contentsOf: rdns)
    }

    return names.isEmpty ? nil : names as CFArray
}

@_cdecl("CertificateCopyCommonNames")
public func CertificateCopyCommonNames(_ certificate: CertificateRef) -> CFArray? {
    guard let certificate = Certificate._fromCertificateRef(certificate) else { return nil }
    return certificate.rdns(identifiedBy: id_at_commonName) as CFArray?
}

@_cdecl("CertificateCopyDescriptionsFromSAN")
public func CertificateCopyDescriptionsFromSAN(_ certificate: CertificateRef) -> CFArray? {
    guard let certificate = Certificate._fromCertificateRef(certificate) else { return nil }
    guard let names = certificate.subjectAltName?.map({ String(describing: $0) }), !names.isEmpty else {
        return nil
    }
    return names as CFArray
}

@_cdecl("CertificateCopyDataReencoded")
public func CertificateCopyDataReencoded(_ certificate: CertificateRef) -> CFData? {
    let certificate = Certificate._fromCertificateRef(certificate)!
    let asn1Encoder = ASN1Encoder()

    do {
        return try asn1Encoder.encode(certificate) as CFData
    } catch {
        return nil
    }
}

@_cdecl("CertificateCopyJSONDescription")
public func CertificateCopyJSONDescription(_ certificate: CertificateRef) -> CFString? {
    guard let certificate = Certificate._fromCertificateRef(certificate) else { return nil }

    let jsonEncoder = JSONEncoder()
    jsonEncoder.outputFormatting = .prettyPrinted

    do {
        let data = try jsonEncoder.encode(certificate)
        guard let string = String(data: data, encoding: .utf8) else { return nil }
        return string as CFString
    } catch {
    }

    return nil
}
