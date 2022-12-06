import AnyCodable
import BigNumber
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

struct APOptions: RFC1510BitStringOptionSet, Codable, Equatable {
    var rawValue: UInt8

    init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    static let reserved = APOptions(rawValue: 1 << 0)
    static let use_session_key = APOptions(rawValue: 1 << 1)
    static let mutual_required = APOptions(rawValue: 1 << 2)
}

struct TicketFlags: RFC1510BitStringOptionSet, Codable, Equatable {
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

struct KDCOptions: RFC1510BitStringOptionSet, Codable, Equatable {
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

struct PAC_OPTIONS_FLAGS: RFC1510BitStringOptionSet, Codable, Equatable {
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

typealias EncASRepPart = ASN1ApplicationTagged<
    KERBEROS5.ASN1TagNumber$25,
    ASN1Codable.ASN1ExplicitTagging,
    EncKDCRepPart
>

typealias EncTGSRepPart = ASN1ApplicationTagged<
    KERBEROS5.ASN1TagNumber$26,
    ASN1Codable.ASN1ExplicitTagging,
    EncKDCRepPart
>

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

struct SAMFlags: RFC1510BitStringOptionSet, Codable, Equatable {
    var rawValue: UInt8

    init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    static let use_sad_as_key = SAMFlags(rawValue: 1 << 0)
    static let send_encrypted_sad = SAMFlags(rawValue: 1 << 1)
    static let must_pk_encrypt_sad = SAMFlags(rawValue: 1 << 2)
}

typealias PA_SERVER_REFERRAL_DATA = EncryptedData

struct FastOptions: RFC1510BitStringOptionSet, Codable, Equatable {
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

struct KDCFastFlags: RFC1510BitStringOptionSet, Codable, Equatable {
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

struct PrincipalName: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case name_type = 0
        case name_string = 1
    }

    var name_type: NAME_TYPE
    var name_string: [GeneralString<String>]
}

struct HostAddress: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case addr_type = 0
        case address = 1
    }

    var addr_type: Krb5Int32
    var address: Data
}

typealias HostAddresses = [HostAddress]

struct AuthorizationDataElement: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case ad_type = 0
        case ad_data = 1
    }

    var ad_type: Krb5Int32
    var ad_data: Data
}

typealias AuthorizationData = [AuthorizationDataElement]

struct LastReqInner: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case lr_type = 0
        case lr_value = 1
    }

    var lr_type: LR_TYPE
    var lr_value: KerberosTime
}

typealias LastReq = [LastReqInner]

struct EncryptedData: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case etype = 0
        case kvno = 1
        case cipher = 2
    }

    var etype: ENCTYPE
    var kvno: Krb5Int32?
    var cipher: Data
}

struct EncryptionKey: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case keytype = 0
        case keyvalue = 1
    }

    var keytype: Krb5Int32
    var keyvalue: Data
}

struct TransitedEncoding: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case tr_type = 0
        case contents = 1
    }

    var tr_type: Krb5Int32
    var contents: Data
}

struct Ticket: Codable, Equatable {
    static let metadata = ASN1Metadata(tag: .applicationTag(1), tagging: .explicit)

    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case tkt_vno = 0
        case realm = 1
        case sname = 2
        case enc_part = 3
    }

    var tkt_vno: Krb5Int32
    var realm: Realm
    var sname: PrincipalName
    var enc_part: EncryptedData
}

struct EncTicketPart: Codable, Equatable {
    static let metadata = ASN1Metadata(tag: .applicationTag(3), tagging: .explicit)

    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case flags = 0
        case key = 1
        case crealm = 2
        case cname = 3
        case transited = 4
        case authtime = 5
        case starttime = 6
        case endtime = 7
        case renew_till = 8
        case caddr = 9
        case authorization_data = 10
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

struct Checksum: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case cksumtype = 0
        case checksum = 1
    }

    var cksumtype: CKSUMTYPE
    var checksum: Data
}

struct EncKDCRepPart: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case key = 0
        case last_req = 1
        case nonce = 2
        case key_expiration = 3
        case flags = 4
        case authtime = 5
        case starttime = 6
        case endtime = 7
        case renew_till = 8
        case srealm = 9
        case sname = 10
        case caddr = 11
        case encrypted_pa_data = 12
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

