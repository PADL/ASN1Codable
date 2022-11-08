/// HeimASN1Translator generated 2022-11-14 04:31:54 +0000

import Foundation
import BigNumber
import AnyCodable
import ASN1CodingKit

// ASN.1 module RFC2459 with explicit tagging
typealias Version = Int
let rfc3280_version_1: Version = 0
let rfc3280_version_2: Version = 1
let rfc3280_version_3: Version = 2

var id_pkcs_1: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.840.113549.1.1")!

var id_pkcs1_rsaEncryption: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.840.113549.1.1.1")!

var id_pkcs1_md2WithRSAEncryption: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.840.113549.1.1.2")!

var id_pkcs1_md5WithRSAEncryption: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.840.113549.1.1.4")!

var id_pkcs1_sha1WithRSAEncryption: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.840.113549.1.1.5")!

var id_pkcs1_sha256WithRSAEncryption: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.840.113549.1.1.11")!

var id_pkcs1_sha384WithRSAEncryption: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.840.113549.1.1.12")!

var id_pkcs1_sha512WithRSAEncryption: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.840.113549.1.1.13")!

var id_heim_rsa_pkcs1_x509: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.752.43.16.1")!

var id_pkcs_2: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.840.113549.1.2")!

var id_pkcs2_md2: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.840.113549.1.2.2")!

var id_pkcs2_md4: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.840.113549.1.2.4")!

var id_pkcs2_md5: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.840.113549.1.2.5")!

var id_rsa_digestAlgorithm: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.840.113549.2")!

var id_rsa_digest_md2: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.840.113549.2.2")!

var id_rsa_digest_md4: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.840.113549.2.4")!

var id_rsa_digest_md5: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.840.113549.2.5")!

var id_pkcs_3: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.840.113549.1.3")!

var id_pkcs3_rc2_cbc: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.840.113549.1.3.2")!

var id_pkcs3_rc4: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.840.113549.1.3.4")!

var id_pkcs3_des_ede3_cbc: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.840.113549.1.3.7")!

var id_rsadsi_encalg: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.840.113549.3")!

var id_rsadsi_rc2_cbc: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.840.113549.3.2")!

var id_rsadsi_des_ede3_cbc: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.840.113549.3.7")!

var id_secsig_sha_1: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.14.3.2.26")!

var id_secsig_sha_1WithRSAEncryption: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.14.3.2.29")!

var id_nistAlgorithm: ObjectIdentifier = ObjectIdentifier(rawValue: "2.16.840.1.101.3.4")!

var id_nist_aes_algs: ObjectIdentifier = ObjectIdentifier(rawValue: "2.16.840.1.101.3.4.1")!

var id_aes_128_cbc: ObjectIdentifier = ObjectIdentifier(rawValue: "2.16.840.1.101.3.4.1.2")!

var id_aes_192_cbc: ObjectIdentifier = ObjectIdentifier(rawValue: "2.16.840.1.101.3.4.1.22")!

var id_aes_256_cbc: ObjectIdentifier = ObjectIdentifier(rawValue: "2.16.840.1.101.3.4.1.42")!

var id_nist_sha_algs: ObjectIdentifier = ObjectIdentifier(rawValue: "2.16.840.1.101.3.4.2")!

var id_sha256: ObjectIdentifier = ObjectIdentifier(rawValue: "2.16.840.1.101.3.4.2.1")!

var id_sha224: ObjectIdentifier = ObjectIdentifier(rawValue: "2.16.840.1.101.3.4.2.4")!

var id_sha384: ObjectIdentifier = ObjectIdentifier(rawValue: "2.16.840.1.101.3.4.2.2")!

var id_sha512: ObjectIdentifier = ObjectIdentifier(rawValue: "2.16.840.1.101.3.4.2.3")!

var id_dhpublicnumber: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.840.10046.2.1")!

var id_ecPublicKey: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.840.10045.2.1")!

var id_ecDH: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.132.1.12")!

var id_ecMQV: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.132.1.13")!

var id_ecdsa_with_SHA512: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.840.10045.4.3.4")!

var id_ecdsa_with_SHA384: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.840.10045.4.3.3")!

var id_ecdsa_with_SHA256: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.840.10045.4.3.2")!

var id_ecdsa_with_SHA224: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.840.10045.4.3.1")!

var id_ecdsa_with_SHA1: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.840.10045.4.1")!

var id_ec_group_secp256r1: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.840.10045.3.1.7")!

var id_ec_group_secp160r1: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.132.0.8")!

var id_ec_group_secp160r2: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.132.0.30")!

var id_ec_group_secp224r1: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.132.0.33")!

var id_ec_group_secp384r1: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.132.0.34")!

var id_ec_group_secp521r1: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.132.0.35")!

var id_x9_57: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.840.10046.4")!

var id_dsa: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.840.10046.4.1")!

var id_dsa_with_sha1: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.840.10046.4.3")!

var id_x520_at: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.4")!

var id_at_commonName: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.4.3")!

var id_at_surname: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.4.4")!

var id_at_serialNumber: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.4.5")!

var id_at_countryName: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.4.6")!

var id_at_localityName: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.4.7")!

var id_at_stateOrProvinceName: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.4.8")!

