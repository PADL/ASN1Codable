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

public protocol ExpressibleByDate: Equatable, Hashable {
    init(_ date: Date)
}

extension Date: ExpressibleByDate {
    public init(_ date: Date) {
        self = date
    }
}

extension Date?: ExpressibleByDate {
    public init(_ date: Date) {
        self = date
    }
}

@propertyWrapper
public struct GeneralizedTime<Value: Codable & ExpressibleByDate>:
    Codable, Equatable, Hashable, ASN1UniversalTaggedValue {
    public var wrappedValue: Value

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public init() where Value: ExpressibleByNilLiteral {
        self.wrappedValue = nil
    }

    public static var metadata: ASN1Metadata {
        ASN1Metadata(tag: .universal(.generalizedTime))
    }
}

@propertyWrapper
public struct UTCTime<Value: Codable & ExpressibleByDate>:
    Codable, Equatable, Hashable, ASN1UniversalTaggedValue {
    public var wrappedValue: Value

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public init() where Value: ExpressibleByNilLiteral {
        self.wrappedValue = nil
    }

    public static var metadata: ASN1Metadata {
        ASN1Metadata(tag: .universal(.utcTime))
    }
}
