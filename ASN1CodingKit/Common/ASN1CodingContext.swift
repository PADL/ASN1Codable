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

// FIXME this really needs to go so we can be less stateful
// FIXME should it be a class

import Foundation

enum ASN1EnumCodingState {
    case none
    case `enum`
    case enumCase
}

protocol ASN1CodingContext {
    var enumCodingState: ASN1EnumCodingState { get set }
    var encodeAsSet: Bool { get set }
}

extension ASN1CodingContext {
    mutating func nextEnumCodingState() {
        if self.enumCodingState == .enum {
            self.enumCodingState = .enumCase
        } else {
            self.enumCodingState = .none
        }
    }
}
