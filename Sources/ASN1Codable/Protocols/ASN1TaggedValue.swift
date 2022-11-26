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

public protocol ASN1TaggedValue: Codable, CustomStringConvertible,
    CustomDebugStringConvertible, ASN1TypeMetadataRepresentable {
    associatedtype Value: Codable

    var wrappedValue: Value { get set }
    var projectedValue: ASN1Metadata { get }

    init(wrappedValue: Value)
}

public protocol ASN1UniversalTaggedValue: ASN1TaggedValue {}

extension ASN1TaggedValue {
    static var wrappedType: Value.Type {
        Value.self
    }

    public var projectedValue: ASN1Metadata {
        Self.metadata
    }

    public func encode(to encoder: Encoder) throws {
        precondition(!(encoder is ASN1Codable.ASN1EncoderImpl))
        try self.wrappedValue.encode(to: encoder)
    }

    public init(from decoder: Decoder) throws {
        precondition(!(decoder is ASN1Codable.ASN1DecoderImpl))
        try self.init(wrappedValue: Value(from: decoder))
    }

    public var description: String {
        String(describing: self.wrappedValue)
    }

    public var debugDescription: String {
        let valueDescription: String
        var debugDescription = self.projectedValue.debugDescription

        switch self.wrappedValue {
        case is Void:
            valueDescription = "null"
        case let wrappedValue as CustomDebugStringConvertible:
            valueDescription = wrappedValue.debugDescription
        default:
            valueDescription = String(describing: self.wrappedValue)
        }

        if !debugDescription.isEmpty {
            debugDescription.append(" ")
        }
        debugDescription.append(valueDescription)
        return debugDescription
    }
}
