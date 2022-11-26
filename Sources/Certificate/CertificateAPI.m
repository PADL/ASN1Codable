/*
 * Copyright (c) 2012,2014 Apple Inc. All Rights Reserved.
 *
 * @APPLE_LICENSE_HEADER_START@
 *
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this
 * file.
 *
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 *
 * @APPLE_LICENSE_HEADER_END@
 */

#import <Foundation/Foundation.h>

#import <Certificate/Certificate.h>
#import <Certificate/CertificateInternal.h>
#import <Certificate/CertificatePriv.h>

#import "CertificateAPI.h"
#import "CFRelease.h"

OSStatus CertificateCopyCommonName(CertificateRef certificate, CFStringRef *commonName)
{
    if (!certificate) {
        return errSecParam;
    }
    CFArrayRef commonNames = CertificateCopyCommonNames(certificate);
    if (!commonNames) {
        return errSecInternal;
    }

    if (commonName) {
        CFIndex count = CFArrayGetCount(commonNames);
        *commonName = CFRetainSafe(CFArrayGetValueAtIndex(commonNames, count-1));
    }
    CFReleaseSafe(commonNames);
    return errSecSuccess;
}

OSStatus CertificateCopyEmailAddresses(CertificateRef certificate, CFArrayRef * __nonnull CF_RETURNS_RETAINED emailAddresses) {
    if (!certificate || !emailAddresses) {
        return errSecParam;
    }
    *emailAddresses = CertificateCopyRFC822Names(certificate);
    if (*emailAddresses == NULL) {
        *emailAddresses = CFArrayCreate(NULL, NULL, 0, &kCFTypeArrayCallBacks);
    }
    return errSecSuccess;
}

CFDataRef CertificateCopySerialNumberData(CertificateRef certificate, CFErrorRef *error) {
    if (!certificate) {
        if (error) {
                *error = CFErrorCreate(NULL, kCFErrorDomainOSStatus, errSecInvalidCertificate, NULL);
        }
        return NULL;
    }
    return _CertificateCopySerialNumberData(certificate);
}
