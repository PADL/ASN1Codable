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

/// A field that optionally has an ASN.1 tag and potentially a specialised type
struct HeimASN1FieldDescriptor: HeimASN1Emitter, HeimASN1SwiftTypeRepresentable, CustomStringConvertible {
    /// whether the tag is explicit, implicit, or default
    var tagging: HeimASN1TaggingEnvironment?
    /// wrapping tax
    var tag: ASN1DecodedTag?
    /// the ASN.1 type being wrapped
    var type: HeimASN1Type
    /// whether it is optional or not
    var isOptional: Bool
    var isDefault: Bool

    init(_ typeDef: HeimASN1TypeDef) {
        self.tagging = typeDef.choiceTaggingEnvironment ?? typeDef.taggingEnvironment
        self.tag = typeDef.isTag ? typeDef.tag : nil
        self.type = typeDef.isTag ? typeDef.tType! : HeimASN1Type.typeDef(typeDef)
        precondition(typeDef.isTag == false || typeDef.parent != nil)
                
        if typeDef.parent?.isOptional ?? false {
            self.isOptional = true
        } else {
            self.isOptional = false
        }
        
        if typeDef.parent?.defaultValue != nil {
            self.isDefault = true
        } else {
            self.isDefault = false
        }

        // FIXME
        if self.canUseObjectSetValuePropertyWrapper {
            self.isOptional = true
        }
    }
    
    ///
    /// Determining the correct type to emit is somewhat complicated due to the fact that property
    /// wrappers are not supported in all contexts (e.g. in enum cases). Hence a wrapped type
    /// has two representations: a property wrapper one (which is more ergonomic as the compiler
    /// "looks through" the wrappers) and a normal generic (which requires the consumer to unwrap
    /// values explicitly). The latter is accessed through the normal swiftType property.

    func emit(_ outputStream: inout OutputStream) throws {
        self.propertyWrappers.forEach {
            outputStream.write("\t@\($0)\n")
        }
    }
    
    private var isTagged: Bool {
        return self.tag != nil
    }
    
    private var isBitStringEnumeration: Bool {
        return type.tag == .universal(.bitString) && !(type.typeDefValue?.tType?.typeDefValue?.members?.isEmpty ?? true)
    }
    
    private var _swiftType: String {
        let swiftType: String
        
        if let objectSetWrapperType = self.objectSetWrapperType {
            swiftType = "\(objectSetWrapperType)\(self._optionalSuffix)"
        } else if self.isBitStringEnumeration {
            swiftType = "ASN1RawRepresentableBitString<_\(self.type.typeDefValue!.generatedName)>"
        } else if let wrappedPrimitiveType = self.wrappedPrimitiveType {
            /// this is here for debugging, it can be removed for production
            swiftType = "\(wrappedPrimitiveType.0)<\(wrappedPrimitiveType.1)\(self._optionalSuffix)>"
        } else {
            swiftType = "\(self.type.swiftType!)\(self._optionalSuffix)"
        }
        
        return swiftType
    }
    
    /// returns the generic type for this wrapped type
    var swiftType: String? {
        return self.taggedWrapperType ?? self._swiftType
    }

    private var wrappedPrimitiveType: (String, String)? {
        if case .universal(let tagNo) = self.type.tag {
            return tagNo.wrappedSwiftType
        } else {
            return nil
        }
    }
    
    private var hasWrappedPrimitiveType: Bool {
        self.wrappedPrimitiveType != nil
    }
    
    private var taggedWrapperType: String? {
        guard let tag = self.tag else {
            return nil
        }
        
        precondition(!tag.isUniversal)
        let wrapperType: (String, UInt)
        let tagging = self.tagging ?? HeimASN1TaggingEnvironment.explicit
        
        switch tag {
        case .taggedTag(let tagNo):
            wrapperType = ("ASN1ContextTagged", tagNo)
        case .applicationTag(let tagNo):
            wrapperType = ("ASN1ApplicationTagged", tagNo)
        case .privateTag(let tagNo):
            wrapperType = ("ASN1PrivateTagged", tagNo)
        default:
            return nil
        }
        
        return "\(wrapperType.0)<ASN1TagNumber$\(wrapperType.1), \(tagging.swiftType!), \(self._swiftType)>"
    }
    
    private var hasTaggedWrapperType: Bool {
        return self.tag != nil
    }
    
