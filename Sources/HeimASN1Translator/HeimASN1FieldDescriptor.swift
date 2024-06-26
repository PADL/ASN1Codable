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
    self.tagging = typeDef.desiredTaggingEnvironment
    self.tag = typeDef.isTag ? typeDef.tag : nil
    self.type = typeDef.isTag ? typeDef.tType! : HeimASN1Type.typeDef(typeDef)

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

    // FIXME:
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

  private var isUsingTagCodingKey: Bool {
    let isUniformlyContextTagged = self.type.typeDefValue?.grandParent?.isUniformlyContextTagged ?? false
    let isChoice = self.type.typeDefValue?.parent?.isChoice ?? false

    return !isChoice || isUniformlyContextTagged
  }

  private var translator: HeimASN1Translator? {
    self.type.typeDefValue?.translator
  }

  private var isTagged: Bool {
    self.tag != nil
  }

  private var _swiftType: String {
    let swiftType: String

    if let objectSetWrapperType = self.objectSetWrapperType {
      swiftType = "\(objectSetWrapperType)\(self._optionalSuffix)"
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
    self.taggedWrapperType ?? self._swiftType
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

    let modulePrefix: String

    if let module = self.type.typeDefValue?.translator?.module {
      modulePrefix = "\(module.module)."
    } else {
      modulePrefix = ""
    }

    self.translator?.didEmitWrapperWithTagNumber(wrapperType.1)

    return "\(wrapperType.0)<\(modulePrefix)ASN1TagNumber$\(wrapperType.1), \(tagging.swiftType!), \(self._swiftType)>"
  }

  private var hasTaggedWrapperType: Bool {
    self.tag != nil
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
    self.objectSetWrapperType != nil
  }

  private var isOpenType: Bool {
    self.type.typeDefValue?.grandParent?.openType != nil
  }

  private var openType: HeimASN1OpenType? {
    self.type.typeDefValue?.grandParent?.openType
  }

  private var parentName: String? {
    self.type.typeDefValue?.parent?.name
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
    self.isObjectSetValueType && self.type.tag == .universal(.octetString)
  }

  private var isSetOrSequence: Bool {
    guard let tag = self.type.tag else {
      return false
    }

    return tag == .universal(.set) || tag == .universal(.sequence)
  }

  private var canUseObjectSetValuePropertyWrapper: Bool {
    self.isObjectSetValueType && !(self.isTagged || self.needsTypeErasedObjectSetValueType)
  }

  private var needsTypeErasedObjectSetValueType: Bool {
    self.isSetOrSequence
  }

  /// returns an array of property wrappers in declaration order. at present at most two are returned.
  var propertyWrappers: [String] {
    var wrappers = [String]()

    if !self.isUsingTagCodingKey, let taggedWrapperType = self.taggedWrapperType {
      wrappers.append(taggedWrapperType)
    }

    if let objectSetWrapperType = self.objectSetWrapperType,
       self.isObjectSetTypeType || self.canUseObjectSetValuePropertyWrapper {
      wrappers.append(objectSetWrapperType)
    }

    if let wrappedPrimitiveType = self.wrappedPrimitiveType {
      wrappers.append(wrappedPrimitiveType.0)
    }

    return wrappers
  }

  private var _optionalSuffix: String {
    self.isDefault || self.isOptional ? "?" : ""
  }

  /// returns the innermost type for this wrapped type
  var _bareSwiftType: String {
    let bareSwiftType: String

    if let wrappedPrimitiveType = self.wrappedPrimitiveType {
      bareSwiftType = wrappedPrimitiveType.1
    } else if self.isObjectSetValueType {
      if self.needsTypeErasedObjectSetValueType, case .universal(let tagNo) = self.type.tag {
        bareSwiftType = "\(tagNo.swiftType!)<ASN1AnyObjectSetValue>"
      } else if self.type.swiftType == "AnyCodable" || self.isOctetStringEncodedObjectSetValueType {
        if self.isTagged {
          bareSwiftType = "ASN1ObjectSetValue"
        } else {
          bareSwiftType = "(any Codable)"
        }
      } else {
        bareSwiftType = self.type.swiftType!
      }
    } else {
      bareSwiftType = self.type.swiftType!
    }

    return bareSwiftType
  }

  var bareSwiftType: String {
    "\(self._bareSwiftType)\(self._optionalSuffix)"
  }

  var bareSwiftTypeSansOptional: String {
    "\(self._bareSwiftType)"
  }

  private var _dereferencedTypeDefValue: HeimASN1TypeDef? {
    if let typeRef = self.type.typeDefValue?.tType?.typeRefValue,
       let translator = self.translator,
       let derefTypeRef = translator.resolveTypeRef(typeRef) {
      return derefTypeRef
    } else {
      return nil
    }
  }

  private var _dereferencedUniversalTypeTag: ASN1Tag? {
    if let dereferencedTypeDefValue = self._dereferencedTypeDefValue,
       let tag = dereferencedTypeDefValue.tType?.typeDefValue?.tTypeUniversalValue?.tag,
       case .universal(let asn1Tag) = tag {
      return asn1Tag
    } else {
      return nil
    }
  }

  private var _dereferencedSwiftType: (String, String)? {
    if let asn1Tag = self._dereferencedUniversalTypeTag {
      if let wrappedSwiftType = asn1Tag.wrappedSwiftType {
        return wrappedSwiftType
      } else if let swiftType = asn1Tag.swiftType {
        return ("", swiftType)
      }
    }

    return nil
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

  private func _initializer(for bareSwiftType: String) -> String {
    if bareSwiftType == "String" {
      return "\"\""
    } else {
      return ".init()"
    }
  }

  private var _initializer: String {
    guard let dereferencedSwiftType = self._dereferencedSwiftType, !dereferencedSwiftType.0.isEmpty else {
      return self._initializer(for: self._bareSwiftType)
    }

    precondition(self.wrappedPrimitiveType == nil)
    return "\(dereferencedSwiftType.0)<\(dereferencedSwiftType.1)>(wrappedValue: \(self._initializer(for: dereferencedSwiftType.1)))"
  }

  var initialValue: String {
    self.isOptional ? "nil" : "\(self._initializer)"
  }

  var needsInitialValue: Bool {
    // FIXME:
    !self.propertyWrappers.isEmpty && !self.bareSwiftType.hasPrefix("(any") && !self.isObjectSetTypeType
  }

  var isInitializedWithWrappedValue: Bool {
    self.propertyWrappers.count == 1
  }

  var hasNestedWrappers: Bool {
    self.propertyWrappers.count > 1
  }
}
