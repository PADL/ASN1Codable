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
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        try Self.allTests.forEach { test in
            try test.1(self)()
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    static var allTests: [String: (ASN1CodableTests) -> () throws -> Void] = ["test_encode_INTEGER": test_encode_INTEGER]
}

extension ASN1CodableTests {
    func test_encode<T: Codable & Equatable>(_ value: T, encodedAs data: Data) {
        do {
            let encoder = ASN1Encoder()
            let encoded = try encoder.encode(value)
            XCTAssertEqual(encoded, data)

            let decoder = ASN1Decoder()
            let decoded = try decoder.decode(T.self, from: data)
            XCTAssertEqual(decoded, value)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_encode_INTEGER() {
        self.test_encode(Int(72), encodedAs: Data([0x02, 0x01, 0x48]))
    }
}
