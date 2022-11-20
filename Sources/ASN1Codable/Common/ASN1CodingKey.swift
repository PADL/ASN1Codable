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

public protocol ASN1CodingKey: CodingKey, CustomDebugStringConvertible {
    var metatype: ASN1Metatype { get }
}

extension ASN1CodingKey {
    public var debugDescription: String {
        return self.metatype.debugDescription
    }
}

internal struct ASN1PlaceholderCodingKey: CodingKey {
    let key: ASN1CodingKey

    init(_ key: ASN1CodingKey) { self.key = key }
    init?(intValue: Int) { return nil }
    init?(stringValue: String) { return nil }

    var stringValue: String { return key.stringValue }
    var intValue: Int? { return key.intValue }
}


public struct ASN1ExplicitTagCodingKey: ASN1CodingKey {
    let tag: ASN1DecodedTag
    
    init(tag: ASN1DecodedTag) {
        self.tag = tag
    }
    
    public var metatype: ASN1Metatype {
        return ASN1Metatype(tag: self.tag, tagging: .explicit)
    }

    public init?(stringValue: String) {
        guard let tag = ASN1DecodedTag(tagString: stringValue) else {
            return nil
        }
        
        self.init(tag: tag)
    }
        
    public init?(intValue: Int) {
        if intValue < 0 {
            return nil
        }
        
        self.init(tag: .taggedTag(UInt(intValue)))
    }
    
    public var stringValue: String {
        return tag.tagString
    }
    
    public var intValue: Int? {
        if case .taggedTag(let tagNo) = self.tag, tagNo < Int.max {
            return Int(tagNo)
        }
        
        return nil
    }
}

public struct ASN1ImplicitTagCodingKey: ASN1CodingKey {
    let tag: ASN1DecodedTag
    
    init(tag: ASN1DecodedTag) {
        self.tag = tag
    }
    
    public var metatype: ASN1Metatype {
        return ASN1Metatype(tag: self.tag, tagging: .implicit)
    }

    public init?(stringValue: String) {
        guard let tag = ASN1DecodedTag(tagString: stringValue) else {
            return nil
        }
        
        self.init(tag: tag)
    }
        
    public init?(intValue: Int) {
        if intValue < 0 {
            return nil
        }
        
        self.init(tag: .taggedTag(UInt(intValue)))
    }
    
    public var stringValue: String {
        return tag.tagString
    }
    
    public var intValue: Int? {
        if case .taggedTag(let tagNo) = self.tag, tagNo < Int.max {
            return Int(tagNo)
        }
        
        return nil
    }
}
