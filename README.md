# ASN1CodingKit

ASN1CodingKit is a Swift framework for encoding Codable types using ASN.1. It is intended to be the glue between an ASN.1 compiler that generates Swift types from an ASN.1 module, and [ASN1Kit](https://github.com/gematik/ASN1Kit) which provides the raw encoding.

Note that it is presently a work in progress: it is not ready for production (or even testing) use.

## Example

```swift
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
```

Note there are some limitations with property wrappers and optionals, particularly when the wrapper is nested. We may replace the property wrappers with a variation on CodingKey.

```
let berData = try ASN1Encoder().encode(testValue)
let decodedValue = try ASN1Decoder().decode(TestType.self, from: berData)
```