    private var objectSetWrapperType: String? {
        guard let localName = self.parentName, let openType = self.openType else {
            return nil
        }

        // because we are comparing ASN.1 name (type-id) not C name (type_id)
        if localName == openType.typeIdMember {
            return "ASN1ObjectSetType"
        } else if localName == openType.openTypeMember {
            return "ASN1ObjectSetValue"
        } else {
            return nil
        }
    }
    
    private var hasObjectSetWrapperType: Bool {
        return self.objectSetWrapperType != nil
    }
        
    private var isOpenType: Bool {
        return type.typeDefValue?.grandParent?.openType != nil
    }
    
    private var openType: HeimASN1OpenType? {
        return type.typeDefValue?.grandParent?.openType
    }
    
    private var parentName: String? {
        return type.typeDefValue?.parent?.name
    }
    
    private var isObjectSetValueType: Bool {
        guard let localName = self.parentName, let openType = self.openType else {
            return false
        }

        return localName == openType.openTypeMember
    }
    
    private var isObjectSetTypeType: Bool {
        guard let localName = self.parentName, let openType = self.openType else {
            return false
        }

        return localName == openType.typeIdMember
    }
    
    private var isOctetStringEncodedObjectSetValueType: Bool {
        return self.isObjectSetValueType && type.tag == .universal(.octetString)
    }
    
    private var isSetOrSequence: Bool {
        guard let tag = self.type.tag else {
            return false
        }
        
        return tag == .universal(.set) || tag == .universal(.sequence)
    }
    
    private var canUseObjectSetValuePropertyWrapper: Bool {
        return self.isObjectSetValueType && !(self.isTagged || self.needsTypeErasedObjectSetValueType)
    }

    private var needsTypeErasedObjectSetValueType: Bool {
        return self.isSetOrSequence
    }
    
    /// returns an array of property wrappers in declaration order. at present at most two are returned.
    var propertyWrappers: [String] {
        var wrappers = [String]()
        
        if let taggedWrapperType = self.taggedWrapperType {
            wrappers.append(taggedWrapperType)
        }

        if let objectSetWrapperType = self.objectSetWrapperType, (self.isObjectSetTypeType || self.canUseObjectSetValuePropertyWrapper) {
            wrappers.append(objectSetWrapperType)
        }
        
        if let wrappedPrimitiveType = self.wrappedPrimitiveType {
            wrappers.append(wrappedPrimitiveType.0)
        }
        
        return wrappers
    }
    
    private var _optionalSuffix: String {
        return self.isDefault || self.isOptional ? "?" : ""
    }
    
    /// returns the innermost type for this wrapped type
    var _bareSwiftType: String {
        let bareSwiftType: String
        
        if let wrappedPrimitiveType = self.wrappedPrimitiveType {
            bareSwiftType = wrappedPrimitiveType.1
        } else if self.isObjectSetValueType {
            if self.needsTypeErasedObjectSetValueType, case .universal(let tagNo) = self.type.tag {
                bareSwiftType = "\(tagNo.swiftType!)<ASN1AnyObjectSetValue>"
            } else if type.swiftType == "AnyCodable" || self.isOctetStringEncodedObjectSetValueType {
                if self.isTagged {
                    bareSwiftType = "ASN1ObjectSetValue"
                } else {
                    bareSwiftType = "(any Codable)"
                }
            } else {
                bareSwiftType = type.swiftType!
            }
        } else {
            bareSwiftType = type.swiftType!
        }
        
        return bareSwiftType
    }
    
    var bareSwiftType: String {
        return "\(self._bareSwiftType)\(self._optionalSuffix)"
    }
    
    var bareSwiftTypeSansOptional: String {
        return "\(self._bareSwiftType)"
    }
    
    var description: String {
        let tagDesc: String
        if let tag = self.tag {
            tagDesc = tag.description
        } else {
            tagDesc = "<nil>"
        }
        return "FieldDescriptor {tag=\(tagDesc), bareSwiftType=\(self.bareSwiftType), propertyWrappers=\(self.propertyWrappers)}"
    }
    
    private var _initializer: String {
        switch self.bareSwiftType {
        case "String":
            return "\"\""
        default:
            return "\(self.bareSwiftType)()"
        }
    }
    
    var initialValue: String {
        return self.isOptional ? "nil" : "\(self._initializer)"
    }
    
    var needsInitialValue: Bool {
        // FIXME
        return self.propertyWrappers.count != 0 && !self.bareSwiftType.hasPrefix("(any") && !self.isObjectSetTypeType
    }
    
    var isInitializedWithWrappedValue: Bool {
        return self.propertyWrappers.count == 1
    }
    
    var hasNestedWrappers: Bool {
        return self.propertyWrappers.count > 1
    }

}
