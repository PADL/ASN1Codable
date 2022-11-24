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

/// Represents an open typed value.
@propertyWrapper
public struct ASN1ObjectSetValue: Codable {
    public typealias Value = (any Codable)?

    public var wrappedValue: Value

    public init() {
        self.wrappedValue = nil
    }

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        guard let encoder = encoder as? ASN1EncoderImpl,
              let objectSetCodingContext = encoder.context.objectSetCodingContext else {
            try container.encode(AnyCodable(self.wrappedValue))
            return
        }

        let type = objectSetCodingContext.type(encoder.context)

        // FIXME: set tagging environment to EXPLICIT then restore
        do {
            if objectSetCodingContext.encodeAsOctetString {
                let berData: Data

                if type != nil {
                    if let wrappedValue = self.wrappedValue {
                        berData = try ASN1Encoder().encode(wrappedValue)
                    } else {
                        berData = Data() // FIXME: honour NULL encoding preference
                    }
                } else if let data = self.wrappedValue as? Data {
                    berData = data
                } else {
                    fatalError("Object set type \(String(describing: objectSetCodingContext.valueType)) " +
                        "not mapped to a type, but wrapped value is not Data")
                }

                try container.encode(berData)
            } else {
                if let wrappedValue = self.wrappedValue {
                    try container.encode(wrappedValue)
                } else {
                    try container.encodeNil()
                }
            }
        } catch {
            debugPrint("Failed to encode object set value \(String(describing: self.wrappedValue)) " +
                "for type \(objectSetCodingContext.objectSetType): \(error)")
            throw error
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        guard let decoder = decoder as? ASN1DecoderImpl else {
            self.wrappedValue = try container.decode(AnyCodable.self)
            return
        }

        // FIXME: set tagging environment to EXPLICIT then restore
        guard let objectSetCodingContext = decoder.context.objectSetCodingContext else {
            self.wrappedValue = nil
            return
        }

        let type = objectSetCodingContext.type(decoder.context)
        let valueType = objectSetCodingContext.valueType ?? "nil"

        do {
            if objectSetCodingContext.encodeAsOctetString {
                let berData = try container.decode(Data.self)
                if let type {
                    self.wrappedValue = try ASN1Decoder().decode(type, from: berData)
                } else {
                    debugPrint("Unknown object set type \(valueType), decoding as Data")
                    self.wrappedValue = berData
                }
            } else {
                guard let type else {
                    debugPrint("Unknown object set type \(valueType), cannot decode")
                    let context = DecodingError.Context(codingPath: container.codingPath,
                                                        debugDescription: "Unknown object set type \(valueType)")
                    throw DecodingError.typeMismatch(Data.self, context)
                }

                self.wrappedValue = try container.decode(type)
            }
        } catch {
            debugPrint("Failed to decode object set type \(valueType): \(error)")
            throw error
        }
    }
}

extension ASN1ObjectSetValue: CustomStringConvertible {
    public var description: String {
        if let value = self.wrappedValue {
            return String(describing: value)
        } else {
            return "<unsupported>"
        }
    }
}
