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
import AnyCodable

// swiftlint:disable force_try nesting
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

    func test_decorated() {
        var td = TESTDecorated(version: 3)

        td.version2 = 5
        td.version3 = my_vers(v: 5)

        do {
            let encoder = ASN1Encoder()
            let encoded = try encoder.encode(td)

            let decoder = ASN1Decoder()
            let tnd = try decoder.decode(TESTNotDecorated.self, from: encoded)

            XCTAssertEqual(td.version, tnd.version)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    // FIXME: can't implement test_decorated_choice() as no stored values on enums

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
        let test0 = try! Data(hex: "300e800100a106bf7f03020102820103")
        let c0 = TESTImplicit(ti1: 0, ti2: TESTImplicitInner(foo: 2), ti3: 3)
        self.test_encodeDecode(c0, encodedAs: test0)

        /*
         * UNIV CONS Sequence = 10 bytes {
         *   CONTEXT PRIM tag 0 = 1 bytes [0] IMPLICIT content
         *   CONTEXT PRIM tag 2 = 1 bytes [2] IMPLICIT content
         *   CONTEXT PRIM tag 51 = 1 bytes [51] IMPLICIT content
         * }
         */
        let test1 = try! Data(hex: "300a8001018201039f330104")
        let c1 = TESTImplicit2(ti1: 1,
                               ti3: TESTInteger3(wrappedValue: TESTInteger2(wrappedValue: 3)),
                               ti4: 4)
        self.test_encodeDecode(c1, encodedAs: test1)

        /*
         * CONTEXT CONS tag 5 = 5 bytes [5]
         *   CONTEXT CONS tag 1 = 3 bytes [1]
         *     UNIV PRIM Integer = integer 5
         */
        let test2 = try! Data(hex: "a505a103020105")
        let c2 = TESTImplicit3.ti2(TESTImplicit3Inner.i1(5))
        self.test_encodeDecode(c2, encodedAs: test2)

        /*
         * Notice: same as tests3[].bytes.
         *
         * CONTEXT CONS tag 5 = 5 bytes [5]
         *   CONTEXT CONS tag 1 = 3 bytes [1]
         *     UNIV PRIM Integer = integer 5
         */
        let test3 = test2
        let c3 = TESTImplicit4.ti2(TESTChoice2.i1(5))
        self.test_encodeDecode(c3, encodedAs: test3)
    }

    /*
     UNIV CONS Sequence 12
       UNIV CONS Sequence 5
         CONTEXT CONS 0 3
           UNIV PRIM Integer 1 01
       CONTEXT CONS 1 3
         UNIV PRIM Integer 1 03

     UNIV CONS Sequence 5
       CONTEXT CONS 1 3
         UNIV PRIM Integer 1 03

     UNIV CONS Sequence 8
       CONTEXT CONS 1 3
         UNIV PRIM Integer 1 04
       UNIV PRIM Integer 1 05

     */
    func test_taglessalloc() {
        let test1 = try! Data(hex: "300c3005a003020101a103020103")
        let c1 = TESTAlloc(tagless: TESTAllocInner(ai: 1), three: 3)
        self.test_encodeDecode(c1, encodedAs: test1)

        let test2 = try! Data(hex: "3005a103020103")
        let c2 = TESTAlloc(tagless: nil, three: 3)
        self.test_encodeDecode(c2, encodedAs: test2)

        // FIXME: AnyCodable Data does not round trip
        /*
         let test3 = try! Data(hex: "3008a103020104020105")
         let c3 = TESTAlloc(tagless: nil, three: 4, tagless2: AnyCodable(Data([0x02, 0x01, 0x05])))
         self.test_encodeDecode(c3, encodedAs: test3)
          */

        let test4 = try! Data(hex: "3008a103020104020101")
        let c4 = TESTAlloc(tagless: nil, three: 4, tagless2: AnyCodable(1))
        self.test_encodeDecode(c4, encodedAs: test4)
    }

    /*
     UNIV CONS Sequence 5
       CONTEXT CONS 0 3
         UNIV PRIM Integer 1 00

     UNIV CONS Sequence 5
       CONTEXT CONS 1 3
         UNIV PRIM Integer 1 03

     UNIV CONS Sequence 10
       CONTEXT CONS 0 3
         UNIV PRIM Integer 1 00
       CONTEXT CONS 1 3
         UNIV PRIM Integer 1 01

     */
    func test_optional() {
        let test0 = try! Data(hex: "3000")
        let c0 = TESTOptional(zero: nil, one: nil)
        self.test_encodeDecode(c0, encodedAs: test0)

        let test1 = try! Data(hex: "3005a003020100")
        let c1 = TESTOptional(zero: 0, one: nil)
        self.test_encodeDecode(c1, encodedAs: test1)

        let test2 = try! Data(hex: "3005a103020101")
        let c2 = TESTOptional(zero: nil, one: 1)
        self.test_encodeDecode(c2, encodedAs: test2)

        let test3 = try! Data(hex: "300aa003020100a103020101")
        let c3 = TESTOptional(zero: 0, one: 1)
        self.test_encodeDecode(c3, encodedAs: test3)
    }

    func test_mechtypelist() {
        let test = try! Data(hex: "302E06092A864882F71201020206092A864886F712010202060A2B06010401823702021" +
            "E060A2B06010401823702020A")
        let mtl: TESTMechTypeList = [ObjectIdentifier(rawValue: "1.2.840.48018.1.2.2")!,
                                     ObjectIdentifier(rawValue: "1.2.840.113554.1.2.2")!,
                                     ObjectIdentifier(rawValue: "1.3.6.1.4.1.311.2.2.30")!,
                                     ObjectIdentifier(rawValue: "1.3.6.1.4.1.311.2.2.10")!]
        self.test_encodeDecode(mtl, encodedAs: test)
    }

    func test_seq4() {
        let test0 = try! Data(hex: "3000")
        let c0 = TESTSeqOf4()
        self.test_encodeDecode(c0, encodedAs: test0)

        let test1 = try! Data(hex: "3002a100")
        var c1 = TESTSeqOf4()
        c1.b2 = []
        self.test_encodeDecode(c1, encodedAs: test1)

        let test2 = try! Data(hex: "3006a0023000a100")
        var c2 = TESTSeqOf4()
        c2.b1 = []
        c2.b2 = []
        self.test_encodeDecode(c2, encodedAs: test2)

        let test3 = try! Data(hex: "3076a01830163014040004020102020101020900ffffffffffffffffa1273025020101" +
            "020900ffffffffffffffff0209008000000000000000040004020102040400010203a2" +
            "31302f040002010104020102020900ffffffffffffffff040400010203020900800000" +
            "000000000004010002050100000000")
        let b1 = TESTSeqOf4.B1(s1: Data(),
                               s2: Data([0x01, 0x02]),
                               u1: 1,
                               u2: 18_446_744_073_709_551_615)
        let b2 = TESTSeqOf4.B2(u1: 1,
                               u2: 18_446_744_073_709_551_615,
                               u3: 9_223_372_036_854_775_808,
                               s1: Data(),
                               s2: Data([0x01, 0x02]),
                               s3: Data([0x00, 0x01, 0x02, 0x03]))
        let b3 = TESTSeqOf4.B3(s1: Data(),
                               u1: 1,
                               s2: Data([0x01, 0x02]),
                               u2: 18_446_744_073_709_551_615,
                               s3: Data([0x00, 0x01, 0x02, 0x03]),
                               u3: 9_223_372_036_854_775_808,
                               s4: Data([0x00]),
                               u4: 4_294_967_296)
        var c3 = TESTSeqOf4()
        c3.b1 = [b1]
        c3.b2 = [b2]
        c3.b3 = [b3]
        self.test_encodeDecode(c3, encodedAs: test3)
    }

    func test_seqof5() {
        let test0 = try! Data(hex: "3000")
        let c0 = TESTSeqOf5()
        self.test_encodeDecode(c0, encodedAs: test0)

        let test1 = try! Data(hex: "307c307a30780201010406010101010101020900fffffffffffffffe04060202020202" +
            "020201020406030303030303020900fffffffffffffffd04060404040404040201030406050" +
            "505050505020900fffffffffffffffc04060606060606060201040406070707070707020900" +
            "fffffffffffffffb0406080808080808")
        let b = TESTSeqOf5.B(u0: 1,
                             s0: Data(repeating: 1, count: 6),
                             u1: 18_446_744_073_709_551_614,
                             s1: Data(repeating: 2, count: 6),
                             u2: 2,
                             s2: Data(repeating: 3, count: 6),
                             u3: 18_446_744_073_709_551_613,
                             s3: Data(repeating: 4, count: 6),
                             u4: 3,
                             s4: Data(repeating: 5, count: 6),
                             u5: 18_446_744_073_709_551_612,
                             s5: Data(repeating: 6, count: 6),
                             u6: 4,
                             s6: Data(repeating: 7, count: 6),
                             u7: 18_446_744_073_709_551_611,
                             s7: Data(repeating: 8, count: 6))
        let c1 = TESTSeqOf5(b: [b])
        self.test_encodeDecode(c1, encodedAs: test1)
    }

    func test_default() {
        let test0 = try! Data(hex: "3000")
        let c0 = TESTDefault()
        self.test_encodeDecode(c0, encodedAs: test0)
        XCTAssertEqual(c0.name, "Heimdal")
        XCTAssertEqual(c0.version, 8)
        XCTAssertEqual(c0.maxint, 9_223_372_036_854_775_807)
        XCTAssertEqual(c0.works, true)

        let test1 = try! Data(hex: "30170c076865696d64616ca00302010702047fffffff010100")
        var c1 = TESTDefault()
        c1.name = "heimdal"
        c1.version = 7
        c1.maxint = 2_147_483_647
        c1.works = false
        self.test_encodeDecode(c1, encodedAs: test1)
        XCTAssertEqual(c1.name, "heimdal")
        XCTAssertEqual(c1.version, 7)
        XCTAssertEqual(c1.maxint, 2_147_483_647)
        XCTAssertEqual(c1.works, false)

        let test2 = try! Data(hex: "3008a003020107010100")
        var c2 = TESTDefault()
        c2.version = 7
        c2.works = false
        self.test_encodeDecode(c2, encodedAs: test2)
        XCTAssertEqual(c2.name, "Heimdal")
        XCTAssertEqual(c2.version, 7)
        XCTAssertEqual(c2.maxint, 9_223_372_036_854_775_807)
        XCTAssertEqual(c2.works, false)

        let test3 = try! Data(hex: "300f0c076865696d64616c02047fffffff")
        var c3 = TESTDefault()
        c3.name = "heimdal"
        c3.maxint = 2_147_483_647
        self.test_encodeDecode(c3, encodedAs: test3)
        XCTAssertEqual(c3.name, "heimdal")
        XCTAssertEqual(c3.version, 8)
        XCTAssertEqual(c3.maxint, 2_147_483_647)
        XCTAssertEqual(c3.works, true)
    }

    func test_bit_string() {
        typealias KeyUsage = ASN1RawRepresentableBitString<_KeyUsage>
        struct _KeyUsage: OptionSet, Codable, Equatable {
            var rawValue: UInt16

            init(rawValue: UInt16) {
                self.rawValue = rawValue
            }

            static let digitalSignature = _KeyUsage(rawValue: 1 << 0)
            static let nonRepudiation = _KeyUsage(rawValue: 1 << 1)
            static let keyEncipherment = _KeyUsage(rawValue: 1 << 2)
            static let dataEncipherment = _KeyUsage(rawValue: 1 << 3)
            static let keyAgreement = _KeyUsage(rawValue: 1 << 4)
            static let keyCertSign = _KeyUsage(rawValue: 1 << 5)
            static let cRLSign = _KeyUsage(rawValue: 1 << 6)
            static let encipherOnly = _KeyUsage(rawValue: 1 << 7)
            static let decipherOnly = _KeyUsage(rawValue: 1 << 8)
        }

        let test0 = try! Data(hex: "03020780")
        let c0 = _KeyUsage.digitalSignature
        self.test_encodeDecode(KeyUsage(wrappedValue: c0), encodedAs: test0)

        let test1 = try! Data(hex: "030205a0")
        let c1 = _KeyUsage([.digitalSignature, .keyEncipherment])
        self.test_encodeDecode(KeyUsage(wrappedValue: c1), encodedAs: test1)

        let test2 = try! Data(hex: "0303070080")
        let c2 = _KeyUsage.decipherOnly
        self.test_encodeDecode(KeyUsage(wrappedValue: c2), encodedAs: test2)

        let test3 = try! Data(hex: "030100")
        let c3 = _KeyUsage()
        self.test_encodeDecode(KeyUsage(wrappedValue: c3), encodedAs: test3)
    }

    func test_bit_string_rfc1510() {
        typealias TicketFlags = ASN1RawRepresentableBitString<_TicketFlags>
        struct _TicketFlags: OptionSet, Codable, ASN1RFC1510RawRepresentable {
            var rawValue: UInt32

            init(rawValue: UInt32) {
                self.rawValue = rawValue
            }

            static let reserved = _TicketFlags(rawValue: 1 << 0)
            static let forwardable = _TicketFlags(rawValue: 1 << 1)
            static let forwarded = _TicketFlags(rawValue: 1 << 2)
            static let proxiable = _TicketFlags(rawValue: 1 << 3)
            static let proxy = _TicketFlags(rawValue: 1 << 4)
            static let may_postdate = _TicketFlags(rawValue: 1 << 5)
            static let postdated = _TicketFlags(rawValue: 1 << 6)
            static let invalid = _TicketFlags(rawValue: 1 << 7)
            static let renewable = _TicketFlags(rawValue: 1 << 8)
            static let initial = _TicketFlags(rawValue: 1 << 9)
            static let pre_authent = _TicketFlags(rawValue: 1 << 10)
            static let hw_authent = _TicketFlags(rawValue: 1 << 11)
            static let transited_policy_checked = _TicketFlags(rawValue: 1 << 12)
            static let ok_as_delegate = _TicketFlags(rawValue: 1 << 13)
            static let enc_pa_rep = _TicketFlags(rawValue: 1 << 15)
            static let anonymous = _TicketFlags(rawValue: 1 << 16)
        }

        let test0 = try! Data(hex: "03050080000000")
        let tf0 = _TicketFlags.reserved
        self.test_encodeDecode(TicketFlags(wrappedValue: tf0), encodedAs: test0)

        let test1 = try! Data(hex: "03050040200000")
        let tf1 = _TicketFlags([.forwardable, .pre_authent])
        self.test_encodeDecode(TicketFlags(wrappedValue: tf1), encodedAs: test1)

        let test2 = try! Data(hex: "03050000200000")
        let tf2 = _TicketFlags.pre_authent
        self.test_encodeDecode(TicketFlags(wrappedValue: tf2), encodedAs: test2)

        let test3 = try! Data(hex: "03050000000000")
        let tf3 = _TicketFlags()
        self.test_encodeDecode(TicketFlags(wrappedValue: tf3), encodedAs: test3)
    }

    func test_time() {
        let test0 = try! Data(hex: "180f31393730303130313031313833315a")
        let t0 = GeneralizedTime(wrappedValue: Date(timeIntervalSince1970: 4711))
        self.test_encodeDecode(t0, encodedAs: test0)

        let test1 = try! Data(hex: "180f32303039303532343032303234305a")
        let t1 = GeneralizedTime(wrappedValue: Date(timeIntervalSince1970: 1_243_130_560))
        self.test_encodeDecode(t1, encodedAs: test1)
    }

    func test_preserve() {
        let test0 = try! Data(hex: "300AA003020100A103020101")
        let t0 = TESTPreserve()
        self.test_encodeDecode(t0, encodedAs: test0)
    }
}
