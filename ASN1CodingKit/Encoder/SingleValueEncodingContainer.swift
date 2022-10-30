//
//  SingleValueEncodingContainer.swift
//  asn1bridgetest
//
//  Created by Luke Howard on 23/10/2022.
//

import Foundation
import ASN1Kit

extension ASN1EncoderImpl {
    final class SingleValueContainer: ASN1EncodingContainer {
        private var _object: ASN1Object?

        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]
        
        var tags: [ASN1DecodedTag] = []
        var taggingModes: [ASN1TaggingMode] = []
        var didEncode: Bool = false
        var state: ASN1CodingState
        
        private var defaultTaggingMode: ASN1TaggingMode {
            return (self.userInfo[CodingUserInfoKey.ASN1TaggingMode] as? ASN1TaggingMode) ?? .automatic
        }
        
        private(set) var object: ASN1Object? {
            get {
                return self._object
            }
            
            set {
                preconditionCanEncodeNewValue()
                self._object = newValue
                self.didEncode = true
            }
        }
        
        init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any], state: ASN1CodingState) {
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.state = state
        }

        func preconditionCanEncodeNewValue() {
            precondition(!self.didEncode)
        }
        
        fileprivate func wrap(tag: ASN1DecodedTag?, taggingMode: ASN1TaggingMode?) throws {
            guard let object = self._object,
                  let tag = tag else {
                return
            }
            
            let taggingMode: ASN1TaggingMode = taggingMode ?? self.defaultTaggingMode
            self._object = object.wrap(with: tag, constructed: taggingMode != .implicit)
        }
    }
}

extension ASN1EncoderImpl.SingleValueContainer: SingleValueEncodingContainer {
    func encodeNil() throws {
        preconditionCanEncodeNewValue()
        self.didEncode = true
    }
    
    func encodeFixedWithInteger<T>(_ value: T) throws where T: FixedWidthInteger {
        let object: ASN1Object
        
        object = T.isSigned ?
            try Int(value).asn1encode(tag: nil) : try UInt(value).asn1encode(tag: nil)
        self.object = object
    }
    
    func encode(_ value: Bool) throws {
        let object: ASN1Object = try value.asn1encode(tag: nil)
        self.object = object
    }
    
    func encode(_ value: String) throws {
        let object: ASN1Object = try value.asn1encode(tag: nil)
        self.object = object
    }
    
    func encode(_ value: Double) throws {
        fatalError("no support for encoding floating point values")
        //throw ASN1Error.unsupported("No support yet for floating point values")
    }
    
    func encode(_ value: Float) throws {
        fatalError("no support for encoding floating point values")
        //throw ASN1Error.unsupported("No support yet for floating point values")
    }
    
    func encode(_ value: Int) throws {
        try self.encodeFixedWithInteger(value)
    }
    
    func encode(_ value: Int8) throws {
        try self.encodeFixedWithInteger(value)
    }
    
    func encode(_ value: Int16) throws {
        try self.encodeFixedWithInteger(value)
    }
    
    func encode(_ value: Int32) throws {
        try self.encodeFixedWithInteger(value)
    }
    
    func encode(_ value: Int64) throws {
        try self.encodeFixedWithInteger(value)
    }
    
    func encode(_ value: UInt) throws {
        try self.encodeFixedWithInteger(value)
    }
    
    func encode(_ value: UInt8) throws {
        try self.encodeFixedWithInteger(value)
    }
    
    func encode(_ value: UInt16) throws {
        try self.encodeFixedWithInteger(value)
    }
    
    func encode(_ value: UInt32) throws {
        try self.encodeFixedWithInteger(value)
    }
    
    func encode(_ value: UInt64) throws {
        try self.encodeFixedWithInteger(value)
    }
    
    private func encode<T: Encodable>(_ value: T,
                                      tags: inout [ASN1DecodedTag],
                                      taggingModes: inout [ASN1TaggingMode]) throws {
        if let value = value as? ASN1EncodableType {
            try self.encodePrimitiveValue(value, tags: &tags)
        } else {
            try self.encodeConstructedValue(value)
        }
                
        try tags.filter { $0.isUniversal == false }.forEach {
            try self.wrap(tag: $0, taggingMode: taggingModes.popLast() ?? .automatic)
        }
        tags = []
        taggingModes = []
    }

    func encode<T: Encodable>(_ value: T) throws {
        if let value = value as? ASN1Type & Encodable {
            let type = type(of: value)
            var tags: [ASN1DecodedTag]
            var taggingModes: [ASN1TaggingMode]
            
            if let tag = type.tag {
                tags = [tag]
            } else {
                tags = []
            }
            
            if let taggingMode = type.taggingMode {
                taggingModes = [taggingMode]
            } else {
                taggingModes = []
            }
            
            try self.encode(value, tags: &tags, taggingModes: &taggingModes)
        } else {
            try self.encode(value, tags: &self.tags, taggingModes: &self.taggingModes)
        }
    }
    
    private func encodePrimitiveValue(_ value: ASN1EncodableType,
                                      tags: inout [ASN1DecodedTag]) throws {
        let object: ASN1Object
        
        if let tag = tags.last, tag.isUniversal {
            object = try value.asn1encode(tag: tag)
            tags.removeLast()
        } else {
            object = try value.asn1encode(tag: nil)
        }
        
        self.object = object
    }

    private func encodeConstructedValue<T: Encodable>(_ value: T) throws {
        // FIXME sort struct set fields by encoding
        self.state.encodeAsSet = value is Set<AnyHashable> || value is ASN1EncodeAsSetType
        
        let encoder = ASN1EncoderImpl(codingPath: self.codingPath, userInfo: self.userInfo, state: self.state)
        try value.encode(to: encoder)
        
        if let object = encoder.object {
            self.object = object
            if var value = value as? ASN1PreserveBinary {
                value._save = try object.serialize()
            }
        }
    }
}
