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
public func CertificateCreateWithBytes(
    _: CFAllocator!,
    _ bytes: [UInt8],
    _ der_length: CFIndex
) -> CertificateRef? {
    let data = Data(bytes: bytes, count: der_length)
    return Certificate.create(with: data)
}

@_cdecl("CertificateCreateWithKeychainItem")
public func CertificateCreateWithKeychainItem(
    _: CFAllocator!,
    _ der_certificate: CFData,
    _ keychain_item: Unmanaged<CFTypeRef>
) -> CertificateRef? {
    guard let certificate = Certificate.create(with: der_certificate as Data) else { return nil }
    certificate._swiftObject._keychain_item = keychain_item.takeRetainedValue()
    return certificate
}

@_cdecl("CertificateCopyComponentAttributes")
public func CertificateCopyComponentAttributes(_ certificate: CertificateRef?) -> Unmanaged<CFDictionary>? {
    guard let certificate = certificate?._swiftObject else { return nil }
    guard let componentAttributes = certificate.componentAttributes else { return nil }
    return Unmanaged.passRetained(componentAttributes)
}

@_cdecl("CertificateGetSubjectKeyID")
public func CertificateGetSubjectKeyID(_ certificate: CertificateRef?) -> Unmanaged<CFData>? {
    guard let certificate = certificate?._swiftObject else { return nil }
    guard let subjectKeyID: Data = certificate.extension(id_x509_ce_subjectKeyIdentifier) else { return nil }
    return Unmanaged.passUnretained(subjectKeyID as CFData)
}

@_cdecl("CertificateSetKeychainItem")
public func CertificateSetKeychainItem(
    _ certificate: CertificateRef?,
    _ keychain_item: Unmanaged<CFTypeRef>
) -> OSStatus {
    guard let certificate = certificate?._swiftObject else { return errSecParam }
    certificate._keychain_item = keychain_item.takeRetainedValue()
    return errSecSuccess
}

@_cdecl("CertificateGetLength")
public func CertificateGetLength(_ certificate: CertificateRef) -> CFIndex {
    let certificate = certificate._swiftObject
    return certificate._save?.count ?? 0
}

@_cdecl("CertificateCopyIPAddresses")
public func CertificateCopyIPAddresses(_ certificate: CertificateRef) -> Unmanaged<CFArray>? {
    let certificate = certificate._swiftObject

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

    return Unmanaged.passRetained(datas as CFArray)
}

@_cdecl("CertificateCopyRFC822Names")
public func CertificateCopyRFC822Names(_ certificate: CertificateRef) -> Unmanaged<CFArray>? {
    let certificate = certificate._swiftObject

    var names = [String]()

    if let san = certificate.subjectAltName {
        names.append(contentsOf: san.compactMap {
            if case .rfc822Name(let rfc822Name) = $0 {
                return String(describing: rfc822Name)
            } else {
                return nil
            }
        })
    } else if let rdns = certificate.rdns(identifiedBy: id_at_emailAddress) {
        names.append(contentsOf: rdns)
    }

    guard !names.isEmpty else {
        return nil
    }

    return Unmanaged.passRetained(names as CFArray)
}

@_cdecl("CertificateCopyCommonNames")
public func CertificateCopyCommonNames(_ certificate: CertificateRef) -> Unmanaged<CFArray>? {
    let certificate = certificate._swiftObject

    guard let rdns = certificate.rdns(identifiedBy: id_at_commonName),
          !rdns.isEmpty else {
        return nil
    }

    return Unmanaged.passRetained(rdns as CFArray)
}

@_cdecl("CertificateCopyNTPrincipalNames")
public func CertificateCopyNTPrincipalNames(_ certificate: CertificateRef) -> Unmanaged<CFArray>? {
    let certificate = certificate._swiftObject

    guard let names = certificate.subjectAltName?.compactMap({
        if case .otherName(let otherName) = $0,
           otherName.type_id == id_pkix_on_pkinit_ms_san ||
           otherName.type_id == id_pkix_on_pkinit_san {
            return String(describing: otherName.value)
        } else {
            return nil
        }
    }), !names.isEmpty else {
        return nil
    }

    return Unmanaged.passRetained(names as CFArray)
}

@objc protocol PropertyType {
    var propertyType: String? { get }
}

extension NSObject {
    @objc var propertyType: String? {
        nil
    }
}

