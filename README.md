# ASN1Codable

ASN1Codable is an idiomatic, ergonomic, and somewhat opinionated framework for ASN.1 encoding and decoding Swift Codable types.

For the most part, the ASN.1 type system is isomorphic to Swift’s: for example, a `SEQUENCE` or `SET` is mapped to a Swift `struct`, a `CHOICE` or `ENUMERATED` type to an `enum`, `SEQUENCE OF` to `Array`, `SET OF` to `SET`, `OPTIONAL` to `Optional`, etc.

Types can be defined directly in Swift, or generated from the ASN.1 using a translator that reads the output of [Heimdal’s](https://github.com/heimdal/heimdal) `asn1_compile` tool.

Source code is available [here](https://github.com/PADL/ASN1Codable).

## Architecture

ASN.1 encoding and decoding is presently provided by the [ASN1Kit](https://github.com/gematik/ASN1Kit) library, although this should be treated as an implementation detail.

ASN.1 types have additional metadata, most prominently tag numbers and tagging environments (such as `IMPLICIT` or `EXPLICIT`), which have no natural representation in Swift. Presently ASN1Codable uses generic property wrappers and protocols to annotate Swift types with ASN.1 metadata, but this may change in the future (for example, when the `@runtimeMetadata` attribute is finished).

Generally we find it more ergonomic to attach ASN.1 metadata at the definition site, rather than out-of-band with a custom `CodingKey` or a separate schema. This allows existing Swift types to be encoded as ASN.1 without change. Having said that, using the ASN.1 translator will ideally render the metadata representation an implementation detail.

Features supported by ASN1Codable include:

* Integration with Heimdal ASN.1 compiler `asn1_compile` through `asn1json2swift` translator tool
* Open types (runtime determination of Swift type corresponding to ASN.1 type)
* Encoding and decoding of any Swift type that conforms to `Encodable` or `Decodable` (respectively)
* `AUTOMATIC` tagging
* Large integers using BigNumber
* Preservation of encoded value on decode in `_save` (for verifying signatures)

## Usage

You can use the encoder and decoder as follows:

```
let encodedValue = try ASN1Encoder().encode(1234)
let decodedValue = try ASN1Decoder().decode(Int.self, from: encodedValue)
```

## asn1json2swift

The HeimASN1Translator framework reads the JSON AST representation emitted by `asn1_compile` and emits Swift source code. (Note: you will need to use the master branch of Heimdal if you wish to recompile the ASN.1 as the translator depends on some new features of the ASN.1 compiler.)

Features include:

* Emitting types as `struct`, `class`, or `@objc class` (the default is `struct`, unless the type is preserved or self-referencing)
* Mapping of ASN.1 types to user defined types
* Propagation of preservation (`_save`) and decoration options
* `DEFAULT` values through getter synthesis
* User-specified additional conformances

There are some limitations, for example anonymous nested types are not supported, and there are some cases where property wrapper initializers are not correctly emitted. These are easily worked around.

The `asn1json2swift` tool is a driver for the framework.

## certutil

This repository includes `Certificate.framework`, a C API modeled on the macOS `Security.framework`, as a proof of concept. Included also is a `certutil` tool for reading a PEM-encoded certificate and outputting a JSON representation, along with the SAN and re-encoded DER. The Swift types are generated from `rfc2459.json` at build time, which in turn (if `/usr/local/heimdal/bin/asn1_compile` is present) is generated from `rfc2459.asn1`.

## Examples

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

In cases where property cannot be used (such as enumerated types), it is more ergonomic to use a protocol conforming to `ASN1TagCodingKey`. This is possible as long as all fields in the type are tagged and share a tagging environment.

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

