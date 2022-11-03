//
// Copyright (c) 2022 gematik GmbH
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
import ASN1Kit
import BigNumber

extension BInt: ASN1DecodableType {
    public init(from asn1: ASN1Object) throws {
        guard let data = asn1.data.primitive, asn1.tag == .universal(.integer) else {
            throw ASN1Error.malformedEncoding("ASN.1 Object is not properly formatted")
        }
        self.init(bytes: Array(data))
    }
}

extension BInt: ASN1EncodableType {
    public func asn1encode(tag: ASN1DecodedTag?) throws -> ASN1Object {
        let data = Data(self.getBytes())
        return data.asn1encode(tag: .universal(.integer))
    }
}
