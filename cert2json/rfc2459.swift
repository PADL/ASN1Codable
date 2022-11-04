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
import ASN1CodingKit
import BigNumber
import AnyCodable

public enum Version: Int, Codable {
    case rfc3280_version_1 = 0
    case rfc3280_version_2 = 1
    case rfc3280_version_3 = 2
}

public typealias CertificateSerialNumber = BInt

public struct AlgorithmIdentifier: Codable {
    var algorithm: ObjectIdentifier
    var parameters: AnyCodable?
}

public typealias AttributeType = ObjectIdentifier

public typealias AttributeValue = AnyCodable

public typealias AttributeValues = Set<AttributeValue>

public enum DirectoryString: Codable, Hashable {
    case ia5String(IA5String<String>)
    case printableString(PrintableString<String>)
    case universalString(UniversalString<String>)
    case utf8String(UTF8String<String>)
    case bmpString(BMPString<String>)
}

public struct AttributeTypeAndValue: Codable, Hashable {
    var type: AttributeType
    var value: DirectoryString
}

public struct Attribute: Codable, Hashable {
    var type: AttributeTypeAndValue
    var value: AttributeValues
}

public typealias RelativeDistinguishedName = Set<AttributeTypeAndValue>

public typealias RDNSequence = [RelativeDistinguishedName]

public enum Name: Codable {
    case rdnSequence(RDNSequence)
}

public enum Time: Codable {
    case utcTime(UTCTime)
    case generalTime(GeneralizedTime)
}

public struct Validity: Codable {
    var notBefore: Time
    var notAfter: Time
}

public struct SubjectPublicKeyInfo: Codable {
    var algorithm: AlgorithmIdentifier
    var subjectPublicKey: BitString = BitString()
}

public let PKIXonPKINITSan = ObjectIdentifier(rawValue: "1.3.6.1.5.2.2")!

public typealias Realm = GeneralString<String>
public typealias NAME_TYPE = Int

public struct PrincipalName: Codable {
    @ASN1ContextTagged<ASN1TagNumber$0, ASN1AutomaticTagging, NAME_TYPE>
    var name_type: NAME_TYPE = 0
    
    @ASN1ContextTagged<ASN1TagNumber$1, ASN1AutomaticTagging, [GeneralString<String>]>
    var name_string: [GeneralString<String>] = []
}
public struct KRB5PrincipalName: Codable {
    @ASN1ContextTagged<ASN1TagNumber$0, ASN1AutomaticTagging, Realm>
    var realm: GeneralString<String> = GeneralString<String>(wrappedValue: "")

    @ASN1ContextTagged<ASN1TagNumber$1, ASN1AutomaticTagging, PrincipalName>
    var principalName: PrincipalName = PrincipalName()
}

public struct OtherName: ASN1ObjectSetRepresentable {
    public static let knownTypes: [ObjectIdentifier: Codable.Type] = [
        PKIXonPKINITSan : ASN1ContextTagged<ASN1TagNumber$0, ASN1AutomaticTagging, KRB5PrincipalName>.self
    ]

    @ASN1ObjectSetType
    public var type_id: ObjectIdentifier
    @ASN1ObjectSetValue
    public var value: Any
}

public enum GeneralName: Codable {
    case otherName(ASN1ContextTagged<ASN1TagNumber$0, ASN1ImplicitTagging, OtherName>)
    case rfc822Name(ASN1ContextTagged<ASN1TagNumber$1, ASN1ImplicitTagging, IA5String<String>>)
}

public typealias GeneralNames = [GeneralName]
public typealias SkipCerts = Int32

public struct KeyUsageOptionSet: OptionSet, Codable {
    public let rawValue: UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    static let digitalSignature = KeyUsageOptionSet(rawValue: 1 << 0)
    static let nonRepudiation = KeyUsageOptionSet(rawValue: 1 << 1)
    static let keyEncipherment = KeyUsageOptionSet(rawValue: 1 << 2)
    static let dataEncipherment = KeyUsageOptionSet(rawValue: 1 << 3)
    static let keyAgreement = KeyUsageOptionSet(rawValue: 1 << 4)
    static let keyCertSign = KeyUsageOptionSet(rawValue: 1 << 5)
    static let cRLSign = KeyUsageOptionSet(rawValue: 1 << 6)
    static let encipherOnly = KeyUsageOptionSet(rawValue: 1 << 7)
    static let decipherOnly = KeyUsageOptionSet(rawValue: 1 << 8)
}

