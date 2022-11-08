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

struct Value: Codable {
    var label: String?
    var value: Int
}

class HeimASN1TypeDef: Codable, HeimASN1Emitter, HeimASN1SwiftTypeRepresentable, HeimASN1TagRepresentable, Equatable, CustomStringConvertible {
    static func == (lhs: HeimASN1TypeDef, rhs: HeimASN1TypeDef) -> Bool {
        return lhs.name == rhs.name
    }
    
    var name: String
    var generatedName: String
    var isType: Bool?
    var exported: Bool?
    var isTypeDef: Bool?
    var tagClass: HeimASN1TagClass?
    var tagValue: UInt?
    var taggingEnvironment: HeimASN1TaggingEnvironment?
    var tType: HeimASN1Type?
    var cType: String?
    var members: [HeimASN1TypeMember]?
    var alias: Bool?
    var optional: Bool?
    var type: HeimASN1Type?
    var constant: Bool?
    var value: [Value]?
    var intValue: Int?
    var isExtensible: Bool?
    var openType: HeimASN1OpenType?
    var preserve: Bool?
    var decorate: [HeimASN1Decoration]?
    weak var parent: HeimASN1TypeDef?
    weak var translator: HeimASN1Translator?
    var needsHashableConformance: Bool? = nil // cached value
    
    var grandParent: HeimASN1TypeDef? {
        self.parent?.parent
    }
    
