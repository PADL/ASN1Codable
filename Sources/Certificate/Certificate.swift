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

@_cdecl("CertificateCreateWithData")
public func CertificateCreateWithData(_ allocator: CFAllocator!,
                                      _ der_certificate: CFData?) -> CertificateRef?
{
    guard let der_certificate = der_certificate else { return nil }
    return Certificate.create(with: der_certificate as Data)
}

@_cdecl("CertificateCopyData")
public func CertificateCopyData(_ certificate: CertificateRef?) -> CFData?
{
    guard let certificate = Certificate._fromCertificateRef(certificate) else { return nil }
    guard let data = certificate._save else { return nil }
    return data as CFData
}

@_cdecl("CertificateCopySubjectSummary")
public func CertificateCopySubjectSummary(_ certificate: CertificateRef) -> CFString?
{
    guard let certificate = Certificate._fromCertificateRef(certificate) else { return nil }

    // try subject
    // try common name
    // rfc822
    // DNS names
    
    return nil
}
