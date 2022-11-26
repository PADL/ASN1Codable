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

enum Division: Codable, Equatable {
    struct Manufacturing: Codable, Equatable {
        var plantID: Int
        var majorProduct: Data
    }

    struct RAndD: Codable, Equatable {
        var labID: Int
        var currentProject: Data
    }

    case manufacturing(Manufacturing)
    case r_and_d(RAndD)
}

class TestClass: Codable, Equatable, ASN1PrivateTaggedType, ASN1PreserveBinary {
    static var tagNumber: UInt = 100

    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case version = 0
        case data = 1
        case bitString = 2
    }

    var _save: Data?
    var version: Int = 1
    var data = Data([0x02, 0x03, 0xFF])
    var bitString = BitString([0x02, 0x03, 0xCC])

    static func == (lhs: TestClass, rhs: TestClass) -> Bool {
        return lhs.version == rhs.version &&
            lhs.data == rhs.data &&
            lhs.bitString == rhs.bitString
    }
}

extension ASN1CodableTests {
    func test_CHOICE_Division() {
        let r_and_d = Division.RAndD(labID: 48, currentProject: Data([0x44, 0x58, 0x2D, 0x37]))
        let currentAssignment = Division.r_and_d(r_and_d)

        self.test_encodeDecode(currentAssignment,
                               encodedAs: Data([0xA1, 0x09, 0x80, 0x01, 0x30, 0x81, 0x04, 0x44,
                                                0x58, 0x2D, 0x37]),
                               taggingEnvironment: .automatic)
    }

    func test_encode_SEQUENCE_ApplicationTaggedTestStruct_PropertyWrapper() {
        struct TestStruct: Codable, Equatable, ASN1ApplicationTaggedType {
            static var tagNumber: UInt = 100

            var _save: Data?

            @ASN1ContextTagged<ASN1TagNumber$0, ASN1DefaultTagging, Int>
            var version: Int = 1

            @ASN1ContextTagged<ASN1TagNumber$1, ASN1DefaultTagging, Data>
            var data = Data()

            @ASN1ContextTagged<ASN1TagNumber$2, ASN1ImplicitTagging, BitString>
            var bitString = BitString([0x02, 0x03, 0xCC])

            @ASN1ContextTagged<ASN1TagNumber$3, ASN1DefaultTagging, UInt?>
            var whatever: UInt? = 1234

            @ASN1ContextTagged<ASN1TagNumber$4, ASN1DefaultTagging, PrintableString<String>>
            @PrintableString
            var foobar = "hello world"

            @ASN1ContextTagged<ASN1TagNumber$5, ASN1DefaultTagging, [String]>
            var anArray = ["Hello", "ASN.1", "Coding", "Kit"]

            @ASN1ContextTagged<ASN1TagNumber$6, ASN1DefaultTagging, Set<String>>
            var aSet = Set(["A", "Set"])

            @ASN1ContextTagged<ASN1TagNumber$7, ASN1DefaultTagging, GeneralString<String?>>
            @GeneralString
            var barbar: String? = "hello"
        }

        let data = Data(base64Encoded: "f2RaMFigAwIBAaECBACCBAACA8yjBAICBNKkDRMLaGVsbG8gd29ybGSlHTAb" +
            "DAVIZWxsbwwFQVNOLjEMBkNvZGluZwwDS2l0pgoxCAwBQQwDU2V0pwcbBWhlbGxv")!

        self.test_encodeDecode(TestStruct(), encodedAs: data)
    }

    func test_encode_SEQUENCE_PrivateTaggedTestStruct_PropertyWrapper() {
        struct TestStruct: Codable, Equatable, ASN1PrivateTaggedType {
            static var tagNumber: UInt = 100

            @ASN1ContextTagged<ASN1TagNumber$0, ASN1DefaultTagging, Int>
            var version: Int = 1

            @ASN1ContextTagged<ASN1TagNumber$1, ASN1DefaultTagging, Data>
            var data = Data([0x02, 0x03, 0xFF])

            @ASN1ContextTagged<ASN1TagNumber$2, ASN1DefaultTagging, BitString>
            var bitString = BitString([0x02, 0x03, 0xCC])
        }

        let data = Data(base64Encoded: "/2QWMBSgAwIBAaEFBAMCA/+iBgMEAAIDzA==")!
        self.test_encodeDecode(TestStruct(), encodedAs: data)
    }

    func test_encode_SEQUENCE_PrivateTaggedTestStruct_CodingKey() {

        let data = Data(base64Encoded: "/2QWMBSgAwIBAaEFBAMCA/+iBgMEAAIDzA==")!
        self.test_encodeDecode(TestClass(), encodedAs: data)
    }

    func test_encode_SEQUENCE_AutoType() {
        enum AutoEnum: Codable, Equatable {
            case C1(String)
            case C2(Int)
            case C3(ObjectIdentifier)
        }

        struct AutoType: Codable, Equatable {
            var name = "John"
            var age = 25
            var oid = AutoEnum.C3(ObjectIdentifier(rawValue: "1.2.3.4.5.6")!)
        }

        let untagged = Data(base64Encoded: "MBAMBEpvaG4CARkGBSoDBAUG")!
        self.test_encodeDecode(AutoType(), encodedAs: untagged)
        let automatic = Data(base64Encoded: "MBKABEpvaG6BARmiB4IFKgMEBQY=")!
        self.test_encodeDecode(AutoType(), encodedAs: automatic, taggingEnvironment: .automatic)
    }

