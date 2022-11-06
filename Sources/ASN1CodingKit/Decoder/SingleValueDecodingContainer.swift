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

extension ASN1DecoderImpl {
    final class SingleValueContainer: ASN1DecodingContainer {
        private(set) var object: ASN1Object

        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]        
        var context: ASN1DecodingContext

        init(object: ASN1Object, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any],
             context: ASN1DecodingContext = ASN1DecodingContext()) {
            self.object = object
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.context = context
        }
    }
}

extension ASN1DecoderImpl.SingleValueContainer: SingleValueDecodingContainer {
    private func mappingASN1Error<T>(_ type: T.Type, _ block: () throws -> T) throws -> T {
        do {
            return try block()
        } catch let error as ASN1Error {
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "ASN.1 decoding error",
                                                underlyingError: error)
            throw DecodingError.dataCorrupted(context)
        }
    }

    func decodeNil() -> Bool {
        // FIXME check for zero length data?
        return object.isNull
    }
    
    func decode(_ type: Bool.Type) throws -> Bool {
        return try self.mappingASN1Error(type) {
            guard self.object.tag == .universal(.boolean) else {
                let context = DecodingError.Context(codingPath: self.codingPath,
                                                    debugDescription: "Expected \(ASN1DecodedTag.universal(.boolean)) tag when decoding \(self.object)")
                throw DecodingError.dataCorrupted(context)
            }

            return try Bool(from: self.object)
        }
    }
    
    func decode(_ type: String.Type) throws -> String {
        return try self.mappingASN1Error(type) {
            return try String(from: self.object)
        }
    }
    
    func decode(_ type: Double.Type) throws -> Double {
        throw ASN1Error.unsupported("Not implemented yet")
    }
    
    func decode(_ type: Float.Type) throws -> Float {
        throw ASN1Error.unsupported("Not implemented yet")
    }
    
    private func decodeFixedWidthInteger<T>(_ type: T.Type) throws -> T where T: FixedWidthInteger {
        try self.mappingASN1Error(type) {
            guard self.object.tag == .universal(.integer) else {
                let context = DecodingError.Context(codingPath: self.codingPath,
                                                    debugDescription: "Expected \(ASN1DecodedTag.universal(.integer)) tag when decoding \(self.object)")
                throw DecodingError.typeMismatch(type, context)
            }
            
            guard let data = object.data.primitive, !data.isEmpty else {
                let context = DecodingError.Context(codingPath: self.codingPath,
                                                    debugDescription: "Missing data for object \(self.object)")
                throw DecodingError.dataCorrupted(context)
            }
            
            guard type.bitWidth >= data.count * 8 else {
                let context = DecodingError.Context(codingPath: self.codingPath,
                                                    debugDescription: "Integer encoded in \(self.object) too large for \(type.bitWidth)-bit integer")
                throw DecodingError.dataCorrupted(context)
            }
        
            // FIXME can FixedWidthInteger be larger than platform integer?
            if T.isSigned {
                guard let value = data.asn1integer else {
                    let context = DecodingError.Context(codingPath: self.codingPath,
                                                        debugDescription: "Integer encoded in \(self.object) too large for platform signed integer")
                    throw DecodingError.dataCorrupted(context)
                }
                return T(value)
            } else {
                guard let value = data.unsignedIntValue else {
                    let context = DecodingError.Context(codingPath: self.codingPath,
                                                        debugDescription: "Integer encoded in \(self.object) too large for platform unsigned integer")
                    throw DecodingError.dataCorrupted(context)
                }
                return T(value)
            }
        }
    }

    func decode(_ type: Int.Type) throws -> Int {
        return try self.decodeFixedWidthInteger(type)
    }
    
    func decode(_ type: Int8.Type) throws -> Int8 {
        return try self.decodeFixedWidthInteger(type)
    }
    
    func decode(_ type: Int16.Type) throws -> Int16 {
        return try self.decodeFixedWidthInteger(type)
    }
    
    func decode(_ type: Int32.Type) throws -> Int32 {
        return try self.decodeFixedWidthInteger(type)
    }
    
    func decode(_ type: Int64.Type) throws -> Int64 {
        return try self.decodeFixedWidthInteger(type)
    }
    
    func decode(_ type: UInt.Type) throws -> UInt {
        return try self.decodeFixedWidthInteger(type)
    }
    
    func decode(_ type: UInt8.Type) throws -> UInt8 {
        return try self.decodeFixedWidthInteger(type)
    }
    
    func decode(_ type: UInt16.Type) throws -> UInt16 {
        return try self.decodeFixedWidthInteger(type)
    }
    
    func decode(_ type: UInt32.Type) throws -> UInt32 {
        return try self.decodeFixedWidthInteger(type)
    }
    
    func decode(_ type: UInt64.Type) throws -> UInt64 {
        return try self.decodeFixedWidthInteger(type)
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        return try self.mappingASN1Error(type) {
            return try self.decode(type, from: self.object)
        }
    }

    private func decode<T>(_ type: T.Type, from object: ASN1Object, skipTaggedValues: Bool = false) throws -> T where T : Decodable {
        let value: T
        
        // FIXME
        self.context = self.context.decodingSingleValue(type)

        if !skipTaggedValues, let type = type as? ASN1TaggedType.Type {
            value = try self.decodeTaggedValue(type, from: object) as! T
        } else if let type = type as? any (Decodable & ASN1TaggedWrappedValue).Type {
            value = try self.decodeTaggedProperty(type, from: object) as! T
        } else if let type = type as? ASN1DecodableType.Type {
            value = try decodePrimitiveValue(type, from: object, verifiedTag: skipTaggedValues) as! T
        } else {
            value = try self.decodeConstructedValue(type, from: object)
        }
        
        return value
    }
    
    private func decodeTaggedValue<T>(_ type: T.Type, from object: ASN1Object) throws -> T where T: Decodable & ASN1TaggedType {
        return try self.decodeTagged(type, from: object, tag: T.tag, tagging: T.tagging, skipTaggedValues: true)
    }
    
    private func decodeTaggedProperty<T>(_ type: T.Type, from object: ASN1Object) throws -> T where T: Decodable & ASN1TaggedWrappedValue {
        let wrappedValue = try self.decodeTagged(type.Value, from: object, tag: T.tag, tagging: T.tagging)
        
        return T(wrappedValue: wrappedValue)
    }
    
    private func decodePrimitiveValue<T>(_ type: T.Type, from object: ASN1Object, verifiedTag: Bool = false) throws -> T where T: ASN1DecodableType {
        let expectedTag = ASN1DecodingContext.tag(for: type)
        
        guard verifiedTag || (self.object.tag.isUniversal && self.object.tag == expectedTag) else {
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Expected \(expectedTag) when decoding \(self.object)")
            throw DecodingError.typeMismatch(type, context)
        }
        
        return try T(from: object)
    }
    
    private func decodeTagged<T>(_ type: T.Type,
                                 from object: ASN1Object,
                                 tag: ASN1DecodedTag?,
                                 tagging: ASN1Tagging?,
                                 skipTaggedValues: Bool = false) throws -> T where T: Decodable {
        guard let tag = tag else {
            // FIXME should this happen? precondition check?
            return try self.decode(type, from: object, skipTaggedValues: skipTaggedValues)
        }
        
        guard object.tag == tag else {
            // FIXME should we check for ASN1NullObject instead
            // FIXME are we potentailly squashing real tag mismatch errors
            if (object.isNull || tag.isUniversal == false), type is any OptionalProtocol.Type {
                return Optional<Decodable>.init(nilLiteral: ()) as! T
            }
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Expected tag \(tag) but received \(object.tag)")
            throw DecodingError.typeMismatch(type, context)
        }
                
        let unwrappedObject: ASN1Object
        let tagging = tagging ?? self.context.taggingEnvironment
        let innerTag = tagging == .implicit ? ASN1DecodingContext.tag(for: type) : tag
        
        if object.constructed {
            // FIXME something is very wrong here
            if tagging == .implicit && !ASN1DecodingContext.isEnum(type) {
                // FIXME propagate save
                unwrappedObject = ASN1Kit.create(tag: innerTag, data: object.data)
            } else {
                guard let items = object.data.items, items.count == 1, let firstObject = object.data.items!.first else {
                    let context = DecodingError.Context(codingPath: self.codingPath,
                                                        debugDescription: "Tag \(tag) for single value container must wrap a single value only")
                    throw DecodingError.typeMismatch(type, context)
                }
                unwrappedObject = firstObject
            }
        } else if innerTag.isUniversal {
            if tagging == .implicit {
                // FIXME propagate save
                unwrappedObject = ASN1Kit.create(tag: innerTag, data: object.data)
            } else {
                unwrappedObject = object
            }
        } else {
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Expected universal tag \(innerTag) for primitive object \(object)")
            throw DecodingError.typeMismatch(type, context)
        }
        
        let verifiedUniversalTag = !object.constructed && tag.isUniversal
        
        return try self.decode(type, from: unwrappedObject, skipTaggedValues: verifiedUniversalTag || skipTaggedValues)
    }

    private func decodeConstructedValue<T>(_ type: T.Type, from object: ASN1Object) throws -> T where T : Decodable {
        context.encodeAsSet = type is Set<AnyHashable>.Type || type is ASN1EncodeAsSetType.Type
        
        // FIXME does the fact we need to do this perhaps represent a misarchitecture?
        // e.g. should codingKeys represent the tags?

        if let type = type as? ASN1ObjectSetCodable.Type {
            self.context.objectSetCodingContext = ASN1ObjectSetCodingContext(objectSetType: type,
                                                                             encodeAsOctetString: type is ASN1ObjectSetOctetStringCodable.Type)
        }

        let decoder = ASN1DecoderImpl(object: object, codingPath: self.codingPath,
                                      userInfo: self.userInfo, context: self.context)
        do {
            let value = try T(from: decoder)
            
            if var value = value as? ASN1PreserveBinary {
                value._save = object.save
            }
                        
            return value
        } catch {
            let isOptional = type is OptionalProtocol.Type

            if isOptional, let error = error as? DecodingError, case .typeMismatch(_, _) = error {
                return Optional<Decodable>.init(nilLiteral: ()) as! T
            } else {
                throw error
            }
        }
    }
}

// meaningless but allows us to conform to the rest of the protocol
extension ASN1DecoderImpl.SingleValueContainer {
    func currentObject() throws -> ASN1Object {
        return self.object
    }
    
    var currentIndex: Int {
        return 0
    }
}
