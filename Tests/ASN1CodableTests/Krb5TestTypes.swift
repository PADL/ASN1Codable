import BigNumber
import AnyCodable
import Foundation
import ASN1Codable

typealias NAME_TYPE = Int
let KRB5_NT_UNKNOWN: NAME_TYPE = 0
let KRB5_NT_PRINCIPAL: NAME_TYPE = 1
let KRB5_NT_SRV_INST: NAME_TYPE = 2
let KRB5_NT_SRV_HST: NAME_TYPE = 3
let KRB5_NT_SRV_XHST: NAME_TYPE = 4
let KRB5_NT_UID: NAME_TYPE = 5
let KRB5_NT_X500_PRINCIPAL: NAME_TYPE = 6
let KRB5_NT_SMTP_NAME: NAME_TYPE = 7
let KRB5_NT_ENTERPRISE_PRINCIPAL: NAME_TYPE = 10
let KRB5_NT_WELLKNOWN: NAME_TYPE = 11
let KRB5_NT_SRV_HST_DOMAIN: NAME_TYPE = 12
let KRB5_NT_ENT_PRINCIPAL_AND_ID: NAME_TYPE = -130
let KRB5_NT_MS_PRINCIPAL: NAME_TYPE = -128
let KRB5_NT_MS_PRINCIPAL_AND_ID: NAME_TYPE = -129
let KRB5_NT_NTLM: NAME_TYPE = -1200
let KRB5_NT_X509_GENERAL_NAME: NAME_TYPE = -1201
let KRB5_NT_GSS_HOSTBASED_SERVICE: NAME_TYPE = -1202
let KRB5_NT_CACHE_UUID: NAME_TYPE = -1203
let KRB5_NT_SRV_HST_NEEDS_CANON: NAME_TYPE = -195_894_762

typealias MESSAGE_TYPE = Int
let krb_as_req: MESSAGE_TYPE = 10
let krb_as_rep: MESSAGE_TYPE = 11
let krb_tgs_req: MESSAGE_TYPE = 12
let krb_tgs_rep: MESSAGE_TYPE = 13
let krb_ap_req: MESSAGE_TYPE = 14
let krb_ap_rep: MESSAGE_TYPE = 15
let krb_safe: MESSAGE_TYPE = 20
let krb_priv: MESSAGE_TYPE = 21
let krb_cred: MESSAGE_TYPE = 22
let krb_error: MESSAGE_TYPE = 30

typealias PADATA_TYPE = Int
let KRB5_PADATA_NONE: PADATA_TYPE = 0
let KRB5_PADATA_TGS_REQ: PADATA_TYPE = 1
let KRB5_PADATA_AP_REQ: PADATA_TYPE = 1
let KRB5_PADATA_ENC_TIMESTAMP: PADATA_TYPE = 2
let KRB5_PADATA_PW_SALT: PADATA_TYPE = 3
let KRB5_PADATA_ENC_UNIX_TIME: PADATA_TYPE = 5
let KRB5_PADATA_SANDIA_SECUREID: PADATA_TYPE = 6
let KRB5_PADATA_SESAME: PADATA_TYPE = 7
let KRB5_PADATA_OSF_DCE: PADATA_TYPE = 8
let KRB5_PADATA_CYBERSAFE_SECUREID: PADATA_TYPE = 9
let KRB5_PADATA_AFS3_SALT: PADATA_TYPE = 10
let KRB5_PADATA_ETYPE_INFO: PADATA_TYPE = 11
let KRB5_PADATA_SAM_CHALLENGE: PADATA_TYPE = 12
let KRB5_PADATA_SAM_RESPONSE: PADATA_TYPE = 13
let KRB5_PADATA_PK_AS_REQ_19: PADATA_TYPE = 14
let KRB5_PADATA_PK_AS_REP_19: PADATA_TYPE = 15
let KRB5_PADATA_PK_AS_REQ_WIN: PADATA_TYPE = 15
let KRB5_PADATA_PK_AS_REQ: PADATA_TYPE = 16
let KRB5_PADATA_PK_AS_REP: PADATA_TYPE = 17
let KRB5_PADATA_PA_PK_OCSP_RESPONSE: PADATA_TYPE = 18
let KRB5_PADATA_ETYPE_INFO2: PADATA_TYPE = 19
let KRB5_PADATA_USE_SPECIFIED_KVNO: PADATA_TYPE = 20
let KRB5_PADATA_SVR_REFERRAL_INFO: PADATA_TYPE = 20
let KRB5_PADATA_SAM_REDIRECT: PADATA_TYPE = 21
let KRB5_PADATA_GET_FROM_TYPED_DATA: PADATA_TYPE = 22
let KRB5_PADATA_SAM_ETYPE_INFO: PADATA_TYPE = 23
let KRB5_PADATA_SERVER_REFERRAL: PADATA_TYPE = 25
let KRB5_PADATA_ALT_PRINC: PADATA_TYPE = 24
let KRB5_PADATA_SAM_CHALLENGE2: PADATA_TYPE = 30
let KRB5_PADATA_SAM_RESPONSE2: PADATA_TYPE = 31
let KRB5_PA_EXTRA_TGT: PADATA_TYPE = 41
let KRB5_PADATA_FX_FAST_ARMOR: PADATA_TYPE = 71
let KRB5_PADATA_TD_KRB_PRINCIPAL: PADATA_TYPE = 102
let KRB5_PADATA_PK_TD_TRUSTED_CERTIFIERS: PADATA_TYPE = 104
let KRB5_PADATA_PK_TD_CERTIFICATE_INDEX: PADATA_TYPE = 105
let KRB5_PADATA_TD_APP_DEFINED_ERROR: PADATA_TYPE = 106
let KRB5_PADATA_TD_REQ_NONCE: PADATA_TYPE = 107
let KRB5_PADATA_TD_REQ_SEQ: PADATA_TYPE = 108
let KRB5_PADATA_PA_PAC_REQUEST: PADATA_TYPE = 128
let KRB5_PADATA_FOR_USER: PADATA_TYPE = 129
let KRB5_PADATA_FOR_X509_USER: PADATA_TYPE = 130
let KRB5_PADATA_FOR_CHECK_DUPS: PADATA_TYPE = 131
let KRB5_PADATA_AS_CHECKSUM: PADATA_TYPE = 132
let KRB5_PADATA_PK_AS_09_BINDING: PADATA_TYPE = 132
let KRB5_PADATA_FX_COOKIE: PADATA_TYPE = 133
let KRB5_PADATA_AUTHENTICATION_SET: PADATA_TYPE = 134
let KRB5_PADATA_AUTH_SET_SELECTED: PADATA_TYPE = 135
let KRB5_PADATA_FX_FAST: PADATA_TYPE = 136
let KRB5_PADATA_FX_ERROR: PADATA_TYPE = 137
let KRB5_PADATA_ENCRYPTED_CHALLENGE: PADATA_TYPE = 138
let KRB5_PADATA_OTP_CHALLENGE: PADATA_TYPE = 141
let KRB5_PADATA_OTP_REQUEST: PADATA_TYPE = 142
let KBB5_PADATA_OTP_CONFIRM: PADATA_TYPE = 143
let KRB5_PADATA_OTP_PIN_CHANGE: PADATA_TYPE = 144
let KRB5_PADATA_EPAK_AS_REQ: PADATA_TYPE = 145
let KRB5_PADATA_EPAK_AS_REP: PADATA_TYPE = 146
let KRB5_PADATA_PKINIT_KX: PADATA_TYPE = 147
let KRB5_PADATA_PKU2U_NAME: PADATA_TYPE = 148
let KRB5_PADATA_REQ_ENC_PA_REP: PADATA_TYPE = 149
let KER5_PADATA_KERB_KEY_LIST_REQ: PADATA_TYPE = 161
let KER5_PADATA_KERB_PAKEY_LIST_REP: PADATA_TYPE = 162
let KRB5_PADATA_SUPPORTED_ETYPES: PADATA_TYPE = 165
let KRB5_PADATA_PAC_OPTIONS: PADATA_TYPE = 167
let KRB5_PADATA_GSS: PADATA_TYPE = 655

