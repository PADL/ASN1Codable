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

extension ASN1Object {
    var sortedByTag: ASN1Object {
        guard self.constructed, self.tag == .universal(.set), let items = self.data.items else {
            return self
        }
        
        let sorted = items.sorted(by: { ASN1DecodedTag.sort($0.tag, $1.tag) })
        
        return ASN1Kit.create(tag: self.tag, data: .constructed(sorted))
    }
    
    var sortedByEncodedValue: ASN1Object {
        guard self.constructed, self.tag == .universal(.set), let items = self.data.items else {
            return self
        }

        let sorted = items.sorted(by: Self.sort)

        return ASN1Kit.create(tag: self.tag, data: .constructed(sorted))
    }
    
    private static func sort(_ lhs: ASN1Object, _ rhs: ASN1Object) -> Bool {
        do {
            let lhs_serialized = try lhs.serialize()
            let rhs_serialized = try rhs.serialize()
            
            if lhs_serialized.count == rhs_serialized.count {
                let cmp = lhs_serialized.withUnsafeBytes { lhs_bytes in
                    rhs_serialized.withUnsafeBytes { rhs_bytes in
                        return memcmp(lhs_bytes.bindMemory(to: UInt8.self).baseAddress,
                                      rhs_bytes.bindMemory(to: UInt8.self).baseAddress,
                                      lhs_serialized.count)
                    }
                }
                return cmp > 0
            } else {
                return lhs_serialized.count < rhs_serialized.count
            }
        } catch {
            return false
        }
    }
}
