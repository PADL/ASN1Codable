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

extension Certificate {
    static func _fromCertificateRef(_ certificateRef: CertificateRef!) -> Certificate? {
        if certificateRef == nil { return nil }
        return unsafeBitCast(certificateRef, to: Certificate.self)
    }

    var _certificateRef: CertificateRef {
        let certificate = Unmanaged<Certificate>.passRetained(self)
        return unsafeBitCast(certificate, to: CertificateRef.self)
    }

    static func create(with der_certificate: Data) -> CertificateRef? {
        do {
            let certificate = try ASN1Decoder().decode(Certificate.self, from: der_certificate as Data)
            return certificate._certificateRef
        } catch {
            debugPrint("Failed to decode certificate: \(error)")
            return nil
        }
    }
}
