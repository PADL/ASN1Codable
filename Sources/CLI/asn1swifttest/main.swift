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
import BigNumber

public struct TestStruct: Codable, ASN1TaggedType, ASN1SetCodable {
    public static var tagNumber: ASN1TagNumberRepresentable.Type? = ASN1TagNumber$10.self    

    
    /*
    @ASN1ContextTagged<ASN1TagNumber$0, ASN1DefaultTagging, Int>
    public var version: Int = 1

    @ASN1ContextTagged<ASN1TagNumber$1, ASN1DefaultTagging, Data>
    public var data: Data = Data()

    @ASN1ContextTagged<ASN1TagNumber$2, ASN1ImplicitTagging, BitString>
    var bitString = BitString([0x02, 0x03, 0xcc])
     */


    @ASN1ContextTagged<ASN1TagNumber$3, ASN1DefaultTagging, UTCTime<Date?>>
    @UTCTime
    public var utcTime: Date? = nil

    @ASN1ContextTagged<ASN1TagNumber$4, ASN1DefaultTagging, PrintableString<String>>
    @PrintableString
    public var foobar = "hello world"

    /*
    @ASN1ContextTagged<ASN1TagNumber$5, ASN1DefaultTagging, Array<String>>
    var anArray = ["Hello", "ASN.1", "Coding", "Kit"]

    @ASN1ContextTagged<ASN1TagNumber$6, ASN1DefaultTagging, Set<String>>
    var aSet = Set(["A", "Set"])
    */
    
    @ASN1ContextTagged<ASN1TagNumber$7, ASN1DefaultTagging, GeneralString<String?>>
    @GeneralString
    public var barbar: String? = "hello"
}

struct SignatureWrapper: Codable {
    @ASN1ContextTagged<ASN1TagNumber$1, ASN1DefaultTagging, Data>
    var signatureValue: Data = Data()
    
    var someString = "hello, world"
}

let ts = TestStruct()

struct TestType: Codable, ASN1ApplicationTaggedType {
    static var tagNumber: ASN1TagNumberRepresentable.Type? = ASN1TagNumber$10.self
    
    @ASN1ContextTagged<ASN1TagNumber$0, ASN1DefaultTagging, UInt>
    var someInteger: UInt = 0

    @ASN1ContextTagged<ASN1TagNumber$1, ASN1DefaultTagging, GeneralizedTime>
    @GeneralizedTime
    var someTime: Date = Date()
    
    @ASN1ContextTagged<ASN1TagNumber$2, ASN1DefaultTagging, PrintableString<String?>>
    @PrintableString
    var someString: String? = nil
}

var testValue = TestType()
testValue.someInteger = 1234
testValue.someTime = Date()
testValue.someString = "Hello"

//https://www.oss.com/asn1/resources/asn1-made-simple/asn1-quick-reference/asn1-tags.html
struct ImplicitAutoType: Codable, ASN1ContextTaggedType, ASN1ImplicitlyTaggedType {
    static var tagNumber: ASN1TagNumberRepresentable.Type? = ASN1TagNumber$0.self
    var name = "John"
    var age = 25
}

struct ExplicitAutoType: Codable, ASN1ContextTaggedType {
    static var tagNumber: ASN1TagNumberRepresentable.Type? = ASN1TagNumber$0.self
    var name = "John"
    var age = 25
}

enum AutoEnum: Codable {
    case C1(String)
    case C2(Int)
    case C3(ObjectIdentifier)
}

let autoEnum = AutoEnum.C3(ObjectIdentifier(rawValue: "1.2.3.4.5.6")!)
struct AutoType: Codable {
    var name = "John"
    var age = 25
    var oid = autoEnum
}



let automatic: AutoType = AutoType()


let foobar = Set(["Hello", "World!"])

public enum Color: Int, Codable {
    case red = 0
    case blue = 1
    case yellow = 2
}

let color = Color.blue

let setTest = Set(arrayLiteral: "surely this is the biggest value", "B", "a", "CCC")

func test() -> Void {
    let oi = try! ObjectIdentifier.from(string: "1.2.840.113549.1.1.11")
    do {
        let valueToEncode = ts
        
        print("Encoding value: \(String(describing: valueToEncode))")
        
        let asn1Encoder = ASN1Encoder()
        //asn1Encoder.taggingEnvironment = .automatic
        let berData = try asn1Encoder.encode(valueToEncode)
        print("BER: \(berData.toHexString())")
        
        dumpEncodedData(berData)
        
        let asn1Decoder = ASN1Decoder()
        asn1Decoder.taggingEnvironment = asn1Encoder.taggingEnvironment
        let value = try asn1Decoder.decode(type(of: valueToEncode), from: berData)
        
        print("Decoded value: \(String(describing: value))")
        //print("Extensions \(String(describing: value.tbsCertificate.extensions))")
        
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
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let jsonData = try String(data: encoder.encode(value), encoding: .utf8) {
            print("JSON: \(jsonData)")
        }
    } catch {
        print("Error \(error)")
    }
}