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

@_cdecl("CertificateCreateWithData")
func CertificateCreateWithData(_ allocator: CFAllocator,
                               _ der_certificate: CFData?) -> Certificate?
{
    guard let der_certificate = der_certificate else { return nil }
    do {
        return try ASN1Decoder().decode(Certificate.self, from: der_certificate as Data)
    } catch {
        return nil
    }
}

@_cdecl("CertificateCreateWithBytes")
func CertificateCreateWithBytes(_ allocator: CFAllocator,
                                 _ bytes: [UInt8],
                                 _ der_length: CFIndex) -> Certificate?
{
    do {
        let data = Data(bytes: bytes, count: der_length)
        return try ASN1Decoder().decode(Certificate.self, from: data)
    } catch {
        return nil
    }
}

extension Certificate {
    var componentAttributes: NSDictionary? {
        guard let attributes: ASN1TaggedDictionary = self.extension(id_apple_ce_appleComponentAttributes) else {
            return nil
        }
        
        return attributes.wrappedValue.mapValues { $0.value as? NSObject } as NSDictionary
    }
    
    @objc var serialNumberData: CFData? {
        do {
            return try ASN1Encoder().encode(self.tbsCertificate.serialNumber) as CFData
        } catch {
            return nil
        }
    }
}

@_cdecl("CertificateCopyComponentAttributes")
func CertificateCopyComponentAttributes(_ certificate: Certificate?) -> CFDictionary? {
    guard let certificate = certificate else { return nil }
    
    return certificate.componentAttributes
}

@_cdecl("CertificateGetSubjectKeyID")
func CertificateGetSubjectKeyID(_ certificate: Certificate?) -> CFData? {
    guard let certificate = certificate else { return nil }
    guard let subjectKeyID: Data = certificate.extension(id_x509_ce_subjectKeyIdentifier) else { return nil }
    
    return subjectKeyID as CFData
}

@_cdecl("CertificateCreateWithKeychainItem")
func CertificateCreateWithKeychainItem(_ allocator: CFAllocator,
                                       _ der_certificate: CFData,
                                       _ keychain_item: CFTypeRef) -> Certificate?
{
    guard let certificate = CertificateCreateWithData(allocator, der_certificate) else { return nil }
    certificate._keychain_item = keychain_item
    return certificate
}

@_cdecl("CertificateSetKeychainItem")
func CertificateSetKeychainItem(_ certificate: Certificate?, _ keychain_item: CFTypeRef) -> OSStatus
{
    guard let certificate = certificate else { return errSecParam }
    certificate._keychain_item = keychain_item
    return errSecSuccess
}

@_cdecl("CertificateCopyData")
func CertificateCopyData(_ certificate: Certificate?) -> CFData?
{
    guard let certificate = certificate else { return nil }
    guard let data = certificate._save else { return nil }
    return data as CFData
}

@_cdecl("CertificateGetLength")
func CertificateGetLength(_ certificate: Certificate) -> CFIndex
{
    return certificate._save?.count ?? 0
}
