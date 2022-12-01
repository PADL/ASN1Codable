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
import DataKit

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

    func test_certificate_proxy10_child_child_test() {
        let der = """
        MIIFezCCA2OgAwIBAgIJAIZ6hp81I2P5MA0GCSqGSIb3DQEBCwUAMEMxCzAJBgNV
        BAYTAlNFMRIwEAYDVQQDDAlUZXN0IGNlcnQxEDAOBgNVBAMMB3Byb3h5MTAxDjAM
        BgNVBAMMBWNoaWxkMCAXDTE5MDMyMjIyMjUxNloYDzI1MTgxMTIxMjIyNTE2WjBT
        MQswCQYDVQQGEwJTRTESMBAGA1UEAwwJVGVzdCBjZXJ0MRAwDgYDVQQDDAdwcm94
        eTEwMQ4wDAYDVQQDDAVjaGlsZDEOMAwGA1UEAwwFY2hpbGQwggIiMA0GCSqGSIb3
        DQEBAQUAA4ICDwAwggIKAoICAQDOIxKHoKGi1/5V21RKfDqag54mjcz/ye0NvVHq
        QKXJ4I8EVZyP7fwtl4ElcZ0GyHhqetXsulqgzuoGns5eCAq9mMkX4+3/EXvy0lyz
        rVa+K5ysq6rsUMg7LPpiWA6RM3YYahNedzk3gsRghJ8q0vbvpTzNZQ1A+IOY1kdX
        AeqyBqUT6kLycPYzU/eL2WzVe6pTRt1p2LKckDjxCKJI1ocYhWrdFhbB9YduvEVp
        IRTINGXGvTpk8ZwzvgUQk1BmeGc1qqnmY+/wEEfpu1OZD2+5rJWQ7pSyB1jnMBxq
        mTc5jkrMkzJX9F5JleVY9+bKZcBGu34mmAa4vXfwQOnM2HXAvjw3DJGlZCuNKExs
        Ji9RyZcbe1NZqlBkp9l79cnlqURV6HftFFTyBNloEaNdzi81rYiMlxEoHEHqjLvo
        9HCNV90WDDHPxDG+iOKyY6OAZ/QtjGEAjizp1NYHYkvTG3PzVvqQCsNF4iWzksQY
        3M0OgyDybskOxvUN0NzDrF7Zw0+SqBSnYGWokVoghzQHMQHEOv/gYvrdw4kGs5Db
        RXPfiYKJSPlsFgi0zXpZgm8Br2GxEW6ZfADaK/eONC6FW2W4aL9oqC8XyV2kYi/v
        69G+UeULhVELL4bsUf0moPELFpuwyShHqfQ4l5Us5m66zxc/I0ekz2N66mWv/WQ9
        LNJBBwIDAQABo2AwXjAJBgNVHRMEAjAAMAsGA1UdDwQEAwIF4DAdBgNVHQ4EFgQU
        W8uH0Ungtk49Eykz3IE+8z536hswJQYIKwYBBQUHAQ4BAf8EFjAUAgEKMA8GCCsG
        AQUFBxUABANmb28wDQYJKoZIhvcNAQELBQADggIBAAJxESHv3qYUiqzpmWI13Bbe
        v9UqS/Le+WmWosv7JfbBV/aL9T2FF0uw/sMojKxxs88wfipYAaf7Or92JBlaSyt0
        YMhmhW7+miLEoWqeKkRfBx0q5IHvtmQMpNjDxA9uTXJW0U6FIyhVxXRte/3x4owk
        KUfq5P43ErPMEVipaM0ns2y4+d9WimFtUY/52l/NqH84pwgP/2JuNYtRaOZ5pjyO
        //zSUpiDbyE1OCeBG2b+YqKwDnCdxdqj0pZps/1fLieBr89GbS4SEMlqRgqN6LxO
        XHkfS3frkD87l32zTuQnhD8vxKU01Kr85t6CPL+FIUhjUCxG3Tll8Z+coxgZp8IX
        bjpyJfEx9834UqA3EDKpcuh3vndvov0nXe5XnxpmYevuCpd5fIjnbAdimFMshni7
        WhW+9HzKGTAKqaGXqRyEsPybm6Psw6F60p5Kbr9X8/+WM8j3mReQI4n1yKfW25kR
        HlqLPmwrJUOGDsf2NV0kYg/8Zd+D5uT02LUKQPh5gd/9X/vm/YNJfmLvkK9V0yI9
        5U6nxRe+kQDreWSpP0mS2Bl3o/mOKDwinn4zZLU3IStrvhoVEo9LeIuehsul8zpk
        57x1zHsKwviywBdAeJOXglQRhGhy76+jcN6Ii5rx6Na7uSlTSQqyz23bXfK8BcJr
        TpIzMZLfa2s8faTjnjAD
        """

        let cert = self.test_encodeDecodeCertificate(der)
        guard let cert else { return }

        let ku = CertificateGetKeyUsage(cert)
        let expectedKu = KeyUsage(rawValue: 7)
        XCTAssertEqual(ku, expectedKu)

        let cns = CertificateCopyCommonNames(cert)
        XCTAssertNotNil(cns)
        guard let cns else { return }

        XCTAssertEqual(cns, ["Test cert", "proxy10", "child", "child"] as CFArray)
    }

    func test_certificate_component_attributes() {
        let der = """
        MIICKDCCAc+gAwIBAgIPAIBKhGmXPWDtVkLuNurIMAoGCCqGSM49BAMCMFkx
        FjAUBgNVBAMMDUJhdHRlcnkgQ0EgTTExFTATBgNVBAsMDENvbXBvbmVudCBD
        QTETMBEGA1UECgwKQXBwbGUgSW5jLjETMBEGA1UECAwKQ2FsaWZvcm5pYTAe
        Fw0yMTA3MTMwNzAwNTBaFw0zMTA3MTEwOTAwNTBaMFwxCzAJBgNVBAYTAlVT
        MRMwEQYDVQQKDApBcHBsZSBJbmMuMRMwEQYDVQQLDApDb21wb25lbnRzMSMw
        IQYDVQQDDBpGUTExMjU2MDA4ODFDQ0YxUC1FMUQxNzkxOTBZMBMGByqGSM49
        AgEGCCqGSM49AwEHA0IABPQHboMdkrGmf0GXmGTalsptTZMsZ3FZhKeErzdh
        Nifuw37TtdZX+AOxBpmvHID0XfMPJUHRwXq6zshHDuGwBJmjdzB1MC0GCSqG
        SIb3Y2QGEQQgDB4xNDo5ZDo5OTo4MToxZDpkZi8xOTIuMTY4LjAuMjMwFgYJ
        KoZIhvdjZAsDBAkwB7+HaQMBAQAwFwYJKoZIhvdjZAsBAQH/BAdCYXR0ZXJ5
        MBMGCSqGSIb3Y2QLAgQGMjc4ZDQ2MAoGCCqGSM49BAMCA0cAMEQCIFZAYFnQ
        MsLd+8Jjg7mdccd2gl+y+pwWtycFOv2ZFPO7AiA+3/vRdTJBNTdYB6aOCdZe
        VybGXfesalKvuTn4l8VKsg==
        """

        let cert = self.test_encodeDecodeCertificate(der)
        guard let cert else { return }

        let cns = CertificateCopyCommonNames(cert)
        XCTAssertNotNil(cns)
        guard let cns else { return }

        XCTAssertEqual(cns, ["FQ1125600881CCF1P-E1D17919"] as CFArray)

        let serial = CertificateCopySerialNumberData(cert, nil)
        let expectedSerial = try! Data(hex: "020F00804A8469973D60ED5642EE36EAC8")

        XCTAssertNotNil(serial)
        if let serial {
            XCTAssertEqual(serial as Data, expectedSerial)
        }

        let components = CertificateCopyComponentAttributes(cert)
        XCTAssertEqual(components, [1001: 0] as CFDictionary)
    }

    func test_certificate_kdc() {
        let der = """
        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
        """

        let cert = self.test_encodeDecodeCertificate(der)
        guard let cert else { return }

        let cns = CertificateCopyCommonNames(cert)
        XCTAssertNotNil(cns)
        XCTAssertEqual(cns!, ["kdc"] as CFArray)

        let princs = CertificateCopyNTPrincipalNames(cert)
        XCTAssertNotNil(princs)
        XCTAssertEqual(princs!, ["krbtgt/TEST.H5L.SE@TEST.H5L.SE"] as CFArray)

        let props = CertificateCopyLegacyProperties(cert)
        XCTAssertNotNil(props)
        XCTAssertEqual(props!.valueForKey("Version"), "2" as NSString)
    }

    func test_certificate_pkinit() {
        let der = """
        MIIDcDCCAVigAwIBAgIBBzANBgkqhkiG9w0BAQUFADAqMRswGQYDVQQDDBJoeDUw
        OSBUZXN0IFJvb3QgQ0ExCzAJBgNVBAYTAlNFMCAXDTE5MDMyMjIyMjUwNloYDzI1
        MTgxMTIxMjIyNTA2WjAhMQswCQYDVQQGEwJTRTESMBAGA1UEAwwJcGtpbml0LWVj
        MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEwCuO8wzDG4iU605qEvL7Y5l3ohN6
        Fs5I3Eiag5FeqbirF3eUrlUJjWlKpKhrdxIB+zxvzbHjAr5jsUONj9+MdaNzMHEw
        CQYDVR0TBAIwADALBgNVHQ8EBAMCBeAwHQYDVR0OBBYEFHebdEt1kFDOIMMAm6Uj
        92mox8w0MDgGA1UdEQQxMC+gLQYGKwYBBQICoCMwIaANGwtURVNULkg1TC5TRaEQ
        MA6gAwIBAaEHMAUbA2JhcjANBgkqhkiG9w0BAQUFAAOCAgEAcAK4Ew/ZK3rpQlyC
        ap3q+FHcqS5n7MPLZ0j+ar1YhmfCH9Sg3H0XQZON4GdgAWDMNB8OsPybX/bPkSuj
        7ChbgP8xIRRbPKJcazsylN6rA9lBcMFPTklNY4+ai74Uh7DfvGSD4ZnO5ncSWkPj
        O9fpEF5oNjjeiMJ4r5ejok6/qS3hmPSaNey0KnAYCZn/gPtzSXVHVDF64UMoS1Nx
        gZJMQtubUjitkEfbTtp1bzcUzlZuBtBAjt/xcSOY7rRDt3c6HKWjbz7TX4YLbdS4
        Si6K4NfSdV/KvJzi2LkEv+yKHngo9RNznN0sEHNVz0CWjYq0HHm9qgHest7EMAQR
        r9X7yyhEJQKrs2giAhuZsZbr9/OtbjJ2Z767eLxGmhyzjmY568vYdsgG5Xke8PpU
        P6Hq/2Do+1XZHEc652ffyGkd0ZpWlisBea0i8no75r4yhJrjUNuJacE+GQnVszws
        CJCLk6o5rkiQ7M95PRWRhj44DgqZsdl4FFkXRMB2cKB6kmQqYASqzmux1cE76BtY
        b33d3JBJVeE3Wnt1idoIwaUzyfkNSh0I4Ki+Pw6i4BBxklD4dTOYfL7JL8h8shmU
        FFkLHMq8NP8DpDzwvazI9mOPWdPrZemWmyGplKd9/t1izXdialg43mNMDMPqCU9q
        gHYHWboV0rTBRh4RUFu+jY4hTng=
        """

        let cert = self.test_encodeDecodeCertificate(der)
        guard let cert else { return }

        let cns = CertificateCopyCommonNames(cert)
        XCTAssertNotNil(cns)
        XCTAssertEqual(cns!, ["pkinit-ec"] as CFArray)

        let princs = CertificateCopyNTPrincipalNames(cert)
        XCTAssertNotNil(princs)
        XCTAssertEqual(princs!, ["bar@TEST.H5L.SE"] as CFArray)

        let props = CertificateCopyLegacyProperties(cert)
        XCTAssertNotNil(props)
        XCTAssertEqual(props!.valueForKey("Version"), "2" as NSString)
    }
}

extension CFArray {
    func valueForKey(_ key: String) -> NSObject? {
        guard let array = self as? [[String: NSObject]] else { return nil }
        return array.first { $0["key"] == key as NSString }?["value"]
    }
}
