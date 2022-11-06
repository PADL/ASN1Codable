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

public enum Version: Int, Codable {
    case rfc3280_version_1 = 0
    case rfc3280_version_2 = 1
    case rfc3280_version_3 = 2
}

public typealias CertificateSerialNumber = BInt

public let sha256WithRSAEncryptionOID = ObjectIdentifier(rawValue: "1.2.840.113549.1.1.11")!
public let rsaEncryptionOID = ObjectIdentifier(rawValue: "1.2.840.113549.1.1.1")!

public struct AlgorithmIdentifier: ASN1ObjectSetCodable {
    public static let knownTypes: [ObjectIdentifier: Codable.Type] =
        [sha256WithRSAEncryptionOID : Null.self,
                   rsaEncryptionOID : Null.self]

    @ASN1ObjectSetType
    var algorithm: ObjectIdentifier
    
    @ASN1ObjectSetValue
    var parameters: (any Codable)?
}

public struct TPMSpecification: Codable {
    @UTF8String
    var family: String = ""

    var level: Int32
    var revision: Int32
}
public let TPMSpecificationOID = ObjectIdentifier(rawValue: "2.23.133.2.16")!

public struct AttributeTypeAndValue: Codable, Hashable {
    var type: AttributeType
    var value: DirectoryString
}

public typealias AttributeType = ObjectIdentifier
public typealias AttributeValue = ASN1AnyObjectSetValue // type erased

public struct Attribute: ASN1ObjectSetCodable {
    public static let knownTypes: [ObjectIdentifier: Codable.Type] =
        [TPMSpecificationOID : TPMSpecification.self]

    @ASN1ObjectSetType
    var type: AttributeType
    
    var value: Set<AttributeValue>
}

public typealias Attributes = [Attribute]

public typealias SubjectDirectoryAttributes = [Attribute]

public enum DirectoryString: Codable, Hashable {
    case ia5String(IA5String<String>)
    case printableString(PrintableString<String>)
    case universalString(UniversalString<String>)
    case utf8String(UTF8String<String>)
    case bmpString(BMPString<String>)
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
public let PKIXonHardwareModuleName = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.8.4")!

public typealias Realm = GeneralString<String>
public typealias NAME_TYPE = Int

public struct PrincipalName: Codable {
    @ASN1ContextTagged<ASN1TagNumber$0, ASN1DefaultTagging, NAME_TYPE>
    var name_type: NAME_TYPE = 0
    
    @ASN1ContextTagged<ASN1TagNumber$1, ASN1DefaultTagging, [GeneralString<String>]>
    var name_string: [GeneralString<String>] = []
}
public struct KRB5PrincipalName: Codable {
    @ASN1ContextTagged<ASN1TagNumber$0, ASN1DefaultTagging, Realm>
    var realm: GeneralString<String> = GeneralString<String>(wrappedValue: "")

    @ASN1ContextTagged<ASN1TagNumber$1, ASN1DefaultTagging, PrincipalName>
    var principalName: PrincipalName = PrincipalName()
}

public struct HardwareModuleName: Codable {
    var hwType: ObjectIdentifier
    var hwSerialNumber: Data
}

public struct OtherName: ASN1ObjectSetCodable {
    public static let knownTypes: [ObjectIdentifier: Codable.Type] = [
        PKIXonPKINITSan : KRB5PrincipalName.self,
        PKIXonHardwareModuleName : HardwareModuleName.self
    ]

    @ASN1ObjectSetType
    public var type_id: ObjectIdentifier

    public var value: ASN1ContextTagged<ASN1TagNumber$0, ASN1DefaultTagging, ASN1ObjectSetValue>
}

public enum GeneralName: Codable {
    case otherName(ASN1ContextTagged<ASN1TagNumber$0, ASN1ImplicitTagging, OtherName>)
    case rfc822Name(ASN1ContextTagged<ASN1TagNumber$1, ASN1ImplicitTagging, IA5String<String>>)
    case dNSName(ASN1ContextTagged<ASN1TagNumber$2, ASN1ImplicitTagging, IA5String<String>>)
    case directoryName(ASN1ContextTagged<ASN1TagNumber$4, ASN1ImplicitTagging, Name>)
    case uniformResourceIdentifier(ASN1ContextTagged<ASN1TagNumber$6, ASN1ImplicitTagging, IA5String<String>>)
    case iPAddress(ASN1ContextTagged<ASN1TagNumber$7, ASN1ImplicitTagging, Data>)
    case registeredID(ASN1ContextTagged<ASN1TagNumber$8, ASN1ImplicitTagging, ObjectIdentifier>)
}

public typealias GeneralNames = [GeneralName]

public struct _KeyUsage: OptionSet, Codable {
    public let rawValue: UInt16
    
    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
    
