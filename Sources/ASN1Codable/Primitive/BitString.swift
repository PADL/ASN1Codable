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

public struct BitString: MutableDataProtocol, ContiguousBytes, Equatable, Hashable {
  public var startIndex: Data.Index { self.wrappedValue.startIndex }
  public var endIndex: Data.Index { self.wrappedValue.endIndex }
  public var regions: CollectionOfOne<BitString> { CollectionOfOne(self) }

  public var wrappedValue: Data

  public init() {
    self.wrappedValue = Data()
  }

  public subscript(position: Data.Index) -> UInt8 {
    get {
      self.wrappedValue[position]
    }
    set(newValue) {
      self.wrappedValue[position] = newValue
    }
  }

  public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
    try self.wrappedValue.withUnsafeBytes(body)
  }

  public mutating func withUnsafeMutableBytes<R>(_ body: (UnsafeMutableRawBufferPointer) throws -> R) rethrows -> R {
    try self.wrappedValue.withUnsafeMutableBytes(body)
  }

  public mutating func replaceSubrange<C>(
    _ subrange: Range<Data.Index>,
    with newElements: __owned C
  ) where C: Collection, C.Element == Element {
    self.wrappedValue.replaceSubrange(subrange, with: newElements)
  }
}

extension BitString: Decodable {
  public init(from decoder: Decoder) throws {
    precondition(!(decoder is ASN1Codable.ASN1DecoderImpl))
    self.wrappedValue = try Data(from: decoder)
  }
}

extension BitString: Encodable {
  public func encode(to encoder: Encoder) throws {
    precondition(!(encoder is ASN1Codable.ASN1EncoderImpl))
    try self.wrappedValue.encode(to: encoder)
  }
}

extension BitString: ASN1DecodableType {
  public init(from asn1: ASN1Object) throws {
    switch (asn1.tag, asn1.data) {
    case (ASN1DecodedTag.universal(.bitString), .primitive(let data)):
      try self.wrappedValue = Data(bitString: data)
    default:
      throw ASN1Error.malformedEncoding("Invalid tag \(asn1.tag) for BitString")
    }
  }
}

extension BitString: ASN1EncodableType {
  public func asn1encode(tag: ASN1DecodedTag?) throws -> ASN1Object {
    try self.wrappedValue.asn1bitStringEncode(tag: tag)
  }
}

extension BitString: ASN1UniversalTagRepresentable {
  static var tagNo: ASN1Tag { .bitString }
}
