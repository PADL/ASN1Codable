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

private extension ASN1DecodedTag {
    var tagType: UInt8 {
        switch self {
        case .universal(_):
            return ASN1Tag.universal
        case .applicationTag(_):
            return ASN1Tag.application
        case .taggedTag(_):
            return ASN1Tag.tagged
        case .privateTag(_):
            return ASN1Tag.private
        }
    }
    
    var tagNo: UInt {
        switch self {
        case .universal(let tagNo):
            return UInt(tagNo.rawValue)
        case .applicationTag(let tagNo):
            return tagNo
        case .taggedTag(let tagNo):
            return tagNo
        case .privateTag(let tagNo):
            return tagNo
        }
    }
}

extension ASN1Object {
    var sorted: ASN1Object {
        guard self.constructed, self.tag == .universal(.set), let items = self.data.items else {
            return self
        }
        
        let sorted = items.sorted(by: { lhs, rhs in
            let lhs_tagType = lhs.tag.tagType, rhs_tagType = rhs.tag.tagType
            let lhs_tagNo = lhs.tag.tagNo, rhs_tagNo = rhs.tag.tagNo
            
            if lhs_tagType == lhs_tagType {
                return lhs_tagNo < rhs_tagNo
            } else {
                return lhs_tagType < rhs_tagType
            }
        })
        
        return ASN1Kit.create(tag: self.tag, data: .constructed(sorted))
    }
}
