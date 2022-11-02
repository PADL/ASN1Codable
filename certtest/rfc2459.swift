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

/*
public enum DirectoryString: Codable, Hashable {
    case ia5String(IA5String<String>)
    case printableString(PrintableString<String>)
    case universalString(UniversalString<String>)
    case utf8String(UTF8String<String>)
    case bmpString(BMPString<String>)
}
 */

typealias DirectoryString = String

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

public enum Name: Codable, ASN1ChoiceCodable {
    // FIXME temporary
    enum CodingKeys: CodingKey {
        case rdnSequence
    }

    public static var allCodingKeys: [CodingKey] {
        return [CodingKeys.rdnSequence]
    }
    
    public static func type(for key: any CodingKey) -> Any.Type {
        let key = key as! Name.CodingKeys
        switch key {
        case .rdnSequence:
            return RDNSequence.self
        }
    }
    
    case rdnSequence(RDNSequence)
}

public enum Time: Codable, ASN1ChoiceCodable {
    case utcTime(UTCTime)
    case generalTime(GeneralizedTime)
    
    // FIXME temporary
    enum CodingKeys: CodingKey {
        case utcTime
        case generalTime
    }

    public static var allCodingKeys: [CodingKey] {
        return [CodingKeys.utcTime, CodingKeys.generalTime]
    }
    
    public static func type(for key: any CodingKey) -> Any.Type {
        let key = key as! Time.CodingKeys
        switch key {
        case .utcTime:
            return UTCTime.self
        case .generalTime:
            return GeneralizedTime.self
        }
    }
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

public enum GeneralName: Codable, ASN1ChoiceCodable {
    //FIXME IA5String
    case rfc822Name(ASN1ContextTagged<ASN1TagNumber$1, ASN1ImplicitTagging, String>)
    
    // FIXME temporary
    enum CodingKeys: CodingKey {
        case rfc822Name
    }

    public static var allCodingKeys: [CodingKey] {
        return [CodingKeys.rfc822Name]
    }
    
    public static func type(for key: any CodingKey) -> Any.Type {
        let key = key as! GeneralName.CodingKeys
        switch key {
        case .rfc822Name:
            return ASN1ContextTagged<ASN1TagNumber$1, ASN1ImplicitTagging, String>.self
        }
    }
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
        let innerDecoder = ASN1Decoder()
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

    // MBZ before encode
    public var _save: Data? = nil

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
