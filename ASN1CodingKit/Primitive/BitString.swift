//
//  BitString.swift
//  ASN1Kit
//
//  Created by Luke Howard on 26/10/2022.
//

import Foundation
import ASN1Kit

public struct BitString: MutableDataProtocol, ContiguousBytes, Codable, ASN1CodableType {
    public var startIndex: Data.Index { self.wrappedValue.startIndex }
    public var endIndex: Data.Index { self.wrappedValue.endIndex }
    public var regions: CollectionOfOne<BitString> { CollectionOfOne(self) }

    private var wrappedValue: Data

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
}
