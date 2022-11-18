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
import BigNumber

extension BInt: ASN1DecodableType {
    public init(from asn1: ASN1Object) throws {
        guard let data = asn1.data.primitive, asn1.tag == .universal(.integer) else {
            throw ASN1Error.malformedEncoding("ASN.1 object has incorrect tag \(asn1.tag)")
        }
        
        if data.count == 0 {
            throw ASN1Error.malformedEncoding("ASN.1 integer is empty")
        } else if data.count == 1 {
            //
        } else if (data[0] == 0 && data[1] & 0x80 == 0) || (data[0] == 0xff && data[1] & 0x80 == 0x80) {
            // note that the latter check may fail with certificates from CAs that
            // read 8 bytes of RNG into a buffer and tag with [UNIVERSAL INTEGER]
            // for serialNumber. so we may need to remove this check.
            throw ASN1Error.malformedEncoding("ASN.1 integer is not minimally encoded")
        }

        if data.count > 0 && data[0] & 0x80 == 0x80 {
            var notBytes = [UInt8](repeating: 0, count: data.count)
            (0..<notBytes.count).forEach {
                notBytes[$0] = data[$0] ^ 0xff
            }
            self.init(bytes: notBytes)
            self += 1
            self *= -1
        } else {
            self.init(bytes: Array(data))
        }
    }
}

extension BInt: ASN1EncodableType {
    public func asn1encode(tag: ASN1DecodedTag?) throws -> ASN1Object {
        var bytes: [UInt8]
        
        if self.signum() < 0 {
            let value = self.magnitude - 1
            bytes = value.getBytes()

            (0..<bytes.count).forEach {
                bytes[$0] ^= 0xff
            }
            if bytes.count == 0 || bytes[0] & 0x80 == 0 {
                bytes.insert(0xff, at: 0)
            }
        } else if self.signum() == 0 {
            bytes = [0x00]
        } else {
            bytes = self.getBytes()
            if bytes.count > 0 && bytes[0] & 0x80 != 0 {
                bytes.insert(0x00, at: 0)
            }
        }

        return Data(bytes).asn1encode(tag: .universal(.integer))
    }
}

extension BInt: ASN1UniversalTagRepresentable {
    static var tagNo: ASN1Tag { return .integer }
}
