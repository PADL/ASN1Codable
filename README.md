# ASN1Codable

ASN1Codable is a Swift framework for encoding Codable types using ASN.1. The types can either be defined directly in Swift, or they can be generated from the ASN.1 using a translator that reads the output of [Heimdal's](https://github.com/heimdal/heimdal) `asn1compile` tool. The underlying ASN.1 encoding is provided by the [ASN1Kit](https://github.com/gematik/ASN1Kit) library.

## Example

### SEQUENCE

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

The source distribution includes a `certutil` tool which reads a PEM-encoded certificate and outputs a JSON representation, using the native Swift JSON encoder. It also can re-encode the certificate to ASN.1, useful for verifying round-tripping. The API `certutil` uses is provided by `Certificate.framework`, which is a C API modeled on the macOS Security framework and implemented in Swift using ASN1Codable.

The RFC2459 ASN.1 is based on Heimdal's and was translated from the JSON using the `asn1json2swift` tool. You will need to use the master branch of Heimdal if you wish to recompile the ASN.1 as the translator depends on some new features of the ASN.1 compiler.

