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

import XCTest
import ASN1Codable
import AnyCodable

let ot_String = ObjectIdentifier(rawValue: "1.0")!
let ot_Int = ObjectIdentifier(rawValue: "1.1")!

// swiftlint:disable force_try nesting
extension ASN1CodableTests {
  func test_ObjectSetAny() {
    struct OpenType: Codable, Equatable, ASN1ObjectSetCodable {
      static let knownTypes: [AnyHashable: Codable.Type] = [
        ot_String: String.self,
        ot_Int: Int.self,
      ]

      enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case id = 0
        case value = 1
      }

      @ASN1ObjectSetType
      var id: ObjectIdentifier

      // FIXME: needs to be AnyCodable because we need Equatable conformance to test
      @ASN1AnyObjectSetValue
      var value: AnyCodable
    }

    self.test_encodeDecode(OpenType(id: ot_String, value: AnyCodable("String Value")),
                           encodedAs: try! Data(hex: "3015A003060128A10E0C0C537472696E672056616C7565"))
    self.test_encodeDecode(OpenType(id: ot_Int, value: AnyCodable(1234)),
                           encodedAs: try! Data(hex: "300BA003060129A104020204D2"))
  }

  func test_ObjectSetAnyOctetString() {
    struct OpenType: Codable, Equatable, ASN1ObjectSetOctetStringCodable {
      static let knownTypes: [AnyHashable: Codable.Type] = [
        ot_String: String.self,
        ot_Int: Int.self,
      ]

      enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case id = 0
        case value = 1
      }

      @ASN1ObjectSetType
      var id: ObjectIdentifier

      // FIXME: needs to be AnyCodable because we need Equatable conformance to test
      @ASN1AnyObjectSetValue
      var value: AnyCodable
    }

    self.test_encodeDecode(OpenType(id: ot_String, value: AnyCodable("String Value")),
                           encodedAs: try! Data(hex: "3017A003060128A110040E0C0C537472696E672056616C7565"))
    self.test_encodeDecode(OpenType(id: ot_Int, value: AnyCodable(1234)),
                           encodedAs: try! Data(hex: "300DA003060129A1060404020204D2"))
  }

  func test_ObjectSet() {
    struct OpenType: Codable, ASN1ObjectSetCodable {
      static let knownTypes: [AnyHashable: Codable.Type] = [
        ot_String: String.self,
        ot_Int: Int.self,
      ]

      enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case id = 0
        case value = 1
      }

      @ASN1ObjectSetType
      var id: ObjectIdentifier

      @ASN1ObjectSetValue
      var value: (any Codable)?
    }

    self.test_encode(OpenType(id: ot_String, value: ASN1ObjectSetValue(wrappedValue: "String Value")),
                     encodedAs: try! Data(hex: "3015A003060128A10E0C0C537472696E672056616C7565"))
    self.test_encode(OpenType(id: ot_Int, value: ASN1ObjectSetValue(wrappedValue: 1234)),
                     encodedAs: try! Data(hex: "300BA003060129A104020204D2"))
  }

  func test_ObjectSetOctetString() {
    struct OpenType: Codable, ASN1ObjectSetOctetStringCodable {
      static let knownTypes: [AnyHashable: Codable.Type] = [
        ot_String: String.self,
        ot_Int: Int.self,
      ]

      enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case id = 0
        case value = 1
      }

      @ASN1ObjectSetType
      var id: ObjectIdentifier

      @ASN1ObjectSetValue
      var value: (any Codable)?
    }

    self.test_encode(OpenType(id: ot_String, value: ASN1ObjectSetValue(wrappedValue: "String Value")),
                     encodedAs: try! Data(hex: "3017A003060128A110040E0C0C537472696E672056616C7565"))
    self.test_encode(OpenType(id: ot_Int, value: ASN1ObjectSetValue(wrappedValue: 1234)),
                     encodedAs: try! Data(hex: "300DA003060129A1060404020204D2"))
  }
}
