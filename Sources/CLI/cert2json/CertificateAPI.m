//
//  CertificateAPI.m
//  cert2json
//
//  Created by Luke Howard on 21/11/2022.
//

#import <Foundation/Foundation.h>

#import "cert2json-Bridging-Header.h"
#import "cert2json-Swift.h"

#include <Security/Security.h>

typedef Certificate *CertificateRef;

CFDataRef CertificateCopySerialNumberData(
        CertificateRef certificate,
        CFErrorRef *error)
{
    if (certificate == NULL) {
        *error = CFErrorCreate(NULL, kCFErrorDomainOSStatus, errSecInvalidCertificateRef, NULL);
    }
    
    return [certificate serialNumberData];
}