enum PrincipalNameAttrSrc: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case enc_kdc_rep_part = 0
        case enc_ticket_part = 1
    }

    case enc_kdc_rep_part(EncKDCRepPart)
    case enc_ticket_part(EncTicketPart)
}

struct PrincipalNameAttrs: Codable, Equatable {
    var pac: AnyCodable?

    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case authenticated = 0
        case source = 1
        case authenticator_ad = 2
        case peer_realm = 3
        case transited = 4
        case pac_verified = 5
        case kdc_issued_verified = 6
        case want_ad = 7
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

struct CompositePrincipal: Codable, Equatable {
    static let metadata = ASN1Metadata(tag: .applicationTag(48), tagging: .explicit)

    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case name = 0
        case realm = 1
        case nameattrs = 2
    }

    var name: PrincipalName
    var realm: Realm
    var nameattrs: PrincipalNameAttrs?
}

struct Principal: Codable, Equatable {
    var nameattrs: PrincipalNameAttrs?

    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case name = 0
        case realm = 1
    }

    var name: PrincipalName
    var realm: Realm
}

typealias Principals = [Principal]

struct Authenticator: Codable, Equatable {
    static let metadata = ASN1Metadata(tag: .applicationTag(2), tagging: .explicit)

    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case authenticator_vno = 0
        case crealm = 1
        case cname = 2
        case cksum = 3
        case cusec = 4
        case ctime = 5
        case subkey = 6
        case seq_number = 7
        case authorization_data = 8
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

struct PA_DATA: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case padata_type = 1
        case padata_value = 2
    }

    var padata_type: PADATA_TYPE
    var padata_value: Data
}

struct ETYPE_INFO_ENTRY: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case etype = 0
        case salt = 1
        case salttype = 2
    }

    var etype: ENCTYPE
    var salt: Data?
    var salttype: Krb5Int32?
}

typealias ETYPE_INFO = [ETYPE_INFO_ENTRY]

struct ETYPE_INFO2_ENTRY: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case etype = 0
        case salt = 1
        case s2kparams = 2
    }

    var etype: ENCTYPE
    var salt: KerberosString?
    var s2kparams: Data?
}

typealias ETYPE_INFO2 = [ETYPE_INFO2_ENTRY]

typealias METHOD_DATA = [PA_DATA]

struct TypedData: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case data_type = 0
        case data_value = 1
    }

    var data_type: Krb5Int32
    var data_value: Data?
}

typealias TYPED_DATA = [TypedData]

struct KDC_REQ_BODY: Codable, Equatable, ASN1PreserveBinary {
    var _save: Data? = nil

    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case kdc_options = 0
        case cname = 1
        case realm = 2
        case sname = 3
        case from = 4
        case till = 5
        case rtime = 6
        case nonce = 7
        case etype = 8
        case addresses = 9
        case enc_authorization_data = 10
        case additional_tickets = 11
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

struct KDC_REQ: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case pvno = 1
        case msg_type = 2
        case padata = 3
        case req_body = 4
    }

    var pvno: Krb5Int32
    var msg_type: MESSAGE_TYPE
    var padata: METHOD_DATA?
    var req_body: KDC_REQ_BODY
}

struct PA_ENC_TS_ENC: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case patimestamp = 0
        case pausec = 1
    }

    var patimestamp: KerberosTime
    var pausec: Krb5Int32?
}

struct PA_PAC_REQUEST: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case include_pac = 0
    }

    var include_pac: Bool
}

struct PA_PAC_OPTIONS: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case flags = 0
    }

    var flags: PAC_OPTIONS_FLAGS
}

struct KERB_AD_RESTRICTION_ENTRY: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case restriction_type = 0
        case restriction = 1
    }

    var restriction_type: Krb5Int32
    var restriction: Data
}

typealias PA_KERB_KEY_LIST_REQ = [ENCTYPE]

typealias PA_KERB_KEY_LIST_REP = [ENCTYPE]

