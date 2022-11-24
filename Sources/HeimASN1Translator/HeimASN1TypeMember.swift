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

indirect enum HeimASN1TypeMember: Codable, HeimASN1Emitter, HeimASN1SwiftTypeRepresentable {
    case dictionary([String: AnyCodable])
    case typeDef(HeimASN1TypeDef)

    var dictionaryValue: [String: AnyCodable]? {
        if case .dictionary(let type) = self {
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

    var bitStringTag: String? {
        guard let typeDefValue = self.typeDefValue else {
            return nil
        }

        let components = typeDefValue.generatedName.components(separatedBy: ":")

        guard components.count == 2 else {
            return nil
        }

        guard !components[0].hasPrefix("_unused") else {
            return nil
        }

        return components[0]
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        do {
            let constructed = try container.decode(HeimASN1TypeDef.self)
            self = .typeDef(constructed)
        } catch {
            do {
                let dictionary = try container.decode(Dictionary<String, AnyCodable>.self)
                self = .dictionary(dictionary)
            } catch {
                throw error
            }
        }
    }

    func encode(to encoder: Encoder) throws {
    }

    var swiftType: String? {
        switch self {
        case .typeDef(let type):
            return type.swiftType
        case .dictionary:
            fatalError("unimplemented")
        }
    }

    func emit(_ outputStream: inout OutputStream) throws {
        if case .typeDef(let type) = self {
            try type.emit(&outputStream)
        }
    }
}
