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

internal extension Certificate {
    static func _fromCertificateRef(_ certificateRef: CertificateRef!) -> Certificate? {
        if certificateRef == nil { return nil }
        return unsafeBitCast(certificateRef, to: Certificate.self)
    }
    
    var _certificateRef: CertificateRef {
        let certificate = Unmanaged<Certificate>.passRetained(self)
        return unsafeBitCast(certificate, to: CertificateRef.self)
    }

    fileprivate static func create(with der_certificate: Data) -> CertificateRef? {
        do {
            let certificate = try ASN1Decoder().decode(Certificate.self, from: der_certificate as Data)
            return certificate._certificateRef
        } catch {
            return nil
        }
    }
}

@_cdecl("CertificateCreateWithData")
public func CertificateCreateWithData(_ allocator: CFAllocator!,
                                      _ der_certificate: CFData?) -> CertificateRef?
{
    guard let der_certificate = der_certificate else { return nil }
    return Certificate.create(with: der_certificate as Data)
}

@_cdecl("CertificateCreateWithBytes")
public func CertificateCreateWithBytes(_ allocator: CFAllocator!,
                                       _ bytes: [UInt8],
                                       _ der_length: CFIndex) -> CertificateRef?
{
    let data = Data(bytes: bytes, count: der_length)
    return Certificate.create(with: data)
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

@_cdecl("CertificateCreateWithKeychainItem")
public func CertificateCreateWithKeychainItem(_ allocator: CFAllocator!,
                                              _ der_certificate: CFData,
                                              _ keychain_item: CFTypeRef) -> CertificateRef?
{
    guard let certificate: CertificateRef = Certificate.create(with: der_certificate as Data) else {
        return nil
    }
    (Certificate._fromCertificateRef(certificate))!._keychain_item = keychain_item
    return certificate
}

@_cdecl("CertificateSetKeychainItem")
public func CertificateSetKeychainItem(_ certificate: CertificateRef?, _ keychain_item: CFTypeRef) -> OSStatus
{
    guard let certificate = Certificate._fromCertificateRef(certificate) else { return errSecParam }
    certificate._keychain_item = keychain_item
    return errSecSuccess
}

@_cdecl("CertificateCopyData")
public func CertificateCopyData(_ certificate: CertificateRef?) -> CFData?
{
    guard let certificate = Certificate._fromCertificateRef(certificate) else { return nil }
    guard let data = certificate._save else { return nil }
    return data as CFData
}

@_cdecl("CertificateGetLength")
public func CertificateGetLength(_ certificate: CertificateRef) -> CFIndex
{
    guard let certificate = Certificate._fromCertificateRef(certificate) else { return 0 }
    return certificate._save?.count ?? 0
}

@_cdecl("CertificateCopyIPAddresses")
public func CertificateCopyIPAddresses(_ certificate: CertificateRef) -> CFArray?
{
    guard let certificate = Certificate._fromCertificateRef(certificate) else { return nil }
    guard let datas = certificate.subjectAltName?.compactMap({
        if case .iPAddress(let ipAddress) = $0 {
            if let ipv4Address = IPv4Address(ipAddress.wrappedValue) {
                return String(describing: ipv4Address)
            } else if let ipv6Address = IPv6Address(ipAddress.wrappedValue) {
                return String(describing: ipv6Address)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }), datas.count != 0 else {
        return nil
    }
    return datas as CFArray
}

@_cdecl("CertificateCopyIPAddressDatas")
public func CertificateCopyIPAddressDatas(_ certificate: CertificateRef) -> CFArray?
{
    guard let certificate = Certificate._fromCertificateRef(certificate) else { return nil }
    guard let datas = certificate.subjectAltName?.compactMap({
        if case .iPAddress(let ipAddress) = $0 {
            return ipAddress.wrappedValue
        } else {
            return nil
        }
    }), datas.count != 0 else {
        return nil
    }
    return datas as CFArray
}

@_cdecl("CertificateCopyDNSNamesFromSAN")
public func CertificateCopyDNSNamesFromSAN(_ certificate: CertificateRef) -> CFArray?
{
    guard let certificate = Certificate._fromCertificateRef(certificate) else { return nil }
    guard let datas = certificate.subjectAltName?.compactMap({
        if case .dNSName(let dnsName) = $0 {
            return dnsName
        } else {
            return nil
        }
    }), datas.count != 0 else {
        return nil
    }
    return datas as CFArray
}