struct KDC_REP: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case pvno = 0
        case msg_type = 1
        case padata = 2
        case crealm = 3
        case cname = 4
        case ticket = 5
        case enc_part = 6
    }

    var pvno: Krb5Int32
    var msg_type: MESSAGE_TYPE
    var padata: METHOD_DATA?
    var crealm: Realm
    var cname: PrincipalName
    var ticket: Ticket
    var enc_part: EncryptedData
}

struct AP_REQ: Codable, Equatable {
    static let metadata = ASN1Metadata(tag: .applicationTag(14), tagging: .explicit)

    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case pvno = 0
        case msg_type = 1
        case ap_options = 2
        case ticket = 3
        case authenticator = 4
    }

    var pvno: Krb5Int32
    var msg_type: MESSAGE_TYPE
    var ap_options: APOptions
    var ticket: Ticket
    var authenticator: EncryptedData
}

struct AP_REP: Codable, Equatable {
    static let metadata = ASN1Metadata(tag: .applicationTag(15), tagging: .explicit)

    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case pvno = 0
        case msg_type = 1
        case enc_part = 2
    }

    var pvno: Krb5Int32
    var msg_type: MESSAGE_TYPE
    var enc_part: EncryptedData
}

struct EncAPRepPart: Codable, Equatable {
    static let metadata = ASN1Metadata(tag: .applicationTag(27), tagging: .explicit)

    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case ctime = 0
        case cusec = 1
        case subkey = 2
        case seq_number = 3
    }

    var ctime: KerberosTime
    var cusec: Krb5Int32
    var subkey: EncryptionKey?
    var seq_number: Krb5UInt32?
}

struct KRB_SAFE_BODY: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case user_data = 0
        case timestamp = 1
        case usec = 2
        case seq_number = 3
        case s_address = 4
        case r_address = 5
    }

    var user_data: Data
    var timestamp: KerberosTime?
    var usec: Krb5Int32?
    var seq_number: Krb5UInt32?
    var s_address: HostAddress?
    var r_address: HostAddress?
}

struct KRB_SAFE: Codable, Equatable {
    static let metadata = ASN1Metadata(tag: .applicationTag(20), tagging: .explicit)

    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case pvno = 0
        case msg_type = 1
        case safe_body = 2
        case cksum = 3
    }

    var pvno: Krb5Int32
    var msg_type: MESSAGE_TYPE
    var safe_body: KRB_SAFE_BODY
    var cksum: Checksum
}

struct KRB_PRIV: Codable, Equatable {
    static let metadata = ASN1Metadata(tag: .applicationTag(21), tagging: .explicit)

    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case pvno = 0
        case msg_type = 1
        case enc_part = 3
    }

    var pvno: Krb5Int32
    var msg_type: MESSAGE_TYPE
    var enc_part: EncryptedData
}

struct EncKrbPrivPart: Codable, Equatable {
    static let metadata = ASN1Metadata(tag: .applicationTag(28), tagging: .explicit)

    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case user_data = 0
        case timestamp = 1
        case usec = 2
        case seq_number = 3
        case s_address = 4
        case r_address = 5
    }

    var user_data: Data
    var timestamp: KerberosTime?
    var usec: Krb5Int32?
    var seq_number: Krb5UInt32?
    var s_address: HostAddress?
    var r_address: HostAddress?
}

struct KRB_CRED: Codable, Equatable {
    static let metadata = ASN1Metadata(tag: .applicationTag(22), tagging: .explicit)

    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case pvno = 0
        case msg_type = 1
        case tickets = 2
        case enc_part = 3
    }

    var pvno: Krb5Int32
    var msg_type: MESSAGE_TYPE
    var tickets: [Ticket]
    var enc_part: EncryptedData
}

struct KrbCredInfo: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case key = 0
        case prealm = 1
        case pname = 2
        case flags = 3
        case authtime = 4
        case starttime = 5
        case endtime = 6
        case renew_till = 7
        case srealm = 8
        case sname = 9
        case caddr = 10
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

struct EncKrbCredPart: Codable, Equatable {
    static let metadata = ASN1Metadata(tag: .applicationTag(29), tagging: .explicit)

    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case ticket_info = 0
        case nonce = 1
        case timestamp = 2
        case usec = 3
        case s_address = 4
        case r_address = 5
    }

    var ticket_info: [KrbCredInfo]
    var nonce: Krb5Int32?
    var timestamp: KerberosTime?
    var usec: Krb5Int32?
    var s_address: HostAddress?
    var r_address: HostAddress?
}

