# ASN1Codable

ASN1Codable aims to be an idiomatic and ergonomic ASN.1 encoder and decoder for Swift, supporting Codable conforming types. For the most part, the ASN.1 type system is isomorphic to Swift’s: for example, a `SEQUENCE` or `SET` is mapped to a Swift `struct`, a `CHOICE` or `ENUMERATED` type to an `enum`, `OPTIONAL` to `Optional`, etc.

Types can be defined directly in Swift, or generated from the ASN.1 using a translator that reads the output of [Heimdal's](https://github.com/heimdal/heimdal) `asn1compile` tool.

Source code is available [here](https://github.com/PADL/ASN1Codable).

## Architecture

ASN.1 encoding and decoding is presently provided by the [ASN1Kit](https://github.com/gematik/ASN1Kit) library, although this should be treated as an implementation detail.

ASN.1 types have additional metadata, most prominently tag numbers and tagging environments (such as `IMPLICIT` or `EXPLICIT`), which are not naturally represented as language types. (Other examples include size and value constraints.) ASN1Codable uses generic property wrappers and protocols conforming to `CodingKey` to attach this metadata to Swift types and declarations.

Features supported by ASN1Codable include:

* Integration with Heimdal ASN.1 compiler `asn1_compile` through `asn1json2swift` tool
* Open types (runtime determination of Swift type corresponding to ASN.1 type)
* Encoding and decoding of any Swift type that conforms to `Encodable` or `Decodable` (respectively)
* `AUTOMATIC` tagging
* Large integers using BigNumber
* Preservation of encoded value on decode in `_save` (for verifying signatures)

## Example

### SEQUENCE

The `SEQUENCE` below represents tags using the `ASN1ContextTagged` property wrapper.

```asn1
TBSCertificate  ::=  SEQUENCE  {
     version         [0]  Version OPTIONAL, -- EXPLICIT DEFAULT 1,
     serialNumber         CertificateSerialNumber,
     signature            AlgorithmIdentifier,
     issuer               Name,
     validity             Validity,
     subject              Name,
     subjectPublicKeyInfo SubjectPublicKeyInfo,
     issuerUniqueID  [1]  IMPLICIT BIT STRING -- UniqueIdentifier -- OPTIONAL,
                          -- If present, version shall be v2 or v3
     subjectUniqueID [2]  IMPLICIT BIT STRING -- UniqueIdentifier -- OPTIONAL,
                          -- If present, version shall be v2 or v3
     extensions      [3]  EXPLICIT Extensions OPTIONAL
                          -- If present, version shall be v3
}
```

becomes:

```swift
class TBSCertificate: Codable {
        @ASN1ContextTagged<ASN1TagNumber$0, ASN1ExplicitTagging, Version?>
        var version: Version? = nil
        var serialNumber: CertificateSerialNumber
        var signature: AlgorithmIdentifier
        var issuer: Name
        var validity: Validity
        var subject: Name
        var subjectPublicKeyInfo: SubjectPublicKeyInfo
        @ASN1ContextTagged<ASN1TagNumber$1, ASN1ImplicitTagging, BitString?>
        var issuerUniqueID: BitString? = nil
        @ASN1ContextTagged<ASN1TagNumber$2, ASN1ImplicitTagging, BitString?>
        var subjectUniqueID: BitString? = nil
        @ASN1ContextTagged<ASN1TagNumber$3, ASN1ExplicitTagging, Extensions?>
        var extensions: Extensions? = nil
}
```

### CHOICE

In cases where property cannot be used (such as enumerated types), it is more ergonomic to use a protocol conforming to `ASN1TagCodingKey`. This is possible asl ong as all fields in the type are tagged and share a tagging environment.

```asn1
GeneralName ::= CHOICE {
        otherName                       [0]     IMPLICIT OtherName,
        rfc822Name                      [1]     IMPLICIT IA5String,
        dNSName                         [2]     IMPLICIT IA5String,
--      x400Address                     [3]     IMPLICIT ORAddress,--
        directoryName                   [4]     IMPLICIT Name,
--      ediPartyName                    [5]     IMPLICIT EDIPartyName, --
        uniformResourceIdentifier       [6]     IMPLICIT IA5String,
        iPAddress                       [7]     IMPLICIT OCTET STRING,
        registeredID                    [8]     IMPLICIT OBJECT IDENTIFIER
}
```

becomes:

```swift
enum GeneralName: Codable {
        enum CodingKeys: Int, ASN1ImplicitTagCodingKey {
                case otherName = 0
                case rfc822Name = 1
                case dNSName = 2
                case directoryName = 4
                case uniformResourceIdentifier = 6
                case iPAddress = 7
                case registeredID = 8
        }

        case otherName(OtherName)
        case rfc822Name(IA5String<String>)
        case dNSName(IA5String<String>)
        case directoryName(Name)
        case uniformResourceIdentifier(IA5String<String>)
        case iPAddress(Data)
        case registeredID(ObjectIdentifier)
}
```

## Usage

You can use the encoder and decoder as follows:

```
let berData = try ASN1Encoder().encode(someValue)
let decodedValue = try ASN1Decoder().decode(AType.self, from: berData)
```

## Translator

The HeimASN1Translator framework reads the JSON AST representation emitted by `asn1_compile` and emits Swift source code. You will need to use the master branch of Heimdal if you wish to recompile the ASN.1 as the translator depends on some new features of the ASN.1 compiler.

Features include:

* Type maps, so a `SEQUENCE` can be mapped to a Swift or Objective-C class
* Type preservation (original DER saved in `_save` on decode)
* Type decoration (additional fields that are not encoded or decoded)
* `DEFAULT` values through getter synthesis
* User-specified additional conformances

## certutil

The source distribution includes a `certutil` tool which reads a PEM-encoded certificate and outputs a JSON representation, using the native Swift JSON encoder. It also can re-encode the certificate to ASN.1, useful for verifying round-tripping. The API `certutil` uses is provided by `Certificate.framework`, which is a C API modeled on the macOS Security framework. This tool and framework are incomplete and should be treated as a proof of concept only.

