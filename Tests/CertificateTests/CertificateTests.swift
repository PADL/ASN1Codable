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
import Algorithms

final class CertificateTests: XCTestCase {
    func test_encodeDecodeCertificate(_ base64EncodedCertificate: String) -> CertificateRef? {
        let data = Data(base64Encoded: base64EncodedCertificate,
                        options: .ignoreUnknownCharacters)
        XCTAssertNotNil(data)
        guard let data else { return nil }

        let cert = CertificateCreateWithData(kCFAllocatorDefault, data as CFData)

        XCTAssertNotNil(cert)
        guard let cert else { return nil }

        let reencoded = CertificateCopyDataReencoded(cert)
        XCTAssertNotNil(reencoded)
        guard let reencoded else { return nil }

        let chunks = String((reencoded as Data).base64EncodedString().chunks(ofCount: 64).joined(by: "\n"))
        XCTAssertEqual(data, reencoded as Data, chunks)

        return cert
    }

    func test_certificate_j() {
        let der = """
        MIIEajCCA1KgAwIBAgIBATANBgkqhkiG9w0BAQUFADBaMQswCQYDVQQGEwJKUDEN
        MAsGA1UECgwESlBLSTEpMCcGA1UECwwgUHJlZmVjdHVyYWwgQXNzb2NpYXRpb24g
        Rm9yIEpQS0kxETAPBgNVBAsMCEJyaWRnZUNBMB4XDTAzMTIyNzA1MDgxNVoXDTEz
        MTIyNjE0NTk1OVowWjELMAkGA1UEBhMCSlAxDTALBgNVBAoMBEpQS0kxKTAnBgNV
        BAsMIFByZWZlY3R1cmFsIEFzc29jaWF0aW9uIEZvciBKUEtJMREwDwYDVQQLDAhC
        cmlkZ2VDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANTnUmg7K3m8
        52vd77kwkq156euwoWm5no8E8kmaTSc7x2RABPpqNTlMKdZ6ttsyYrqREeDkcvPL
        yF7yf/I8+innasNtsytcTAy8xY8Avsbd4JkCGW9dyPjk9pzzc3yLQ64Rx2fujRn2
        agcEVdPCr/XpJygX8FD5bbhkZ0CVoiASBmlHOcC3YpFlfbT1QcpOSOb7o+VdKVEi
        MMfbBuU2IlYIaSr/R1nO7RPNtkqkFWJ1/nKjKHyzZje7j70qSxb+BTGcNgTHa1YA
        UrogKB+UpBftmb4ds+XlkEJ1dvwokiSbCDaWFKD+YD4B2s0bvjCbw8xuZFYGhNyR
        /2D5XfN1s2MCAwEAAaOCATkwggE1MA4GA1UdDwEB/wQEAwIBBjAPBgNVHRMBAf8E
        BTADAQH/MG0GA1UdHwRmMGQwYqBgoF6kXDBaMQswCQYDVQQGEwJKUDENMAsGA1UE
        CgwESlBLSTEpMCcGA1UECwwgUHJlZmVjdHVyYWwgQXNzb2NpYXRpb24gRm9yIEpQ
        S0kxETAPBgNVBAsMCEJyaWRnZUNBMIGDBgNVHREEfDB6pHgwdjELMAkGA1UEBhMC
        SlAxJzAlBgNVBAoMHuWFrOeahOWAi+S6uuiqjeiovOOCteODvOODk+OCuTEeMBwG
        A1UECwwV6YO96YGT5bqc55yM5Y2U6K2w5LyaMR4wHAYDVQQLDBXjg5bjg6rjg4Pj
        grjoqo3oqLzlsYAwHQYDVR0OBBYEFNQXMiCqQNkR2OaZmQgLtf8mR8p8MA0GCSqG
        SIb3DQEBBQUAA4IBAQATjJo4reTNPC5CsvAKu1RYT8PyXFVYHbKsEpGt4GR8pDCg
        HEGAiAhHSNrGh9CagZMXADvlG0gmMOnXowriQQixrtpkmx0TB8tNAlZptZWkZC+R
        8TnjOkHrk2nFAEC3ezbdK0R7MR4tJLDQCnhEWbg50rf0wZ/aF8uAaVeEtHXa6W0M
        Xq3dSe0XAcrLbX4zZHQTaWvdpLAIjl6DZ3SCieRMyoWUL+LXaLFdTP5WBCd+No58
        IounD9X4xxze2aeRVaiV/WnQ0OSPNS7n7YXy6xQdnaOU4KRW/Lne1EDf5IfWC/ih
        bVAmhZMbcrkWWcsR6aCPG+2mV3zTD6AUzuKPal8Y
        """

        let cert = self.test_encodeDecodeCertificate(der)
        guard let cert else { return }

        let cns = CertificateCopyCommonNames(cert)
        XCTAssertNil(cns)

        let serial = CertificateCopySerialNumberData(cert, nil)
        XCTAssertNotNil(serial)
        if let serial {
            XCTAssertEqual(serial as Data, Data([0x02, 0x01, 0x01]))
        }
    }

    func test_certificate_secp256r1TestCA() {
        let der = """
        MIIBuTCCAWCgAwIBAgIBATAKBggqhkjOPQQDAjA2MQswCQYDVQQGEwJTRTEQMA4G
        A1UECgwHSGVpbWRhbDEVMBMGA1UEAwwMQ0Egc2VjcDI1NnIxMCAXDTE5MDMyMjIy
        MjUyNVoYDzI1MTgxMTIxMjIyNTI1WjA2MQswCQYDVQQGEwJTRTEQMA4GA1UECgwH
        SGVpbWRhbDEVMBMGA1UEAwwMQ0Egc2VjcDI1NnIxMFkwEwYHKoZIzj0CAQYIKoZI
        zj0DAQcDQgAE5SuFK+KhglopQr1aMjl4ZEBaw4HYM2yVORyBOQWx3e8Pj90bFocE
        4gyS4P2V0YraxACsQgMp+s4e8/6gXPeMtqNdMFswHQYDVR0OBBYEFOtR3wCoaF9m
        8dWylzOdd5vfbwmDMB8GA1UdIwQYMBaAFOtR3wCoaF9m8dWylzOdd5vfbwmDMAwG
        A1UdEwQFMAMBAf8wCwYDVR0PBAQDAgEGMAoGCCqGSM49BAMCA0cAMEQCIF/JTbEv
        iuYcuREFzWgZ/AgfLe2sRwEgSy6UcAWOYllkAiApMzA3xKjaX1/hhkDGKZnHfcTM
        tRuM0FuTdO+e15ku8w==
        """

        let cert = self.test_encodeDecodeCertificate(der)
        guard let cert else { return }
    }
}
