//
//  rfc2459.swift
//  asn1bridgetest
//
//  Created by Luke Howard on 24/10/2022.
//

import Foundation
import ASN1Kit
import ASN1CodingKit
import AnyCodable // FIXME

public enum Version: Int, Codable {
    case rfc3280_version_1 = 0
    case rfc3280_version_2 = 1
    case rfc3280_version_3 = 2
}

public typealias CertificateSerialNumber = Int

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
    case universalString(UniveralString<String>)
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

public let SubjectAltNameOID = ObjectIdentifier(rawValue: "2.5.29.17")!

public enum GeneralName: Codable {
    case rfc822Name(IA5String<String>)
}

public typealias GeneralNames = [GeneralName]

public typealias SkipCerts = Int32

public let InhibitAnyPolicyOID = ObjectIdentifier(rawValue: "2.5.29.54")!

public struct Extension: Codable {
    private static let knownTypes: [ObjectIdentifier: Any.Type] =
        [SubjectAltNameOID : GeneralNames.self,
         InhibitAnyPolicyOID : SkipCerts.self]

    var extnID: ObjectIdentifier
    var critical: Bool = false
    var extnValue: any Codable
    
    enum CodingKeys: CodingKey {
        case extnID
        case critical
        case extnValue
    }

    public init(extnID: ObjectIdentifier,
                critical: Bool = false,
                extnValue: any Codable) {
        self.extnID = extnID
        self.critical = critical
        self.extnValue = extnValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.extnID = try container.decode(ObjectIdentifier.self, forKey: .extnID)
        self.critical = try container.decode(Bool.self, forKey: .critical)
        
        let witness = try ASN1ObjectSet.type(for: self.extnID,
                                             in: Self.self,
                                             with: Self.knownTypes,
                                             userInfo: decoder.userInfo)
        let berData = try container.decode(Data.self, forKey: .extnValue)
        let innerDecoder = JSONDecoder() // XXX FIXME once ASN1Decoder exists!
        self.extnValue = try innerDecoder.decode(witness, from: berData)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.extnID, forKey: .extnID)
        try container.encode(self.critical, forKey: .critical)
        
        let innerEncoder = ASN1Encoder()
        let berData = try innerEncoder.encode(self.extnValue)
        try container.encode(berData, forKey: .extnValue)
    }
}

// must be class to support ASN1PreserveBinary on encode

public class TBSCertificate: Codable, ASN1PreserveBinary {
    public var _save: Data? = nil
    
    // CodingKeys required to omit _save on encode
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

    @ASN1ContextTagged<ASN1TagNumber$0, Version?>
    var version: Version?
    var serialNumber: CertificateSerialNumber
    var signature: AlgorithmIdentifier
    var issuer: Name
    var validity: Validity
    var subject: Name
    var subjectPublicKeyInfo: SubjectPublicKeyInfo
    
    // FIXME remove need for placeholder value when using nested property wrappers and optionals
    @ASN1ContextTagged<ASN1TagNumber$1, ASN1ImplicitlyTagged<BitString?>>
    @ASN1ImplicitlyTagged<BitString?>
    var issuerUniqueID: BitString? = BitString()

    // FIXME remove need for placeholder value when using nested property wrappers and optionals
    @ASN1ContextTagged<ASN1TagNumber$2, ASN1ImplicitlyTagged<BitString?>>
    @ASN1ImplicitlyTagged<BitString?>
    var subjectUniqueID: BitString? = BitString()
    
    @ASN1ContextTagged<ASN1TagNumber$3, [Extension]?>
    var extensions: [Extension]?
    
    public init(version: Version? = nil,
                serialNumber: CertificateSerialNumber,
                signature: AlgorithmIdentifier,
                issuer: Name,
                validity: Validity,
                subject: Name,
                subjectPublicKeyInfo: SubjectPublicKeyInfo,
                issuerUniqueID: BitString? = nil,
                subjectUniqueID: BitString? = nil,
                extensions: [Extension]? = nil) {
        self.version = version
        self.serialNumber = serialNumber
        self.signature = signature
        self.issuer = issuer
        self.validity = validity
        self.subject = subject
        self.subjectPublicKeyInfo = subjectPublicKeyInfo
        self.issuerUniqueID = issuerUniqueID
        self.subjectUniqueID = subjectUniqueID
        self.extensions = extensions
    }
}

public struct Certificate: Codable {
    var tbsCertificate: TBSCertificate
    var signatureAlgorithm: AlgorithmIdentifier
    var signatureValue: BitString = BitString()
}
