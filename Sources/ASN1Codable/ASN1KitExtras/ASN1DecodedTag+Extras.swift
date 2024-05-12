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

extension ASN1DecodedTag {
  private var tagType: UInt8 {
    switch self {
    case .universal:
      return ASN1Tag.universal
    case .applicationTag:
      return ASN1Tag.application
    case .taggedTag:
      return ASN1Tag.tagged
    case .privateTag:
      return ASN1Tag.private
    }
  }

  private var tagNo: UInt {
    switch self {
    case .universal(let tagNo):
      return UInt(tagNo.rawValue)
    case .applicationTag(let tagNo):
      return tagNo
    case .taggedTag(let tagNo):
      return tagNo
    case .privateTag(let tagNo):
      return tagNo
    }
  }
}

extension ASN1DecodedTag: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.tagType)
    hasher.combine(self.tagNo)
  }
}

extension ASN1DecodedTag: Decodable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let tag = try container.decode(String.self)

    precondition(!(decoder is ASN1DecoderImpl))

    guard let tag = Self(tagString: tag) else {
      let context = DecodingError.Context(codingPath: container.codingPath,
                                          debugDescription: "Invalid tag \(tag)")
      throw DecodingError.dataCorrupted(context)
    }

    self = tag
  }
}

extension ASN1DecodedTag: Encodable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(self.tagString)
  }
}

extension ASN1DecodedTag {
  static func sort(_ lhs: ASN1DecodedTag, _ rhs: ASN1DecodedTag) -> Bool {
    let lhsTagType = lhs.tagType, rhsTagType = rhs.tagType
    let lhsTagNo = lhs.tagNo, rhsTagNo = rhs.tagNo

    if lhsTagType == lhsTagType {
      return lhsTagNo < rhsTagNo
    } else {
      return lhsTagType < rhsTagType
    }
  }
}

extension ASN1DecodedTag {
  var tagString: String {
    let tagString: String

    switch self {
    case .applicationTag(let tagNo):
      tagString = "application.\(tagNo)"
    case .taggedTag(let tagNo):
      tagString = "\(tagNo)"
    case .universal(let tag):
      tagString = "universal.\(tag.rawValue)"
    case .privateTag(let tagNo):
      tagString = "private.\(tagNo)"
    }

    return tagString
  }

  init?(tagString tag: String) {
    if !tag.contains(".") {
      guard let tagNo = UInt(tag) else {
        return nil
      }
      self = .taggedTag(tagNo)
    } else {
      let typeTagNo = tag.components(separatedBy: ".")
      guard typeTagNo.count == 2, let tagNo = UInt(typeTagNo[1]) else {
        return nil
      }
      switch typeTagNo[0] {
      case "application":
        self = .applicationTag(tagNo)
      case "universal":
        guard tagNo == tagNo & 0xFF, let tag = ASN1Tag(rawValue: UInt8(tagNo)) else {
          return nil
        }
        self = .universal(tag)
      case "private":
        self = .privateTag(tagNo)
      default:
        return nil
      }
    }
  }
}
