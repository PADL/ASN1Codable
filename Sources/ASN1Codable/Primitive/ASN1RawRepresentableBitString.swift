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

/// for handling RFC1510 (Kerberos) bit strings which are padded to 32 bits
public protocol ASN1RFC1510RawRepresentable {}

@propertyWrapper
public struct ASN1RawRepresentableBitString<Value> where
    Value: RawRepresentable & Codable,
    Value.RawValue: FixedWidthInteger & Codable {
    public var wrappedValue: Value

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public init() where Value: ExpressibleByNilLiteral {
        self.wrappedValue = nil
    }
}

extension ASN1RawRepresentableBitString: Decodable {
    public init(from decoder: Decoder) throws {
        precondition(!(decoder is ASN1Codable.ASN1DecoderImpl))
        self.wrappedValue = try Value(from: decoder)
    }
}

extension ASN1RawRepresentableBitString: Encodable {
    public func encode(to encoder: Encoder) throws {
        precondition(!(encoder is ASN1Codable.ASN1EncoderImpl))
        try self.wrappedValue.encode(to: encoder)
    }
}

extension ASN1RawRepresentableBitString: ASN1DecodableType {
    public init(from asn1: ASN1Object) throws {
        let bitString = try BitString(from: asn1)
        let rawValueSize = Value.RawValue.bitWidth / 8

        guard rawValueSize >= bitString.count else {
            throw ASN1Error.malformedEncoding("BitString encoded in \(asn1) too large for raw value")
        }

        var data = bitString.wrappedValue.map(\.bitSwapped)
        data.append(contentsOf: Data(count: rawValueSize - bitString.count))

        let rawValue = (data.withUnsafeBytes { $0.load(as: Value.RawValue.self) }).littleEndian
        guard let wrappedValue = Value(rawValue: rawValue) else {
            throw ASN1Error.malformedEncoding("BitString encoded in \(asn1) not representable as raw value")
        }

        self.wrappedValue = wrappedValue
    }
}

extension ASN1RawRepresentableBitString: ASN1EncodableType {
    public func asn1encode(tag: ASN1Kit.ASN1DecodedTag?) throws -> ASN1Object {
        let rfc1510BitString = Value.self is ASN1RFC1510RawRepresentable.Type
        var data = Swift.withUnsafeBytes(of: self.wrappedValue.rawValue.littleEndian) { Data($0) }

        if !rfc1510BitString {
            let index = data.reversed().firstIndex(where: { $0 != 0 })
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

extension ASN1RawRepresentableBitString: ASN1UniversalTagRepresentable {
    static var tagNo: ASN1Tag { .bitString }
}

extension ASN1RawRepresentableBitString: Equatable where Value: Equatable {}

extension ASN1RawRepresentableBitString: Hashable where Value: Hashable {}

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
