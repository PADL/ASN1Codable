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

class PersonnelRecord: Codable, Equatable {
    var name: String
    var location: Int
    var age: Int?

    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case name = 0
        case location = 1
        case age = 2
    }

    required init(name: String, location: Int, age: Int?) {
        self.name = name
        self.location = location
        self.age = age
    }

    static func == (lhs: PersonnelRecord, rhs: PersonnelRecord) -> Bool {
        lhs.name == rhs.name && lhs.location == rhs.location && lhs.age == rhs.age
    }
}

final class ContractorPersonnelRecord: PersonnelRecord {
    var company: String?

    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case `super` = 100
        case company = 101
    }

    required init(name: String, location: Int, age: Int?) {
        super.init(name: name, location: location, age: age)
        self.company = nil
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.company = try container.decodeIfPresent(String.self, forKey: .company)
        try super.init(from: container.superDecoder(forKey: .super))
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try super.encode(to: container.superEncoder(forKey: .super))
        try container.encodeIfPresent(self.company, forKey: .company)
    }

    static func == (lhs: ContractorPersonnelRecord, rhs: ContractorPersonnelRecord) -> Bool {
        guard lhs as PersonnelRecord == rhs as PersonnelRecord else { return false }
        return lhs.company == rhs.company
    }
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
        lhs.version == rhs.version &&
            lhs.data == rhs.data &&
            lhs.bitString == rhs.bitString
    }
}

// swiftlint:disable force_try nesting
extension ASN1CodableTests {
    func test_CHOICE_Division() {
        let r_and_d = Division.RAndD(labID: 48, currentProject: Data([0x44, 0x58, 0x2D, 0x37]))
        let currentAssignment = Division.r_and_d(r_and_d)

        self.test_encodeDecode(currentAssignment,
                               encodedAs: Data([0xA1, 0x09, 0x80, 0x01, 0x30, 0x81, 0x04, 0x44,
                                                0x58, 0x2D, 0x37]),
                               taggingEnvironment: .automatic)
    }

    func test_SEQUENCE_ApplicationTaggedTestStruct_PropertyWrapper() {
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

    func test_SEQUENCE_ApplicationTaggedTestStruct_MetadataCodingKey() {
        struct TestStruct: Codable, Equatable, ASN1ApplicationTaggedType {
            static var tagNumber: UInt = 100

            enum CodingKeys: String, ASN1MetadataCodingKey {
                case version
                case data
                case bitString
                case whatever
                case foobar
                case anArray
                case aSet
                case barbar

                static func metadata(forKey key: Self) -> ASN1Metadata? {
                    let metadata: ASN1Metadata?

                    switch key {
                    case version:
                        metadata = ASN1Metadata(tag: .taggedTag(0), tagging: nil)
                    case data:
                        metadata = ASN1Metadata(tag: .taggedTag(1), tagging: nil)
                    case bitString:
                        metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .implicit)
                    case whatever:
                        metadata = ASN1Metadata(tag: .taggedTag(3), tagging: nil)
                    case foobar:
                        metadata = ASN1Metadata(tag: .taggedTag(4), tagging: nil)
                    case anArray:
                        metadata = ASN1Metadata(tag: .taggedTag(5), tagging: nil)
                    case aSet:
                        metadata = ASN1Metadata(tag: .taggedTag(6), tagging: nil)
                    case barbar:
                        metadata = ASN1Metadata(tag: .taggedTag(7), tagging: nil)
                    }

                    return metadata
                }
            }

            var _save: Data?

            var version: Int = 1
            var data = Data()
            var bitString = BitString([0x02, 0x03, 0xCC])
            var whatever: UInt? = 1234
            @PrintableString
            var foobar = "hello world"
            var anArray = ["Hello", "ASN.1", "Coding", "Kit"]
            var aSet = Set(["A", "Set"])
            @GeneralString
            var barbar: String? = "hello"
        }

        let data = Data(base64Encoded: "f2RaMFigAwIBAaECBACCBAACA8yjBAICBNKkDRMLaGVsbG8gd29ybGSlHTAb" +
            "DAVIZWxsbwwFQVNOLjEMBkNvZGluZwwDS2l0pgoxCAwBQQwDU2V0pwcbBWhlbGxv")!

        self.test_encodeDecode(TestStruct(), encodedAs: data)
    }

