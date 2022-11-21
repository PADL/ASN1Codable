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

@propertyWrapper
public struct ASN1TaggedDictionary {
    public var wrappedValue: Dictionary<ASN1DecodedTag, AnyCodable>
    
    public init(wrappedValue: Dictionary<ASN1DecodedTag, AnyCodable>) {
        self.wrappedValue = wrappedValue
    }
}

extension ASN1TaggedDictionary: Decodable {
    public init(from decoder: Decoder) throws {
        if let decoder = decoder as? ASN1DecoderImpl {
            let container = try decoder.container(keyedBy: ASN1ExplicitTagCodingKey.self)
            
            self.wrappedValue = Dictionary()
            try container.allKeys.forEach {
                self.wrappedValue[$0.tag] = try container.decode(AnyCodable.self, forKey: $0)
            }
        } else {
            let container = try decoder.singleValueContainer()
            self.wrappedValue = try container.decode(Dictionary<ASN1DecodedTag, AnyCodable>.self)
            return
        }
    }
}

extension ASN1TaggedDictionary: Encodable {
    public func encode(to encoder: Encoder) throws {
        if let encoder = encoder as? ASN1EncoderImpl {
            var container = encoder.container(keyedBy: ASN1ExplicitTagCodingKey.self)
            
            try self.wrappedValue.keys.sorted(by: ASN1DecodedTag.sort).forEach {
                let key = ASN1ExplicitTagCodingKey(tag: $0)
                let value = self.wrappedValue[$0]
                try container.encode(value, forKey: key)
            }
        } else {
            var container = encoder.singleValueContainer()
            try container.encode(self.wrappedValue)
            return
        }
    }
}
