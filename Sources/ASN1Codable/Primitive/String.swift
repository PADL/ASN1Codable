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

extension String: ASN1UniversalTagRepresentable {
    static var tagNo: ASN1Tag { .utf8String }
}

public protocol ExpressibleByString: Equatable, Hashable {
    init(_ string: String)
}

extension String: ExpressibleByString {
    public init(_ string: String) {
        self = string
    }
}

extension String?: ExpressibleByString {
    public init(_ string: String) {
        self = string
    }
}

@propertyWrapper
public struct GeneralString<Value: Codable & ExpressibleByString>:
    Codable, Equatable, Hashable, ASN1UniversalTaggedValue {
    public var wrappedValue: Value

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public init() where Value: ExpressibleByNilLiteral {
        self.wrappedValue = nil
    }

    public static var metadata: ASN1Metadata {
        ASN1Metadata(tag: .universal(.generalString))
    }
}

@propertyWrapper
public struct IA5String<Value: Codable & ExpressibleByString>:
    Codable, Equatable, Hashable, ASN1UniversalTaggedValue {
    public var wrappedValue: Value

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public init() where Value: ExpressibleByNilLiteral {
        self.wrappedValue = nil
    }

    public static var metadata: ASN1Metadata {
        ASN1Metadata(tag: .universal(.ia5String))
    }
}

@propertyWrapper
public struct UTF8String<Value: Codable & ExpressibleByString>:
    Codable, Equatable, Hashable, ASN1UniversalTaggedValue {
    public var wrappedValue: Value

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public init() where Value: ExpressibleByNilLiteral {
        self.wrappedValue = nil
    }

    public static var metadata: ASN1Metadata {
        ASN1Metadata(tag: .universal(.utf8String))
    }
}

@propertyWrapper
public struct UniversalString<Value: Codable & ExpressibleByString>:
    Codable, Equatable, Hashable, ASN1UniversalTaggedValue {
    public var wrappedValue: Value

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public init() where Value: ExpressibleByNilLiteral {
        self.wrappedValue = nil
    }

    public static var metadata: ASN1Metadata {
        ASN1Metadata(tag: .universal(.universalString))
    }
}

@propertyWrapper
public struct BMPString<Value: Codable & ExpressibleByString>:
    Codable, Equatable, Hashable, ASN1UniversalTaggedValue {
    public var wrappedValue: Value

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public init() where Value: ExpressibleByNilLiteral {
        self.wrappedValue = nil
    }

    public static var metadata: ASN1Metadata {
        ASN1Metadata(tag: .universal(.bmpString))
    }
}

@propertyWrapper
public struct PrintableString<Value: Codable & ExpressibleByString>:
    Codable, Equatable, Hashable, ASN1UniversalTaggedValue {
    public var wrappedValue: Value

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public init() where Value: ExpressibleByNilLiteral {
        self.wrappedValue = nil
    }

    public static var metadata: ASN1Metadata {
        ASN1Metadata(tag: .universal(.printableString))
    }
}

extension ASN1DecodedTag {
    var isString: Bool {
        switch self {
        case .universal(let tag):
            return tag.isString
        default:
            return false
        }
    }
}

extension ASN1Tag {
    var isString: Bool {
        switch self {
        case .numericString:
            fallthrough
        case .ia5String:
            fallthrough
        case .printableString:
            fallthrough
        case .graphicString:
            fallthrough
        case .visibleString:
            fallthrough
        case .generalString:
            fallthrough
        case .universalString:
            fallthrough
        case .bmpString:
            fallthrough
        case .utf8String:
            return true
        default:
            return false
        }
    }
}
