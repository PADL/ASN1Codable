# ASN1Codable

ASN1Codable is a Swift framework for ASN.1 encoding and decoding Swift Codable types.

For the most part, the ASN.1 type system is isomorphic to Swift’s, for example:

* `SEQUENCE` or `SET` is mapped to a `struct`
* `CHOICE` or `ENUMERATED` type to an `enum`
* `SEQUENCE OF` to `Array`
* `SET OF` to `SET`
* `OPTIONAL` to `Optional`

Types can be defined directly in Swift, or generated from the ASN.1 using a translator that reads the output of [Heimdal’s](https://github.com/heimdal/heimdal) `asn1_compile` tool.

Features supported by ASN1Codable include:

* Integration with Heimdal ASN.1 compiler `asn1_compile` through `asn1json2swift` translator tool
* Open types (runtime determination of Swift type corresponding to ASN.1 type)
* Encoding and decoding of any Swift type that conforms to `Encodable` or `Decodable` (respectively)
* `AUTOMATIC` tagging
* Large integers using BigNumber
* Preservation of encoded value on decode in `_save` (for verifying signatures)

## Architecture

ASN.1 encoding and decoding is presently provided by the [ASN1Kit](https://github.com/gematik/ASN1Kit) library, although this should be treated as an implementation detail.

ASN.1 types have additional metadata, most prominently tag numbers and tagging environments (such as `IMPLICIT` or `EXPLICIT`), which have no natural representation in Swift. Presently ASN1Codable uses a variety of language features to associate ASN.1 metadata with Swift types.

Generally this involves using a custom `CodingKey` type that either directly encodes the tag number (for types with uniform tagging) or provides a function mapping a key to metadata. There are some cases, such as type aliases and enumerated types with non-uniform tagging, where generic wrappers are used instead. For universal types such as integers and strings, ASN1Codable uses Swift type metadata.

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

The `SEQUENCE` below can be represented using the `ASN1ContextTagged` property wrapper.

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

Ergonomics are slightly improved by avoiding the property wrapper and instead using a specialised CodingKeys. This format exposes ASN1Kit internal types (specifically `ASN1DecodedTag`) and is such not guaranteed to be stable across releases; rather, it is only to be used by the `asn1json2swift` translator.

```swift
struct TBSCertificate: Codable {
    enum CodingKeys: ASN1MetadataCodingKey {
        case version
        case serialNumber
        case signature
        case issuer
        case validity
        case subject
        case subjectPublicKeyInfo
        case issuerUniqueID
        case subjectUniqueID
        case extensions

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case version:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case issuerUniqueID:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .implicit)
            case subjectUniqueID:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .implicit)
            case extensions:
                metadata = ASN1Metadata(tag: .taggedTag(3), tagging: .explicit)
            default:
                metadata = nil
            }

            return metadata
        }
    }

    var version: Version?
    var serialNumber: CertificateSerialNumber
    var signature: SignatureAlgorithmIdentifier
    var issuer: Name
    var validity: Validity
    var subject: Name
    var subjectPublicKeyInfo: SubjectPublicKeyInfo
    var issuerUniqueID: BitString?
    var subjectUniqueID: BitString?
    var extensions: Extensions?
}
```

### CHOICE

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

becomes either:

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

or:

```swift
enum GeneralName: Codable {
    enum CodingKeys: CaseIterable, ASN1MetadataCodingKey {
        case otherName
        case rfc822Name
        case dNSName
        case directoryName
        case uniformResourceIdentifier
        case iPAddress
        case registeredID

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case otherName:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .implicit)
            case rfc822Name:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .implicit)
            case dNSName:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .implicit)
            case directoryName:
                metadata = ASN1Metadata(tag: .taggedTag(4), tagging: .explicit)
            case uniformResourceIdentifier:
                metadata = ASN1Metadata(tag: .taggedTag(6), tagging: .implicit)
            case iPAddress:
                metadata = ASN1Metadata(tag: .taggedTag(7), tagging: .implicit)
            case registeredID:
                metadata = ASN1Metadata(tag: .taggedTag(8), tagging: .implicit)
            }

            return metadata
        }
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

The former is a more compact representation that may be used with a uniform tagging environment (note that `directoryName` is defined as `IMPLICIT` in the ASN.1, but is promoted to `EXPLICIT` as it is a `CHOICE`; this is handled at runtime). It also has an API stability guarantee that the latter format does not.