typealias AUTHDATA_TYPE = Int
let KRB5_AUTHDATA_IF_RELEVANT: AUTHDATA_TYPE = 1
let KRB5_AUTHDATA_INTENDED_FOR_SERVER: AUTHDATA_TYPE = 2
let KRB5_AUTHDATA_INTENDED_FOR_APPLICATION_CLASS: AUTHDATA_TYPE = 3
let KRB5_AUTHDATA_KDC_ISSUED: AUTHDATA_TYPE = 4
let KRB5_AUTHDATA_AND_OR: AUTHDATA_TYPE = 5
let KRB5_AUTHDATA_MANDATORY_TICKET_EXTENSIONS: AUTHDATA_TYPE = 6
let KRB5_AUTHDATA_IN_TICKET_EXTENSIONS: AUTHDATA_TYPE = 7
let KRB5_AUTHDATA_MANDATORY_FOR_KDC: AUTHDATA_TYPE = 8
let KRB5_AUTHDATA_INITIAL_VERIFIED_CAS: AUTHDATA_TYPE = 9
let KRB5_AUTHDATA_OSF_DCE: AUTHDATA_TYPE = 64
let KRB5_AUTHDATA_SESAME: AUTHDATA_TYPE = 65
let KRB5_AUTHDATA_OSF_DCE_PKI_CERTID: AUTHDATA_TYPE = 66
let KRB5_AUTHDATA_AUTHENTICATION_STRENGTH: AUTHDATA_TYPE = 70
let KRB5_AUTHDATA_FX_FAST_ARMOR: AUTHDATA_TYPE = 71
let KRB5_AUTHDATA_FX_FAST_USED: AUTHDATA_TYPE = 72
let KRB5_AUTHDATA_WIN2K_PAC: AUTHDATA_TYPE = 128
let KRB5_AUTHDATA_GSS_API_ETYPE_NEGOTIATION: AUTHDATA_TYPE = 129
let KRB5_AUTHDATA_SIGNTICKET_OLDER: AUTHDATA_TYPE = -17
let KRB5_AUTHDATA_SIGNTICKET_OLD: AUTHDATA_TYPE = 142
let KRB5_AUTHDATA_SIGNTICKET: AUTHDATA_TYPE = 512
let KRB5_AUTHDATA_SYNTHETIC_PRINC_USED: AUTHDATA_TYPE = 513
let KRB5_AUTHDATA_KERB_LOCAL: AUTHDATA_TYPE = 141
let KRB5_AUTHDATA_TOKEN_RESTRICTIONS: AUTHDATA_TYPE = 142
let KRB5_AUTHDATA_AP_OPTIONS: AUTHDATA_TYPE = 143
let KRB5_AUTHDATA_TARGET_PRINCIPAL: AUTHDATA_TYPE = 144
let KRB5_AUTHDATA_ON_BEHALF_OF: AUTHDATA_TYPE = 580
let KRB5_AUTHDATA_BEARER_TOKEN_JWT: AUTHDATA_TYPE = 581
let KRB5_AUTHDATA_BEARER_TOKEN_SAML: AUTHDATA_TYPE = 582
let KRB5_AUTHDATA_BEARER_TOKEN_OIDC: AUTHDATA_TYPE = 583
let KRB5_AUTHDATA_CSR_AUTHORIZED: AUTHDATA_TYPE = 584
let KRB5_AUTHDATA_GSS_COMPOSITE_NAME: AUTHDATA_TYPE = 655

typealias CKSUMTYPE = Int
let CKSUMTYPE_NONE: CKSUMTYPE = 0
let CKSUMTYPE_CRC32: CKSUMTYPE = 1
let CKSUMTYPE_RSA_MD4: CKSUMTYPE = 2
let CKSUMTYPE_RSA_MD4_DES: CKSUMTYPE = 3
let CKSUMTYPE_DES_MAC: CKSUMTYPE = 4
let CKSUMTYPE_DES_MAC_K: CKSUMTYPE = 5
let CKSUMTYPE_RSA_MD4_DES_K: CKSUMTYPE = 6
let CKSUMTYPE_RSA_MD5: CKSUMTYPE = 7
let CKSUMTYPE_RSA_MD5_DES: CKSUMTYPE = 8
let CKSUMTYPE_RSA_MD5_DES3: CKSUMTYPE = 9
let CKSUMTYPE_SHA1_OTHER: CKSUMTYPE = 10
let CKSUMTYPE_HMAC_SHA1_DES3: CKSUMTYPE = 12
let CKSUMTYPE_SHA1: CKSUMTYPE = 14
let CKSUMTYPE_HMAC_SHA1_96_AES_128: CKSUMTYPE = 15
let CKSUMTYPE_HMAC_SHA1_96_AES_256: CKSUMTYPE = 16
let CKSUMTYPE_HMAC_SHA256_128_AES128: CKSUMTYPE = 19
let CKSUMTYPE_HMAC_SHA384_192_AES256: CKSUMTYPE = 20
let CKSUMTYPE_GSSAPI: CKSUMTYPE = 32771
let CKSUMTYPE_HMAC_MD5: CKSUMTYPE = -138
let CKSUMTYPE_HMAC_MD5_ENC: CKSUMTYPE = -1138
let CKSUMTYPE_SHA256: CKSUMTYPE = -21
let CKSUMTYPE_SHA384: CKSUMTYPE = -22
let CKSUMTYPE_SHA512: CKSUMTYPE = -23

typealias ENCTYPE = Int
let KRB5_ENCTYPE_NULL: ENCTYPE = 0
let KRB5_ENCTYPE_DES_CBC_CRC: ENCTYPE = 1
let KRB5_ENCTYPE_DES_CBC_MD4: ENCTYPE = 2
let KRB5_ENCTYPE_DES_CBC_MD5: ENCTYPE = 3
let KRB5_ENCTYPE_DES3_CBC_MD5: ENCTYPE = 5
let KRB5_ENCTYPE_OLD_DES3_CBC_SHA1: ENCTYPE = 7
let KRB5_ENCTYPE_SIGN_DSA_GENERATE: ENCTYPE = 8
let KRB5_ENCTYPE_ENCRYPT_RSA_PRIV: ENCTYPE = 9
let KRB5_ENCTYPE_ENCRYPT_RSA_PUB: ENCTYPE = 10
let KRB5_ENCTYPE_DES3_CBC_SHA1: ENCTYPE = 16
let KRB5_ENCTYPE_AES128_CTS_HMAC_SHA1_96: ENCTYPE = 17
let KRB5_ENCTYPE_AES256_CTS_HMAC_SHA1_96: ENCTYPE = 18
let KRB5_ENCTYPE_AES128_CTS_HMAC_SHA256_128: ENCTYPE = 19
let KRB5_ENCTYPE_AES256_CTS_HMAC_SHA384_192: ENCTYPE = 20
let KRB5_ENCTYPE_ARCFOUR_HMAC_MD5: ENCTYPE = 23
let KRB5_ENCTYPE_ARCFOUR_HMAC_MD5_56: ENCTYPE = 24
let KRB5_ENCTYPE_ENCTYPE_PK_CROSS: ENCTYPE = 48
let KRB5_ENCTYPE_ARCFOUR_MD4: ENCTYPE = -128
let KRB5_ENCTYPE_ARCFOUR_HMAC_OLD: ENCTYPE = -133
let KRB5_ENCTYPE_ARCFOUR_HMAC_OLD_EXP: ENCTYPE = -135
let KRB5_ENCTYPE_DES_CBC_NONE: ENCTYPE = -4096
let KRB5_ENCTYPE_DES3_CBC_NONE: ENCTYPE = -4097
let KRB5_ENCTYPE_DES_CFB64_NONE: ENCTYPE = -4098
let KRB5_ENCTYPE_DES_PCBC_NONE: ENCTYPE = -4099
let KRB5_ENCTYPE_DIGEST_MD5_NONE: ENCTYPE = -4100
let KRB5_ENCTYPE_CRAM_MD5_NONE: ENCTYPE = -4101

typealias Krb5UInt32 = Swift.UInt32

typealias Krb5Int32 = Swift.Int32

typealias KerberosString = GeneralString<String>

typealias Realm = GeneralString<String>

typealias KerberosTime = GeneralizedTime<Date>