extension NSDictionary {
    override var propertyType: String? {
        "section"
    }
}

extension NSData {
    override var propertyType: String? {
        "data"
    }
}

extension NSString {
    override var propertyType: String? {
        "string"
    }
}

extension NSURL {
    override var propertyType: String? {
        "url"
    }
}

extension NSDate {
    override var propertyType: String? {
        "date"
    }
}

extension NSArray {
    override var propertyType: String? {
        "array"
    }
}

extension NSNumber {
    override var propertyType: String? {
        "number"
    }
}

extension NSDictionary {
    var nsKeyValueArray: NSArray {
        self.map {
            let label = $0.0
            var value = $0.1
            let propertyType = (value as? NSObject)?.propertyType

            if let dictionary = value as? NSDictionary { value = dictionary.nsKeyValueArray }

            if let propertyType {
                return ["type": propertyType, "label": label, "value": value] as NSDictionary
            } else {
                return ["label": label, "value": value] as NSDictionary
            }
        } as NSArray
    }
}

extension Dictionary where Value: NSObject {
    var nsKeyValueArray: NSArray {
        (self as NSDictionary).nsKeyValueArray
    }
}

extension BitString {
    var nsData: NSData {
        self.wrappedValue as NSData
    }
}

extension Certificate {
    func rdnProperty(_ name: Name) -> NSDictionary? {
        guard case .rdnSequence(let rdns) = name, !rdns.isEmpty else {
            return nil
        }

        return rdns.reduce([String: NSObject]()) { result, rdn in
            var result = result as [String: NSObject]

            rdn.forEach { ava in
                let oid = String(describing: ava.type)
                let value = String(describing: ava.value) as NSString

                if let existing = result[oid] {
                    if let existing = existing as? NSMutableArray {
                        existing.add(value)
                    } else {
                        result[oid] = NSMutableArray(objects: [existing, value])
                    }
                } else {
                    result[oid] = value
                }
            }

            return result
        } as NSDictionary
    }

    var versionProperty: NSString {
        "\(self.tbsCertificate.version ?? rfc3280_version_2 + 1)" as NSString
    }

    var serialNumberProperty: NSDictionary {
        // FIXME: why is there this inner wrapping? looks wrong to me
        ["Serial Number": String(describing: self.tbsCertificate.serialNumber) as NSString] as NSDictionary
    }

    var validityPeriodProperty: NSDictionary {
        ["Not Valid Before": self.tbsCertificate.validity.notBefore.nsDate,
         "Not Valid After": self.tbsCertificate.validity.notAfter.nsDate] as NSDictionary
    }

    var publicKeyAlgorithmProperty: NSDictionary {
        var properties = [String: NSObject]()
        let spki = self.tbsCertificate.subjectPublicKeyInfo

        properties["Algorithm"] = String(describing: spki.algorithm.algorithm) as NSObject

        if let parameters = spki.algorithm.parameters, !(parameters is Null) {
            properties["Parameters"] = String(describing: parameters) as NSObject
        }
        return properties as NSDictionary
    }

    var publicKeyDataProperty: NSData {
        self.tbsCertificate.subjectPublicKeyInfo.subjectPublicKey.nsData
    }

    var publicKeyInfoProperty: NSDictionary {
        var properties = [String: NSObject]()
        properties["Public Key Algorithm"] = self.publicKeyAlgorithmProperty
        properties["Public Key Data"] = self.publicKeyDataProperty
        return properties as NSDictionary
    }

    var signatureAlgorithmProperty: NSDictionary {
        var properties = [String: NSObject]()

        properties["Algorithm"] = String(describing: signatureAlgorithm.algorithm) as NSObject

        if let parameters = signatureAlgorithm.parameters, !(parameters is Null) {
            properties["Parameters"] = String(describing: parameters) as NSObject
        }
        return properties as NSDictionary
    }

    var signatureDataProperty: NSData {
        self.signatureValue.nsData
    }

    var signatureProperty: NSDictionary {
        var properties = [String: NSObject]()
        properties["Signature Algorithm"] = self.signatureAlgorithmProperty
        properties["Signature Data"] = self.signatureDataProperty
        return properties as NSDictionary
    }
}

