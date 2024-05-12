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

public protocol BitStringOptionSet: OptionSet, ASN1CodableType where RawValue: FixedWidthInteger {}
public protocol RFC1510BitStringOptionSet: BitStringOptionSet {}

extension BitStringOptionSet {
  public init(from asn1: ASN1Object) throws {
    let bitString = try BitString(from: asn1)
    let rawValueSize = RawValue.bitWidth / 8

    guard rawValueSize >= bitString.count else {
      throw ASN1Error.malformedEncoding("BitString encoded in \(asn1) too large for raw value")
    }

    var data = bitString.wrappedValue.map(\.bitSwapped)
    data.append(contentsOf: Data(count: rawValueSize - bitString.count))

    let rawValue = (data.withUnsafeBytes { $0.load(as: RawValue.self) }).littleEndian
    guard let value = Self(rawValue: rawValue) else {
      throw ASN1Error.malformedEncoding("BitString encoded in \(asn1) not representable as raw value")
    }

    self = value
  }

  public func asn1encode(tag: ASN1Kit.ASN1DecodedTag?) throws -> ASN1Object {
    let rfc1510BitString = self is any RFC1510BitStringOptionSet
    var data = Swift.withUnsafeBytes(of: self.rawValue.littleEndian) { Data($0) }

    if !rfc1510BitString {
      let index = data.reversed().firstIndex { $0 != 0 }
      data.count = index?.base ?? 0
    }

    data = Data(data.map(\.bitSwapped))

    var bits: Int
    if rfc1510BitString {
      bits = 0
    } else {
      bits = data.last?.trailingZeroBitCount ?? 0
      if bits == 8 { bits = 0 }
    }

    return try data.asn1bitStringEncode(unused: bits, tag: tag)
  }
}

/// https://stackoverflow.com/questions/60594125/is-there-a-way-to-reverse-the-bit-order-in-uint64
extension UInt8 {
  fileprivate var bitSwapped: Self {
    var v = self
    var s = Self(v.bitWidth)
    precondition(s.nonzeroBitCount == 1, "Bit width must be a power of two")
    var mask = ~Self(0)
    repeat {
      s = s >> 1
      mask ^= mask << s
      v = ((v >> s) & mask) | ((v << s) & ~mask)
    } while s > 1
    return v
  }
}
