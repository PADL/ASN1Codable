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

/// A coding key which is expressable as ASN.1 metadata
public protocol ASN1CodingKey: CodingKey {
  var metadata: ASN1Metadata { get }
}

/// A coding key which can be constructed from an intValue representing a tag number
public protocol ASN1ContextTagCodingKey: ASN1CodingKey {}

extension ASN1ContextTagCodingKey {
  fileprivate var tagNo: UInt {
    guard let intValue = self.intValue, let tagNo = UInt(exactly: intValue) else {
      preconditionFailure("Invalid context tag coding key \(self)")
    }

    return tagNo
  }
}

/// A coding key representing an explicit CONTEXT tag
public protocol ASN1ExplicitTagCodingKey: ASN1ContextTagCodingKey {}

extension ASN1ExplicitTagCodingKey {
  public var metadata: ASN1Metadata {
    ASN1Metadata(tag: .taggedTag(self.tagNo), tagging: .explicit)
  }
}

/// A coding key representing an implicit CONTEXT tag
public protocol ASN1ImplicitTagCodingKey: ASN1ContextTagCodingKey {}

extension ASN1ImplicitTagCodingKey {
  public var metadata: ASN1Metadata {
    ASN1Metadata(tag: .taggedTag(self.tagNo), tagging: .implicit)
  }
}

/// A coding key representing any kind of tag or metadata
public protocol ASN1MetadataCodingKey: ASN1CodingKey, CaseIterable {
  static func metadata(forKey key: Self) -> ASN1Metadata?
}

extension ASN1MetadataCodingKey {
  public var metadata: ASN1Metadata {
    guard let metadata = Self.metadata(forKey: self) else {
      return ASN1Metadata()
    }
    precondition(!(metadata.tag?.isUniversal ?? false))
    return metadata
  }
}
