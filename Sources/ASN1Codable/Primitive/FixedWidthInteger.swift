//
// Copyright (c) 2009 The Go Authors. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//     * Redistributions of source code must retain the above copyright
// notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above
// copyright notice, this list of conditions and the following disclaimer
// in the documentation and/or other materials provided with the
// distribution.
//     * Neither the name of Google Inc. nor the names of its
// contributors may be used to endorse or promote products derived from
// this software without specific prior written permission.
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
// OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
// LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import Foundation
import ASN1Kit

extension FixedWidthInteger {
    init(from asn1: ASN1Object) throws {
        guard let data = asn1.data.primitive else {
            throw ASN1Error.malformedEncoding("ASN.1 object has incorrect tag \(asn1.tag)")
        }

        if data.isEmpty {
            throw ASN1Error.malformedEncoding("ASN.1 integer is empty")
        } else if data.count == 1 {
            //
        } else if (data[0] == 0 && data[1] & 0x80 == 0) || (data[0] == 0xFF && data[1] & 0x80 == 0x80) {
            // note that the latter check may fail with certificates from CAs that
            // read 8 bytes of RNG into a buffer and tag with [UNIVERSAL INTEGER]
            // for serialNumber. so we may need to remove this check.
            throw ASN1Error.malformedEncoding("ASN.1 integer is not minimally encoded")
        }

        // FIXME: can FixedWidthInteger be larger than platform integer?
        if Self.isSigned {
            guard let value = data.asn1integer,
                  let fixedWidthInteger = Self(exactly: value) else {
                throw ASN1Error.malformedEncoding("Integer encoded in \(asn1) is too large")
            }
            self = fixedWidthInteger
        } else {
            let slice: Data

            if data[0] & 0x80 == 0x80 {
                throw ASN1Error.malformedEncoding("Integer encoded in \(asn1) is negative")
            } else if data[0] == 0 {
                slice = data[1 ..< data.count]
            } else {
                slice = data
            }

            guard let value = slice.unsignedIntValue,
                  let fixedWidthInteger = Self(exactly: value) else {
                throw ASN1Error.malformedEncoding("Integer encoded in \(asn1) is too large")
            }
            self = fixedWidthInteger
        }
    }
}

extension FixedWidthInteger {
    func asn1encode(tag: ASN1DecodedTag?) throws -> ASN1Object {
        let fixedWidthInteger: (any FixedWidthInteger & ASN1EncodableType)?

        fixedWidthInteger = Self.isSigned ? Int(exactly: self) : UInt(exactly: self)
        guard let fixedWidthInteger else {
            throw ASN1Error.malformedEncoding("Integer \(self) is too large")
        }

        return try fixedWidthInteger.asn1encode(tag: tag)
    }
}