struct KRB_ERROR: Codable, Equatable {
    static let metadata = ASN1Metadata(tag: .applicationTag(30), tagging: .explicit)

    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case pvno = 0
        case msg_type = 1
        case ctime = 2
        case cusec = 3
        case stime = 4
        case susec = 5
        case error_code = 6
        case crealm = 7
        case cname = 8
        case realm = 9
        case sname = 10
        case e_text = 11
        case e_data = 12
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

struct ChangePasswdDataMS: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case newpasswd = 0
        case targname = 1
        case targrealm = 2
    }

    var newpasswd: Data
    var targname: PrincipalName?
    var targrealm: Realm?
}

typealias EtypeList = [ENCTYPE]

struct AD_KDCIssued: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case ad_checksum = 0
        case i_realm = 1
        case i_sname = 2
        case elements = 3
    }

    var ad_checksum: Checksum
    var i_realm: Realm?
    var i_sname: PrincipalName?
    var elements: AuthorizationData
}

struct AD_AND_OR: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case condition_count = 0
        case elements = 1
    }

    var condition_count: Krb5Int32
    var elements: AuthorizationData
}

struct PA_SAM_CHALLENGE_2_BODY: Codable, ASN1Codable.ASN1ExtensibleType {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case sam_type = 0
        case sam_flags = 1
        case sam_type_name = 2
        case sam_track_id = 3
        case sam_challenge_label = 4
        case sam_challenge = 5
        case sam_response_prompt = 6
        case sam_pk_for_sad = 7
        case sam_nonce = 8
        case sam_etype = 9
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
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case sam_body = 0
        case sam_cksum = 1
    }

    var sam_body: PA_SAM_CHALLENGE_2_BODY
    var sam_cksum: [Checksum]
}

struct PA_SAM_RESPONSE_2: Codable, ASN1Codable.ASN1ExtensibleType {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case sam_type = 0
        case sam_flags = 1
        case sam_track_id = 2
        case sam_enc_nonce_or_sad = 3
        case sam_nonce = 4
    }

    var sam_type: Krb5Int32
    var sam_flags: SAMFlags
    @GeneralString
    var sam_track_id: String? = nil
    var sam_enc_nonce_or_sad: EncryptedData
    var sam_nonce: Krb5Int32
}

struct PA_ENC_SAM_RESPONSE_ENC: Codable, ASN1Codable.ASN1ExtensibleType {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case sam_nonce = 0
        case sam_sad = 1
    }

    var sam_nonce: Krb5Int32
    @GeneralString
    var sam_sad: String? = nil
}

struct PA_S4U2Self: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case name = 0
        case realm = 1
        case cksum = 2
        case auth = 3
    }

    var name: PrincipalName
    var realm: Realm
    var cksum: Checksum
    @GeneralString
    var auth: String = ""
}

struct S4UUserID: Codable, Equatable, ASN1ExtensibleType {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case nonce = 0
        case cname = 1
        case crealm = 2
        case subject_certificate = 3
        case options = 4
    }

    var nonce: Krb5UInt32
    var cname: PrincipalName?
    var crealm: Realm
    var subject_certificate: Data?
    var options: BitString?
}

struct PA_S4U_X509_USER: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case user_id = 0
        case checksum = 1
    }

    var user_id: S4UUserID
    var checksum: Checksum
}

struct AD_LoginAlias: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case login_alias = 0
        case checksum = 1
    }

    var login_alias: PrincipalName
    var checksum: Checksum
}

struct PA_SvrReferralData: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case referred_name = 1
        case referred_realm = 0
    }

    var referred_name: PrincipalName?
    var referred_realm: Realm
}

struct PA_ServerReferralData: Codable, Equatable, ASN1ExtensibleType {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case referred_realm = 0
        case true_principal_name = 1
        case requested_principal_name = 2
        case referral_valid_until = 3
    }

    var referred_realm: Realm?
    var true_principal_name: PrincipalName?
    var requested_principal_name: PrincipalName?
    var referral_valid_until: KerberosTime?
}

