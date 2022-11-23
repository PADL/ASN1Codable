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

fileprivate extension ASN1DecodedTag {
    var tagType: UInt8 {
        switch self {
        case .universal(_):
            return ASN1Tag.universal
        case .applicationTag(_):
            return ASN1Tag.application
        case .taggedTag(_):
            return ASN1Tag.tagged
        case .privateTag(_):
            return ASN1Tag.private
        }
    }
    
    var tagNo: UInt {
        switch self {
        case .universal(let tagNo):
            return UInt(tagNo.rawValue)
        case .applicationTag(let tagNo):
            return tagNo
        case .taggedTag(let tagNo):
            return tagNo
        case .privateTag(let tagNo):
            return tagNo
        }
    }
}

extension ASN1DecodedTag: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.tagType)
        hasher.combine(self.tagNo)
    }
}

extension ASN1DecodedTag: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let tag = try container.decode(String.self)

        precondition(!(decoder is ASN1DecoderImpl))
        
        guard let tag = Self(tagString:  tag) else {
            let context = DecodingError.Context(codingPath: container.codingPath,
                                                debugDescription: "Invalid tag \(tag)")
            throw DecodingError.dataCorrupted(context)
        }
        
        self = tag
    }
}

extension ASN1DecodedTag: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.tagString)
    }
}

extension ASN1DecodedTag {
    static func sort(_ lhs: ASN1DecodedTag, _ rhs: ASN1DecodedTag) -> Bool {
        let lhs_tagType = lhs.tagType, rhs_tagType = rhs.tagType
        let lhs_tagNo = lhs.tagNo, rhs_tagNo = rhs.tagNo
        
        if lhs_tagType == lhs_tagType {
            return lhs_tagNo < rhs_tagNo
        } else {
            return lhs_tagType < rhs_tagType
        }
    }
}

fileprivate extension ASN1DecodedTag {
    var tagString: String {
        let tagString: String
        
        switch self {
        case .applicationTag(let tagNo):
            tagString = "application.\(tagNo)"
            break
        case .taggedTag(let tagNo):
            tagString = "\(tagNo)"
            break
        case .universal(let tag):
            tagString = "universal.\(tag.rawValue)"
            break
        case .privateTag(let tagNo):
            tagString = "private.\(tagNo)"
            break
        }
        
        return tagString
    }
    
    init?(tagString tag: String) {
        if !tag.contains(".") {
            guard let tagNo = UInt(tag) else {
                return nil
            }
            self = .taggedTag(tagNo)
        } else {
            let typeTagNo = tag.components(separatedBy: ".")
            guard typeTagNo.count == 2, let tagNo = UInt(typeTagNo[1]) else {
                return nil
            }
            switch typeTagNo[0] {
            case "application":
                self = .applicationTag(tagNo)
                break
            case "universal":
                guard tagNo == tagNo & 0xff, let tag = ASN1Tag(rawValue: UInt8(tagNo)) else {
                    return nil
                }
                self = .universal(tag)
                break
            case "private":
                self = .privateTag(tagNo)
                break
            default:
                return nil
            }
        }
    }
}