var id_at_streetAddress: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.4.9")!

var id_at_organizationName: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.4.10")!

var id_at_organizationalUnitName: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.4.11")!

var id_at_title: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.4.12")!

var id_at_description: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.4.13")!

var id_at_name: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.4.41")!

var id_at_givenName: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.4.42")!

var id_at_initials: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.4.43")!

var id_at_generationQualifier: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.4.44")!

var id_at_dnQualifier: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.4.46")!

var id_at_pseudonym: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.4.65")!

var id_Userid: ObjectIdentifier = ObjectIdentifier(rawValue: "0.9.2342.19200300.100.1.1")!

var id_domainComponent: ObjectIdentifier = ObjectIdentifier(rawValue: "0.9.2342.19200300.100.1.25")!

var id_at_emailAddress: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.840.113549.1.9.1")!

var id_x509_ce: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.29")!

typealias AttributeType = ObjectIdentifier

typealias AttributeValue = AnyCodable

typealias CertificateSerialNumber = BInt

typealias UniqueIdentifier = BitString

typealias DHPublicKey = BInt

var id_x509_ce_keyUsage: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.29.15")!

typealias KeyUsage = ASN1RawRepresentableBitString<_KeyUsage>
struct _KeyUsage: OptionSet, Codable {
    var rawValue: UInt16

