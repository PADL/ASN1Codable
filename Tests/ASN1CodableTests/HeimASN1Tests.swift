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

/*
 * Copyright (c) 1999 - 2005 Kungliga Tekniska Högskolan
 * (Royal Institute of Technology, Stockholm, Sweden).
 * All rights reserved.
 *
 * Portions Copyright (c) 2009 Apple Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the Institute nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE INSTITUTE AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE INSTITUTE OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

import XCTest
import ASN1Codable
import BigNumber

/// various tests translated from Heimdal
///
extension ASN1CodableTests {
    func test_large_tag() {
        let lt1 = TESTLargeTag(foo: 1, bar: 2)
        self.test_encodeDecode(lt1,
                               encodedAs: Data([0x30, 0x0D, 0xBF, 0x7F, 0x03, 0x02, 0x01, 0x01,
                                                0xBF, 0x81, 0x00, 0x03, 0x02, 0x01, 0x02]))
    }

    func test_tag_length() {
        struct TestData {
            let ok: Bool
            let expectedLen: Int
            let data: Data
        }

        let td: [TestData] = [TestData(ok: true, expectedLen: 3, data: Data([0x02, 0x01, 0x00])),
                              TestData(ok: true, expectedLen: 3, data: Data([0x02, 0x01, 0x7F])),
                              TestData(ok: true, expectedLen: 4, data: Data([0x02, 0x02, 0x00, 0x80])),
                              TestData(ok: true, expectedLen: 4, data: Data([0x02, 0x02, 0x01, 0x00])),
                              TestData(ok: true, expectedLen: 4, data: Data([0x02, 0x02, 0x02, 0x00])),
                              TestData(ok: false, expectedLen: 0, data: Data([0x02, 0x02, 0x00])),
                              TestData(ok: false, expectedLen: 0, data: Data([0x02, 0x7F, 0x7F])),
                              TestData(ok: false, expectedLen: 0, data: Data([0x02, 0x03, 0x00, 0x80])),
                              TestData(ok: false, expectedLen: 0, data: Data([0x02, 0x7F, 0x01, 0x00])),
                              TestData(ok: false, expectedLen: 0, data: Data([0x02, 0xFF, 0x7F, 0x02, 0x00]))]

        let values: [UInt32] = [0, 127, 128, 256, 512,
                                0, 127, 128, 256, 512]

        for i in 0 ..< values.count {
            let decoder = ASN1Decoder()
            do {
                let decoded = try decoder.decode(UInt32.self, from: td[i].data)
                if td[i].ok {
                    XCTAssertEqual(decoded, values[i])
                } else {
                    XCTAssertNotEqual(decoded, values[i])
                }
            } catch {
                XCTAssertEqual(false, td[i].ok)
            }
        }
    }

    func test_choice() {
        let td: [Data] = [Data([0xA1, 0x03, 0x02, 0x01, 0x01]),
                          Data([0xA2, 0x03, 0x02, 0x01, 0x02])]

        let c1 = TESTChoice1.i1(1)
        let c2 = TESTChoice1.i2(2)

        self.test_encodeDecode(c1, encodedAs: td[0])
        self.test_encodeDecode(c2, encodedAs: td[1])
    }

    func test_implicit() {
        /*
         * UNIV CONS Sequence = 14 bytes {
         *   CONTEXT PRIM tag 0 = 1 bytes [0] IMPLICIT content
         *   CONTEXT CONS tag 1 = 6 bytes [1]
         *     CONTEXT CONS tag 127 = 3 bytes [127]
         *       UNIV PRIM Integer = integer 2
         *   CONTEXT PRIM tag 2 = 1 bytes [2] IMPLICIT content
         * }
         */
        let test1 = try! Data(hex: "300e800100a106bf7f03020102820103")
        let c0 = TESTImplicit(ti1: 0, ti2: TESTImplicitInner(foo: 2), ti3: 3)
        self.test_encodeDecode(c0, encodedAs: test1)

        /*
         * UNIV CONS Sequence = 10 bytes {
         *   CONTEXT PRIM tag 0 = 1 bytes [0] IMPLICIT content
         *   CONTEXT PRIM tag 2 = 1 bytes [2] IMPLICIT content
         *   CONTEXT PRIM tag 51 = 1 bytes [51] IMPLICIT content
         * }
         */
        let test2 = try! Data(hex: "300a8001018201039f330104")
        let c1 = TESTImplicit2(ti1: 1,
                               ti3: TESTInteger3(wrappedValue: TESTInteger2(wrappedValue: 3)),
                               ti4: 4)
        self.test_encodeDecode(c1, encodedAs: test2)

        /*
         * CONTEXT CONS tag 5 = 5 bytes [5]
         *   CONTEXT CONS tag 1 = 3 bytes [1]
         *     UNIV PRIM Integer = integer 5
         */
        let test3 = try! Data(hex: "a505a103020105")
        let c2 = TESTImplicit3.ti2(TESTImplicit3Inner.i1(5))
        self.test_encodeDecode(c2, encodedAs: test3)

        /*
         * Notice: same as tests3[].bytes.
         *
         * CONTEXT CONS tag 5 = 5 bytes [5]
         *   CONTEXT CONS tag 1 = 3 bytes [1]
         *     UNIV PRIM Integer = integer 5
         */
        let test4 = test3
        let c3 = TESTImplicit4.ti2(TESTChoice2.i1(5))
        self.test_encodeDecode(c3, encodedAs: test4)
    }
}
