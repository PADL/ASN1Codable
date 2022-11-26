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

extension ASN1CodableTests {
    func test_encode<T: Codable & Equatable>(_ value: T, encodedAs data: Data, taggingEnvironment: ASN1Tagging? = nil) {
        do {
            let encoder = ASN1Encoder()
            encoder.taggingEnvironment = taggingEnvironment
            let encoded = try encoder.encode(value)
            XCTAssertEqual(encoded, data)

            let decoder = ASN1Decoder()
            decoder.taggingEnvironment = taggingEnvironment
            let decoded = try decoder.decode(T.self, from: data)
            XCTAssertEqual(decoded, value)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_encode_INTEGER() {
        self.test_encode(Int(72), encodedAs: Data([0x02, 0x01, 0x48]))
    }
    
    func test_encode_ENUMERATED() {
        enum Color: Int, Codable {
            case red = 0
            case blue = 1
            case yellow = 2
        }
        self.test_encode(Color.blue, encodedAs: Data([0x0A, 0x01, 0x01]))
    }
    
    func test_encode_OCTET_STRING() {
        self.test_encode(Data([0xA2, 0x4F]), encodedAs: Data([0x04, 0x02, 0xA2, 0x4F]))
    }
    
    func test_encode_NULL() {
        self.test_encode(Null(), encodedAs: Data([0x05, 0x00]))
    }
}
