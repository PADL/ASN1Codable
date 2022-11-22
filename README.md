# ASN1Codable

ASN1Codable is a Swift framework for encoding Codable types using ASN.1. The types can either be defined directly in Swift, or they can be generated from the ASN.1 using a translator that reads the output of [Heimdal's](https://github.com/heimdal/heimdal) `asn1compile` tool. The underlying ASN.1 encoding is provided by the [ASN1Kit](https://github.com/gematik/ASN1Kit) library.

## Example

```asn1
AttributeType ::= OBJECT IDENTIFIER

--- DirectoryString is normally a CHOICE, but we can explicitly
--- map it to a String with the --map-type option to asn1json2swift

AttributeTypeAndValue ::= SEQUENCE {
        type    AttributeType,
        value   DirectoryString
}
```

becomes:

```swift
typealias AttributeType = ObjectIdentifier

typealias DirectoryString = String

struct AttributeTypeAndValue: Codable, Equatable, Hashable {
        enum CodingKeys: String, CodingKey {
                case type
                case value
        }

        var type: AttributeType
        var value: DirectoryString
}
```

You can use the encoder and decoder as follows:

```
let berData = try ASN1Encoder().encode(someValue)
let decodedValue = try ASN1Decoder().decode(AType.self, from: berData)
```

The source distribution includes a `cert2json` tool which reads a PEM-encoded certificate and outputs a JSON representation, using the native Swift JSON encoder. It also can re-encode the certificate to ASN.1, useful for verifying round-tripping. The API `cert2json` uses is provided by `Certificate.framework`, which is a C API modeled on the macOS Security framework and implemented in Swift using ASN1Codable.

The RFC2459 ASN.1 is based on Heimdal's and was translated from the JSON using the `asn1json2swift` tool. You will need to use the master branch of Heimdal if you wish to recompile the ASN.1 as the translator depends on some new features of the ASN.1 compiler.

