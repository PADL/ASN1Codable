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
import Echo

final class ASN1AutomaticTaggingContext: CustomStringConvertible {
    private var tagNo: UInt
    
    init?<T>(_ type: T.Type) {
        // this is expensive, so use automatic tags sparingly, or have the compiler do the job
        guard let metadata = reflect(type) as? StructMetadata else {
            return nil
        }
        
        let hasTaggedFields = metadata.descriptor.fields.records.contains {
            guard let fieldType = metadata.type(of: $0.mangledTypeName),
                  let wrappedFieldType = fieldType as? any ASN1TaggedWrappedValue.Type else {
                return false
            }
            return wrappedFieldType.tag != nil
        }
        
        guard !hasTaggedFields else {
            return nil
        }
        
        self.tagNo = 0
    }
    
    func nextTag() -> UInt {
        defer { self.tagNo += 1 }
        return self.tagNo
    }
    
    var description: String {
        return "ASN1AutomaticTaggingContext(tagNo: \(self.tagNo))"
    }
}
