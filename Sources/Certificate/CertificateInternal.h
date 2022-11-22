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
#import <Certificate/Certificate.h>

__BEGIN_DECLS

CF_ASSUME_NONNULL_BEGIN
CF_IMPLICIT_BRIDGING_ENABLED

/// extended (private) APIs

__nullable CFArrayRef
CertificateCopyDescriptionsFromSAN(CertificateRef certificate);

__nullable CFDataRef
CertificateCopyReencoded(CertificateRef certificate);

__nullable CFStringRef
CertificateCopyJSONDescription(CertificateRef certificate);

CF_IMPLICIT_BRIDGING_DISABLED
CF_ASSUME_NONNULL_END

__END_DECLS