    init(rawValue: UInt16) {
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


typealias CertPolicyId = ObjectIdentifier

typealias PolicyQualifierId = ObjectIdentifier

typealias CPSuri = IA5String<String>

var id_x509_ce_authorityKeyIdentifier: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.29.35")!

typealias KeyIdentifier = Data

var id_x509_ce_subjectKeyIdentifier: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.29.14")!

typealias SubjectKeyIdentifier = KeyIdentifier

var id_x509_ce_basicConstraints: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.29.19")!

var id_x509_ce_nameConstraints: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.29.30")!

typealias BaseDistance = UInt32

var id_x509_ce_privateKeyUsagePeriod: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.29.16")!

var id_x509_ce_certificatePolicies: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.29.32")!

var id_x509_ce_certificatePolicies_anyPolicy: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.29.32.0")!

var id_x509_ce_policyMappings: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.29.33")!

var id_x509_ce_subjectAltName: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.29.17")!

var id_x509_ce_issuerAltName: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.29.18")!

var id_x509_ce_subjectDirectoryAttributes: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.29.9")!

var id_x509_ce_policyConstraints: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.29.36")!

var id_x509_ce_extKeyUsage: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.29.37")!

var id_x509_ce_anyExtendedKeyUsage: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.29.37.0")!

var id_x509_ce_cRLReasons: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.29.21")!

var id_x509_ce_cRLDistributionPoints: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.29.31")!

var id_x509_ce_deltaCRLIndicator: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.29.27")!

var id_x509_ce_issuingDistributionPoint: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.29.28")!

var id_x509_ce_holdInstructionCode: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.29.23")!

var id_x509_ce_invalidityDate: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.29.24")!

var id_x509_ce_certificateIssuer: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.29.29")!

var id_x509_ce_inhibitAnyPolicy: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.29.54")!

var id_heim_ce_pkinit_princ_max_life: ObjectIdentifier = ObjectIdentifier(rawValue: "1.2.752.43.16.4")!

typealias DistributionPointReasonFlags = ASN1RawRepresentableBitString<_DistributionPointReasonFlags>
struct _DistributionPointReasonFlags: OptionSet, Codable {
    var rawValue: UInt16

    init(rawValue: UInt16) {
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


typealias DSAPublicKey = BInt

typealias ECPoint = Data

var id_x509_ce_cRLNumber: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.29.20")!

var id_x509_ce_freshestCRL: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.29.46")!

var id_x509_ce_cRLReason: ObjectIdentifier = ObjectIdentifier(rawValue: "2.5.29.21")!

enum CRLReason: Int, Codable {
    case unspecified = 0
    case keyCompromise = 1
    case cACompromise = 2
    case affiliationChanged = 3
    case superseded = 4
    case cessationOfOperation = 5
    case certificateHold = 6
    case removeFromCRL = 8
    case privilegeWithdrawn = 9
    case aACompromise = 10
}

typealias PKIXXmppAddr = UTF8String<String>

typealias SRVName = IA5String<String>

var id_pkix: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7")!

var id_pkix_on: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.8")!

var id_pkix_on_xmppAddr: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.8.5")!

var id_pkix_on_dnsSRV: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.8.7")!

var id_pkix_on_hardwareModuleName: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.8.4")!

var id_pkix_on_permanentIdentifier: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.8.3")!

var id_pkix_kp: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.3")!

var id_pkix_kp_serverAuth: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.3.1")!

var id_pkix_kp_clientAuth: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.3.2")!

var id_pkix_kp_codeSigning: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.3.3")!

var id_pkix_kp_emailProtection: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.3.4")!

var id_pkix_kp_ipsecEndSystem: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.3.5")!

var id_pkix_kp_ipsecTunnel: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.3.6")!

var id_pkix_kp_ipsecUser: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.3.7")!

var id_pkix_kp_timeStamping: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.3.8")!

var id_pkix_kp_OCSPSigning: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.3.9")!

var id_pkix_kp_DVCS: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.3.10")!

var id_pkix_kp_ipsecIKE: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.3.17")!

var id_pkix_kp_capwapAC: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.3.18")!

var id_pkix_kp_capwapWTP: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.3.19")!

var id_pkix_kp_sipDomain: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.3.20")!

var id_pkix_kp_secureShellClient: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.3.21")!

var id_pkix_kp_secureShellServer: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.3.22")!

var id_pkix_kp_sendRouter: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.3.23")!

var id_pkix_kp_sendProxiedRouter: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.3.24")!

var id_pkix_kp_sendOwner: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.3.25")!

var id_pkix_kp_sendProxiedOwner: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.3.26")!

var id_pkix_kp_cmcCA: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.3.27")!

var id_pkix_kp_cmcRA: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.3.28")!

var id_pkix_kp_cmcArchive: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.3.29")!

var id_pkix_kp_bgpsec_router: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.3.30")!

var id_msft: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.4.1.311")!

var id_msft_kp_msCodeInd: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.4.1.311.2.1.21")!

var id_msft_kp_msCodeCom: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.4.1.311.2.1.22")!

var id_msft_kp_msCTLSign: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.4.1.311.10.3.1")!

var id_msft_kp_msSGC: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.4.1.311.10.3.3")!

var id_msft_kp_msEFS: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.4.1.311.10.3.4")!

var id_msft_kp_msSmartcardLogin: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.4.1.311.20.2.2")!

var id_msft_kp_msUPN: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.4.1.311.20.2.3")!

var id_pkix_pe: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.1")!

var id_pkix_pe_authorityInfoAccess: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.1.1")!

var id_pkix_pe_proxyCertInfo: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.1.14")!

var id_pkix_pe_subjectInfoAccess: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.1.11")!

var id_pkix_ppl: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.21")!

var id_pkix_ppl_anyLanguage: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.21.0")!

var id_pkix_ppl_inheritAll: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.21.1")!

var id_pkix_ppl_independent: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.21.2")!

var tcg: ObjectIdentifier = ObjectIdentifier(rawValue: "2.23.133")!

var tcg_attribute: ObjectIdentifier = ObjectIdentifier(rawValue: "2.23.133.2")!

var tcg_kp: ObjectIdentifier = ObjectIdentifier(rawValue: "2.23.133.8")!

var tcg_at_tpmManufacturer: ObjectIdentifier = ObjectIdentifier(rawValue: "2.23.133.2.1")!

var tcg_at_tpmModel: ObjectIdentifier = ObjectIdentifier(rawValue: "2.23.133.2.2")!

var tcg_at_tpmVersion: ObjectIdentifier = ObjectIdentifier(rawValue: "2.23.133.2.3")!

var tcg_at_tpmSpecification: ObjectIdentifier = ObjectIdentifier(rawValue: "2.23.133.2.16")!

var tcg_at_tpmSecurityAssertions: ObjectIdentifier = ObjectIdentifier(rawValue: "2.23.133.2.18")!

var tcg_kp_EKCertificate: ObjectIdentifier = ObjectIdentifier(rawValue: "2.23.133.8.1")!

var tcg_tpm20: ObjectIdentifier = ObjectIdentifier(rawValue: "2.23.133.1.2")!

var tcg_on_ekPermIdSha256: ObjectIdentifier = ObjectIdentifier(rawValue: "2.23.133.12.1")!

var tcg_cap_verifiedTPMResidency: ObjectIdentifier = ObjectIdentifier(rawValue: "2.23.133.11.1.1")!

var tcg_cap_verifiedTPMFixed: ObjectIdentifier = ObjectIdentifier(rawValue: "2.23.133.11.1.2")!

var tcg_cap_verifiedTPMRestricted: ObjectIdentifier = ObjectIdentifier(rawValue: "2.23.133.11.1.3")!

enum EKGenerationType: Int, Codable {
    case ekgt_internal = 0
    case ekgt_injected = 1
    case ekgt_internalRevocable = 2
    case ekgt_injectedRevocable = 3
}

enum EKGenerationLocation: Int, Codable {
    case tpmManufacturer = 0
    case platformManufacturer = 1
    case ekCertSigner = 2
}

typealias EKCertificateGenerationLocation = EKGenerationLocation

enum EvaluationAssuranceLevel: Int, Codable {
    case ealevell = 1
    case ealevel2 = 2
    case ealevel3 = 3
    case ealevel4 = 4
    case ealevel5 = 5
    case ealevel6 = 6
    case ealevel7 = 7
}

enum SecurityLevel: Int, Codable {
    case sllevel1 = 1
    case sllevel2 = 2
    case sllevel3 = 3
    case sllevel4 = 4
}

enum StrengthOfFunction: Int, Codable {
    case sof_basic = 0
    case sof_medium = 1
    case sof_high = 2
}

enum EvaluationStatus: Int, Codable {
    case designedToMeet = 0
    case evaluationInProgress = 1
    case evaluationCompleted = 2
}

typealias TPMVersion = Int
let tpm_v1: TPMVersion = 0

var id_pkix_on_pkinit_ms_san: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.4.1.311.20.2.3")!

typealias AliasUTF8String = UTF8String<String>

typealias AliasIA5String = UTF8String<String>

typealias AliasPrintableString = PrintableString<String>

typealias X520name = DirectoryString

typealias X520CommonName = DirectoryString

typealias X520LocalityName = DirectoryString

typealias X520OrganizationName = DirectoryString

typealias X520StateOrProvinceName = DirectoryString

typealias X520OrganizationalUnitName = DirectoryString

typealias SkipCerts = UInt32

typealias HeimPkinitPrincMaxLifeSecs = UInt32

var id_uspkicommon_card_id: ObjectIdentifier = ObjectIdentifier(rawValue: "2.16.840.1.101.3.6.6")!

var id_uspkicommon_piv_interim: ObjectIdentifier = ObjectIdentifier(rawValue: "2.16.840.1.101.3.6.9.1")!

var id_netscape: ObjectIdentifier = ObjectIdentifier(rawValue: "2.16.840.1.113730")!

var id_netscape_cert_comment: ObjectIdentifier = ObjectIdentifier(rawValue: "2.16.840.1.113730.1.13")!

var id_ms_cert_enroll_domaincontroller: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.4.1.311.20.2")!






































var id_pkix_qt: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.2")!

var id_pkix_qt_cps: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.2.1")!

var id_pkix_qt_unotice: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.2.2")!

var id_pkix_ad: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.48")!

var id_pkix_ad_ocsp: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.48.1")!

var id_pkix_ad_caIssuers: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.48.2")!

var id_pkix_ad_timeStamping: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.48.3")!

var id_pkix_ad_caRepository: ObjectIdentifier = ObjectIdentifier(rawValue: "1.3.6.1.5.5.7.48.5")!

struct AlgorithmIdentifier: Codable {
    enum CodingKeys: String, CodingKey {
        case algorithm
        case parameters
    }

    var algorithm: ObjectIdentifier
    var parameters: AnyCodable?
}


enum DirectoryString: Codable, Equatable, Hashable {
    case ia5String(IA5String<String>)
    case printableString(PrintableString<String>)
    case universalString(UniversalString<String>)
    case utf8String(UTF8String<String>)
    case bmpString(BMPString<String>)
}

typealias AttributeValues = Set<AttributeValue>

struct Attribute: Codable {
    enum CodingKeys: String, CodingKey {
        case type
        case value
    }

    var type: AttributeType
    var value: AttributeValues
}

struct AttributeTypeAndValue: Codable, Equatable, Hashable {
    enum CodingKeys: String, CodingKey {
        case type
        case value
    }

    var type: AttributeType
    var value: DirectoryString
}

typealias RelativeDistinguishedName = Set<AttributeTypeAndValue>

typealias RDNSequence = Array<RelativeDistinguishedName>

enum Name: Codable {
    case rdnSequence(RDNSequence)
}

enum Time: Codable {
    case utcTime(UTCTime<Date>)
    case generalTime(GeneralizedTime<Date>)
}

struct Validity: Codable {
    enum CodingKeys: String, CodingKey {
        case notBefore
        case notAfter
    }

    var notBefore: Time
    var notAfter: Time
}

struct SubjectPublicKeyInfo: Codable {
    enum CodingKeys: String, CodingKey {
        case algorithm
        case subjectPublicKey
    }

    var algorithm: AlgorithmIdentifier
    var subjectPublicKey: BitString
}

public struct Extension: Codable, ASN1ObjectSetOctetStringCodable {
    public static let knownTypes: [AnyHashable : Codable.Type] = [
        id_heim_ce_pkinit_princ_max_life : HeimPkinitPrincMaxLifeSecs.self,
        id_pkix_pe_authorityInfoAccess : AuthorityInfoAccessSyntax.self,
        id_pkix_pe_subjectInfoAccess : SubjectInfoAccessSyntax.self,
        id_pkix_pe_proxyCertInfo : ProxyCertInfo.self,
        id_x509_ce_subjectDirectoryAttributes : SubjectDirectoryAttributes.self,
        id_x509_ce_subjectKeyIdentifier : SubjectKeyIdentifier.self,
        id_x509_ce_keyUsage : KeyUsage.self,
        id_x509_ce_privateKeyUsagePeriod : PrivateKeyUsagePeriod.self,
        id_x509_ce_subjectAltName : GeneralNames.self,
        id_x509_ce_issuerAltName : GeneralNames.self,
        id_x509_ce_basicConstraints : BasicConstraints.self,
        id_x509_ce_nameConstraints : NameConstraints.self,
        id_x509_ce_cRLDistributionPoints : CRLDistributionPoints.self,
        id_x509_ce_certificatePolicies : CertificatePolicies.self,
        id_x509_ce_policyMappings : PolicyMappings.self,
        id_x509_ce_authorityKeyIdentifier : AuthorityKeyIdentifier.self,
        id_x509_ce_policyConstraints : PolicyConstraints.self,
        id_x509_ce_extKeyUsage : ExtKeyUsage.self,
        id_x509_ce_freshestCRL : CRLDistributionPoints.self,
        id_x509_ce_inhibitAnyPolicy : SkipCerts.self,
    ]

    public enum CodingKeys: String, CodingKey {
        case extnID
        case _critical = "critical"
        case extnValue
    }

    @ASN1ObjectSetType
    var extnID: ObjectIdentifier
    var _critical: Bool?
    var critical: Bool {
        get { return self._critical ?? false }
        set { self._critical = newValue }
    }
    @ASN1ObjectSetValue
    var extnValue: (any Codable)?
}

typealias Extensions = Array<Extension>

struct TBSCertificate: Codable {
    enum CodingKeys: String, CodingKey {
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

    @ASN1ContextTagged<ASN1TagNumber$0, ASN1ExplicitTagging, Version?>
    var version: Version? = nil
    var serialNumber: CertificateSerialNumber
    var signature: AlgorithmIdentifier
    var issuer: Name
    var validity: Validity
    var subject: Name
    var subjectPublicKeyInfo: SubjectPublicKeyInfo
    @ASN1ContextTagged<ASN1TagNumber$1, ASN1ImplicitTagging, BitString?>
    var issuerUniqueID: BitString? = nil
    @ASN1ContextTagged<ASN1TagNumber$2, ASN1ImplicitTagging, BitString?>
    var subjectUniqueID: BitString? = nil
    @ASN1ContextTagged<ASN1TagNumber$3, ASN1ExplicitTagging, Extensions?>
    var extensions: Extensions? = nil
}

struct Certificate: Codable {
    enum CodingKeys: String, CodingKey {
        case tbsCertificate
        case signatureAlgorithm
        case signatureValue
    }

    var tbsCertificate: TBSCertificate
    var signatureAlgorithm: AlgorithmIdentifier
    var signatureValue: BitString
}

typealias Certificates = Array<Certificate>

struct ValidationParms: Codable {
    enum CodingKeys: String, CodingKey {
        case seed
        case pgenCounter
    }

    var seed: BitString
    var pgenCounter: BInt
}

struct DomainParameters: Codable {
    enum CodingKeys: String, CodingKey {
        case p
        case g
        case q
        case j
        case validationParms
    }

    var p: BInt
    var g: BInt
    var q: BInt?
    var j: BInt?
    var validationParms: ValidationParms?
}

struct DHParameter: Codable {
    enum CodingKeys: String, CodingKey {
        case prime
        case base
        case privateValueLength
    }

    var prime: BInt
    var base: BInt
    var privateValueLength: BInt?
}

public struct OtherName: Codable, ASN1ObjectSetCodable {
    public static let knownTypes: [AnyHashable : Codable.Type] = [
        id_pkix_on_pkinit_ms_san : AliasUTF8String.self,
        id_pkix_on_permanentIdentifier : PermanentIdentifier.self,
        id_pkix_on_hardwareModuleName : HardwareModuleName.self,
        id_pkix_on_xmppAddr : AliasUTF8String.self,
        id_pkix_on_dnsSRV : AliasIA5String.self,
    ]

    public enum CodingKeys: String, CodingKey {
        case type_id
        case value
    }

    @ASN1ObjectSetType
    var type_id: ObjectIdentifier
    @ASN1ContextTagged<ASN1TagNumber$0, ASN1ExplicitTagging, ASN1ObjectSetValue>
    var value: ASN1ObjectSetValue = ASN1ObjectSetValue()
}

enum GeneralName: Codable {
    case otherName(ASN1ContextTagged<ASN1TagNumber$0, ASN1ImplicitTagging, OtherName>)
    case rfc822Name(ASN1ContextTagged<ASN1TagNumber$1, ASN1ImplicitTagging, IA5String<String>>)
    case dNSName(ASN1ContextTagged<ASN1TagNumber$2, ASN1ImplicitTagging, IA5String<String>>)
    case directoryName(ASN1ContextTagged<ASN1TagNumber$4, ASN1ImplicitTagging, Name>)
    case uniformResourceIdentifier(ASN1ContextTagged<ASN1TagNumber$6, ASN1ImplicitTagging, IA5String<String>>)
    case iPAddress(ASN1ContextTagged<ASN1TagNumber$7, ASN1ImplicitTagging, Data>)
    case registeredID(ASN1ContextTagged<ASN1TagNumber$8, ASN1ImplicitTagging, ObjectIdentifier>)
}

typealias GeneralNames = Array<GeneralName>

struct PrivateKeyUsagePeriod: Codable {
    enum CodingKeys: String, CodingKey {
        case notBefore
        case notAfter
    }

    @ASN1ContextTagged<ASN1TagNumber$0, ASN1ImplicitTagging, GeneralizedTime<Date>?>
    var notBefore: GeneralizedTime<Date>? = nil
    @ASN1ContextTagged<ASN1TagNumber$1, ASN1ImplicitTagging, GeneralizedTime<Date>?>
    var notAfter: GeneralizedTime<Date>? = nil
}

public struct PolicyQualifierInfo: Codable, ASN1ObjectSetCodable {
    public static let knownTypes: [AnyHashable : Codable.Type] = [
        id_pkix_qt_cps : AliasIA5String.self,
        id_pkix_qt_unotice : UserNotice.self,
    ]

    public enum CodingKeys: String, CodingKey {
        case policyQualifierId
        case qualifier
    }

    @ASN1ObjectSetType
    var policyQualifierId: ObjectIdentifier
    @ASN1ObjectSetValue
    var qualifier: (any Codable)?
}

typealias PolicyQualifierInfos = Array<PolicyQualifierInfo>

struct PolicyInformation: Codable {
    enum CodingKeys: String, CodingKey {
        case policyIdentifier
        case policyQualifiers
    }

    var policyIdentifier: CertPolicyId
    var policyQualifiers: PolicyQualifierInfos?
}

typealias CertificatePolicies = Array<PolicyInformation>

enum DisplayText: Codable {
    case ia5String(IA5String<String>)
    case bmpString(BMPString<String>)
    case utf8String(UTF8String<String>)
}

struct NoticeReference: Codable {
    enum CodingKeys: String, CodingKey {
        case organization
        case noticeNumbers
    }

    var organization: DisplayText
    var noticeNumbers: Array<Int>
}

struct UserNotice: Codable {
    enum CodingKeys: String, CodingKey {
        case noticeRef
        case explicitText
    }

    var noticeRef: NoticeReference?
    var explicitText: DisplayText?
}

struct PolicyMapping: Codable {
    enum CodingKeys: String, CodingKey {
        case issuerDomainPolicy
        case subjectDomainPolicy
    }

    var issuerDomainPolicy: CertPolicyId
    var subjectDomainPolicy: CertPolicyId
}

typealias PolicyMappings = Array<PolicyMapping>

struct AuthorityKeyIdentifier: Codable {
    enum CodingKeys: String, CodingKey {
        case keyIdentifier
        case authorityCertIssuer
        case authorityCertSerialNumber
    }

    @ASN1ContextTagged<ASN1TagNumber$0, ASN1ImplicitTagging, Data?>
    var keyIdentifier: Data? = nil
    @ASN1ContextTagged<ASN1TagNumber$1, ASN1ImplicitTagging, Array<GeneralName>?>
    var authorityCertIssuer: Array<GeneralName>? = nil
    @ASN1ContextTagged<ASN1TagNumber$2, ASN1ImplicitTagging, Int?>
    var authorityCertSerialNumber: Int? = nil
}


struct BasicConstraints: Codable {
    enum CodingKeys: String, CodingKey {
        case _cA = "cA"
        case pathLenConstraint
    }

    var _cA: Bool?
    var cA: Bool {
        get { return self._cA ?? false }
        set { self._cA = newValue }
    }
    var pathLenConstraint: UInt32?
}

struct GeneralSubtree: Codable {
    enum CodingKeys: String, CodingKey {
        case base
        case _minimum = "minimum"
        case maximum
    }

    var base: GeneralName
    @ASN1ContextTagged<ASN1TagNumber$0, ASN1ImplicitTagging, BaseDistance?>
    var _minimum: BaseDistance?
    var minimum: BaseDistance {
        get { return self._minimum ?? 0 }
        set { self._minimum = newValue }
    }
    @ASN1ContextTagged<ASN1TagNumber$1, ASN1ImplicitTagging, BaseDistance?>
    var maximum: BaseDistance? = nil
}

typealias GeneralSubtrees = Array<GeneralSubtree>

struct NameConstraints: Codable {
    enum CodingKeys: String, CodingKey {
        case permittedSubtrees
        case excludedSubtrees
    }

    @ASN1ContextTagged<ASN1TagNumber$0, ASN1ImplicitTagging, Array<GeneralSubtree>?>
    var permittedSubtrees: Array<GeneralSubtree>? = nil
    @ASN1ContextTagged<ASN1TagNumber$1, ASN1ImplicitTagging, Array<GeneralSubtree>?>
    var excludedSubtrees: Array<GeneralSubtree>? = nil
}

typealias ExtKeyUsage = Array<ObjectIdentifier>

enum DistributionPointName: Codable {
    case fullName(ASN1ContextTagged<ASN1TagNumber$0, ASN1ImplicitTagging, Array<GeneralName>>)
    case nameRelativeToCRLIssuer(ASN1ContextTagged<ASN1TagNumber$1, ASN1ExplicitTagging, RelativeDistinguishedName>)
}

struct DistributionPoint: Codable {
    enum CodingKeys: String, CodingKey {
        case distributionPoint
        case reasons
        case cRLIssuer
    }

    @ASN1ContextTagged<ASN1TagNumber$0, ASN1ExplicitTagging, DistributionPointName?>
    var distributionPoint: DistributionPointName? = nil
    @ASN1ContextTagged<ASN1TagNumber$1, ASN1ImplicitTagging, DistributionPointReasonFlags?>
    var reasons: DistributionPointReasonFlags? = nil
    @ASN1ContextTagged<ASN1TagNumber$2, ASN1ImplicitTagging, GeneralNames?>
    var cRLIssuer: GeneralNames? = nil
}

typealias CRLDistributionPoints = Array<DistributionPoint>

struct DSASigValue: Codable {
    enum CodingKeys: String, CodingKey {
        case r
        case s
    }

    var r: BInt
    var s: BInt
}

struct DSAParams: Codable {
    enum CodingKeys: String, CodingKey {
        case p
        case q
        case g
    }

    var p: BInt
    var q: BInt
    var g: BInt
}

enum ECParameters: Codable {
    case namedCurve(ObjectIdentifier)
}

struct ECDSA_Sig_Value: Codable {
    enum CodingKeys: String, CodingKey {
        case r
        case s
    }

    var r: BInt
    var s: BInt
}

struct RSAPublicKey: Codable {
    enum CodingKeys: String, CodingKey {
        case modulus
        case publicExponent
    }

    var modulus: BInt
    var publicExponent: BInt
}

struct RSAPrivateKey: Codable {
    enum CodingKeys: String, CodingKey {
        case version
        case modulus
        case publicExponent
        case privateExponent
        case prime1
        case prime2
        case exponent1
        case exponent2
        case coefficient
    }

    var version: UInt32
    var modulus: BInt
    var publicExponent: BInt
    var privateExponent: BInt
    var prime1: BInt
    var prime2: BInt
    var exponent1: BInt
    var exponent2: BInt
    var coefficient: BInt
}

struct DigestInfo: Codable {
    enum CodingKeys: String, CodingKey {
        case digestAlgorithm
        case digest
    }

    var digestAlgorithm: AlgorithmIdentifier
    var digest: Data
}

struct HardwareModuleName: Codable {
    enum CodingKeys: String, CodingKey {
        case hwType
        case hwSerialNum
    }

    var hwType: ObjectIdentifier
    var hwSerialNum: Data
}

struct PermanentIdentifier: Codable {
    enum CodingKeys: String, CodingKey {
        case identifierValue
        case assigner
    }

    @UTF8String
    var identifierValue: String? = nil
    var assigner: ObjectIdentifier?
}

struct AccessDescription: Codable {
    enum CodingKeys: String, CodingKey {
        case accessMethod
        case accessLocation
    }

    var accessMethod: ObjectIdentifier
    var accessLocation: GeneralName
}

typealias AuthorityInfoAccessSyntax = Array<AccessDescription>

typealias SubjectInfoAccessSyntax = Array<AccessDescription>

struct ProxyPolicy: Codable {
    enum CodingKeys: String, CodingKey {
        case policyLanguage
        case policy
    }

    var policyLanguage: ObjectIdentifier
    var policy: Data?
}

struct ProxyCertInfo: Codable {
    enum CodingKeys: String, CodingKey {
        case pCPathLenConstraint
        case proxyPolicy
    }

    var pCPathLenConstraint: UInt32?
    var proxyPolicy: ProxyPolicy
}

struct TPMSecurityAssertions: Codable, ASN1ExtensibleType {
    enum CodingKeys: String, CodingKey {
        case _version = "version"
        case _fieldUpgradable = "fieldUpgradable"
        case ekGenerationType
        case ekGenerationLocation
        case ekCertificateGenerationLocation
        case ccInfo
        case fipsLevel
        case _iso9000Certified = "iso9000Certified"
        case iso9000Uri
    }

    var _version: TPMVersion?
    var version: TPMVersion {
        get { return self._version ?? 0 }
        set { self._version = newValue }
    }
    var _fieldUpgradable: Bool?
    var fieldUpgradable: Bool {
        get { return self._fieldUpgradable ?? false }
        set { self._fieldUpgradable = newValue }
    }
    @ASN1ContextTagged<ASN1TagNumber$0, ASN1ExplicitTagging, EKGenerationType?>
    var ekGenerationType: EKGenerationType? = nil
    @ASN1ContextTagged<ASN1TagNumber$1, ASN1ExplicitTagging, EKGenerationLocation?>
    var ekGenerationLocation: EKGenerationLocation? = nil
    @ASN1ContextTagged<ASN1TagNumber$2, ASN1ExplicitTagging, EKCertificateGenerationLocation?>
    var ekCertificateGenerationLocation: EKCertificateGenerationLocation? = nil
    @ASN1ContextTagged<ASN1TagNumber$3, ASN1ExplicitTagging, CommonCriteriaMeasures?>
    var ccInfo: CommonCriteriaMeasures? = nil
    @ASN1ContextTagged<ASN1TagNumber$4, ASN1ExplicitTagging, FIPSLevel?>
    var fipsLevel: FIPSLevel? = nil
    @ASN1ContextTagged<ASN1TagNumber$5, ASN1ExplicitTagging, Bool?>
    var _iso9000Certified: Bool?
    var iso9000Certified: Bool {
        get { return self._iso9000Certified ?? false }
        set { self._iso9000Certified = newValue }
    }
    @IA5String
    var iso9000Uri: String? = nil
}

struct TPMSpecification: Codable, ASN1ExtensibleType {
    enum CodingKeys: String, CodingKey {
        case family
        case level
        case revision
    }

    @UTF8String
    var family: String = ""
    var level: UInt32
    var revision: UInt32
}


struct URIReference: Codable {
    enum CodingKeys: String, CodingKey {
        case uniformResourceIdentifier
        case hashAlgorithm
        case hashValue
    }

    @IA5String
    var uniformResourceIdentifier: String = ""
    var hashAlgorithm: AlgorithmIdentifier?
    var hashValue: BitString?
}

struct CommonCriteriaMeasures: Codable, ASN1ExtensibleType {
    enum CodingKeys: String, CodingKey {
        case version
        case assurancelevel
        case evaluationStatus
        case _plus = "plus"
        case strengthOfFunction
        case profileOid
        case profileUri
        case targetOid
        case targetUri
    }

    @IA5String
    var version: String = ""
    var assurancelevel: EvaluationAssuranceLevel
    var evaluationStatus: EvaluationStatus
    var _plus: Bool?
    var plus: Bool {
        get { return self._plus ?? false }
        set { self._plus = newValue }
    }
    @ASN1ContextTagged<ASN1TagNumber$0, ASN1ImplicitTagging, StrengthOfFunction?>
    var strengthOfFunction: StrengthOfFunction? = nil
    @ASN1ContextTagged<ASN1TagNumber$1, ASN1ImplicitTagging, ObjectIdentifier?>
    var profileOid: ObjectIdentifier? = nil
    @ASN1ContextTagged<ASN1TagNumber$2, ASN1ImplicitTagging, URIReference?>
    var profileUri: URIReference? = nil
    @ASN1ContextTagged<ASN1TagNumber$3, ASN1ImplicitTagging, ObjectIdentifier?>
    var targetOid: ObjectIdentifier? = nil
    @ASN1ContextTagged<ASN1TagNumber$4, ASN1ImplicitTagging, URIReference?>
    var targetUri: URIReference? = nil
}

struct FIPSLevel: Codable, ASN1ExtensibleType {
    enum CodingKeys: String, CodingKey {
        case version
        case level
        case _plus = "plus"
    }

    @IA5String
    var version: String = ""
    var level: SecurityLevel
    var _plus: Bool?
    var plus: Bool {
        get { return self._plus ?? false }
        set { self._plus = newValue }
    }
}







public struct SingleAttribute: Codable, ASN1ObjectSetCodable {
    public static let knownTypes: [AnyHashable : Codable.Type] = [
        id_domainComponent : AliasIA5String.self,
        id_at_emailAddress : AliasIA5String.self,
        id_at_commonName : X520CommonName.self,
        id_at_surname : X520name.self,
        id_at_serialNumber : AliasPrintableString.self,
        id_at_countryName : AliasPrintableString.self,
        id_at_localityName : X520LocalityName.self,
        id_at_stateOrProvinceName : DirectoryString.self,
        id_at_organizationName : DirectoryString.self,
        id_at_organizationalUnitName : DirectoryString.self,
        id_at_title : DirectoryString.self,
        id_at_name : X520name.self,
        id_at_givenName : X520name.self,
        id_at_initials : X520name.self,
        id_at_generationQualifier : X520name.self,
        id_at_dnQualifier : AliasPrintableString.self,
        id_at_pseudonym : DirectoryString.self,
        tcg_at_tpmManufacturer : AliasUTF8String.self,
        tcg_at_tpmModel : AliasUTF8String.self,
        tcg_at_tpmVersion : AliasUTF8String.self,
        tcg_at_tpmSpecification : TPMSpecification.self,
        tcg_at_tpmSecurityAssertions : TPMSecurityAssertions.self,
    ]

    public enum CodingKeys: String, CodingKey {
        case type
        case value
    }

    @ASN1ObjectSetType
    var type: ObjectIdentifier
    @ASN1ObjectSetValue
    var value: (any Codable)?
}

public struct AttributeSet: Codable, ASN1ObjectSetCodable {
    public static let knownTypes: [AnyHashable : Codable.Type] = [
        id_domainComponent : AliasIA5String.self,
        id_at_emailAddress : AliasIA5String.self,
        id_at_commonName : X520CommonName.self,
        id_at_surname : X520name.self,
        id_at_serialNumber : AliasPrintableString.self,
        id_at_countryName : AliasPrintableString.self,
        id_at_localityName : X520LocalityName.self,
        id_at_stateOrProvinceName : DirectoryString.self,
        id_at_organizationName : DirectoryString.self,
        id_at_organizationalUnitName : DirectoryString.self,
        id_at_title : DirectoryString.self,
        id_at_name : X520name.self,
        id_at_givenName : X520name.self,
        id_at_initials : X520name.self,
        id_at_generationQualifier : X520name.self,
        id_at_dnQualifier : AliasPrintableString.self,
        id_at_pseudonym : DirectoryString.self,
        tcg_at_tpmManufacturer : AliasUTF8String.self,
        tcg_at_tpmModel : AliasUTF8String.self,
        tcg_at_tpmVersion : AliasUTF8String.self,
        tcg_at_tpmSpecification : TPMSpecification.self,
        tcg_at_tpmSecurityAssertions : TPMSecurityAssertions.self,
    ]

    public enum CodingKeys: String, CodingKey {
        case type
        case values
    }

    @ASN1ObjectSetType
    var type: ObjectIdentifier
    var values: Set<ASN1AnyObjectSetValue>
}

typealias SubjectDirectoryAttributes = Array<AttributeSet>

struct PolicyConstraints: Codable {
    enum CodingKeys: String, CodingKey {
        case requireExplicitPolicy
        case inhibitPolicyMapping
    }

    @ASN1ContextTagged<ASN1TagNumber$0, ASN1ImplicitTagging, SkipCerts?>
    var requireExplicitPolicy: SkipCerts? = nil
    @ASN1ContextTagged<ASN1TagNumber$1, ASN1ImplicitTagging, SkipCerts?>
    var inhibitPolicyMapping: SkipCerts? = nil
}