struct APOptions: RFC1510BitStringOptionSet, Codable {
    var rawValue: UInt8

    init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    static let reserved = APOptions(rawValue: 1 << 0)
    static let use_session_key = APOptions(rawValue: 1 << 1)
    static let mutual_required = APOptions(rawValue: 1 << 2)
}

struct TicketFlags: RFC1510BitStringOptionSet, Codable {
    var rawValue: UInt32

    init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    static let reserved = TicketFlags(rawValue: 1 << 0)
    static let forwardable = TicketFlags(rawValue: 1 << 1)
    static let forwarded = TicketFlags(rawValue: 1 << 2)
    static let proxiable = TicketFlags(rawValue: 1 << 3)
    static let proxy = TicketFlags(rawValue: 1 << 4)
    static let may_postdate = TicketFlags(rawValue: 1 << 5)
    static let postdated = TicketFlags(rawValue: 1 << 6)
    static let invalid = TicketFlags(rawValue: 1 << 7)
    static let renewable = TicketFlags(rawValue: 1 << 8)
    static let initial = TicketFlags(rawValue: 1 << 9)
    static let pre_authent = TicketFlags(rawValue: 1 << 10)
    static let hw_authent = TicketFlags(rawValue: 1 << 11)
    static let transited_policy_checked = TicketFlags(rawValue: 1 << 12)
    static let ok_as_delegate = TicketFlags(rawValue: 1 << 13)
    static let enc_pa_rep = TicketFlags(rawValue: 1 << 15)
    static let anonymous = TicketFlags(rawValue: 1 << 16)
}

struct KDCOptions: RFC1510BitStringOptionSet, Codable {
    var rawValue: UInt32

    init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    static let reserved = KDCOptions(rawValue: 1 << 0)
    static let forwardable = KDCOptions(rawValue: 1 << 1)
    static let forwarded = KDCOptions(rawValue: 1 << 2)
    static let proxiable = KDCOptions(rawValue: 1 << 3)
    static let proxy = KDCOptions(rawValue: 1 << 4)
    static let allow_postdate = KDCOptions(rawValue: 1 << 5)
    static let postdated = KDCOptions(rawValue: 1 << 6)
    static let renewable = KDCOptions(rawValue: 1 << 8)
    static let cname_in_addl_tkt = KDCOptions(rawValue: 1 << 14)
    static let canonicalize = KDCOptions(rawValue: 1 << 15)
    static let request_anonymous = KDCOptions(rawValue: 1 << 16)
    static let disable_transited_check = KDCOptions(rawValue: 1 << 26)
    static let renewable_ok = KDCOptions(rawValue: 1 << 27)
    static let enc_tkt_in_skey = KDCOptions(rawValue: 1 << 28)
    static let renew = KDCOptions(rawValue: 1 << 30)
    static let validate = KDCOptions(rawValue: 1 << 31)
}

typealias LR_TYPE = Int
let LR_NONE: LR_TYPE = 0
let LR_INITIAL_TGT: LR_TYPE = 1
let LR_INITIAL: LR_TYPE = 2
let LR_ISSUE_USE_TGT: LR_TYPE = 3
let LR_RENEWAL: LR_TYPE = 4
let LR_REQUEST: LR_TYPE = 5
let LR_PW_EXPTIME: LR_TYPE = 6
let LR_ACCT_EXPTIME: LR_TYPE = 7

typealias AS_REQ = ASN1ApplicationTagged<KERBEROS5.ASN1TagNumber$10, ASN1Codable.ASN1ExplicitTagging, KDC_REQ>

typealias TGS_REQ = ASN1ApplicationTagged<KERBEROS5.ASN1TagNumber$12, ASN1Codable.ASN1ExplicitTagging, KDC_REQ>

struct PAC_OPTIONS_FLAGS: RFC1510BitStringOptionSet, Codable {
    var rawValue: UInt8

    init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    static let claims = PAC_OPTIONS_FLAGS(rawValue: 1 << 0)
    static let branch_aware = PAC_OPTIONS_FLAGS(rawValue: 1 << 1)
    static let forward_to_full_dc = PAC_OPTIONS_FLAGS(rawValue: 1 << 2)
    static let resource_based_constrained_delegation = PAC_OPTIONS_FLAGS(rawValue: 1 << 3)
}

typealias PROV_SRV_LOCATION = GeneralString<String>

typealias AS_REP = ASN1ApplicationTagged<KERBEROS5.ASN1TagNumber$11, ASN1Codable.ASN1ExplicitTagging, KDC_REP>

typealias TGS_REP = ASN1ApplicationTagged<KERBEROS5.ASN1TagNumber$13, ASN1Codable.ASN1ExplicitTagging, KDC_REP>

typealias EncASRepPart = ASN1ApplicationTagged<KERBEROS5.ASN1TagNumber$25, ASN1Codable.ASN1ExplicitTagging, EncKDCRepPart>

typealias EncTGSRepPart = ASN1ApplicationTagged<KERBEROS5.ASN1TagNumber$26, ASN1Codable.ASN1ExplicitTagging, EncKDCRepPart>

var krb5_pvno: Int = 5

var domain_X500_Compress: Int = 1

typealias AD_IF_RELEVANT = AuthorizationData

typealias AD_MANDATORY_FOR_KDC = AuthorizationData

typealias PA_SAM_TYPE = Int
let PA_SAM_TYPE_ENIGMA: PA_SAM_TYPE = 1
let PA_SAM_TYPE_DIGI_PATH: PA_SAM_TYPE = 2
let PA_SAM_TYPE_SKEY_K0: PA_SAM_TYPE = 3
let PA_SAM_TYPE_SKEY: PA_SAM_TYPE = 4
let PA_SAM_TYPE_SECURID: PA_SAM_TYPE = 5
let PA_SAM_TYPE_CRYPTOCARD: PA_SAM_TYPE = 6

typealias PA_SAM_REDIRECT = HostAddresses

struct SAMFlags: RFC1510BitStringOptionSet, Codable {
    var rawValue: UInt8

    init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    static let use_sad_as_key = SAMFlags(rawValue: 1 << 0)
    static let send_encrypted_sad = SAMFlags(rawValue: 1 << 1)
    static let must_pk_encrypt_sad = SAMFlags(rawValue: 1 << 2)
}

typealias PA_SERVER_REFERRAL_DATA = EncryptedData

struct FastOptions: RFC1510BitStringOptionSet, Codable {
    var rawValue: UInt32

    init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    static let reserved = FastOptions(rawValue: 1 << 0)
    static let hide_client_names = FastOptions(rawValue: 1 << 1)
    static let critical2 = FastOptions(rawValue: 1 << 2)
    static let critical3 = FastOptions(rawValue: 1 << 3)
    static let critical4 = FastOptions(rawValue: 1 << 4)
    static let critical5 = FastOptions(rawValue: 1 << 5)
    static let critical6 = FastOptions(rawValue: 1 << 6)
    static let critical7 = FastOptions(rawValue: 1 << 7)
    static let critical8 = FastOptions(rawValue: 1 << 8)
    static let critical9 = FastOptions(rawValue: 1 << 9)
    static let critical10 = FastOptions(rawValue: 1 << 10)
    static let critical11 = FastOptions(rawValue: 1 << 11)
    static let critical12 = FastOptions(rawValue: 1 << 12)
    static let critical13 = FastOptions(rawValue: 1 << 13)
    static let critical14 = FastOptions(rawValue: 1 << 14)
    static let critical15 = FastOptions(rawValue: 1 << 15)
    static let kdc_follow_referrals = FastOptions(rawValue: 1 << 16)
}

struct KDCFastFlags: RFC1510BitStringOptionSet, Codable {
    var rawValue: UInt8

    init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    static let use_reply_key = KDCFastFlags(rawValue: 1 << 0)
    static let reply_key_used = KDCFastFlags(rawValue: 1 << 1)
    static let reply_key_replaced = KDCFastFlags(rawValue: 1 << 2)
    static let kdc_verified = KDCFastFlags(rawValue: 1 << 3)
    static let requested_hidden_names = KDCFastFlags(rawValue: 1 << 4)
}

