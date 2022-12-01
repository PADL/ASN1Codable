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

public struct ASN1TaggedDictionary {
    private var wrappedValue: [UInt: AnyCodable]

    init(wrappedValue: [UInt: AnyCodable]) {
        self.wrappedValue = wrappedValue
    }

    // swiftlint:disable identifier_name
    public func _bridgeToObjectiveC() -> NSDictionary {
        self.wrappedValue.mapValues {
            $0.value as? NSObject
        } as NSDictionary
    }

    public subscript(key: UInt) -> AnyCodable? {
        self.wrappedValue[key]
    }

    public mutating func setValue(value: AnyCodable?, forKey key: UInt) {
        self.wrappedValue[key] = value
    }
}

extension ASN1TaggedDictionary: Decodable {
    public init(from decoder: Decoder) throws {
        if let decoder = decoder as? ASN1DecoderImpl {
            let container = try decoder.container(keyedBy: ASN1TaggedDictionaryCodingKey.self)
            self.wrappedValue = try Dictionary(uniqueKeysWithValues: container.allKeys.map {
                ($0.tagNo, try container.decode(AnyCodable.self, forKey: $0))
            })
        } else {
            let container = try decoder.singleValueContainer()
            self.wrappedValue = try container.decode([UInt: AnyCodable].self)
            return
        }
    }
}

extension ASN1TaggedDictionary: Encodable {
    public func encode(to encoder: Encoder) throws {
        if let encoder = encoder as? ASN1EncoderImpl {
            var container = encoder.container(keyedBy: ASN1TaggedDictionaryCodingKey.self)

            try self.wrappedValue.keys.sorted { $0 < $1 }.forEach {
                let key = ASN1TaggedDictionaryCodingKey(tagNo: $0)
                try container.encode(self.wrappedValue[$0], forKey: key)
            }
        } else {
            var container = encoder.singleValueContainer()
            try container.encode(self.wrappedValue)
            return
        }
    }
}

private struct ASN1TaggedDictionaryCodingKey: ASN1ExplicitTagCodingKey {
    var tagNo: UInt

    init(tagNo: UInt) {
        self.tagNo = tagNo
    }

    init?(stringValue: String) {
        guard let tagNo = UInt(stringValue) else {
            return nil
        }
        self.tagNo = tagNo
    }

    init?(intValue: Int) {
        if intValue < 0 {
            return nil
        }

        self.tagNo = UInt(intValue)
    }

    var stringValue: String {
        "[\(self.tagNo)]"
    }

    var intValue: Int? {
        self.tagNo < Int.max ? Int(self.tagNo) : nil
    }
}