    static let digitalSignature = _KeyUsage(rawValue: 1 << 0)
    static let nonRepudiation = _KeyUsage(rawValue: 1 << 1)
    static let keyEncipherment = _KeyUsage(rawValue: 1 << 2)
    static let dataEncipherment = _KeyUsage(rawValue: 1 << 3)
    static let keyAgreement = _KeyUsage(rawValue: 1 << 4)
    static let keyCertSign = _KeyUsage(rawValue: 1 << 5)
    static let cRLSign = _KeyUsage(rawValue: 1 << 6)
    static let encipherOnly = _KeyUsage(rawValue: 1 << 7)
    static let decipherOnly = _KeyUsage(rawValue: 1 << 8)
}

public typealias KeyUsage = ASN1RawRepresentableBitString<_KeyUsage>

public typealias ExtKeyUsage = [ObjectIdentifier]

typealias KeyIdentifier = Data

// NB: DecodableDefault is a convenience for users not using an ASN.1
// compiler. If you're building a compiler, prefix the instance variable
// with an underscore, map it using CodingKeys to the real name, and
// implement a getter that returns the default value. See below.

/*
public struct BasicConstraints: Codable {
    var _cA: Bool?
    var _pathLenConstraint: Int?
    
    enum CodingKeys: String, CodingKey {
        case _cA = "cA"
        case _pathLenConstraint = "pathLenConstraint"
    }
    
    var cA: Bool {
        get { return self._cA ?? false }
        set { self._cA = newValue }
    }
    
    var pathLenConstraint: Int {
        get { return self._pathLenConstraint ?? 0 }
        set { self._pathLenConstraint = newValue }
    }
}
 */

public struct BasicConstraints: Codable {
    @DecodableDefault.False var cA: Bool
    @DecodableDefault.Zero var pathLenConstraint: Int
}

public struct AuthorityKeyIdentifier: Codable {
    @ASN1ContextTagged<ASN1TagNumber$0, ASN1ImplicitTagging, Data?>
    var keyIdentifier: Data?

    @ASN1ContextTagged<ASN1TagNumber$1, ASN1ImplicitTagging, GeneralNames?>
    var authorityCertIssuer: GeneralNames?

    @ASN1ContextTagged<ASN1TagNumber$2, ASN1ImplicitTagging, CertificateSerialNumber?>
    var authorityCertSerialNumber: CertificateSerialNumber?
}

public struct _DistributionPointReasonFlags: OptionSet, Codable {
    public let rawValue: UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    static let unused = _DistributionPointReasonFlags(rawValue: 1 << 0)
    static let keyCompromise = _DistributionPointReasonFlags(rawValue: 1 << 1)
    static let cACompromise = _DistributionPointReasonFlags(rawValue: 1 << 2)
    static let affiliationChanged = _DistributionPointReasonFlags(rawValue: 1 << 3)
    static let superseded = _DistributionPointReasonFlags(rawValue: 1 << 4)
    static let cessationOfOperation = _DistributionPointReasonFlags(rawValue: 1 << 5)
    static let certificateHold = _DistributionPointReasonFlags(rawValue: 1 << 6)
    static let privilegeWithdrawn = _DistributionPointReasonFlags(rawValue: 1 << 7)
    static let aACompromise = _DistributionPointReasonFlags(rawValue: 1 << 8)
}

public typealias DistributionPointReasonFlags = ASN1RawRepresentableBitString<_DistributionPointReasonFlags>

public enum DistributionPointName: Codable {
    case fullName(ASN1ContextTagged<ASN1TagNumber$0, ASN1ImplicitTagging, GeneralNames>)
    case nameRelativeToCRLIssuer(ASN1ContextTagged<ASN1TagNumber$1, ASN1ImplicitTagging, RelativeDistinguishedName>)
}

public struct DistributionPoint: Codable {
    @ASN1ContextTagged<ASN1TagNumber$0, ASN1ImplicitTagging, DistributionPointName?>
    var distributionPoint: DistributionPointName?
    
    @ASN1ContextTagged<ASN1TagNumber$1, ASN1ImplicitTagging, DistributionPointReasonFlags?>
    var reasons: DistributionPointReasonFlags?

