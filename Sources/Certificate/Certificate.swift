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
    static func create(with der_certificate: Data) -> CertificateRef? {
        do {
            let decoder = ASN1Decoder()
            let certificate = try decoder.decode(Certificate.self, from: der_certificate as Data)
            return certificate._certificateRef
        } catch {
            debugPrint("Failed to decode certificate: \(error)")
            return nil
        }
    }
}

@_cdecl("CertificateCreateWithData")
public func CertificateCreateWithData(
    _: CFAllocator!,
    _ der_certificate: CFData?
) -> CertificateRef? {
    guard let der_certificate else { return nil }
    return Certificate.create(with: der_certificate as Data)
}

@_cdecl("CertificateCopyData")
public func CertificateCopyData(_ certificate: CertificateRef?) -> CFData? {
    guard let certificate = Certificate._fromCertificateRef(certificate) else { return nil }
    guard let data = certificate._save else { return nil }
    return data as CFData
}

extension Certificate {
    // swiftlint:disable discouraged_optional_collection
    func rdns(identifiedBy oid: AttributeType) -> [String]? {
        guard case .rdnSequence(let rdns) = self.tbsCertificate.subject, !rdns.isEmpty else {
            return nil
        }

        let strings: [String] = rdns.compactMap {
            guard let first = $0.first(where: { $0.type == oid }) else { return nil }
            return String(describing: first)
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
public func CertificateCopySubjectSummary(_ certificate: CertificateRef) -> CFString? {
    guard let certificate = Certificate._fromCertificateRef(certificate) else { return nil }

    let summary: String

    // FIXME: mirror Security.framework, currently just returns a DN
    if let cn = certificate.rdns(identifiedBy: id_at_commonName), !cn.isEmpty {
        summary = cn[0]
    } else if certificate.rdnCount != 0 {
        summary = certificate.tbsCertificate.subject.description
    } else if let emails = CertificateCopyRFC822Names(certificate._certificateRef),
              let email = (emails as NSArray).firstObject as? String {
        summary = email
    } else if let dns = CertificateCopyDNSNamesFromSAN(certificate._certificateRef),
              let dns = (dns as NSArray).firstObject as? String {
        summary = dns
    } else {
        return nil
    }

    return summary as CFString
}

@_cdecl("_CertificateCopySerialNumberData")
func _CertificateCopySerialNumberData(_ certificate: CertificateRef) -> CFData? {
    guard let certificate = Certificate._fromCertificateRef(certificate) else { return nil }
    return certificate.serialNumberData
}
