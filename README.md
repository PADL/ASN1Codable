# ASN1CodingKit

ASN1CodingKit is a Swift framework for encoding Codable types using ASN.1. The types can either be defined directly in Swift, or they can be generated from the ASN.1 using a translator that reads the output of [Heimdal's](https://github.com/heimdal/heimdal) `asn1compile` tool. The underlying ASN.1 encoding is provided by the [ASN1Kit](https://github.com/gematik/ASN1Kit) library.

Note that it is presently a work in progress: it is not ready for production (or even testing) use.

## Example

```asn1
DirectoryString ::= CHOICE {
        ia5String       IA5String,
        printableString PrintableString,
        universalString UniversalString,
        utf8String      UTF8String,
        bmpString       BMPString
}

AttributeValues ::= SET OF AttributeValue

Attribute ::= SEQUENCE {
        type    AttributeType,
        value   AttributeValues
}
```

becomes:

```swift
enum DirectoryString: Codable {
	case ia5String(IA5String<String>)
	case printableString(PrintableString<String>)
	case universalString(UniversalString<String>)
	case utf8String(UTF8String<String>)
	case bmpString(BMPString<String>)
}

typealias AttributeValues = Set<AttributeValue>

struct Attribute: Codable {
	enum CodingKeys: String, CodingKey {
		case type
		case value
	}

	var type: AttributeType
	var value: AttributeValues
}
```

You can use the encoder and decoder as follows:

```
let berData = try ASN1Encoder().encode(someValue)
let decodedValue = try ASN1Decoder().decode(AType.self, from: berData)
```
