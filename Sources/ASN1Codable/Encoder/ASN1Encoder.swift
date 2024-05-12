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

public final class ASN1Encoder {
  public var userInfo: [CodingUserInfoKey: Any] = [:]
  public var taggingEnvironment: ASN1Tagging?
  public var objectSetTypeDictionary: ASN1ObjectSetTypeDictionary?

  public init() {}

  public func encode<T: Encodable>(_ value: T) throws -> Data {
    let encoder = ASN1EncoderImpl(userInfo: self.userInfo,
                                  taggingEnvironment: self.taggingEnvironment,
                                  objectSetTypeDictionary: self.objectSetTypeDictionary)
    let box = Box(value) // needed to encode containing structure
    try box.encode(to: encoder)
    guard let object = encoder.object else {
      let context = EncodingError.Context(codingPath: [], debugDescription: "No object encoded")
      throw EncodingError.invalidValue(value, context)
    }

    return try object.serialize()
  }
}

#if canImport(Combine)
  import Combine

  extension ASN1Encoder: TopLevelEncoder {
    public typealias Input = Data
  }
#endif
