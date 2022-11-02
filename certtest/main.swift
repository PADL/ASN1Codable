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

import Foundation
import ASN1CodingKit

public struct TestStruct: Codable, ASN1TaggedType, ASN1EncodeAsSetType {
    public static var tagNumber: ASN1TagNumberRepresentable.Type? = ASN1TagNumber$10.self

    @ASN1ContextTagged<ASN1TagNumber$0, ASN1AutomaticTagging, Int>
    public var version: Int = 1

    @ASN1ContextTagged<ASN1TagNumber$1, ASN1AutomaticTagging, Data>
    public var data: Data = Data()
    
    @ASN1ContextTagged<ASN1TagNumber$2, ASN1ImplicitTagging, BitString>
    var bitString = BitString([0x02, 0x03, 0xcc])

    @ASN1ContextTagged<ASN1TagNumber$3, ASN1AutomaticTagging, UTCTime>
    @UTCTime
    public var utcTime = Date()

    @ASN1ContextTagged<ASN1TagNumber$4, ASN1AutomaticTagging, PrintableString<String>>
    @PrintableString
    public var foobar = "hello world"
    
    @ASN1ContextTagged<ASN1TagNumber$5, ASN1AutomaticTagging, Array<String>>
    var anArray = ["Hello", "ASN.1", "Coding", "Kit"]

    @ASN1ContextTagged<ASN1TagNumber$6, ASN1AutomaticTagging, Set<String>>
    var aSet = Set(["A", "Set"])

    /*

    @ASN1ContextTagged<ASN1TagNumber$2, ASN1AutomaticTagging, Data>
    public var something: Data = Data([0xff])
    
    
    @ASN1ContextTagged<ASN1TagNumber$4, ASN1AutomaticTagging, Data>
    var signatureValue: Data = Data([0x01, 0xff, 0x02, 0xcc])
    
    @ASN1ContextTagged<ASN1TagNumber$5, ASN1AutomaticTagging, Array<String>>
    var anArray = ["Hello", "ASN.1", "Coding", "Kit"]
    
     */
}

struct SignatureWrapper: Codable {
    @ASN1ContextTagged<ASN1TagNumber$1, ASN1AutomaticTagging, Data>
    var signatureValue: Data = Data()
    
    var someString = "hello, world"
}

let ts = TestStruct()

struct TestType: Codable, ASN1ApplicationTaggedType {
    static var tagNumber: ASN1TagNumberRepresentable.Type? = ASN1TagNumber$10.self
    
    /*
    @ASN1ContextTagged<ASN1TagNumber$0, Version?>
    var version: Version? = .rfc3280_version_1
    
    */

    

    @ASN1ContextTagged<ASN1TagNumber$3, ASN1AutomaticTagging, GeneralizedTime>
    @GeneralizedTime
    var gt = Date()
    
    @ASN1ContextTagged<ASN1TagNumber$5, ASN1AutomaticTagging, PrintableString<String?>>
    @PrintableString
    var value: String? = "hello world"
}

let foobar = Set(["Hello", "World!"])


func test() -> Void {
    let oi = try! ObjectIdentifier.from(string: "1.2.840.113549.1.1.11")
    let ai = AlgorithmIdentifier(algorithm: oi)
    let issuer = Name.rdnSequence(try! RDNSequence.parse(dn: "/2.5.4.6=AU/2.5.4.10=PADL Software Pty Ltd/2.5.4.3=PADL CA"))
    let subject = Name.rdnSequence(try! RDNSequence.parse(dn: "/2.5.4.6=AU/2.5.4.10=PADL Software Pty Ltd/2.5.4.3=Luke Howard"))
    let validity = Validity(notBefore: Time.utcTime(UTCTime(wrappedValue: Date.distantPast)),
                            notAfter: Time.utcTime(UTCTime(wrappedValue: Date.distantFuture)))
    var spki = SubjectPublicKeyInfo(algorithm: try! AlgorithmIdentifier(algorithm: ObjectIdentifier.from(string: "1.2.840.113549.1.1.1")))
    spki.subjectPublicKey = BitString([01, 02, 03])

    let t = TBSCertificate(serialNumber: 1234,
                           signature: ai,
                           issuer: issuer,
                           validity: validity,
                           subject: subject,
                           subjectPublicKeyInfo: spki)
    t.version = Version.rfc3280_version_3
        
    t.issuerUniqueID = BitString([01, 02, 03, 04, 05])
    //t.subjectUniqueID = BitString([0xff, 02, 03, 04, 05])
    let generalName = GeneralName.rfc822Name(ASN1ContextTagged(wrappedValue: "lukeh@padl.com"))
    let generalNames = [generalName]

    let inhibitAnyPolicy = Extension(extnID: InhibitAnyPolicyOID,
                                     critical: false,
                                     extnValue: SkipCerts(1))
    let subjectAltName = Extension(extnID: SubjectAltNameOID,
                                   critical: false,
                                   extnValue: generalNames)
    
    let extensions = [inhibitAnyPolicy, subjectAltName]
    t.extensions = extensions
    
    //let sw = SignatureWrapper(signatureValue: Data([0x01, 0x02, 0x03, 0x55, 0x66, 0xff]))
    //var tt = TestType()
    //let time = Time.utcTime(UTCTime(wrappedValue: Date()))

    var c = Certificate(tbsCertificate: t, signatureAlgorithm: ai)
    c.signatureValue = BitString([0x01, 0x02, 0x03, 0x55, 0x66, 0xff])
        
    do {
        let valueToEncode = c
        
        print("Encoding value: \(valueToEncode)")
        
        let berData = try ASN1Encoder().encode(valueToEncode)
        print("BER: \(berData.toHexString())")
        
        dumpEncodedData(berData)
        
        let decoder = ASN1Decoder()
        let value = try decoder.decode(type(of: valueToEncode), from: berData)
        
        print("Decoded value: \(value)")
        print("Extensions \(String(describing: value.tbsCertificate.extensions))")
        
        // reencode as JSON
        dumpJSONData(value)
    } catch {
        print("failed to encode or decode - \(error)")
        return
    }
}

test()

func dumpEncodedData(_ data: Data) {
    do {
        let asn1 = try ASN1Kit.ASN1Decoder.decode(asn1: data)
        print("ASN.1: \(asn1)")
    } catch {
        print("Error \(error)")
    }
}

func dumpJSONData(_ value: any Encodable) {
    do {
        if let jsonData = try String(data: JSONEncoder().encode(value), encoding: .utf8) {
            print("JSON: \(jsonData)")
        }
    } catch {
        print("Error \(error)")
    }
}
