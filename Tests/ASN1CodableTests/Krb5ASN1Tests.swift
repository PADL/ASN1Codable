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

// swiftlint:disable force_try
extension ASN1CodableTests {
    func test_principal() {
        let test0 = try! Data(hex: "301ba010300ea003020101a10730051b" +
            "036c6861a1071b0553552e5345")
        let n0 = PrincipalName(name_type: KRB5_NT_PRINCIPAL, name_string: [GeneralString(wrappedValue: "lha")])
        let t0 = Principal(name: n0, realm: GeneralString(wrappedValue: "SU.SE"))
        self.test_encodeDecode(t0, encodedAs: test0)

        let test1 = try! Data(hex: "3021a0163014a003020101a10d300b1b" +
            "036c68611b04726f6f74a1071b055355" +
            "2e5345")
        let n1 = PrincipalName(name_type: KRB5_NT_PRINCIPAL, name_string: [GeneralString(wrappedValue: "lha"),
                                                                           GeneralString(wrappedValue: "root")])
        let t1 = Principal(name: n1, realm: GeneralString(wrappedValue: "SU.SE"))
        self.test_encodeDecode(t1, encodedAs: test1)

        let test2 = try! Data(hex: "3034a0263024a003020103a11d301b1b" +
            "04686f73741b136e7574637261636b65" +
            "722e652e6b74682e7365a10a1b08452e" +
            "4b54482e5345")
        let n2 = PrincipalName(name_type: KRB5_NT_SRV_HST, name_string: [GeneralString(wrappedValue: "host"),
                                                                         GeneralString(wrappedValue: "nutcracker.e.kth.se")])
        let t2 = Principal(name: n2, realm: GeneralString(wrappedValue: "E.KTH.SE"))
        self.test_encodeDecode(t2, encodedAs: test2)
    }
}