struct PrincipalName: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case name_type
        case name_string

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .name_type:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .name_string:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            }

            return metadata
        }
    }

    var name_type: NAME_TYPE
    var name_string: [GeneralString<String>]
}

struct HostAddress: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case addr_type
        case address

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .addr_type:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .address:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            }

            return metadata
        }
    }

    var addr_type: Krb5Int32
    var address: Data
}

typealias HostAddresses = [HostAddress]

struct AuthorizationDataElement: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case ad_type
        case ad_data

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .ad_type:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .ad_data:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            }

            return metadata
        }
    }

    var ad_type: Krb5Int32
    var ad_data: Data
}

typealias AuthorizationData = [AuthorizationDataElement]

struct LastReqInner: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case lr_type
        case lr_value

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case lr_type:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case lr_value:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            }

            return metadata
        }
    }

    var lr_type: LR_TYPE
    var lr_value: KerberosTime
}

typealias LastReq = [LastReqInner]

struct EncryptedData: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case etype
        case kvno
        case cipher

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .etype:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .kvno:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .cipher:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            }

            return metadata
        }
    }

    var etype: ENCTYPE
    var kvno: Krb5Int32?
    var cipher: Data
}

struct EncryptionKey: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case keytype
        case keyvalue

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .keytype:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .keyvalue:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            }

            return metadata
        }
    }

    var keytype: Krb5Int32
    var keyvalue: Data
}

struct TransitedEncoding: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case tr_type
        case contents

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .tr_type:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .contents:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            }

            return metadata
        }
    }

    var tr_type: Krb5Int32
    var contents: Data
}

struct Ticket: Codable {
    static let metadata = ASN1Metadata(tag: .applicationTag(1), tagging: .explicit)

    enum CodingKeys: ASN1MetadataCodingKey {
        case tkt_vno
        case realm
        case sname
        case enc_part

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .tkt_vno:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .realm:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .sname:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            case .enc_part:
                metadata = ASN1Metadata(tag: .taggedTag(3), tagging: .explicit)
            }

            return metadata
        }
    }

    var tkt_vno: Krb5Int32
    var realm: Realm
    var sname: PrincipalName
    var enc_part: EncryptedData
}

struct EncTicketPart: Codable {
    static let metadata = ASN1Metadata(tag: .applicationTag(3), tagging: .explicit)

    enum CodingKeys: ASN1MetadataCodingKey {
        case flags
        case key
        case crealm
        case cname
        case transited
        case authtime
        case starttime
        case endtime
        case renew_till
        case caddr
        case authorization_data

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .flags:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .key:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .crealm:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            case .cname:
                metadata = ASN1Metadata(tag: .taggedTag(3), tagging: .explicit)
            case .transited:
                metadata = ASN1Metadata(tag: .taggedTag(4), tagging: .explicit)
            case .authtime:
                metadata = ASN1Metadata(tag: .taggedTag(5), tagging: .explicit)
            case .starttime:
                metadata = ASN1Metadata(tag: .taggedTag(6), tagging: .explicit)
            case .endtime:
                metadata = ASN1Metadata(tag: .taggedTag(7), tagging: .explicit)
            case .renew_till:
                metadata = ASN1Metadata(tag: .taggedTag(8), tagging: .explicit)
            case .caddr:
                metadata = ASN1Metadata(tag: .taggedTag(9), tagging: .explicit)
            case .authorization_data:
                metadata = ASN1Metadata(tag: .taggedTag(10), tagging: .explicit)
            }

            return metadata
        }
    }

    var flags: TicketFlags
    var key: EncryptionKey
    var crealm: Realm
    var cname: PrincipalName
    var transited: TransitedEncoding
    var authtime: KerberosTime
    var starttime: KerberosTime?
    var endtime: KerberosTime
    var renew_till: KerberosTime?
    var caddr: HostAddresses?
    var authorization_data: AuthorizationData?
}

struct Checksum: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case cksumtype
        case checksum

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .cksumtype:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .checksum:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            }

            return metadata
        }
    }

    var cksumtype: CKSUMTYPE
    var checksum: Data
}

struct EncKDCRepPart: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case key
        case last_req
        case nonce
        case key_expiration
        case flags
        case authtime
        case starttime
        case endtime
        case renew_till
        case srealm
        case sname
        case caddr
        case encrypted_pa_data

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .key:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .last_req:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .nonce:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            case .key_expiration:
                metadata = ASN1Metadata(tag: .taggedTag(3), tagging: .explicit)
            case .flags:
                metadata = ASN1Metadata(tag: .taggedTag(4), tagging: .explicit)
            case .authtime:
                metadata = ASN1Metadata(tag: .taggedTag(5), tagging: .explicit)
            case .starttime:
                metadata = ASN1Metadata(tag: .taggedTag(6), tagging: .explicit)
            case .endtime:
                metadata = ASN1Metadata(tag: .taggedTag(7), tagging: .explicit)
            case .renew_till:
                metadata = ASN1Metadata(tag: .taggedTag(8), tagging: .explicit)
            case .srealm:
                metadata = ASN1Metadata(tag: .taggedTag(9), tagging: .explicit)
            case .sname:
                metadata = ASN1Metadata(tag: .taggedTag(10), tagging: .explicit)
            case .caddr:
                metadata = ASN1Metadata(tag: .taggedTag(11), tagging: .explicit)
            case .encrypted_pa_data:
                metadata = ASN1Metadata(tag: .taggedTag(12), tagging: .explicit)
            }

            return metadata
        }
    }

    var key: EncryptionKey
    var last_req: LastReq
    var nonce: Krb5Int32
    var key_expiration: KerberosTime?
    var flags: TicketFlags
    var authtime: KerberosTime
    var starttime: KerberosTime?
    var endtime: KerberosTime
    var renew_till: KerberosTime?
    var srealm: Realm
    var sname: PrincipalName
    var caddr: HostAddresses?
    var encrypted_pa_data: METHOD_DATA?
}

enum PrincipalNameAttrSrc: Codable {
    enum CodingKeys: CaseIterable, ASN1MetadataCodingKey {
        case enc_kdc_rep_part
        case enc_ticket_part

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .enc_kdc_rep_part:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .enc_ticket_part:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            }

            return metadata
        }
    }

    case enc_kdc_rep_part(EncKDCRepPart)
    case enc_ticket_part(EncTicketPart)
}

struct PrincipalNameAttrs: Codable {
    var pac: Any?

    enum CodingKeys: ASN1MetadataCodingKey {
        case authenticated
        case source
        case authenticator_ad
        case peer_realm
        case transited
        case pac_verified
        case kdc_issued_verified
        case want_ad

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .authenticated:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .source:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .authenticator_ad:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            case .peer_realm:
                metadata = ASN1Metadata(tag: .taggedTag(3), tagging: .explicit)
            case .transited:
                metadata = ASN1Metadata(tag: .taggedTag(4), tagging: .explicit)
            case .pac_verified:
                metadata = ASN1Metadata(tag: .taggedTag(5), tagging: .explicit)
            case .kdc_issued_verified:
                metadata = ASN1Metadata(tag: .taggedTag(6), tagging: .explicit)
            case .want_ad:
                metadata = ASN1Metadata(tag: .taggedTag(7), tagging: .explicit)
            }

            return metadata
        }
    }

    var authenticated: Bool
    var source: PrincipalNameAttrSrc?
    var authenticator_ad: AuthorizationData?
    var peer_realm: Realm?
    var transited: TransitedEncoding?
    var pac_verified: Bool
    var kdc_issued_verified: Bool
    var want_ad: AuthorizationData?
}

struct CompositePrincipal: Codable {
    static let metadata = ASN1Metadata(tag: .applicationTag(48), tagging: .explicit)

    enum CodingKeys: ASN1MetadataCodingKey {
        case name
        case realm
        case nameattrs

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .name:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .realm:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .nameattrs:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            }

            return metadata
        }
    }

    var name: PrincipalName
    var realm: Realm
    var nameattrs: PrincipalNameAttrs?
}

struct Principal: Codable {
    var nameattrs: PrincipalNameAttrs?

    enum CodingKeys: ASN1MetadataCodingKey {
        case name
        case realm

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .name:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .realm:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            }

            return metadata
        }
    }

    var name: PrincipalName
    var realm: Realm
}