extension Time {
    var nsDate: NSDate {
        switch self {
        case .utcTime(let utcTime):
            return utcTime.wrappedValue as NSDate
        case .generalTime(let generalizedTime):
            return generalizedTime.wrappedValue as NSDate
        }
    }
}

@_cdecl("CertificateCopyLegacyProperties")
public func CertificateCopyLegacyProperties(_ certificate: CertificateRef) -> Unmanaged<CFArray>? {
    let certificate = certificate._swiftObject

    var properties = [String: NSObject]()

    if let subjectName = certificate.rdnProperty(certificate.tbsCertificate.subject) {
        properties["Subject Name"] = subjectName
    }

    if let subjectName = certificate.rdnProperty(certificate.tbsCertificate.issuer) {
        properties["Issuer Name"] = subjectName
    }

    properties["Version"] = certificate.versionProperty
    properties["Serial Number"] = certificate.serialNumberProperty

    properties["Not Valid Before"] = certificate.tbsCertificate.validity.notBefore.nsDate
    properties["Not Valid After"] = certificate.tbsCertificate.validity.notAfter.nsDate

    properties["Subject Unique ID"] = certificate.tbsCertificate.subjectUniqueID?.nsData
    properties["Issuer Unique ID"] = certificate.tbsCertificate.issuerUniqueID?.nsData

    properties["Public Key Algorithm"] = certificate.publicKeyAlgorithmProperty
    properties["Public Key Data"] = certificate.publicKeyDataProperty

    // appendExtension
    properties["Signature"] = certificate.signatureDataProperty
    // SEC_FINGERPRINTS_KEY appendFingerprintsProperty

    return Unmanaged.passRetained(properties.nsKeyValueArray)
}

@_cdecl("CertificateCopyProperties")
public func CertificateCopyProperties(_ certificate: CertificateRef) -> Unmanaged<CFArray>? {
    let certificate = certificate._swiftObject

    if let properties = certificate._properties {
        return Unmanaged.passRetained(properties)
    }

    var properties = [String: NSObject]()

    if let subjectName = certificate.rdnProperty(certificate.tbsCertificate.subject) {
        properties["Subject Name"] = subjectName
    }

    if let subjectName = certificate.rdnProperty(certificate.tbsCertificate.issuer) {
        properties["Issuer Name"] = subjectName
    }

    properties["Version"] = certificate.versionProperty
    properties["Serial Number"] = certificate.serialNumberProperty
    properties["Validity Period"] = certificate.validityPeriodProperty

    properties["Subject Unique ID"] = certificate.tbsCertificate.subjectUniqueID?.nsData
    properties["Issuer Unique ID"] = certificate.tbsCertificate.issuerUniqueID?.nsData
    properties["Public Key Info"] = certificate.publicKeyInfoProperty

    // appendExtension
    properties["Signature"] = certificate.signatureProperty
    // SEC_FINGERPRINTS_KEY appendFingerprintsProperty

    certificate._properties = properties.nsKeyValueArray

    return Unmanaged.passRetained(certificate._properties!)
}

@_cdecl("CertificateCopyDescriptionsFromSAN")
public func CertificateCopyDescriptionsFromSAN(_ certificate: CertificateRef) -> Unmanaged<CFArray>? {
    let certificate = certificate._swiftObject
    guard let names = certificate.subjectAltName?.map({ String(describing: $0) }),
          !names.isEmpty else {
        return nil
    }

    return Unmanaged.passRetained(names as CFArray)
}

@_cdecl("CertificateCopyDataReencoded")
public func CertificateCopyDataReencoded(_ certificate: CertificateRef) -> Unmanaged<CFData>? {
    let certificate = certificate._swiftObject
    let asn1Encoder = ASN1Encoder()

    do {
        let data = try asn1Encoder.encode(certificate)
        return Unmanaged.passRetained(data as CFData)
    } catch {
        return nil
    }
}

@_cdecl("CertificateCopyJSONDescription")
public func CertificateCopyJSONDescription(_ certificate: CertificateRef) -> Unmanaged<CFString>? {
    let certificate = certificate._swiftObject

    let jsonEncoder = JSONEncoder()
    jsonEncoder.outputFormatting = .prettyPrinted

    do {
        let data = try jsonEncoder.encode(certificate)
        guard let string = String(data: data, encoding: .utf8) else { return nil }
        return Unmanaged.passRetained(string as CFString)
    } catch {}

    return nil
}
