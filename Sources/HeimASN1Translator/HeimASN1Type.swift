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
import AnyCodable

protocol HeimASN1SwiftTypeRepresentable {
    var swiftType: String? { get }
}

indirect enum HeimASN1Type: Codable, Equatable, HeimASN1SwiftTypeRepresentable, HeimASN1TagRepresentable {
    case universal(HeimASN1UniversalType)
    case typeDef(HeimASN1TypeDef)
    case typeRef(String)

    static func == (lhs: HeimASN1Type, rhs: HeimASN1Type) -> Bool {
        lhs.name == rhs.name
    }

    var universalTypeValue: HeimASN1UniversalType? {
        if case .universal(let type) = self {
            return type
        } else {
            return nil
        }
    }

    var typeDefValue: HeimASN1TypeDef? {
        if case .typeDef(let type) = self {
            return type
        } else {
            return nil
        }
    }

    var typeRefValue: String? {
        if case .typeRef(let type) = self {
            return type
        } else {
            return nil
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        do {
            let type = try container.decode(HeimASN1UniversalType.self)
            self = .universal(type)
        } catch {
            do {
                let ref = try container.decode(String.self)
                self = .typeRef(ref)
            } catch {
                do {
                    let constructed = try container.decode(HeimASN1TypeDef.self)
                    self = .typeDef(constructed)
                } catch {
                    throw error
                }
            }
        }
    }

    func encode(to _: Encoder) throws {}

    static func cTypeToSwiftType(_ cType: String) -> String? {
        switch cType {
        case "heim_integer":
            return "BigNumber.BInt"
        case "int64_t":
            return "Swift.Int64"
        case "int":
            return "Swift.Int32"
        case "uint64_t":
            return "Swift.UInt64"
        case "unsigned int":
            return "Swift.UInt32"
        default:
            return nil
        }
    }

    var swiftType: String? {
        switch self {
        case .typeDef(let type):
            if type.tag == .universal(.integer),
               let cType = type.tTypeTypeDefValue?.cType,
               let swiftType = Self.cTypeToSwiftType(cType) {
                return swiftType
            } else {
                return type.swiftType
            }
        case .universal(let type):
            return type.swiftType
        case .typeRef(let type):
            return type == "HEIM_ANY" ? "AnyCodable" : type
        }
    }

    var name: String {
        switch self {
        case .typeDef(let type):
            return type.name
        case .universal(let type):
            return type.rawValue
        case .typeRef(let type):
            return type
        }
    }

    var tag: ASN1DecodedTag? {
        switch self {
        case .typeDef(let type):
            return type.tag
        case .universal(let type):
            return type.tag
        case .typeRef(let type):
            if let type = self.typeDefValue?.translator?.resolveTypeRef(type) {
                return type.tag
            } else {
                return nil
            }
        }
    }

    private func emitTypeDef(_ typeDef: HeimASN1TypeDef, containingTypeDef: HeimASN1TypeDef, _ outputStream: inout OutputStream) throws {
        typeDef.parent = containingTypeDef

        if containingTypeDef.isTypeDef ?? false {
            try self.emitTypeDefDefinition(typeDef, containingTypeDef: containingTypeDef, &outputStream)
        } else {
            try self.emitTypeDefField(typeDef, containingTypeDef: containingTypeDef, &outputStream)
        }
    }

    private func emitTypeDefField(_ typeDef: HeimASN1TypeDef, containingTypeDef: HeimASN1TypeDef, _ outputStream: inout OutputStream) throws {
        let isChoice = containingTypeDef.parent?.isChoice ?? false

        if isChoice {
            let fieldDescriptor = HeimASN1FieldDescriptor(containingTypeDef)

            if (containingTypeDef.parent?.isUniformlyContextTagged ?? false) ||
                (containingTypeDef.parent?.needsMetadataCodingKeys ?? false) {
                outputStream.write("\tcase \(containingTypeDef.generatedName)(\(fieldDescriptor.bareSwiftType))\n")
            } else {
                outputStream.write("\tcase \(containingTypeDef.generatedName)(\(fieldDescriptor.swiftType!))\n")
            }
        } else {
            let fieldDescriptor = HeimASN1FieldDescriptor(typeDef)
            let isDefault = containingTypeDef.defaultValue != nil
            let visibility = containingTypeDef.visibility
            let generatedName = isDefault ? "_\(containingTypeDef.generatedName)" : containingTypeDef.generatedName
            try fieldDescriptor.emit(&outputStream)
            outputStream.write("\t\(visibility)var \(generatedName): \(fieldDescriptor.bareSwiftType)")
            if fieldDescriptor.needsInitialValue, !isDefault {
                outputStream.write(" = \(fieldDescriptor.initialValue)")
            }
            outputStream.write("\n")
            if let defaultValue = containingTypeDef.defaultValue {
                // emit an accessor with the public type name
                outputStream.write("\t\(containingTypeDef.visibility)var \(containingTypeDef.generatedName): \(fieldDescriptor.bareSwiftTypeSansOptional) {\n")
                let defaultValueString: String
                if defaultValue.value is String {
                    defaultValueString = "\"\(defaultValue.value)\""
                } else {
                    defaultValueString = String(describing: defaultValue.value)
                }
                outputStream.write("\t\tget { self.\(generatedName) ?? \(defaultValueString) }\n")
                outputStream.write("\t\tset { self.\(generatedName) = newValue }\n")
                outputStream.write("\t}\n")
            }
        }
    }

    private func swiftType(containingTypeDef: HeimASN1TypeDef) -> String {
        let fieldDescriptor = HeimASN1FieldDescriptor(containingTypeDef)
        return fieldDescriptor.swiftType!
    }

    private func emitSwiftTypeAlias(containingTypeDef: HeimASN1TypeDef, _ outputStream: inout OutputStream) {
        if !(containingTypeDef.translator?.typeRefExists(containingTypeDef.generatedName) ?? false) {
            let swiftType = self.swiftType(containingTypeDef: containingTypeDef)
            outputStream.write("\(containingTypeDef.visibility)typealias \(containingTypeDef.generatedName) = \(swiftType)\n")
            containingTypeDef.translator?.cacheTypeRef(containingTypeDef.generatedName)
        }
    }

    private func emitTypeDefDefinition(_ typeDef: HeimASN1TypeDef, containingTypeDef: HeimASN1TypeDef, _ outputStream: inout OutputStream) throws {
        let swiftType = self.swiftType(containingTypeDef: containingTypeDef)

        if containingTypeDef.tag == .universal(.enumerated) {
            outputStream.write("\(containingTypeDef.visibility)enum \(containingTypeDef.generatedName): \(containingTypeDef.swiftConformances(swiftType)) {\n")
            try typeDef.members?.forEach {
                if let member = $0.typeDefValue {
                    member.parent = typeDef
                    try member.emit(&outputStream)
                } else if let member = $0.dictionaryValue?.first {
                    outputStream.write("\tcase \(member.key) = \(member.value)\n")
                }
            }
            outputStream.write("}\n")
        } else {
            if containingTypeDef.isTaggedType == false,
               typeDef.hasSwiftTypeDefinition == false {
                self.emitSwiftTypeAlias(containingTypeDef: containingTypeDef, &outputStream)
            }

            try typeDef.emit(&outputStream)
        }
    }

    private func wrappedInitializer(containingTypeDef: HeimASN1TypeDef, value: AnyCodable) -> String {
        if let grandParent = containingTypeDef.grandParent {
            let fieldDescriptor = HeimASN1FieldDescriptor(grandParent)
            precondition(!fieldDescriptor.hasNestedWrappers)

            if fieldDescriptor.isInitializedWithWrappedValue {
                let quotedValue: String
                if value.value is String {
                    quotedValue = "\"\(value)\""
                } else {
                    quotedValue = "\(value)"
                }

                return "\(fieldDescriptor.swiftType!)(wrappedValue: \(quotedValue))"
            }
        }

        return "\(value)"
    }

    private func emitUniversal(_ universal: HeimASN1UniversalType, containingTypeDef: HeimASN1TypeDef, _ outputStream: inout OutputStream) throws {
        // let swiftType = self.swiftType(containingTypeDef: containingTypeDef)
        let swiftType = self.swiftType!
        let constant = containingTypeDef.constant ?? false

        if constant {
            outputStream.write("\(containingTypeDef.visibility)var \(containingTypeDef.generatedName): \(swiftType)\(containingTypeDef.isOptional ?? false ? "?" : "")")

            switch universal {
            case .objectIdentifier:
                if let oidStringValue = containingTypeDef.oidStringValue {
                    outputStream.write(" = ASN1Kit.ObjectIdentifier(rawValue: \"\(oidStringValue)\")!\n")
                }
            case .integer:
                outputStream.write(" = \(containingTypeDef.value![0].value)\n")
            default:
                break
            }
        } else {
            switch universal {
            case .integer:
                try containingTypeDef.members?.forEach {
                    if let member = $0.typeDefValue {
                        member.parent = typeDefValue
                        try member.emit(&outputStream)
                    } else if let member = $0.dictionaryValue?.first {
                        let value = wrappedInitializer(containingTypeDef: containingTypeDef, value: member.value)
                        outputStream.write("\(containingTypeDef.visibility)let \(member.key): \(containingTypeDef.generatedName) = \(value)\n")
                    }
                }
            default:
                self.emitSwiftTypeAlias(containingTypeDef: containingTypeDef, &outputStream)
            }
        }
    }

    private func emitTypeRef(_ ref: String, containingTypeDef: HeimASN1TypeDef, _ outputStream: inout OutputStream) throws {
        if containingTypeDef.isTypeDef ?? false {
            self.emitSwiftTypeAlias(containingTypeDef: containingTypeDef, &outputStream)
        } else if containingTypeDef.parent?.tTypeUniversalValue == .choice {
            outputStream.write("\tcase \(containingTypeDef.generatedName)(\(ref))\n")
        } else {
            fatalError("unhandled type ref \(ref)")
        }
    }

    func emitType(containingTypeDef: HeimASN1TypeDef, _ outputStream: inout OutputStream) throws {
        switch self {
        case .typeDef(let type):
            precondition(type.parent != nil)
            type.tType?.typeDefValue?.parent = containingTypeDef
            try self.emitTypeDef(type, containingTypeDef: containingTypeDef, &outputStream)
        case .universal(let type):
            try self.emitUniversal(type, containingTypeDef: containingTypeDef, &outputStream)
        case .typeRef(let type):
            try self.emitTypeRef(type, containingTypeDef: containingTypeDef, &outputStream)
        }
    }
}