typealias Principals = [Principal]

struct Authenticator: Codable {
    static let metadata = ASN1Metadata(tag: .applicationTag(2), tagging: .explicit)

    enum CodingKeys: ASN1MetadataCodingKey {
        case authenticator_vno
        case crealm
        case cname
        case cksum
        case cusec
        case ctime
        case subkey
        case seq_number
        case authorization_data

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .authenticator_vno:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .crealm:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .cname:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            case .cksum:
                metadata = ASN1Metadata(tag: .taggedTag(3), tagging: .explicit)
            case .cusec:
                metadata = ASN1Metadata(tag: .taggedTag(4), tagging: .explicit)
            case .ctime:
                metadata = ASN1Metadata(tag: .taggedTag(5), tagging: .explicit)
            case .subkey:
                metadata = ASN1Metadata(tag: .taggedTag(6), tagging: .explicit)
            case .seq_number:
                metadata = ASN1Metadata(tag: .taggedTag(7), tagging: .explicit)
            case .authorization_data:
                metadata = ASN1Metadata(tag: .taggedTag(8), tagging: .explicit)
            }

            return metadata
        }
    }

    var authenticator_vno: Krb5Int32
    var crealm: Realm
    var cname: PrincipalName
    var cksum: Checksum?
    var cusec: Krb5Int32
    var ctime: KerberosTime
    var subkey: EncryptionKey?
    var seq_number: Krb5UInt32?
    var authorization_data: AuthorizationData?
}

struct PA_DATA: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case padata_type
        case padata_value

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .padata_type:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .padata_value:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            }

            return metadata
        }
    }

    var padata_type: PADATA_TYPE
    var padata_value: Data
}

struct ETYPE_INFO_ENTRY: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case etype
        case salt
        case salttype

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .etype:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .salt:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .salttype:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            }

            return metadata
        }
    }

    var etype: ENCTYPE
    var salt: Data?
    var salttype: Krb5Int32?
}

typealias ETYPE_INFO = [ETYPE_INFO_ENTRY]

struct ETYPE_INFO2_ENTRY: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case etype
        case salt
        case s2kparams

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .etype:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .salt:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .s2kparams:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            }

            return metadata
        }
    }

    var etype: ENCTYPE
    var salt: KerberosString?
    var s2kparams: Data?
}

typealias ETYPE_INFO2 = [ETYPE_INFO2_ENTRY]

typealias METHOD_DATA = [PA_DATA]

struct TypedData: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case data_type
        case data_value

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .data_type:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .data_value:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            }

            return metadata
        }
    }

    var data_type: Krb5Int32
    var data_value: Data?
}

typealias TYPED_DATA = [TypedData]

struct KDC_REQ_BODY: Codable, ASN1Codable.ASN1PreserveBinary {
    var _save: Data? = nil

    enum CodingKeys: ASN1MetadataCodingKey {
        case kdc_options
        case cname
        case realm
        case sname
        case from
        case till
        case rtime
        case nonce
        case etype
        case addresses
        case enc_authorization_data
        case additional_tickets

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .kdc_options:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .cname:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .realm:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            case .sname:
                metadata = ASN1Metadata(tag: .taggedTag(3), tagging: .explicit)
            case .from:
                metadata = ASN1Metadata(tag: .taggedTag(4), tagging: .explicit)
            case .till:
                metadata = ASN1Metadata(tag: .taggedTag(5), tagging: .explicit)
            case .rtime:
                metadata = ASN1Metadata(tag: .taggedTag(6), tagging: .explicit)
            case .nonce:
                metadata = ASN1Metadata(tag: .taggedTag(7), tagging: .explicit)
            case .etype:
                metadata = ASN1Metadata(tag: .taggedTag(8), tagging: .explicit)
            case .addresses:
                metadata = ASN1Metadata(tag: .taggedTag(9), tagging: .explicit)
            case .enc_authorization_data:
                metadata = ASN1Metadata(tag: .taggedTag(10), tagging: .explicit)
            case .additional_tickets:
                metadata = ASN1Metadata(tag: .taggedTag(11), tagging: .explicit)
            }

            return metadata
        }
    }

    var kdc_options: KDCOptions
    var cname: PrincipalName?
    var realm: Realm
    var sname: PrincipalName?
    var from: KerberosTime?
    var till: KerberosTime?
    var rtime: KerberosTime?
    var nonce: Krb5Int32
    var etype: [ENCTYPE]
    var addresses: HostAddresses?
    var enc_authorization_data: EncryptedData?
    var additional_tickets: [Ticket]?
}

struct KDC_REQ: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case pvno
        case msg_type
        case padata
        case req_body

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .pvno:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .msg_type:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            case .padata:
                metadata = ASN1Metadata(tag: .taggedTag(3), tagging: .explicit)
            case .req_body:
                metadata = ASN1Metadata(tag: .taggedTag(4), tagging: .explicit)
            }

            return metadata
        }
    }

    var pvno: Krb5Int32
    var msg_type: MESSAGE_TYPE
    var padata: METHOD_DATA?
    var req_body: KDC_REQ_BODY
}

struct PA_ENC_TS_ENC: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case patimestamp
        case pausec

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .patimestamp:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .pausec:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            }

            return metadata
        }
    }

    var patimestamp: KerberosTime
    var pausec: Krb5Int32?
}

struct PA_PAC_REQUEST: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case include_pac

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .include_pac:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            }

            return metadata
        }
    }

    var include_pac: Bool
}

struct PA_PAC_OPTIONS: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case flags

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .flags:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            }

            return metadata
        }
    }

    var flags: PAC_OPTIONS_FLAGS
}

struct KERB_AD_RESTRICTION_ENTRY: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case restriction_type
        case restriction

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .restriction_type:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .restriction:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            }

            return metadata
        }
    }

    var restriction_type: Krb5Int32
    var restriction: Data
}

typealias PA_KERB_KEY_LIST_REQ = [ENCTYPE]

typealias PA_KERB_KEY_LIST_REP = [ENCTYPE]

struct KDC_REP: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case pvno
        case msg_type
        case padata
        case crealm
        case cname
        case ticket
        case enc_part

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .pvno:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .msg_type:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .padata:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            case .crealm:
                metadata = ASN1Metadata(tag: .taggedTag(3), tagging: .explicit)
            case .cname:
                metadata = ASN1Metadata(tag: .taggedTag(4), tagging: .explicit)
            case .ticket:
                metadata = ASN1Metadata(tag: .taggedTag(5), tagging: .explicit)
            case .enc_part:
                metadata = ASN1Metadata(tag: .taggedTag(6), tagging: .explicit)
            }

            return metadata
        }
    }

    var pvno: Krb5Int32
    var msg_type: MESSAGE_TYPE
    var padata: METHOD_DATA?
    var crealm: Realm
    var cname: PrincipalName
    var ticket: Ticket
    var enc_part: EncryptedData
}

struct AP_REQ: Codable {
    static let metadata = ASN1Metadata(tag: .applicationTag(14), tagging: .explicit)

    enum CodingKeys: ASN1MetadataCodingKey {
        case pvno
        case msg_type
        case ap_options
        case ticket
        case authenticator

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .pvno:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .msg_type:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .ap_options:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            case .ticket:
                metadata = ASN1Metadata(tag: .taggedTag(3), tagging: .explicit)
            case .authenticator:
                metadata = ASN1Metadata(tag: .taggedTag(4), tagging: .explicit)
            }

            return metadata
        }
    }

    var pvno: Krb5Int32
    var msg_type: MESSAGE_TYPE
    var ap_options: APOptions
    var ticket: Ticket
    var authenticator: EncryptedData
}

struct AP_REP: Codable {
    static let metadata = ASN1Metadata(tag: .applicationTag(15), tagging: .explicit)

    enum CodingKeys: ASN1MetadataCodingKey {
        case pvno
        case msg_type
        case enc_part

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .pvno:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .msg_type:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .enc_part:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            }

            return metadata
        }
    }

    var pvno: Krb5Int32
    var msg_type: MESSAGE_TYPE
    var enc_part: EncryptedData
}

struct EncAPRepPart: Codable {
    static let metadata = ASN1Metadata(tag: .applicationTag(27), tagging: .explicit)

