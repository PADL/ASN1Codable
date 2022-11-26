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
@testable import ASN1Codable

class ASN1CodableTests: XCTestCase {
    func test_encodeDecode<T: Codable & Equatable>(
        _ value: T,
        encodedAs data: Data,
        taggingEnvironment: ASN1Tagging? = nil
    ) {
        self.test_encode(value, encodedAs: data, taggingEnvironment: taggingEnvironment)
        self.test_decode(value, encodedAs: data, taggingEnvironment: taggingEnvironment)
    }

    func test_decode<T: Decodable & Equatable>(
        _ value: T,
        encodedAs data: Data,
        taggingEnvironment: ASN1Tagging? = nil
    ) {
        do {
            let decoder = ASN1Decoder()
            decoder.taggingEnvironment = taggingEnvironment
            let decoded = try decoder.decode(T.self, from: data)
            XCTAssertEqual(decoded, value)

            if let preserved = decoded as? ASN1PreserveBinary {
                XCTAssertNotNil(preserved._save)
                XCTAssertEqual(preserved._save, data, "Expected preserved data " +
                    "\(String(describing: preserved._save?.hexString())) to " +
                    "match \(data.hexString())")
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_encode<T: Encodable>(
        _ value: T,
        encodedAs data: Data,
        taggingEnvironment: ASN1Tagging? = nil
    ) {
        do {
            let encoder = ASN1Encoder()
            encoder.taggingEnvironment = taggingEnvironment
            let encoded = try encoder.encode(value)
            XCTAssertEqual(encoded, data, "Expected encoded data \(encoded.hexString()) to match \(data.hexString())")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