public typealias KeyUsage = ASN1RawRepresentableBitString<KeyUsageOptionSet>

public typealias ExtKeyUsage = [ObjectIdentifier]

typealias KeyIdentifier = Data

public struct BasicConstraints: Codable {
    @DecodableDefault.False var cA: Bool
    @DecodableDefault.Zero var pathLenConstraint: Int
}

public let KeyUsageOID = ObjectIdentifier(rawValue: "2.5.29.15")!
public let ExtKeyUsageOID = ObjectIdentifier(rawValue: "2.5.29.37")!
public let SubjectKeyIdentifierOID = ObjectIdentifier(rawValue: "2.5.29.14")!
public let SubjectAltNameOID = ObjectIdentifier(rawValue: "2.5.29.17")!
public let BasicConstraintsOID = ObjectIdentifier(rawValue: "2.5.29.19")!
public let InhibitAnyPolicyOID = ObjectIdentifier(rawValue: "2.5.29.54")!

public struct Extension: ASN1ObjectSetRepresentable {
    public static let knownTypes: [ObjectIdentifier: Codable.Type] = [
        KeyUsageOID : KeyUsage.self,
        ExtKeyUsageOID : ExtKeyUsage.self,
        SubjectKeyIdentifierOID : KeyIdentifier.self,
        SubjectAltNameOID : GeneralNames.self,
        BasicConstraintsOID : BasicConstraints.self,
        InhibitAnyPolicyOID : SkipCerts.self
    ]
    
    @ASN1ObjectSetType
    var extnID: ObjectIdentifier
    @DecodableDefault.False
    var critical: Bool
    @ASN1ObjectSetValue
    var extnValue: Any
}

// must be class to support ASN1PreserveBinary on encode

public class TBSCertificate: Codable, ASN1PreserveBinary {
    public var _save: Data? = nil

    // Note to compiler implementor: CodingKeys must be specified for all
    // ASN.1 fields whenever a decoration (including _save) is used, to
    // avoid the encoding of the decorated types
    
    enum CodingKeys: CodingKey {
        case version
        case serialNumber
        case signature
        case issuer
        case validity
        case subject
        case subjectPublicKeyInfo
        case issuerUniqueID
        case subjectUniqueID
        case extensions
    }
    
    @ASN1ContextTagged<ASN1TagNumber$0, ASN1AutomaticTagging, Version?>
    var version: Version?
    var serialNumber: CertificateSerialNumber
    var signature: AlgorithmIdentifier
    var issuer: Name
    var validity: Validity
    var subject: Name
    var subjectPublicKeyInfo: SubjectPublicKeyInfo
    
    @ASN1ContextTagged<ASN1TagNumber$1, ASN1ImplicitTagging, BitString?>
    var issuerUniqueID: BitString? = BitString()

    @ASN1ContextTagged<ASN1TagNumber$2, ASN1ImplicitTagging, BitString?>
    var subjectUniqueID: BitString?
    
    @ASN1ContextTagged<ASN1TagNumber$3, ASN1ExplicitTagging, [Extension]?>
    var extensions: [Extension]?

    public init(version: Version? = nil,
                serialNumber: CertificateSerialNumber,
                signature: AlgorithmIdentifier,
                issuer: Name,
                validity: Validity,
                subject: Name,
                subjectPublicKeyInfo: SubjectPublicKeyInfo) {
        self.version = version
        self.serialNumber = serialNumber
        self.signature = signature
        self.issuer = issuer
        self.validity = validity
        self.subject = subject
        self.subjectPublicKeyInfo = subjectPublicKeyInfo
    }
}

public struct Certificate: Codable {
    var tbsCertificate: TBSCertificate
    var signatureAlgorithm: AlgorithmIdentifier
    var signatureValue: BitString = BitString()
}