    enum CodingKeys: ASN1MetadataCodingKey {
        case ctime
        case cusec
        case subkey
        case seq_number

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .ctime:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .cusec:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .subkey:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            case .seq_number:
                metadata = ASN1Metadata(tag: .taggedTag(3), tagging: .explicit)
            }

            return metadata
        }
    }

    var ctime: KerberosTime
    var cusec: Krb5Int32
    var subkey: EncryptionKey?
    var seq_number: Krb5UInt32?
}

struct KRB_SAFE_BODY: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case user_data
        case timestamp
        case usec
        case seq_number
        case s_address
        case r_address

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .user_data:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .timestamp:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .usec:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            case .seq_number:
                metadata = ASN1Metadata(tag: .taggedTag(3), tagging: .explicit)
            case .s_address:
                metadata = ASN1Metadata(tag: .taggedTag(4), tagging: .explicit)
            case .r_address:
                metadata = ASN1Metadata(tag: .taggedTag(5), tagging: .explicit)
            }

            return metadata
        }
    }

    var user_data: Data
    var timestamp: KerberosTime?
    var usec: Krb5Int32?
    var seq_number: Krb5UInt32?
    var s_address: HostAddress?
    var r_address: HostAddress?
}

struct KRB_SAFE: Codable {
    static let metadata = ASN1Metadata(tag: .applicationTag(20), tagging: .explicit)

    enum CodingKeys: ASN1MetadataCodingKey {
        case pvno
        case msg_type
        case safe_body
        case cksum

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .pvno:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .msg_type:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .safe_body:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            case .cksum:
                metadata = ASN1Metadata(tag: .taggedTag(3), tagging: .explicit)
            }

            return metadata
        }
    }

    var pvno: Krb5Int32
    var msg_type: MESSAGE_TYPE
    var safe_body: KRB_SAFE_BODY
    var cksum: Checksum
}

struct KRB_PRIV: Codable {
    static let metadata = ASN1Metadata(tag: .applicationTag(21), tagging: .explicit)

    enum CodingKeys: ASN1MetadataCodingKey {
        case pvno
        case msg_type
        case enc_part

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .pvno:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .msg_type:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .enc_part:
                metadata = ASN1Metadata(tag: .taggedTag(3), tagging: .explicit)
            }

            return metadata
        }
    }

    var pvno: Krb5Int32
    var msg_type: MESSAGE_TYPE
    var enc_part: EncryptedData
}

struct EncKrbPrivPart: Codable {
    static let metadata = ASN1Metadata(tag: .applicationTag(28), tagging: .explicit)

    enum CodingKeys: ASN1MetadataCodingKey {
        case user_data
        case timestamp
        case usec
        case seq_number
        case s_address
        case r_address

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .user_data:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .timestamp:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .usec:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            case .seq_number:
                metadata = ASN1Metadata(tag: .taggedTag(3), tagging: .explicit)
            case .s_address:
                metadata = ASN1Metadata(tag: .taggedTag(4), tagging: .explicit)
            case .r_address:
                metadata = ASN1Metadata(tag: .taggedTag(5), tagging: .explicit)
            }

            return metadata
        }
    }

    var user_data: Data
    var timestamp: KerberosTime?
    var usec: Krb5Int32?
    var seq_number: Krb5UInt32?
    var s_address: HostAddress?
    var r_address: HostAddress?
}

struct KRB_CRED: Codable {
    static let metadata = ASN1Metadata(tag: .applicationTag(22), tagging: .explicit)

    enum CodingKeys: ASN1MetadataCodingKey {
        case pvno
        case msg_type
        case tickets
        case enc_part

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .pvno:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .msg_type:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .tickets:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            case .enc_part:
                metadata = ASN1Metadata(tag: .taggedTag(3), tagging: .explicit)
            }

            return metadata
        }
    }

    var pvno: Krb5Int32
    var msg_type: MESSAGE_TYPE
    var tickets: [Ticket]
    var enc_part: EncryptedData
}

struct KrbCredInfo: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case key
        case prealm
        case pname
        case flags
        case authtime
        case starttime
        case endtime
        case renew_till
        case srealm
        case sname
        case caddr

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .key:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .prealm:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .pname:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            case .flags:
                metadata = ASN1Metadata(tag: .taggedTag(3), tagging: .explicit)
            case .authtime:
                metadata = ASN1Metadata(tag: .taggedTag(4), tagging: .explicit)
            case .starttime:
                metadata = ASN1Metadata(tag: .taggedTag(5), tagging: .explicit)
            case .endtime:
                metadata = ASN1Metadata(tag: .taggedTag(6), tagging: .explicit)
            case .renew_till:
                metadata = ASN1Metadata(tag: .taggedTag(7), tagging: .explicit)
            case .srealm:
                metadata = ASN1Metadata(tag: .taggedTag(8), tagging: .explicit)
            case .sname:
                metadata = ASN1Metadata(tag: .taggedTag(9), tagging: .explicit)
            case .caddr:
                metadata = ASN1Metadata(tag: .taggedTag(10), tagging: .explicit)
            }

            return metadata
        }
    }

    var key: EncryptionKey
    var prealm: Realm?
    var pname: PrincipalName?
    var flags: TicketFlags?
    var authtime: KerberosTime?
    var starttime: KerberosTime?
    var endtime: KerberosTime?
    var renew_till: KerberosTime?
    var srealm: Realm?
    var sname: PrincipalName?
    var caddr: HostAddresses?
}

struct EncKrbCredPart: Codable {
    static let metadata = ASN1Metadata(tag: .applicationTag(29), tagging: .explicit)

    enum CodingKeys: ASN1MetadataCodingKey {
        case ticket_info
        case nonce
        case timestamp
        case usec
        case s_address
        case r_address

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .ticket_info:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .nonce:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .timestamp:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            case .usec:
                metadata = ASN1Metadata(tag: .taggedTag(3), tagging: .explicit)
            case .s_address:
                metadata = ASN1Metadata(tag: .taggedTag(4), tagging: .explicit)
            case .r_address:
                metadata = ASN1Metadata(tag: .taggedTag(5), tagging: .explicit)
            }

            return metadata
        }
    }

    var ticket_info: [KrbCredInfo]
    var nonce: Krb5Int32?
    var timestamp: KerberosTime?
    var usec: Krb5Int32?
    var s_address: HostAddress?
    var r_address: HostAddress?
}

struct KRB_ERROR: Codable {
    static let metadata = ASN1Metadata(tag: .applicationTag(30), tagging: .explicit)

    enum CodingKeys: ASN1MetadataCodingKey {
        case pvno
        case msg_type
        case ctime
        case cusec
        case stime
        case susec
        case error_code
        case crealm
        case cname
        case realm
        case sname
        case e_text
        case e_data

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .pvno:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .msg_type:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .ctime:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            case .cusec:
                metadata = ASN1Metadata(tag: .taggedTag(3), tagging: .explicit)
            case .stime:
                metadata = ASN1Metadata(tag: .taggedTag(4), tagging: .explicit)
            case .susec:
                metadata = ASN1Metadata(tag: .taggedTag(5), tagging: .explicit)
            case .error_code:
                metadata = ASN1Metadata(tag: .taggedTag(6), tagging: .explicit)
            case .crealm:
                metadata = ASN1Metadata(tag: .taggedTag(7), tagging: .explicit)
            case .cname:
                metadata = ASN1Metadata(tag: .taggedTag(8), tagging: .explicit)
            case .realm:
                metadata = ASN1Metadata(tag: .taggedTag(9), tagging: .explicit)
            case .sname:
                metadata = ASN1Metadata(tag: .taggedTag(10), tagging: .explicit)
            case .e_text:
                metadata = ASN1Metadata(tag: .taggedTag(11), tagging: .explicit)
            case .e_data:
                metadata = ASN1Metadata(tag: .taggedTag(12), tagging: .explicit)
            }

            return metadata
        }
    }

    var pvno: Krb5Int32
    var msg_type: MESSAGE_TYPE
    var ctime: KerberosTime?
    var cusec: Krb5Int32?
    var stime: KerberosTime
    var susec: Krb5Int32
    var error_code: Krb5Int32
    var crealm: Realm?
    var cname: PrincipalName?
    var realm: Realm
    var sname: PrincipalName
    @GeneralString
    var e_text: String? = nil
    var e_data: Data?
}

