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

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>

///
/// This API is a partial re-implementation of SecCertificate from Security.framework
/// in order to explore the feasibility of updating it to a more modern Swift core.
///

__BEGIN_DECLS

CF_ASSUME_NONNULL_BEGIN
CF_IMPLICIT_BRIDGING_ENABLED

struct __Certificate;
typedef struct CF_BRIDGED_TYPE(CFTypeRef) __Certificate *CertificateRef;

__nullable CertificateRef
CertificateCreateWithData(CFAllocatorRef __nullable allocator, CFDataRef data);

__nullable CFDataRef
CertificateCopyData(CertificateRef certificate);

__nullable
CFStringRef CertificateCopySubjectSummary(CertificateRef certificate);

OSStatus
CertificateCopyCommonName(CertificateRef certificate, CFStringRef * __nonnull CF_RETURNS_RETAINED commonName);

OSStatus
CertificateCopyEmailAddresses(CertificateRef certificate, CFArrayRef * __nonnull CF_RETURNS_RETAINED emailAddresses);

__nullable
CFDataRef CertificateCopySerialNumberData(CertificateRef certificate, CFErrorRef *error);

typedef CF_OPTIONS(uint32_t, KeyUsage) {
    kKeyUsageUnspecified      = 0u,
    kKeyUsageDigitalSignature = 1u << 0,
    kKeyUsageNonRepudiation   = 1u << 1,
    kKeyUsageContentCommitment= 1u << 1,
    kKeyUsageKeyEncipherment  = 1u << 2,
    kKeyUsageDataEncipherment = 1u << 3,
    kKeyUsageKeyAgreement     = 1u << 4,
    kKeyUsageKeyCertSign      = 1u << 5,
    kKeyUsageCRLSign          = 1u << 6,
    kKeyUsageEncipherOnly     = 1u << 7,
    kKeyUsageDecipherOnly     = 1u << 8,
    kKeyUsageCritical         = 1u << 31,
    kKeyUsageAll              = 0x7FFFFFFFu
};

KeyUsage CertificateGetKeyUsage(__nullable CertificateRef certificate);

CF_IMPLICIT_BRIDGING_DISABLED
CF_ASSUME_NONNULL_END

__END_DECLS
