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

/// A placeholder key used to mark already processed keys when coding tagged values
struct ASN1PlaceholderCodingKey: CodingKey {
    private let wrappedValue: ASN1CodingKey

    init(_ wrappedValue: ASN1CodingKey) { self.wrappedValue = wrappedValue }
    init?(intValue _: Int) { nil }
    init?(stringValue _: String) { nil }

    var stringValue: String { self.wrappedValue.stringValue }
    var intValue: Int? { self.wrappedValue.intValue }
}
