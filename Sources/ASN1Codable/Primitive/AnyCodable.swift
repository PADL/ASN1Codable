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
import AnyCodable

extension AnyCodable {
  fileprivate var isNull: Bool {
    if let value = self.value as? NSNull {
      return value == NSNull()
    } else {
      return false
    }
  }
}

func isNullAnyCodable<T: Decodable>(_ value: T?) -> Bool {
  guard let value = value as? AnyCodable else { return false }
  return value.isNull
}
