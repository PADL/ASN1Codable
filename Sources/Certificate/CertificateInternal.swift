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

@_cdecl("CertificateCopyIPAddressDatas")
public func CertificateCopyIPAddressDatas(_ certificate: CertificateRef) -> Unmanaged<CFArray>? {
  let certificate = certificate._swiftObject

  guard let datas = certificate.subjectAltName?.compactMap({
    if case .iPAddress(let ipAddress) = $0 {
      return ipAddress
    } else {
      return nil
    }
  }), !datas.isEmpty else {
    return nil
  }

  return Unmanaged.passRetained(datas as CFArray)
}

@_cdecl("CertificateCopyDNSNamesFromSAN")
public func CertificateCopyDNSNamesFromSAN(_ certificate: CertificateRef) -> Unmanaged<CFArray>? {
  let certificate = certificate._swiftObject

  guard let datas = certificate.subjectAltName?.compactMap({
    if case .dNSName(let dnsName) = $0 {
      return dnsName
    } else {
      return nil
    }
  }), !datas.isEmpty else {
    return nil
  }

  return Unmanaged.passRetained(datas as CFArray)
}

@_cdecl("CertificateCopyRFC822NamesFromSAN")
public func CertificateCopyRFC822NamesFromSAN(_ certificate: CertificateRef) -> Unmanaged<CFArray>? {
  let certificate = certificate._swiftObject

  guard let names = certificate.subjectAltName?.compactMap({
    if case .rfc822Name(let rfc822Name) = $0 {
      return String(describing: rfc822Name)
    } else {
      return nil
    }
  }), !names.isEmpty else {
    return nil
  }

  return Unmanaged.passRetained(names as CFArray)
}

@_cdecl("CertificateCopySerialNumberData")
public func CertificateCopySerialNumberData(
  _ certificate: CertificateRef?,
  _ error: UnsafeMutablePointer<Unmanaged<CFError>?>?
) -> Unmanaged<CFData>? {
  guard let certificate = certificate?._swiftObject else {
    error?.pointee = Unmanaged.passRetained(CFErrorCreate(kCFAllocatorDefault,
                                                          kCFErrorDomainOSStatus,
                                                          CFIndex(errSecDecode),
                                                          nil))
    return nil
  }
  guard let serial = certificate.serialNumberData else {
    return nil
  }
  return Unmanaged.passRetained(serial)
}
