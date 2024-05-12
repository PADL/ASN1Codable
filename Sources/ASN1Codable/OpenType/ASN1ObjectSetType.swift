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

/// Represents a key, typically an `Int` or `ObjectIdentifier`, that is used as a
/// discriminant in encoding an object set.
@propertyWrapper
public struct ASN1ObjectSetType<ValueType>: Codable where ValueType: Codable & Hashable {
  public var wrappedValue: ValueType

  public init(wrappedValue: ValueType) {
    self.wrappedValue = wrappedValue
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(self.wrappedValue)

    if let encoder = encoder as? ASN1EncoderImpl,
       let objectSetCodingContext = encoder.context.objectSetCodingContext {
      precondition(objectSetCodingContext.valueType == nil)
      objectSetCodingContext.valueType = self.wrappedValue
    }
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.wrappedValue = try container.decode(ValueType.self)

    if let decoder = decoder as? ASN1DecoderImpl,
       let objectSetCodingContext = decoder.context.objectSetCodingContext {
      precondition(objectSetCodingContext.valueType == nil)
      objectSetCodingContext.valueType = self.wrappedValue
    }
  }
}

extension ASN1ObjectSetType: Equatable where ValueType: Equatable {}

extension ASN1ObjectSetType: Hashable where ValueType: Hashable {}
