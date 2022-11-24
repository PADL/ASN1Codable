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
    func validateConstraints(with metadata: ASN1Metadata) -> Bool {
        let validatedSizeConstraints: Bool

        if let sizeConstraints = metadata.sizeConstraints {
            switch self.data {
            case .primitive(let data):
                validatedSizeConstraints = sizeConstraints.contains(data.count)
                break
            case .constructed(let items):
                validatedSizeConstraints = sizeConstraints.contains(items.count)
                break
            }
        } else {
            validatedSizeConstraints = true
        }
        
        return validatedSizeConstraints
    }
}