    func test_SEQUENCE_PrivateTaggedTestStruct_PropertyWrapper() {
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

        // check automatic tagging is disabled
        self.test_encodeDecode(TestStruct(), encodedAs: data, taggingEnvironment: .automatic)
    }

    func test_SEQUENCE_PrivateTaggedTestStruct_MetadataCodingKey() {
        struct TestStruct: Codable, Equatable, ASN1PrivateTaggedType {
            static var tagNumber: UInt = 100

            enum CodingKeys: String, ASN1MetadataCodingKey {
                case version
                case data
                case bitString

                static func metadata(forKey key: Self) -> ASN1Metadata? {
                    let metadata: ASN1Metadata?

                    switch key {
                    case version:
                        metadata = ASN1Metadata(tag: .taggedTag(0), valueConstraints: 1 ... 3)
                    case data:
                        metadata = ASN1Metadata(tag: .taggedTag(1))
                    case bitString:
                        metadata = ASN1Metadata(tag: .taggedTag(2), sizeConstraints: 1 ... 64)
                    }

                    return metadata
                }
            }

            var version: Int = 1
            var data = Data([0x02, 0x03, 0xFF])
            var bitString = BitString([0x02, 0x03, 0xCC])
        }

        let data = Data(base64Encoded: "/2QWMBSgAwIBAaEFBAMCA/+iBgMEAAIDzA==")!
        self.test_encodeDecode(TestStruct(), encodedAs: data)

        // check automatic tagging is disabled
        self.test_encodeDecode(TestStruct(), encodedAs: data, taggingEnvironment: .automatic)
    }

    func test_SEQUENCE_PrivateTaggedTestStruct_ContextTagCodingKey() {
        struct TestStruct: Codable, Equatable, ASN1PrivateTaggedType {
            static var tagNumber: UInt = 100

            enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
                case version = 0
                case data = 1
                case bitString = 2
            }

            var version: Int = 1
            var data = Data([0x02, 0x03, 0xFF])
            var bitString = BitString([0x02, 0x03, 0xCC])
        }

        let data = Data(base64Encoded: "/2QWMBSgAwIBAaEFBAMCA/+iBgMEAAIDzA==")!
        self.test_encodeDecode(TestStruct(), encodedAs: data)

