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
    func test_x690sample() {
        let test = try! Data(hex: "60818561101a044a6f686e1a" +
            "01501a05536d697468a00a1a" +
            "084469726563746f72420133" +
            "a10a43083139373130393137" +
            "a21261101a044d6172791a01" +
            "541a05536d697468a342311f" +
            "61111a0552616c70681a0154" +
            "1a05536d697468a00a430831" +
            "39353731313131311f61111a" +
            "05537573616e1a01421a0553" +
            "6d697468a00a430831393539" +
            "30373137")
        let name = X690SampleName(givenName: "John", initial: "P", familyName: "Smith")
        let nameOfSpouse = X690SampleName(givenName: "Mary", initial: "T", familyName: "Smith")
        let ralphName = X690SampleName(givenName: "Ralph", initial: "T", familyName: "Smith")
        let susanName = X690SampleName(givenName: "Susan", initial: "B", familyName: "Smith")
        let children = [X690SampleChildInformation(name: ralphName,
                                                   dateOfBirth: X690SampleDate(
                                                       wrappedValue: VisibleString(wrappedValue: "19571111")
                                                   )),
                        X690SampleChildInformation(name: susanName,
                                                   dateOfBirth: X690SampleDate(
                                                       wrappedValue: VisibleString(wrappedValue: "19590717")
                                                   ))]

        let r = X690SamplePersonnelRecord(name: name,
                                          title: "Director",
                                          number: X690SampleEmployeeNumber(wrappedValue: 51),
                                          dateOfHire: X690SampleDate(
                                              wrappedValue: VisibleString(wrappedValue: "19710917")
                                          ),
                                          nameOfSpouse: nameOfSpouse,
                                          children: children)

        self.test_encodeDecode(r,
                               encodedAs: test,
                               userInfo: [CodingUserInfoKey.ASN1DisableSetSorting: true])
    }
}
