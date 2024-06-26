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

extension ASN1EncoderImpl {
  final class UnkeyedContainer: ASN1EncodingContainer {
    var containers: [ASN1EncodingContainer] = []
    let codingPath: [CodingKey]
    let userInfo: [CodingUserInfoKey: Any]
    var context: ASN1EncodingContext

    init(
      codingPath: [CodingKey],
      userInfo: [CodingUserInfoKey: Any],
      context: ASN1EncodingContext = ASN1EncodingContext()
    ) {
      self.codingPath = codingPath
      self.userInfo = userInfo
      self.context = context
    }

    var count: Int {
      self.containers.count
    }

    var nestedCodingPath: [CodingKey] {
      self.codingPath + [ASN1Key(index: self.count)]
    }
  }
}

extension ASN1EncoderImpl.UnkeyedContainer: UnkeyedEncodingContainer {
  private func addContainer(_ container: ASN1EncodingContainer) {
    self.containers.append(container)
  }

  func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
    let container = ASN1EncoderImpl.UnkeyedContainer(codingPath: self.nestedCodingPath,
                                                     userInfo: self.userInfo,
                                                     context: self.context)
    container.context.encodingNestedContainer()
    self.addContainer(container)

    return container
  }

  func encodeNil() throws {
    var container = self.nestedSingleValueContainer(context: ASN1EncodingContext())
    try container.encodeNil()
  }

  func encode(_ value: Bool) throws {
    try self.encodeUnkeyedSingleValue(value)
  }

  func encode(_ value: Int) throws {
    try self.encodeUnkeyedSingleValue(value)
  }

  func encode(_ value: Int8) throws {
    try self.encodeUnkeyedSingleValue(value)
  }

  func encode(_ value: Int16) throws {
    try self.encodeUnkeyedSingleValue(value)
  }

  func encode(_ value: Int32) throws {
    try self.encodeUnkeyedSingleValue(value)
  }

  func encode(_ value: Int64) throws {
    try self.encodeUnkeyedSingleValue(value)
  }

  func encode(_ value: UInt) throws {
    try self.encodeUnkeyedSingleValue(value)
  }

  func encode(_ value: UInt8) throws {
    try self.encodeUnkeyedSingleValue(value)
  }

  func encode(_ value: UInt16) throws {
    try self.encodeUnkeyedSingleValue(value)
  }

  func encode(_ value: UInt32) throws {
    try self.encodeUnkeyedSingleValue(value)
  }

  func encode(_ value: UInt64) throws {
    try self.encodeUnkeyedSingleValue(value)
  }

  func encode(_ value: String) throws {
    try self.encodeUnkeyedSingleValue(value)
  }

  func encode(_ value: Float) throws {
    try self.encodeUnkeyedSingleValue(value)
  }

  func encode(_ value: Double) throws {
    try self.encodeUnkeyedSingleValue(value)
  }

  func encode<T>(_ value: T) throws where T: Encodable {
    try self.encodeUnkeyedSingleValue(value)
  }

  func nestedContainer<NestedKey>(
    keyedBy _: NestedKey.Type
  ) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
    let container = ASN1EncoderImpl.KeyedContainer<NestedKey>(codingPath: self.nestedCodingPath,
                                                              userInfo: self.userInfo,
                                                              context: self.context)
    container.context.encodingNestedContainer()
    self.addContainer(container)

    return KeyedEncodingContainer(container)
  }

  func superEncoder() -> Encoder {
    ASN1EncoderImpl.ReferencingEncoder(self, at: self.count)
  }
}

extension ASN1EncoderImpl.UnkeyedContainer {
  private func encodeUnkeyedSingleValue<T>(_ value: T) throws where T: Encodable {
    let context = self.context.encodingSingleValue(value)
    var container = self.nestedSingleValueContainer(context: context)

    /// Encode `Array<T?>` as `SEQUENCE OF CHOICE { HEIM_ANY, NULL }`
    if let value = value as? ExpressibleByNilLiteral,
       let value = value as? Encodable? {
      if case .some(let value) = value {
        try container.encode(value)
      } else {
        try container.encode(Null())
      }
    } else {
      try container.encode(value)
    }
  }

  private func nestedSingleValueContainer(context: ASN1EncodingContext) -> SingleValueEncodingContainer {
    let container = ASN1EncoderImpl.SingleValueContainer(codingPath: self.nestedCodingPath,
                                                         userInfo: self.userInfo,
                                                         context: context)
    self.addContainer(container)

    return container
  }

  var object: ASN1Object? {
    var object: ASN1Object?

    if self.context.enumCodingState != .none {
      precondition(self.containers.count <= 1)
      object = self.containers.first?.object
    } else {
      let values = self.containers.compactMap(\.object)

      if self.context.encodeAsSet {
        object = ASN1Kit.create(tag: .universal(.set), data: .constructed(values))
        if !self.disableSetSorting {
          object = object?.sortedByEncodedValue
        }
      } else {
        object = ASN1Kit.create(tag: .universal(.sequence), data: .constructed(values))
      }
    }

    return object
  }
}
