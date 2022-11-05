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

protocol ASN1DecodingContainer {
    var object: ASN1Object { get }
    var context: ASN1DecodingContext { get set }
    var currentObject: ASN1Object { get }
    var currentIndex: Int { get }
}

extension ASN1DecodingContainer {
    var currentObject: ASN1Object {
        if self.context.enumCodingState != .none || self.object.isNull {
            return self.object
        } else {
            precondition(self.object.constructed)
            precondition(self.currentIndex < self.object.data.items!.count)
            return self.object.data.items![self.currentIndex]
        }
    }
}