    func test_encode_SEQUENCE_PersonnelRecord() {
        struct PersonnelRecord: Codable, Equatable {
            var name: Data
            var location: Int
            var age: Int?
        }

        self.test_encodeDecode(PersonnelRecord(name: Data([0x62, 0x69, 0x67, 0x20, 0x68, 0x65, 0x61, 0x64]),
                                               location: 2,
                                               age: 26),
                               encodedAs: Data([0x30, 0x10, 0x04, 0x08, 0x62, 0x69, 0x67, 0x20,
                                                0x68, 0x65, 0x61, 0x64, 0x02, 0x01, 0x02, 0x02,
                                                0x01, 0x1A]))
    }

    func test_encode_SEQUENCE_OF_INTEGER() {
        let weeklyHighs = [10, 12, -2, 8]

        self.test_encodeDecode(weeklyHighs,
                               encodedAs: Data([0x30, 0x0C, 0x02, 0x01, 0x0A, 0x02, 0x01, 0x0C,
                                                0x02, 0x01, 0xFE, 0x02, 0x01, 0x08]))
    }

    func test_encode_SET_PersonnelRecord() {
        struct PersonnelRecord: Codable, Equatable, ASN1SetCodable {
            var name: Data
            var location: Int
            var age: Int?
        }

        self.test_encodeDecode(PersonnelRecord(name: Data([0x44, 0x61, 0x76, 0x79, 0x20, 0x4A, 0x6F, 0x6E,
                                                           0x65, 0x73]),
                               location: 0,
                               age: 44),
                               encodedAs: Data([0x31, 0x12, 0x80, 0x0A, 0x44, 0x61, 0x76, 0x79,
                                                0x20, 0x4A, 0x6F, 0x6E, 0x65, 0x73, 0x81, 0x01,
                                                0x00, 0x82, 0x01, 0x2C]),
                               taggingEnvironment: .automatic)
    }

    func test_encode_AUTOMATIC_SEQUENCE_PersonnelRecord() {
        struct PersonnelRecord: Codable, Equatable {
            @UTF8String var name: String = "John"
            var age: Int = 25
        }

        self.test_encodeDecode(PersonnelRecord(),
                               encodedAs: Data([0x30, 0x09, 0x80, 0x04, 0x4A, 0x6F, 0x68, 0x6E,
                                                0x81, 0x01, 0x19]),
                               taggingEnvironment: .automatic)
    }

    func test_encode_IMPLICIT_SEQUENCE_PersonnelRecord() {
        struct PersonnelRecord: Codable, Equatable, ASN1ContextTaggedType {
            static var tagNumber: UInt = 0

            @UTF8String var name: String = "John"
            var age: Int = 25
        }

        self.test_encodeDecode(PersonnelRecord(),
                               encodedAs: Data([0xA0, 0x09, 0x0C, 0x04, 0x4A, 0x6F, 0x68, 0x6E,
                                                0x02, 0x01, 0x19]),
                               taggingEnvironment: .implicit)
    }

    func test_encode_EXPLICIT_SEQUENCE_PersonnelRecord() {
        struct PersonnelRecord: Codable, Equatable, ASN1ContextTaggedType {
            static var tagNumber: UInt = 0

            @UTF8String var name: String = "John"
            var age: Int = 25
        }

        self.test_encodeDecode(PersonnelRecord(),
                               encodedAs: Data([0xA0, 0x0B, 0x30, 0x09, 0x0C, 0x04, 0x4A, 0x6F,
                                                0x68, 0x6E, 0x02, 0x01, 0x19]),
                               taggingEnvironment: .explicit)
    }

    func test_encode_SET_OF_INTEGER() {
        let weeklyHighs = Set([10, 12, -2, 8])

        self.test_encodeDecode(weeklyHighs,
                               encodedAs: Data([0x31, 0x0C, 0x02, 0x01, 0x08, 0x02, 0x01, 0x0A,
                                                0x02, 0x01, 0x0C, 0x02, 0x01, 0xFE]))
    }
}

enum ASN1TagNumber$0: ASN1TagNumberRepresentable {}
enum ASN1TagNumber$1: ASN1TagNumberRepresentable {}
enum ASN1TagNumber$2: ASN1TagNumberRepresentable {}
enum ASN1TagNumber$3: ASN1TagNumberRepresentable {}
enum ASN1TagNumber$4: ASN1TagNumberRepresentable {}
enum ASN1TagNumber$5: ASN1TagNumberRepresentable {}
enum ASN1TagNumber$6: ASN1TagNumberRepresentable {}
enum ASN1TagNumber$7: ASN1TagNumberRepresentable {}
enum ASN1TagNumber$8: ASN1TagNumberRepresentable {}
enum ASN1TagNumber$9: ASN1TagNumberRepresentable {}
enum ASN1TagNumber$10: ASN1TagNumberRepresentable {}