struct KrbFastReq: Codable, Equatable, ASN1ExtensibleType {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case fast_options = 0
        case padata = 1
        case req_body = 2
    }

    var fast_options: FastOptions
    var padata: METHOD_DATA
    var req_body: KDC_REQ_BODY
}

struct KrbFastArmor: Codable, Equatable, ASN1ExtensibleType {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case armor_type = 0
        case armor_value = 1
    }

    var armor_type: Krb5Int32
    var armor_value: Data
}

struct KrbFastArmoredReq: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case armor = 0
        case req_checksum = 1
        case enc_fast_req = 2
    }

    var armor: KrbFastArmor?
    var req_checksum: Checksum
    var enc_fast_req: EncryptedData
}

enum PA_FX_FAST_REQUEST: Codable, Equatable, ASN1ExtensibleType {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case armored_data = 0
    }

    case armored_data(KrbFastArmoredReq)
}

struct KrbFastFinished: Codable, Equatable, ASN1ExtensibleType {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case timestamp = 0
        case usec = 1
        case crealm = 2
        case cname = 3
        case ticket_checksum = 4
    }

    var timestamp: KerberosTime
    var usec: Krb5Int32
    var crealm: Realm
    var cname: PrincipalName
    var ticket_checksum: Checksum
}

struct KrbFastResponse: Codable, Equatable, ASN1ExtensibleType {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case padata = 0
        case strengthen_key = 1
        case finished = 2
        case nonce = 3
    }

    var padata: METHOD_DATA
    var strengthen_key: EncryptionKey?
    var finished: KrbFastFinished?
    var nonce: Krb5UInt32
}

struct KrbFastArmoredRep: Codable, Equatable, ASN1ExtensibleType {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case enc_fast_rep = 0
    }

    var enc_fast_rep: EncryptedData
}

enum PA_FX_FAST_REPLY: Codable, Equatable, ASN1ExtensibleType {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case armored_data = 0
    }

    case armored_data(KrbFastArmoredRep)
}

struct KDCFastState: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case flags = 0
        case expiration = 1
        case fast_state = 2
        case expected_pa_types = 3
    }

    var flags: KDCFastFlags
    @GeneralizedTime
    var expiration: Date = .init()
    var fast_state: METHOD_DATA
    var expected_pa_types: [PADATA_TYPE]?
}

struct KDCFastCookie: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case version = 0
        case cookie = 1
    }

    @UTF8String
    var version: String = ""
    var cookie: EncryptedData
}

struct KDC_PROXY_MESSAGE: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case kerb_message = 0
        case target_domain = 1
        case dclocator_hint = 2
    }

    var kerb_message: Data
    var target_domain: Realm?
    var dclocator_hint: BigNumber.BInt?
}

struct KERB_TIMES: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case authtime = 0
        case starttime = 1
        case endtime = 2
        case renew_till = 3
    }

    var authtime: KerberosTime
    var starttime: KerberosTime
    var endtime: KerberosTime
    var renew_till: KerberosTime
}

struct KERB_CRED: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case client = 0
        case server = 1
        case keyblock = 2
        case times = 3
        case ticket = 4
        case authdata = 5
        case addresses = 6
        case flags = 7
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

struct KERB_TGS_REQ_IN: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case cache = 0
        case addrs = 1
        case flags = 2
        case imp = 3
        case ticket = 4
        case in_cred = 5
        case krbtgt = 6
        case padata = 7
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

struct KERB_TGS_REQ_OUT: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case subkey = 0
        case t = 1
    }

    var subkey: EncryptionKey?
    var t: TGS_REQ
}

struct KERB_TGS_REP_IN: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case cache = 0
        case subkey = 1
        case in_cred = 2
        case t = 3
    }

    var cache: Data
    var subkey: EncryptionKey?
    var in_cred: KERB_CRED
    var t: TGS_REP
}

struct KERB_TGS_REP_OUT: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case cache = 0
        case cred = 1
        case subkey = 2
    }

    var cache: Data
    var cred: KERB_CRED
    var subkey: EncryptionKey
}

struct KERB_ARMOR_SERVICE_REPLY: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case armor = 0
        case armor_key = 1
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
