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
import BigNumber

extension ASN1CodableTests {
  func test_BIT_STRING() {
    // FIXME: add more tests when we support not rounding to octet boundary
    self.test_encodeDecode(BitString([0xFF]), encodedAs: Data([0x03, 0x02, 0x00, 0xFF]))
  }

  func test_BMPString() {
    let greekCapitalLetterSigma = BMPString(wrappedValue: "Σ")
    self.test_encodeDecode(greekCapitalLetterSigma, encodedAs: Data([0x1E, 0x02, 0x03, 0xA3]))
  }

  func test_BOOLEAN() {
    self.test_encodeDecode(true, encodedAs: Data([0x01, 0x01, 0xFF]))
    self.test_encodeDecode(false, encodedAs: Data([0x01, 0x01, 0x00]))
  }

  func test_ENUMERATED() {
    enum Color: Int, Codable {
      case red = 0
      case blue = 1
      case yellow = 2
    }
    self.test_encodeDecode(Color.blue, encodedAs: Data([0x0A, 0x01, 0x01]))
  }

  func test_GeneralString() {
    // FIXME: check non-ASCII characters
    @GeneralString var mixedChars = "ABC"
    self.test_encodeDecode(_mixedChars, encodedAs: Data([0x1B, 0x03, 0x41, 0x42, 0x43]))
  }

  func test_GeneralizedTime() {
    let dateComponents = DateComponents(calendar: Calendar(identifier: .gregorian),
                                        timeZone: TimeZone(secondsFromGMT: 0),
                                        year: 1996,
                                        month: 04,
                                        day: 15,
                                        hour: 20,
                                        minute: 30)
    self.test_encodeDecode(GeneralizedTime(wrappedValue: dateComponents.date!),
                           encodedAs: Data([0x18, 0x0F, 0x31, 0x39, 0x39, 0x36, 0x30, 0x34,
                                            0x31, 0x35, 0x32, 0x30, 0x33, 0x30, 0x30, 0x30,
                                            0x5A]))
  }

  func test_IA5String() {
    @IA5String var ia5 = "ABCD EFGH"
    self.test_encodeDecode(_ia5, encodedAs: Data([0x16, 0x09, 0x41, 0x42, 0x43, 0x44, 0x20, 0x45,
                                                  0x46, 0x47, 0x48]))
  }

  func test_INTEGER() {
    self.test_encodeDecode(Int(72), encodedAs: Data([0x02, 0x01, 0x48]))
    self.test_encodeDecode(UInt(72), encodedAs: Data([0x02, 0x01, 0x48]))
    self.test_encodeDecode(BInt(72), encodedAs: Data([0x02, 0x01, 0x48]))
    self.test_encodeDecode(Int(-20), encodedAs: Data([0x02, 0x01, 0xEC]))
    self.test_encodeDecode(BInt(-20), encodedAs: Data([0x02, 0x01, 0xEC]))
    self.test_encodeDecode(Int(-2_147_483_648), encodedAs: Data([0x02, 0x04, 0x80, 0x00, 0x00, 0x00]))
    self.test_encodeDecode(BInt(-2_147_483_648), encodedAs: Data([0x02, 0x04, 0x80, 0x00, 0x00, 0x00]))
    self.test_encodeDecode(UInt(4_294_967_295), encodedAs: Data([0x02, 0x05, 0x00, 0xFF, 0xFF, 0xFF, 0xFF]))
    self.test_encodeDecode(BInt(4_294_967_295), encodedAs: Data([0x02, 0x05, 0x00, 0xFF, 0xFF, 0xFF, 0xFF]))
  }

  func test_NULL() {
    self.test_encodeDecode(Null(), encodedAs: Data([0x05, 0x00]))
  }

  func test_OBJECT_IDENTIFIER() {
    self.test_encodeDecode(ASN1Kit.ObjectIdentifier(rawValue: "1.0")!,
                           encodedAs: Data([0x6, 0x1, 0x28]))
    self.test_encodeDecode(ASN1Kit.ObjectIdentifier(rawValue: "2.100.3")!,
                           encodedAs: Data([0x6, 0x3, 0x81, 0x34, 0x3]))
  }

  func test_OCTET_STRING() {
    self.test_encodeDecode(Data([0xA2, 0x4F]), encodedAs: Data([0x04, 0x02, 0xA2, 0x4F]))
  }

  func test_UTCTime() {
    let dateComponents = DateComponents(calendar: Calendar(identifier: .gregorian),
                                        timeZone: TimeZone(secondsFromGMT: 0),
                                        year: 1996,
                                        month: 04,
                                        day: 15,
                                        hour: 20,
                                        minute: 30)
    self.test_encodeDecode(UTCTime(wrappedValue: dateComponents.date!),
                           encodedAs: Data([0x17, 0x0D, 0x39, 0x36, 0x30, 0x34, 0x31, 0x35,
                                            0x32, 0x30, 0x33, 0x30, 0x30, 0x30, 0x5A]))
  }

  func test_UTF8String() {
    let encoded = Data([0x0C, 0x1E, 0xE5, 0x85, 0xAC, 0xE7, 0x9A, 0x84,
                        0xE5, 0x80, 0x8B, 0xE4, 0xBA, 0xBA, 0xE8, 0xAA,
                        0x8D, 0xE8, 0xA8, 0xBC, 0xE3, 0x82, 0xB5, 0xE3,
                        0x83, 0xBC, 0xE3, 0x83, 0x93, 0xE3, 0x82, 0xB9])
    @UTF8String var utf8 = "公的個人認証サービス"
    self.test_encodeDecode(_utf8, encodedAs: encoded)

    // let's also try without the property wrapper
    self.test_encodeDecode(utf8, encodedAs: encoded)
  }
}
