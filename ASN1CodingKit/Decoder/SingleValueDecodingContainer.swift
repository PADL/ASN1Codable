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
        
        // because of the way the type system works (specifically the lack of reflection
        // on types themselves), we can't take the encoder shortcut of directly burrowing
        // through wrapped values. Instead we need to keep a stack of tags and tagging
        // modes as decoder context, and then apply once we hit a concrete wrapped value.
        
        var didEncode: Bool = false
        var context: ASN1DecodingContext

        private var defaultTagging: ASN1Tagging {
            return (self.userInfo[CodingUserInfoKey.ASN1TaggingEnvironment] as? ASN1Tagging) ?? .automatic
        }
        
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
            // FIXME check order of unwrapping
            guard let data = object.data.primitive else {
                let context = DecodingError.Context(codingPath: self.codingPath,
                                                    debugDescription: "No data for object \(self.object)")
                throw DecodingError.dataCorrupted(context)
            }
            
            guard let integer = data.asn1integer else {
                // FIXME unsigned int support
                
                let context = DecodingError.Context(codingPath: self.codingPath,
                                                    debugDescription: "Integer encoded in \(self.object) too large for FixedWidthInteger")
                throw DecodingError.dataCorrupted(context)
            }
            
            return T(integer)
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
        // FIXME
        self.context = self.context.decodingSingleValue(type)
        
        return try self.mappingASN1Error(type) {
            return try self.decode(type, from: self.object)
        }
    }

    private func decode<T>(_ type: T.Type, from object: ASN1Object, skipTaggedValues: Bool = false) throws -> T where T : Decodable {
        let value: T
        
        if !skipTaggedValues, let type = type as? ASN1TaggedType.Type {
            value = try self.decodeTaggedValue(type, from: object) as! T
        } else if let type = type as? any (Decodable & ASN1TaggedProperty).Type {
            value = try self.decodeTaggedProperty(type, from: object) as! T
        } else if let type = type as? ASN1DecodableType.Type {
            value = try self.mappingASN1Error(ASN1DecodableType.self) {
                // FIXME check this doesn't need to be a runtime check rather than an assert
                return try decodePrimitiveValue(type, from: object)
            } as! T
        } else {
            value = try self.decodeConstructedValue(type, from: object)
        }
        
        return value
    }
    
    private func decodeTaggedValue<T>(_ type: T.Type, from object: ASN1Object) throws -> T where T: Decodable & ASN1TaggedType {
        return try self.decodeTagged(type, from: object, tag: T.tag, tagging: T.tagging, skipTaggedValues: true)
    }
    
    private func decodeTaggedProperty<T>(_ type: T.Type, from object: ASN1Object) throws -> T where T: Decodable & ASN1TaggedProperty {
        let wrappedValue = try self.decodeTagged(type.Value, from: object, tag: T.tag, tagging: T.tagging)
        
        return T(wrappedValue: wrappedValue)
    }
    
    private func decodePrimitiveValue<T>(_ type: T.Type, from object: ASN1Object) throws -> T where T: ASN1DecodableType {
        return try T(from: object)
    }
    
    private func decodeTagged<T>(_ type: T.Type,
                                 from object: ASN1Object,
                                 tag: ASN1DecodedTag?,
                                 tagging: ASN1Tagging,
                                 skipTaggedValues: Bool = false) throws -> T where T: Decodable {
        let unwrappedObject: ASN1Object

        if let tag = tag {
            guard object.tag == tag else {
                // FIXME should we check for ASN1NullObject instead
                // FIXME are we potentailly squashing real tag mismatch errors
                if (object.isNull || tag.isUniversal == false), type is any OptionalProtocol.Type {
                    // FIXME keep trying until we find a tag that matches
                   return Optional<Decodable>.none as! T
                }
                
                let context = DecodingError.Context(codingPath: self.codingPath,
                                                    debugDescription: "Expected tag \(tag) but received \(object.tag)")
                throw DecodingError.typeMismatch(type, context)
            }
            
            if tag.isUniversal {
                return try self.decode(type, from: object, skipTaggedValues: true)
            } else if tagging == .implicit {
                guard !object.constructed else {
                    let context = DecodingError.Context(codingPath: self.codingPath,
                                                        debugDescription: "Expected IMPLICIT tag \(tag) to wrap constructed type")
                    throw DecodingError.typeMismatch(type, context)
                }
                
                guard let type = type as? ASN1UniversalTagRepresentable.Type else {
                    let context = DecodingError.Context(codingPath: self.codingPath,
                                                        debugDescription: "Could not find appropriate primitive tag for implicitly encoded \(type)")
                    throw DecodingError.typeMismatch(type, context)
                }

                unwrappedObject = ASN1Kit.create(tag: .universal(type.tagNo), data: object.data)
            } else {
                guard object.constructed else {
                    let context = DecodingError.Context(codingPath: self.codingPath,
                                                        debugDescription: "Expected EXPLICIT tag \(tag) to wrap constructed type")
                    throw DecodingError.typeMismatch(type, context)
                }
                
                guard let items = object.data.items, items.count == 1, let object = object.data.items!.first else {
                    let context = DecodingError.Context(codingPath: self.codingPath,
                                                        debugDescription: "Tag \(tag) for single value container must wrap a single value only")
                    throw DecodingError.typeMismatch(type, context)
                }
                
                unwrappedObject = object
            }
        } else {
            unwrappedObject = object
        }
        
        return try self.decode(type, from: unwrappedObject, skipTaggedValues: skipTaggedValues)
    }

    private func decodeConstructedValue<T>(_ type: T.Type, from object: ASN1Object) throws -> T where T : Decodable {
        context.encodeAsSet = type is Set<AnyHashable>.Type || type is ASN1EncodeAsSetType.Type
        
        // FIXME does the fact we need to do this perhaps represent a misarchitecture?
        // e.g. should codingKeys represent the tags?
        
        let decoder = ASN1DecoderImpl(object: object, codingPath: self.codingPath,
                                      userInfo: self.userInfo, context: self.context)

        return try self.mappingASN1Error(type) {
            let value = try T(from: decoder)
            
            if var value = value as? ASN1PreserveBinary {
                value._save = object.save
            }
            
            return value
        }
    }
}

// meaningless but allows us to conform to the rest of the protocol
extension ASN1DecoderImpl.SingleValueContainer {
    var currentObject: ASN1Object {
        return self.object
    }
    
    var currentIndex: Int {
        return 0
    }
}
