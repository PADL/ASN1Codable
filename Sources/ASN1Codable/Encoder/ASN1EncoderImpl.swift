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

class ASN1EncoderImpl {
  var container: ASN1EncodingContainer?
  var codingPath: [CodingKey]
  let userInfo: [CodingUserInfoKey: Any]
  let context: ASN1EncodingContext

  init(
    codingPath: [CodingKey] = [],
    userInfo: [CodingUserInfoKey: Any] = [:],
    taggingEnvironment: ASN1Tagging? = nil,
    objectSetTypeDictionary: ASN1ObjectSetTypeDictionary? = nil
  ) {
    self.codingPath = codingPath
    self.userInfo = userInfo
    self.context = ASN1EncodingContext(taggingEnvironment: taggingEnvironment ?? .explicit,
                                       objectSetTypeDictionary: objectSetTypeDictionary)
  }

  init(
    codingPath: [CodingKey] = [],
    userInfo: [CodingUserInfoKey: Any] = [:],
    context: ASN1EncodingContext = ASN1EncodingContext()
  ) {
    self.codingPath = codingPath
    self.userInfo = userInfo
    self.context = context
  }

  var object: ASN1Object? {
    self.container?.object
  }
}

extension ASN1EncoderImpl: Encoder {
  /// Returns an encoding container appropriate for holding multiple values
  /// keyed by the given key type.
  ///
  /// You must use only one kind of top-level encoding container. This method
  /// must not be called after a call to `unkeyedContainer()` or after
  /// encoding a value through a call to `singleValueContainer()`
  ///
  /// - parameter type: The key type to use for the container.
  /// - returns: A new keyed encoding container.
  func container<Key>(keyedBy _: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
    // FIXME: AnyCodable breaks this
    // precondition(self.container == nil)

    let container = KeyedContainer<Key>(codingPath: self.codingPath,
                                        userInfo: self.userInfo,
                                        context: self.context)
    self.container = container

    return KeyedEncodingContainer(container)
  }

  /// Returns an encoding container appropriate for holding multiple unkeyed
  /// values.
  ///
  /// You must use only one kind of top-level encoding container. This method
  /// must not be called after a call to `container(keyedBy:)` or after
  /// encoding a value through a call to `singleValueContainer()`
  ///
  /// - returns: A new empty unkeyed container.
  func unkeyedContainer() -> UnkeyedEncodingContainer {
    // FIXME: AnyCodable breaks this
    // precondition(self.container == nil)

    let container = UnkeyedContainer(codingPath: self.codingPath,
                                     userInfo: self.userInfo,
                                     context: self.context)
    self.container = container

    return container
  }

  /// Returns an encoding container appropriate for holding a single primitive
  /// value.
  ///
  /// You must use only one kind of top-level encoding container. This method
  /// must not be called after a call to `unkeyedContainer()` or
  /// `container(keyedBy:)`, or after encoding a value through a call to
  /// `singleValueContainer()`
  ///
  /// - returns: A new empty single value container.
  func singleValueContainer() -> SingleValueEncodingContainer {
    // FIXME: AnyCodable breaks this
    // precondition(self.container == nil)

    let container = SingleValueContainer(codingPath: self.codingPath,
                                         userInfo: self.userInfo,
                                         context: self.context)
    self.container = container

    return container
  }
}
