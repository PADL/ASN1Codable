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

extension CertificateRef {
    var _swiftObject: Certificate {
        unsafeBitCast(self, to: Certificate.self)
    }
}

extension Certificate {
    var _cfObject: CertificateRef {
        unsafeBitCast(Unmanaged<Certificate>.passUnretained(self), to: CertificateRef.self)
    }

    static func create(with der_certificate: Data) -> CertificateRef? {
        do {
            let decoder = ASN1Decoder()
            let certificate = try decoder.decode(Certificate.self, from: der_certificate as Data)
            return unsafeBitCast(Unmanaged<Certificate>.passRetained(certificate), to: CertificateRef.self)
        } catch {
            debugPrint("Failed to decode certificate: \(error)")
            return nil
        }
    }
}

@_cdecl("CertificateCreateWithData")
public func CertificateCreateWithData(
    _: CFAllocator!,
    _ der_certificate: Unmanaged<CFData>?
) -> CertificateRef? {
    guard let der_certificate else { return nil }
    return Certificate.create(with: der_certificate.takeUnretainedValue() as Data)
}

@_cdecl("CertificateCopyData")
public func CertificateCopyData(_ certificate: CertificateRef?) -> Unmanaged<CFData>? {
    guard let certificate = certificate?._swiftObject else { return nil }
    guard let data = certificate._save else { return nil }
    return Unmanaged.passRetained(data as CFData)
}

extension Certificate {
    // swiftlint:disable discouraged_optional_collection
    func rdns(identifiedBy oid: AttributeType) -> [String]? {
        guard case .rdnSequence(let rdns) = self.tbsCertificate.subject, !rdns.isEmpty else {
            return nil
        }

        let strings: [String] = rdns.compactMap {
            guard let first = $0.first(where: { $0.type == oid }) else { return nil }
            return String(describing: first.value)
        }

        guard !strings.isEmpty else { return nil }

        return strings
    }

    var rdnCount: Int {
        guard case .rdnSequence(let rdns) = self.tbsCertificate.subject else { return 0 }
        return rdns.count
    }
}

@_cdecl("CertificateCopySubjectSummary")
public func CertificateCopySubjectSummary(_ certificate: CertificateRef) -> Unmanaged<CFString>? {
    let certificate = certificate._swiftObject
    let summary: String

    // FIXME: mirror Security.framework, currently just returns a DN
    if let cn = certificate.rdns(identifiedBy: id_at_commonName), !cn.isEmpty {
        summary = cn[0]
    } else if certificate.rdnCount != 0 {
        summary = certificate.tbsCertificate.subject.description
    } else if let emails = CertificateCopyRFC822Names(certificate._cfObject),
              let email = (emails.takeRetainedValue() as NSArray).firstObject as? String {
        summary = email
    } else if let dns = CertificateCopyDNSNamesFromSAN(certificate._cfObject),
              let dns = (dns.takeRetainedValue() as NSArray).firstObject as? String {
        summary = dns
    } else {
        return nil
    }

    return Unmanaged.passRetained(summary as CFString)
}

@_cdecl("CertificateGetKeyUsage")
public func CertificateGetKeyUsage(_ certificate: CertificateRef?) -> UInt32 {
    guard let certificate = certificate?._swiftObject else { return 0 }
    guard let keyUsage: KeyUsage = certificate.extension(id_x509_ce_keyUsage) else { return 0 }

    return UInt32(keyUsage.rawValue)
}
