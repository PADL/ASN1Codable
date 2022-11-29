//
//  CertificateAPI.h
//  ASN1Codable
//
//  Created by Luke Howard on 22/11/2022.
//

#ifndef CertificateAPI_h
#define CertificateAPI_h

#import <Certificate/Certificate.h>
#import <Certificate/CertificateInternal.h>
#import <Certificate/CertificatePriv.h>

#import <Security/Security.h>

#define errSecInternal (-26276)
#define errSecDecode (-26265)
#define errSecInvalidCertificate errSecDecode

CF_ASSUME_NONNULL_BEGIN
CF_IMPLICIT_BRIDGING_ENABLED

__nullable
CFDataRef _CertificateCopySerialNumberData(__nonnull CertificateRef certificate);

CF_IMPLICIT_BRIDGING_DISABLED
CF_ASSUME_NONNULL_END

#endif /* CertificateAPI_h */