    @ASN1ContextTagged<ASN1TagNumber$2, ASN1ImplicitTagging, GeneralNames?>
    var cRLIssuer: GeneralNames?
}

typealias CRLDistributionPoints = [DistributionPoint]

public struct PrivateKeyUsagePeriod: Codable {
    @ASN1ContextTagged<ASN1TagNumber$0, ASN1ImplicitTagging, GeneralizedTime?>
    var notBefore: GeneralizedTime?
    
    @ASN1ContextTagged<ASN1TagNumber$1, ASN1ImplicitTagging, GeneralizedTime?>
    var notAfter: GeneralizedTime?
}

public typealias CertPolicyId = ObjectIdentifier
public typealias PolicyQualifierId = ObjectIdentifier

public struct PolicyQualifierInfo: ASN1ObjectSetCodable {
    public static let knownTypes: [ObjectIdentifier: Codable.Type] = [:]

    @ASN1ObjectSetType
    var policyQualifierId: PolicyQualifierId
    
    @ASN1ObjectSetValue
    var qualifier: (any Codable)?
}

public typealias PolicyQualifierInfos = [PolicyQualifierInfo]

public struct PolicyInformation: Codable {
    var policyIdentifier: CertPolicyId
    var policyQualifiers: PolicyQualifierInfos?
}

typealias CertificatePolicies = [PolicyInformation]

public typealias SkipCerts = Int32

public struct AuthorityInfoAccess: Codable {
    var accessMethod: ObjectIdentifier
    var accessLocation: GeneralName
}

public typealias AuthorityInfoAccessSyntax = [AuthorityInfoAccess]

public let SubjectDirectoryAttributesOID = ObjectIdentifier(rawValue: "2.5.29.9")!
public let KeyUsageOID = ObjectIdentifier(rawValue: "2.5.29.15")!
public let ExtKeyUsageOID = ObjectIdentifier(rawValue: "2.5.29.37")!
public let SubjectKeyIdentifierOID = ObjectIdentifier(rawValue: "2.5.29.14")!
public let SubjectAltNameOID = ObjectIdentifier(rawValue: "2.5.29.17")!
public let BasicConstraintsOID = ObjectIdentifier(rawValue: "2.5.29.19")!
public let CRLDistributionPointsOID = ObjectIdentifier(rawValue: "2.5.29.31")!
public let CertificatePoliciesOID = ObjectIdentifier(rawValue: "2.5.29.32")!
public let AuthorityKeyIdentifierOID = ObjectIdentifier(rawValue: "2.5.29.35")!
public let InhibitAnyPolicyOID = ObjectIdentifier(rawValue: "2.5.29.54")!
public let AuthorityInfoAccessOID = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.1.1")!

public struct Extension: ASN1ObjectSetOctetStringCodable {
    public static let knownTypes: [ObjectIdentifier: Codable.Type] = [
        SubjectDirectoryAttributesOID : SubjectDirectoryAttributes.self,
        KeyUsageOID : KeyUsage.self,
        ExtKeyUsageOID : ExtKeyUsage.self,
        SubjectKeyIdentifierOID : KeyIdentifier.self,
        SubjectAltNameOID : GeneralNames.self,
        BasicConstraintsOID : BasicConstraints.self,
        CRLDistributionPointsOID : CRLDistributionPoints.self,
        CertificatePoliciesOID : CertificatePolicies.self,
        AuthorityKeyIdentifierOID : AuthorityKeyIdentifier.self,
        InhibitAnyPolicyOID : SkipCerts.self,
        AuthorityInfoAccessOID : AuthorityInfoAccessSyntax.self
    ]
    
    @ASN1ObjectSetType
    var extnID: ObjectIdentifier
    @DecodableDefault.False
    var critical: Bool
    @ASN1ObjectSetValue
    var extnValue: (any Codable)?
}

// must be class to support ASN1PreserveBinary on encode

public class TBSCertificate: Codable, ASN1PreserveBinary {
    public var _save: Data? = nil

    // Note to compiler implementor: CodingKeys must be specified for all
    // ASN.1 fields whenever a decoration (including _save) is used, to
    // avoid the encoding of the decorated types
    
    enum CodingKeys: String, CodingKey {
        case _version = "version"
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
    
    // this is another, more flexible way of implementing defaults and is what should be emitted by the compiler
    var version: Version {
        get {
            return self._version ?? .rfc3280_version_1
        }
        set {
            self._version = newValue
        }
    }
    
    @ASN1ContextTagged<ASN1TagNumber$0, ASN1DefaultTagging, Version?>
    var _version: Version?
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
        self._version = version
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