        // check automatic tagging is disabled
        self.test_encodeDecode(TestStruct(), encodedAs: data, taggingEnvironment: .automatic)
    }

    func test_SEQUENCE_TestClass_CodingKey() {
        let data = Data(base64Encoded: "/2QWMBSgAwIBAaEFBAMCA/+iBgMEAAIDzA==")!
        self.test_encodeDecode(TestClass(), encodedAs: data)
    }

    func test_SEQUENCE_AutoType() {
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

    func test_SEQUENCE_AutoType_CaseIterableKeys() {
        enum AutoEnum: Codable, Equatable {
            enum CodingKeys: CodingKey, CaseIterable {
                case C1
                case C2
                case C3
            }

            case C1(String)
            case C2(Int)
            case C3(ObjectIdentifier)
        }

        struct AutoType: Codable, Equatable {
            enum CodingKeys: CodingKey, CaseIterable {
                case age // [0]
                case name // [1]
                case oid // [2]
            }

            var name: String
            var age: Int
            var oid: AutoEnum
        }

        let oid = AutoEnum.C3(ObjectIdentifier(rawValue: "1.2.3.4.5.6")!)
        let untagged = try! Data(hex: "30100201190C044A6F686E06052A03040506")
        self.test_encodeDecode(AutoType(name: "John", age: 25, oid: oid),
                               encodedAs: untagged)
        let automatic = try! Data(hex: "301280013C81044A6F686EA20782052A03040506")
        self.test_encodeDecode(AutoType(name: "John", age: 60, oid: oid),
                               encodedAs: automatic, taggingEnvironment: .automatic)
    }

    func test_SEQUENCE_PersonnelRecord() {
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

    func test_SEQUENCE_PersonnelRecordSuper() {
        let cpr = ContractorPersonnelRecord(name: "Luke", location: 1, age: nil)
        cpr.company = "PADL"

        self.test_encodeDecode(cpr,
                               encodedAs: try! Data(hex: "3016A0060C044C756B65A103020101BF65060C045041444C"))
    }

    func test_SEQUENCE_OF_INTEGER() {
        let weeklyHighs = [10, 12, -2, 8]

        self.test_encodeDecode(weeklyHighs,
                               encodedAs: Data([0x30, 0x0C, 0x02, 0x01, 0x0A, 0x02, 0x01, 0x0C,
                                                0x02, 0x01, 0xFE, 0x02, 0x01, 0x08]))
    }

    func test_SET_PersonnelRecord() {
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

    func test_AUTOMATIC_SEQUENCE_PersonnelRecord() {
        struct PersonnelRecord: Codable, Equatable {
            @UTF8String var name: String = "John"
            var age: Int = 25
        }

        self.test_encodeDecode(PersonnelRecord(),
                               encodedAs: Data([0x30, 0x09, 0x80, 0x04, 0x4A, 0x6F, 0x68, 0x6E,
                                                0x81, 0x01, 0x19]),
                               taggingEnvironment: .automatic)
    }

    func test_IMPLICIT_SEQUENCE_PersonnelRecord() {
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

    func test_EXPLICIT_SEQUENCE_PersonnelRecord() {
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

    func test_SET_OF_INTEGER() {
        let weeklyHighs = Set([10, 12, -2, 8])

        self.test_encodeDecode(weeklyHighs,
                               encodedAs: Data([0x31, 0x0C, 0x02, 0x01, 0x08, 0x02, 0x01, 0x0A,
                                                0x02, 0x01, 0x0C, 0x02, 0x01, 0xFE]))
    }

    func test_TaggedDictionary() {
        var taggedDictionary = ASN1TaggedDictionary()

        taggedDictionary[0] = "Testing"
        taggedDictionary[100] = 1234

        self.test_encodeDecode(taggedDictionary,
                               encodedAs: try! Data(hex: "3012A0090C0754657374696E67BF6404020204D2"))
    }

    func test_StringKeyedDictionary() {
        let dictionary = ["continent": "Europe", "country": "Sweden"]

        self.test_encodeDecode(dictionary,
                               encodedAs: try! Data(hex: "312830110C07636F756E7472790C0653776564656E30130C09636F6E74696E656E740C064575726F7065"))
    }

    func test_IntKeyedDictionary() {
        let dictionary = [1234: "Europe", 5555: "Sweden"]

        self.test_encodeDecode(dictionary,
                               encodedAs: try! Data(hex: "311C300C020204D20C064575726F7065300C020215B30C0653776564656E"))
    }

    func test_UIntKeyedDictionary() {
        let dictionary = [1234: "Europe", 5555: "Sweden"]

        self.test_encodeDecode(dictionary,
                               encodedAs: try! Data(hex: "311C300C020204D20C064575726F7065300C020215B30C0653776564656E"))
    }

    func test_CustomKeyedDictionary() {
        struct Key: Codable, Equatable, Hashable {
            var value: UInt

            init(_ value: UInt) {
                self.value = value
            }
        }
        let dictionary = [Key(1234): "Europe", Key(5555): "Sweden"]

        self.test_encodeDecode(dictionary,
                               encodedAs: try! Data(hex: "3120300E3004020204D20C064575726F7065300E3004020215B30C0653776564656E"))
    }

    func test_SEQUENCE_Automatic() {
        let dictionary = [1234: "Europe", 5555: "Sweden"]
        let r_and_d = Division.RAndD(labID: 48, currentProject: Data([0x44, 0x58, 0x2D, 0x37]))
        let pr = PersonnelRecord(name: "Luke", location: 2, age: 102)

        struct SomeType: Codable, Equatable {
            let set: Set<String>
            let dictionary: [Int: String]
            let division: Division
            let personnelRecord: PersonnelRecord
        }

        let st = SomeType(set: Set<String>(arrayLiteral: "a", "b"),
                          dictionary: dictionary,
                          division: Division.r_and_d(r_and_d),
                          personnelRecord: pr)

        self.test_encodeDecode(st,
                               encodedAs: try! Data(hex: "3047A0060C01610C0162A11C300C800204D281064575726F7065300C800215B" +
                                   "3810653776564656EA20BA109800130810444582D37A312A0060C044C756B65A103020102A203020166"),
                               taggingEnvironment: .automatic)
    }

    func test_SEQUENCE_OF_Optional() {
        enum SomeAny: Codable, Equatable {
            case some(AnyCodable)
            case none(Null)
        }
        let sequence: [Int?] = [0, nil, 10, 11, nil, 1, 0, nil, nil, 1234]
        self.test_encodeDecode(sequence,
                               encodedAs: try! Data(hex: "301B020100050002010A02010B050002010102010005000500020204D2"))
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
