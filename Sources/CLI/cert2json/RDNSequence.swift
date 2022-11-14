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
import ASN1Codable

extension RDNSequence {
    static func parse(dn: String) throws -> RDNSequence {
        let dnComponents = dn.components(separatedBy: "/")

        if dnComponents.count < 1 {
            throw ASN1Error.malformedEncoding("Malformed DN")
        }
        
        let rdnSequence: [RelativeDistinguishedName] = try dnComponents[1...].map {
            let rdnComponents = $0.components(separatedBy: "=")
            guard rdnComponents.count == 2 else {
                throw ASN1Error.malformedEncoding("Malformed RDN")
            }
            let oid = try ObjectIdentifier.from(string: rdnComponents[0])
            let directoryString = DirectoryString.ia5String(IA5String(wrappedValue: rdnComponents[1]))
            let ava = AttributeTypeAndValue(type: oid, value: directoryString)

            return RelativeDistinguishedName([ava])
        }
        
        return rdnSequence
    }
}
