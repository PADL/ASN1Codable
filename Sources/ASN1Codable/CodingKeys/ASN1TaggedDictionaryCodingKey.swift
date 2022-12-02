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

struct ASN1TaggedDictionaryCodingKey: ASN1ContextTagCodingKey {
    var metadata: ASN1Metadata {
        ASN1Metadata(tag: .taggedTag(self.tagNo), tagging: .explicit)
    }

    var tagNo: UInt

    init(tagNo: UInt) {
        self.tagNo = tagNo
    }

    init?(stringValue: String) {
        guard let tagNo = UInt(stringValue) else {
            return nil
        }
        self.tagNo = tagNo
    }

    init?(intValue: Int) {
        guard let tagNo = UInt(exactly: intValue) else {
            return nil
        }
        self.tagNo = tagNo
    }

    var stringValue: String {
        "[\(self.tagNo)]"
    }

    var intValue: Int? {
        guard let intValue = Int(exactly: self.tagNo) else {
            return nil
        }
        return intValue
    }
}
