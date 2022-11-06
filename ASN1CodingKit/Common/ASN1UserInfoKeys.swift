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

extension CodingUserInfoKey {
    // ASN1Tagging indicating tagging environment
    public static var ASN1TaggingEnvironment = CodingUserInfoKey(rawValue: "ASN1TaggingEnvironmentInfoKey")!
    
    // [String: [ObjectIdentifier: Any.Type]] mapping string representation of types to OID:type dictionaries
    public static var ASN1ObjectSetTypeDictionary = CodingUserInfoKey(rawValue: "ASN1ObjectSetTypeDictionaryUserInfoKey")!
    
    // bool if absent values should be encoded as NULL rather than omitted
    public static var ASN1EncodeNilAsNull = CodingUserInfoKey(rawValue: "ASN1EncodeNilAsNullInfoKey")!
}