struct ChangePasswdDataMS: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case newpasswd
        case targname
        case targrealm

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .newpasswd:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .targname:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .targrealm:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            }

            return metadata
        }
    }

    var newpasswd: Data
    var targname: PrincipalName?
    var targrealm: Realm?
}

typealias EtypeList = [ENCTYPE]

struct AD_KDCIssued: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case ad_checksum
        case i_realm
        case i_sname
        case elements

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .ad_checksum:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .i_realm:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .i_sname:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            case .elements:
                metadata = ASN1Metadata(tag: .taggedTag(3), tagging: .explicit)
            }

            return metadata
        }
    }

    var ad_checksum: Checksum
    var i_realm: Realm?
    var i_sname: PrincipalName?
    var elements: AuthorizationData
}

struct AD_AND_OR: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case condition_count
        case elements

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .condition_count:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .elements:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            }

            return metadata
        }
    }

    var condition_count: Krb5Int32
    var elements: AuthorizationData
}

struct PA_SAM_CHALLENGE_2_BODY: Codable, ASN1Codable.ASN1ExtensibleType {
    enum CodingKeys: ASN1MetadataCodingKey {
        case sam_type
        case sam_flags
        case sam_type_name
        case sam_track_id
        case sam_challenge_label
        case sam_challenge
        case sam_response_prompt
        case sam_pk_for_sad
        case sam_nonce
        case sam_etype

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .sam_type:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .sam_flags:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .sam_type_name:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            case .sam_track_id:
                metadata = ASN1Metadata(tag: .taggedTag(3), tagging: .explicit)
            case .sam_challenge_label:
                metadata = ASN1Metadata(tag: .taggedTag(4), tagging: .explicit)
            case .sam_challenge:
                metadata = ASN1Metadata(tag: .taggedTag(5), tagging: .explicit)
            case .sam_response_prompt:
                metadata = ASN1Metadata(tag: .taggedTag(6), tagging: .explicit)
            case .sam_pk_for_sad:
                metadata = ASN1Metadata(tag: .taggedTag(7), tagging: .explicit)
            case .sam_nonce:
                metadata = ASN1Metadata(tag: .taggedTag(8), tagging: .explicit)
            case .sam_etype:
                metadata = ASN1Metadata(tag: .taggedTag(9), tagging: .explicit)
            }

            return metadata
        }
    }

    var sam_type: Krb5Int32
    var sam_flags: SAMFlags
    @GeneralString
    var sam_type_name: String? = nil
    @GeneralString
    var sam_track_id: String? = nil
    @GeneralString
    var sam_challenge_label: String? = nil
    @GeneralString
    var sam_challenge: String? = nil
    @GeneralString
    var sam_response_prompt: String? = nil
    var sam_pk_for_sad: EncryptionKey?
    var sam_nonce: Krb5Int32
    var sam_etype: Krb5Int32
}

struct PA_SAM_CHALLENGE_2: Codable, ASN1Codable.ASN1ExtensibleType {
    enum CodingKeys: ASN1MetadataCodingKey {
        case sam_body
        case sam_cksum

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .sam_body:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .sam_cksum:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            }

            return metadata
        }
    }

    var sam_body: PA_SAM_CHALLENGE_2_BODY
    var sam_cksum: [Checksum]
}

struct PA_SAM_RESPONSE_2: Codable, ASN1Codable.ASN1ExtensibleType {
    enum CodingKeys: ASN1MetadataCodingKey {
        case sam_type
        case sam_flags
        case sam_track_id
        case sam_enc_nonce_or_sad
        case sam_nonce

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .sam_type:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .sam_flags:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .sam_track_id:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            case .sam_enc_nonce_or_sad:
                metadata = ASN1Metadata(tag: .taggedTag(3), tagging: .explicit)
            case .sam_nonce:
                metadata = ASN1Metadata(tag: .taggedTag(4), tagging: .explicit)
            }

            return metadata
        }
    }

    var sam_type: Krb5Int32
    var sam_flags: SAMFlags
    @GeneralString
    var sam_track_id: String? = nil
    var sam_enc_nonce_or_sad: EncryptedData
    var sam_nonce: Krb5Int32
}

struct PA_ENC_SAM_RESPONSE_ENC: Codable, ASN1Codable.ASN1ExtensibleType {
    enum CodingKeys: ASN1MetadataCodingKey {
        case sam_nonce
        case sam_sad

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .sam_nonce:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .sam_sad:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            }

            return metadata
        }
    }

    var sam_nonce: Krb5Int32
    @GeneralString
    var sam_sad: String? = nil
}

struct PA_S4U2Self: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case name
        case realm
        case cksum
        case auth

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .name:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .realm:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .cksum:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            case .auth:
                metadata = ASN1Metadata(tag: .taggedTag(3), tagging: .explicit)
            }

            return metadata
        }
    }

    var name: PrincipalName
    var realm: Realm
    var cksum: Checksum
    @GeneralString
    var auth: String = ""
}

struct S4UUserID: Codable, ASN1Codable.ASN1ExtensibleType {
    enum CodingKeys: ASN1MetadataCodingKey {
        case nonce
        case cname
        case crealm
        case subject_certificate
        case options

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .nonce:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .cname:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .crealm:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            case .subject_certificate:
                metadata = ASN1Metadata(tag: .taggedTag(3), tagging: .explicit)
            case .options:
                metadata = ASN1Metadata(tag: .taggedTag(4), tagging: .explicit)
            }

            return metadata
        }
    }

    var nonce: Krb5UInt32
    var cname: PrincipalName?
    var crealm: Realm
    var subject_certificate: Data?
    var options: BitString?
}

struct PA_S4U_X509_USER: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case user_id
        case checksum

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .user_id:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .checksum:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            }

            return metadata
        }
    }

    var user_id: S4UUserID
    var checksum: Checksum
}

struct AD_LoginAlias: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case login_alias
        case checksum

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .login_alias:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .checksum:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            }

            return metadata
        }
    }

    var login_alias: PrincipalName
    var checksum: Checksum
}

struct PA_SvrReferralData: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case referred_name
        case referred_realm

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .referred_name:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .referred_realm:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            }

            return metadata
        }
    }

    var referred_name: PrincipalName?
    var referred_realm: Realm
}

struct PA_ServerReferralData: Codable, ASN1Codable.ASN1ExtensibleType {
    enum CodingKeys: ASN1MetadataCodingKey {
        case referred_realm
        case true_principal_name
        case requested_principal_name
        case referral_valid_until

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .referred_realm:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .true_principal_name:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .requested_principal_name:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            case .referral_valid_until:
                metadata = ASN1Metadata(tag: .taggedTag(3), tagging: .explicit)
            }

            return metadata
        }
    }

    var referred_realm: Realm?
    var true_principal_name: PrincipalName?
    var requested_principal_name: PrincipalName?
    var referral_valid_until: KerberosTime?
}

struct KrbFastReq: Codable, ASN1Codable.ASN1ExtensibleType {
    enum CodingKeys: ASN1MetadataCodingKey {
        case fast_options
        case padata
        case req_body

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .fast_options:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .padata:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .req_body:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            }

            return metadata
        }
    }

    var fast_options: FastOptions
    var padata: METHOD_DATA
    var req_body: KDC_REQ_BODY
}

struct KrbFastArmor: Codable, ASN1Codable.ASN1ExtensibleType {
    enum CodingKeys: ASN1MetadataCodingKey {
        case armor_type
        case armor_value

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .armor_type:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .armor_value:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            }

            return metadata
        }
    }

    var armor_type: Krb5Int32
    var armor_value: Data
}

struct KrbFastArmoredReq: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case armor
        case req_checksum
        case enc_fast_req

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .armor:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .req_checksum:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .enc_fast_req:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            }

            return metadata
        }
    }

    var armor: KrbFastArmor?
    var req_checksum: Checksum
    var enc_fast_req: EncryptedData
}

enum PA_FX_FAST_REQUEST: Codable, ASN1Codable.ASN1ExtensibleType {
    enum CodingKeys: CaseIterable, ASN1MetadataCodingKey {
        case armored_data

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .armored_data:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            }

