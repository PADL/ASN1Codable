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
        
        var dict = Dictionary<UInt, NSObject>()
        
        attributes.wrappedValue.forEach { kv in
            guard case .taggedTag(let tagNo) = kv.0,
                  let ns = kv.1.value as? NSObject else {
                return
            }
            
            dict[tagNo] = ns
        }
        
        return dict as NSDictionary
    }
    
    @objc var serialNumberData: CFData? {
        do {
            let encoded = try ASN1Encoder().encode(self.tbsCertificate.serialNumber)
            return encoded as CFData
        } catch {
            return nil
        }
    }
}

@_cdecl("CertificateCopyComponentAttributes")
func CertificateCopyComponentAttributes(_ certificate: Certificate) -> CFDictionary? {
    return certificate.componentAttributes
}