    var greatGrandParent: HeimASN1TypeDef? {
        self.grandParent?.parent
    }
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case generatedName = "gen_name"
        case isType = "is_type"
        case exported = "exported"
        case isTypeDef = "typedef"
        case tagClass = "tagclass"
        case tagValue = "tagvalue"
        case taggingEnvironment = "tagenv"
        case tType = "ttype"
        case cType = "ctype"
        case members = "members"
        case alias = "alias"
        case optional = "optional"
        case type = "type"
        case constant = "constant"
        case value = "value"
        case isExtensible = "extensible"
        case openType = "opentype"
        case preserve = "preserve"
        case decorate = "decorate"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.generatedName = try container.decode(String.self, forKey: .generatedName)
        self.isType = try container.decodeIfPresent(Bool.self, forKey: .isType)
        self.exported = try container.decodeIfPresent(Bool.self, forKey: .exported)
        self.isTypeDef = try container.decodeIfPresent(Bool.self, forKey: .isTypeDef)
        self.tagClass = try container.decodeIfPresent(HeimASN1TagClass.self, forKey: .tagClass)
        self.tagValue = try container.decodeIfPresent(UInt.self, forKey: .tagValue)
        self.taggingEnvironment = try container.decodeIfPresent(HeimASN1TaggingEnvironment.self, forKey: .taggingEnvironment)
        self.tType = try container.decodeIfPresent(HeimASN1Type.self, forKey: .tType)
        self.cType = try container.decodeIfPresent(String.self, forKey: .cType)
        self.members = try container.decodeIfPresent([HeimASN1TypeMember].self, forKey: .members)
        self.alias = try container.decodeIfPresent(Bool.self, forKey: .alias)
        self.optional = try container.decodeIfPresent(Bool.self, forKey: .optional)
        self.type = try container.decodeIfPresent(HeimASN1Type.self, forKey: .type)
        self.constant = try container.decodeIfPresent(Bool.self, forKey: .constant)
        do {
            self.value = try container.decodeIfPresent([Value].self, forKey: .value)
        } catch {
            let intValue = try container.decode(Int.self, forKey: .value)
            self.value = [Value(value: intValue)]
        }
        self.isExtensible = try container.decodeIfPresent(Bool.self, forKey: .isExtensible)
        self.openType = try container.decodeIfPresent(HeimASN1OpenType.self, forKey: .openType)
        self.preserve  = try container.decodeIfPresent(Bool.self, forKey: .preserve)
        self.decorate = try container.decodeIfPresent([HeimASN1Decoration].self, forKey: .decorate)
        self.translator = decoder.userInfo[HeimASN1TranslatorUserInfoKey] as? HeimASN1Translator
    }
    
    var description: String {
        return "HeimASN1TypeDef {generatedName=(\(generatedName)), isType=\(self.isType ?? false), isTypeDef=\(self.isTypeDef ?? false)}"
    }
    
    var visibility: String {
        let visibility = (parent?.exported ?? false) ? "public " : ""
        
        return visibility
    }
    
    var tTypeTypeDefValue: HeimASN1TypeDef? {
        if case .typeDef(let type) = self.tType {
            return type
        } else {
            return nil
        }
    }
    
    var tTypeUniversalValue: HeimASN1UniversalType? {
        if case .universal(let type) = self.tType {
            return type
        } else {
            return nil
        }
    }
    
    var tTypeTypeRefValue: String? {
        if case .typeRef(let type) = self.tType {
            return type
        } else {
            return nil
        }
    }

    var isTaggedType: Bool {
        return self.parent?.isTag ?? false
    }
    
    var isTag: Bool {
        guard let tagClass = self.tagClass else {
            return false
        }
        
        return tagClass == .context || tagClass == .application || tagClass == .private
    }
   
    private var _typeContainedBySetOrSetOf: Bool {
        if let universalType = self.tType?.universalTypeValue {
            return universalType == .set || universalType == .setOf
        } else {
            return false
        }
    }
    
    var typeContainedBySetOrSetOf: HeimASN1Type? {
        if self._typeContainedBySetOrSetOf {
            return self.members?[1].typeDefValue?.tType
        } else {
            return nil
        }
    }
        
    private var _typeContainedBySetOfOrSequenceOf: Bool {
        if let universalType = self.tType?.universalTypeValue {
            return universalType == .setOf || universalType == .sequenceOf
        } else {
            return false
        }
    }

    var typeContainedBySetOfOrSequenceOf: HeimASN1Type? {
        if self._typeContainedBySetOfOrSequenceOf {
            return self.members?[1].typeDefValue?.tType
        } else {
            return nil
        }
    }

    var swiftType: String? {
        guard let tType = self.tType, let swiftType = tType.swiftType else {
            return nil
        }
        
        if let memberName = self.typeContainedBySetOfOrSequenceOf?.swiftType {
            return "\(swiftType)<\(memberName)>"
        } else {
            return swiftType
        }
    }
    
    var tag: ASN1DecodedTag? {
        guard let tagClass = self.tagClass, let tagValue = self.tagValue else {
            return nil
        }
        
        switch tagClass {
        case .universal:
            return ASN1DecodedTag.universal(ASN1Tag(rawValue: UInt8(tagValue))!)
        case .context:
            return ASN1DecodedTag.taggedTag(tagValue)
        case .application:
            return ASN1DecodedTag.applicationTag(tagValue)
        case .private:
            return ASN1DecodedTag.privateTag(tagValue)
        }
    }
    
    private func closestIntTypeForOptionSet(_ memberCount: Int) throws -> String {
        if memberCount > 64 {
            return "BInt"
        } else if memberCount > 32 {
            return "UInt64"
        } else if memberCount > 16 {
            return "UInt32"
        } else if memberCount > 8 {
            return "UInt16"
        } else {
            return "UInt8"
        }
    }
    
    func _swiftConformances(_ baseType: String?) -> [String] {
        var conformances = [String]()
        if let baseType = baseType {
            conformances.append(baseType)
        }
        conformances.append("Codable")
        
        if self.translator?.typeNeedsHashableConformance(self) ?? false {
            conformances.append("Equatable")
            conformances.append("Hashable")
        }
        if self.preserve ?? false {
            conformances.append("ASN1PreserveBinary")
        }
        if let tag = parent?.tag {
            if tag.isApplicationSpecific {
                conformances.append("ASN1ApplicationTaggedType")
            } else if tag.isContextSpecific {
                conformances.append("ASN1ContextTaggedType")
            } else if tag.isUniversal == false {
                conformances.append("ASN1PrivateTaggedType")
            }
        }
        if let tType = self.tType, case .universal(let type) = tType, type == .set {
            conformances.append("ASN1SetCodable")
        }
        if self.isExtensible ?? false {
            conformances.append("ASN1ExtensibleType")
        }
        if let openType = self.openType {
            let valueMember = self.members?.first { $0.typeDefValue?.name == openType.openTypeMember }
            // FIXME tags
            let isOctetString: Bool = valueMember?.typeDefValue?.type?.tag == ASN1DecodedTag.universal(.octetString)
            conformances.append(isOctetString ? "ASN1ObjectSetOctetStringCodable" : "ASN1ObjectSetCodable")
        }
        return conformances
    }
    
    func swiftConformances(_ baseType: String?) -> String {
        return self._swiftConformances(baseType).joined(separator: ", ")
    }
    
    func emit(_ outputStream: inout OutputStream) throws {
        let visibility = (self.exported ?? false) ? "public " : ""
        
        self.type?.typeDefValue?.parent = self
        self.tType?.typeDefValue?.parent = self

        if self.isTypeDef ?? false, cType != nil, let tType = self.tType {
            if case .universal(let type) = tType {
                switch type {
                case .sequence:
                    fallthrough
                case .set:
                    // main struct implementation
                    let swiftMetaType = self.preserve ?? false ? "class" : "struct"
                    
                    outputStream.write("\(visibility)\(swiftMetaType) \(self.generatedName): \(self.swiftConformances(nil)) {\n")
                    
                    if let tag = parent?.tag, !tag.isUniversal {
                        outputStream.write("\t\(visibility)static let tagNumber: ASN1TagNumberRepresentable.Type? = ASN1TagNumber$\(parent!.tagValue!).self\n\n")
                    }
                    
                    if let openType = self.openType {
                        outputStream.write("\t\(visibility)static let knownTypes: [AnyHashable : Codable.Type] = [\n")
                        openType.members.forEach {
                            let identifier = openType.typeId(for: $0)
                            let typeName = $0.swiftType!
                            
                            outputStream.write("\t\t\(identifier!) : \(typeName).self,\n")
                        }
                        outputStream.write("\t]\n\n")
                    }

                    if self.preserve ?? false {
                        outputStream.write("\t\(visibility)var _save: Data? = nil\n\n")
                    }
                    
                    self.decorate?.forEach {
                        outputStream.write("\t\(visibility)var \($0.name): \($0.type)\($0.isOptional ? "?" : "")\n")
                    }
                    if !(self.decorate?.isEmpty ?? true) {
                        outputStream.write("\n")
                    }
                    
                    if swiftMetaType == "class" {
                        outputStream.write("\t\(visibility)func init() {}\n\n")
                    }

                    outputStream.write("\t\(visibility)enum CodingKeys: String, CodingKey {\n")
                    self.members?.forEach {
                        if let typeDefValue = $0.typeDefValue {
                            outputStream.write("\t\tcase \(typeDefValue.generatedName)\n")
                        } else if let dictionaryValue = $0.dictionaryValue {
                            debugPrint("unexpected dictionary type \(dictionaryValue)")
                        }
                    }
                    outputStream.write("\t}\n\n")
                    try self.members?.forEach {
                        $0.typeDefValue?.parent = self
                        try $0.emit(&outputStream)
                    }
                    outputStream.write("}\n")
                    break
                case .choice:
                    outputStream.write("\(visibility)enum \(self.generatedName): \(self.swiftConformances(nil)) {\n")
                    try self.members?.forEach {
                        $0.typeDefValue?.parent = self
                        try $0.emit(&outputStream)
                    }
                    outputStream.write("}\n")
                    break
                case .bitString:
                    if let members = self.members, !members.isEmpty {
                        let highestUsedMember: Int = members.lastIndex(where: { $0.bitStringTag != nil })! + 1
                        
                        //highestUsedMember = members.last { }
                        let rawType = try(closestIntTypeForOptionSet(highestUsedMember))
                        
                        outputStream.write("\(visibility)struct _\(self.generatedName): \(self.swiftConformances("OptionSet")) {\n")
                        outputStream.write("\t\(visibility)var rawValue: \(rawType)\n\n")
                        outputStream.write("\t\(visibility)init(rawValue: \(rawType)) {\n")
                        outputStream.write("\t\tself.rawValue = rawValue\n")
                        outputStream.write("\t}\n\n")
                        var index: UInt = 0
                        
                        members.forEach { member in
                            guard let tag = member.bitStringTag else {
                                return
                            }
                            outputStream.write("\tstatic let \(tag) = _\(self.generatedName)(rawValue: 1 << \(index))\n")
                            index += 1
                        }
                        outputStream.write("}\n\n")
                    }
                default:
                    try tType.emitType(containingTypeDef: self, &outputStream)
                }
            }
        } else if let tagClass = self.tagClass, tagClass == .universal {
            let tag = ASN1Tag(rawValue: UInt8(self.tagValue!))
            if tag == .sequence || tag == .set {
                if case .typeDef(let type) = self.tType {
                    try type.emit(&outputStream)
                } else if case .universal(let tag) = self.tType {
                    outputStream.write("// universal tag \(tag) \(self)\n")
                }
            } else {
                try self.tType?.emitType(containingTypeDef: self, &outputStream)
            }
        } else if let type = self.type {
            try type.emitType(containingTypeDef: self, &outputStream)
        } else if let tType = self.tType {
            try tType.emitType(containingTypeDef: self, &outputStream)
        } else {
            fatalError("Unhandled main branch - \(self)")
        }
    }
    
    var oidStringValue: String? {
        guard let value = self.value else {
            return nil
        }
        
        return value.map { "\($0.value)" }.joined(separator: ".")
    }
}
