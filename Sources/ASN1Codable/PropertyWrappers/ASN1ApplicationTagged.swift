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

@propertyWrapper
public struct ASN1ApplicationTagged <Tag, Tagging, Value>: Codable, ASN1TaggedWrappedValue where Tag: ASN1TagNumberRepresentable, Tagging: ASN1TaggingRepresentable, Value: Codable {
    public static var tagNumber: Tag.Type { return Tag.self }

    public var wrappedValue: Value
        
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    public init() where Value: ExpressibleByNilLiteral {
        self.wrappedValue = nil
    }

    public static var metatype: ASN1Metatype {
        return ASN1Metatype(tag: .applicationTag(tagNumber.tagNo), tagging: Tagging.tagging)
    }
}

extension ASN1ApplicationTagged: Equatable where Value: Equatable {
}

extension ASN1ApplicationTagged: Hashable where Value: Hashable {
}

public protocol ASN1ApplicationTaggedType: ASN1TaggedType {
}

extension ASN1ApplicationTaggedType {
    public static var metatype: ASN1Metatype {
        return ASN1Metatype(tag: .applicationTag(self.tagNumber))
    }
}
