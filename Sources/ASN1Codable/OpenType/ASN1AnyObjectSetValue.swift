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
import AnyCodable

/// Represents a type-erased object set value.
@propertyWrapper
public struct ASN1AnyObjectSetValue: Codable, Hashable {
    public typealias Value = AnyCodable

    public var wrappedValue: Value

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public func encode(to encoder: Encoder) throws {
        try self.wrappedValue.encode(to: encoder)
    }

    public init(from decoder: Decoder) throws {
        self.wrappedValue = AnyCodable(try ASN1ObjectSetValue(from: decoder))
    }
}
