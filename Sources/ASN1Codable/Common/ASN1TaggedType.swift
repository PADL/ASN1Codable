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

// for applying a tag/flag to an entire type rather than a member

public protocol ASN1TaggedType: ASN1TaggedTypeRepresentable, Codable {    
    static var tagNumber: ASN1TagNumberRepresentable.Type? { get }
}

public protocol ASN1SetCodable: ASN1TaggedType {
}

public extension ASN1TaggedType {
    static var tagNumber: ASN1TagNumberRepresentable.Type? {
        return nil
    }
    
    private static var tag: ASN1DecodedTag? {
        guard let tagNumber = self.tagNumber else {
            return nil
        }
        
        return ASN1DecodedTag.taggedTag(tagNumber.tagNo)
    }
    
    private static var tagging: ASN1Tagging? {
        if self is any ASN1ImplicitlyTaggedType.Type {
            return .implicit
        } else if self is any ASN1ExplicitlyTaggedType.Type {
            return .explicit
        } else {
            return nil
        }
    }
    
    static var metatype: ASN1Metatype {
        return ASN1Metatype(tag: self.tag, tagging: self.tagging)
    }
}
