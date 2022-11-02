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

// FIXME need to deal with bit strings that are not byte multiples

public struct BitString: MutableDataProtocol, ContiguousBytes, Codable, ASN1CodableType {
    public var startIndex: Data.Index { self.wrappedValue.startIndex }
    public var endIndex: Data.Index { self.wrappedValue.endIndex }
    public var regions: CollectionOfOne<BitString> { CollectionOfOne(self) }

    public var wrappedValue: Data

    public init() {
        self.wrappedValue = Data()
    }
    
    public subscript(position: Data.Index) -> UInt8 {
        get {
            return self.wrappedValue[position]
        }
        set(newValue) {
            self.wrappedValue[position] = newValue
        }
    }

    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        return try self.wrappedValue.withUnsafeBytes(body)
    }

    public mutating func withUnsafeMutableBytes<R>(_ body: (UnsafeMutableRawBufferPointer) throws -> R) rethrows -> R {
        return try self.wrappedValue.withUnsafeMutableBytes(body)
    }
    
    public mutating func replaceSubrange<C>(_ subrange: Range<Data.Index>, with newElements: __owned C) where C: Collection, C.Element == Element {
        self.wrappedValue.replaceSubrange(subrange, with: newElements)
    }

    public init(from asn1: ASN1Object) throws {
        switch (asn1.tag, asn1.data) {
        case let (ASN1DecodedTag.universal(.bitString), .primitive(data)):
            try self.wrappedValue = Data(bitString: data)
        default:
            throw ASN1Error.malformedEncoding("Invalid tag \(asn1.tag) for BitString")
        }
    }

    public func asn1encode(tag: ASN1DecodedTag?) throws -> ASN1Object {
        return try self.wrappedValue.asn1bitStringEncode(unused: 0, tag: tag)
    }
    
    public func encode(to encoder: Encoder) throws {
        precondition(!(encoder is ASN1CodingKit.ASN1EncoderImpl))
        try self.wrappedValue.encode(to: encoder)
    }
    
    public init(from decoder: Decoder) throws {
        precondition(!(decoder is ASN1CodingKit.ASN1DecoderImpl))
        self.wrappedValue = try Data(from: decoder)
    }
}