            return metadata
        }
    }

    case armored_data(KrbFastArmoredReq)
}

struct KrbFastFinished: Codable, ASN1Codable.ASN1ExtensibleType {
    enum CodingKeys: ASN1MetadataCodingKey {
        case timestamp
        case usec
        case crealm
        case cname
        case ticket_checksum

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .timestamp:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .usec:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .crealm:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            case .cname:
                metadata = ASN1Metadata(tag: .taggedTag(3), tagging: .explicit)
            case .ticket_checksum:
                metadata = ASN1Metadata(tag: .taggedTag(4), tagging: .explicit)
            }

            return metadata
        }
    }

    var timestamp: KerberosTime
    var usec: Krb5Int32
    var crealm: Realm
    var cname: PrincipalName
    var ticket_checksum: Checksum
}

struct KrbFastResponse: Codable, ASN1Codable.ASN1ExtensibleType {
    enum CodingKeys: ASN1MetadataCodingKey {
        case padata
        case strengthen_key
        case finished
        case nonce

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .padata:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .strengthen_key:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .finished:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            case .nonce:
                metadata = ASN1Metadata(tag: .taggedTag(3), tagging: .explicit)
            }

            return metadata
        }
    }

    var padata: METHOD_DATA
    var strengthen_key: EncryptionKey?
    var finished: KrbFastFinished?
    var nonce: Krb5UInt32
}

struct KrbFastArmoredRep: Codable, ASN1Codable.ASN1ExtensibleType {
    enum CodingKeys: ASN1MetadataCodingKey {
        case enc_fast_rep

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .enc_fast_rep:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            }

            return metadata
        }
    }

    var enc_fast_rep: EncryptedData
}

enum PA_FX_FAST_REPLY: Codable, ASN1Codable.ASN1ExtensibleType {
    enum CodingKeys: CaseIterable, ASN1MetadataCodingKey {
        case armored_data

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .armored_data:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            }

            return metadata
        }
    }

    case armored_data(KrbFastArmoredRep)
}

struct KDCFastState: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case flags
        case expiration
        case fast_state
        case expected_pa_types

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .flags:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .expiration:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .fast_state:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            case .expected_pa_types:
                metadata = ASN1Metadata(tag: .taggedTag(3), tagging: .explicit)
            }

            return metadata
        }
    }

    var flags: KDCFastFlags
    @GeneralizedTime
    var expiration: Date = .init()
    var fast_state: METHOD_DATA
    var expected_pa_types: [PADATA_TYPE]?
}

struct KDCFastCookie: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case version
        case cookie

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .version:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .cookie:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            }

            return metadata
        }
    }

    @UTF8String
    var version: String = ""
    var cookie: EncryptedData
}

struct KDC_PROXY_MESSAGE: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case kerb_message
        case target_domain
        case dclocator_hint

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .kerb_message:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .target_domain:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .dclocator_hint:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            }

            return metadata
        }
    }

    var kerb_message: Data
    var target_domain: Realm?
    var dclocator_hint: BigNumber.BInt?
}

struct KERB_TIMES: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case authtime
        case starttime
        case endtime
        case renew_till

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .authtime:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .starttime:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .endtime:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            case .renew_till:
                metadata = ASN1Metadata(tag: .taggedTag(3), tagging: .explicit)
            }

            return metadata
        }
    }

    var authtime: KerberosTime
    var starttime: KerberosTime
    var endtime: KerberosTime
    var renew_till: KerberosTime
}

struct KERB_CRED: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case client
        case server
        case keyblock
        case times
        case ticket
        case authdata
        case addresses
        case flags

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .client:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .server:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .keyblock:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            case .times:
                metadata = ASN1Metadata(tag: .taggedTag(3), tagging: .explicit)
            case .ticket:
                metadata = ASN1Metadata(tag: .taggedTag(4), tagging: .explicit)
            case .authdata:
                metadata = ASN1Metadata(tag: .taggedTag(5), tagging: .explicit)
            case .addresses:
                metadata = ASN1Metadata(tag: .taggedTag(6), tagging: .explicit)
            case .flags:
                metadata = ASN1Metadata(tag: .taggedTag(7), tagging: .explicit)
            }

            return metadata
        }
    }

    var client: Principal
    var server: Principal
    var keyblock: EncryptionKey
    var times: KERB_TIMES
    var ticket: Data
    var authdata: Data
    var addresses: HostAddresses
    var flags: TicketFlags
}

struct KERB_TGS_REQ_IN: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case cache
        case addrs
        case flags
        case imp
        case ticket
        case in_cred
        case krbtgt
        case padata

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .cache:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .addrs:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .flags:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            case .imp:
                metadata = ASN1Metadata(tag: .taggedTag(3), tagging: .explicit)
            case .ticket:
                metadata = ASN1Metadata(tag: .taggedTag(4), tagging: .explicit)
            case .in_cred:
                metadata = ASN1Metadata(tag: .taggedTag(5), tagging: .explicit)
            case .krbtgt:
                metadata = ASN1Metadata(tag: .taggedTag(6), tagging: .explicit)
            case .padata:
                metadata = ASN1Metadata(tag: .taggedTag(7), tagging: .explicit)
            }

            return metadata
        }
    }

    var cache: Data
    var addrs: HostAddresses
    var flags: Krb5UInt32
    var imp: Principal?
    var ticket: Data?
    var in_cred: KERB_CRED
    var krbtgt: KERB_CRED
    var padata: METHOD_DATA
}

struct KERB_TGS_REQ_OUT: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case subkey
        case t

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .subkey:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .t:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            }

            return metadata
        }
    }

    var subkey: EncryptionKey?
    var t: TGS_REQ
}

struct KERB_TGS_REP_IN: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case cache
        case subkey
        case in_cred
        case t

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .cache:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .subkey:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .in_cred:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            case .t:
                metadata = ASN1Metadata(tag: .taggedTag(3), tagging: .explicit)
            }

            return metadata
        }
    }

    var cache: Data
    var subkey: EncryptionKey?
    var in_cred: KERB_CRED
    var t: TGS_REP
}

struct KERB_TGS_REP_OUT: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case cache
        case cred
        case subkey

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .cache:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .cred:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case .subkey:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            }

            return metadata
        }
    }

    var cache: Data
    var cred: KERB_CRED
    var subkey: EncryptionKey
}

struct KERB_ARMOR_SERVICE_REPLY: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case armor
        case armor_key

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case .armor:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case .armor_key:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            }

            return metadata
        }
    }

    var armor: KrbFastArmor
    var armor_key: EncryptionKey
}

public enum KERBEROS5 {
    public enum ASN1TagNumber$1: ASN1TagNumberRepresentable {}
    public enum ASN1TagNumber$2: ASN1TagNumberRepresentable {}
    public enum ASN1TagNumber$3: ASN1TagNumberRepresentable {}
    public enum ASN1TagNumber$10: ASN1TagNumberRepresentable {}
    public enum ASN1TagNumber$11: ASN1TagNumberRepresentable {}
    public enum ASN1TagNumber$12: ASN1TagNumberRepresentable {}
    public enum ASN1TagNumber$13: ASN1TagNumberRepresentable {}
    public enum ASN1TagNumber$14: ASN1TagNumberRepresentable {}
    public enum ASN1TagNumber$15: ASN1TagNumberRepresentable {}
    public enum ASN1TagNumber$20: ASN1TagNumberRepresentable {}
    public enum ASN1TagNumber$21: ASN1TagNumberRepresentable {}
    public enum ASN1TagNumber$22: ASN1TagNumberRepresentable {}
    public enum ASN1TagNumber$25: ASN1TagNumberRepresentable {}
    public enum ASN1TagNumber$26: ASN1TagNumberRepresentable {}
    public enum ASN1TagNumber$27: ASN1TagNumberRepresentable {}
    public enum ASN1TagNumber$28: ASN1TagNumberRepresentable {}
    public enum ASN1TagNumber$29: ASN1TagNumberRepresentable {}
    public enum ASN1TagNumber$30: ASN1TagNumberRepresentable {}
    public enum ASN1TagNumber$48: ASN1TagNumberRepresentable {}
}
