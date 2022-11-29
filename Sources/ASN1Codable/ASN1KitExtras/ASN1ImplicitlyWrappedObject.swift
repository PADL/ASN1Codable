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
import ASN1Kit

struct ASN1ImplicitlyWrappedObject: ASN1Object {
    let data: ASN1Data
    let tag: ASN1DecodedTag
    let originalEncoding: Data?

    init(object: ASN1Object, tag: ASN1DecodedTag, constructed: Bool? = nil) {
        if constructed ?? object.constructed {
            self.data = ASN1Data.constructed([object])
        } else {
            self.data = object.data
        }
        self.tag = tag
        self.originalEncoding = object.originalEncoding
    }

    var length: Int {
        self.data.length
    }

    var constructed: Bool {
        if case .constructed = self.data {
            return true
        } else {
            return false
        }
    }
}
