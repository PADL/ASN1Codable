import ASN1Codable
import Foundation

typealias X690SampleEmployeeNumber = ASN1ApplicationTagged<x690sample.ASN1TagNumber$2, ASN1Codable.ASN1ImplicitTagging, Int>

typealias X690SampleDate = ASN1ApplicationTagged<x690sample.ASN1TagNumber$3, ASN1Codable.ASN1ImplicitTagging, VisibleString<String>>

struct X690SampleName: Codable, Equatable, ASN1Codable.ASN1ApplicationTaggedType, ASN1Codable.ASN1ImplicitlyTaggedType {
    static let tagNumber: UInt = 1

    enum CodingKeys: String, CodingKey {
        case givenName
        case initial
        case familyName
    }

    @VisibleString
    var givenName: String = ""

    @VisibleString
    var initial: String = ""

    @VisibleString
    var familyName: String = ""
}

struct X690SampleChildInformation: Codable, Equatable, ASN1Codable.ASN1SetCodable {
    enum CodingKeys: String, CodingKey, ASN1MetadataCodingKey {
        case name
        case dateOfBirth

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case dateOfBirth:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            default:
                return nil
            }

            return metadata
        }
    }

    var name: X690SampleName
    var dateOfBirth: X690SampleDate = .init(wrappedValue: VisibleString<String>(wrappedValue: ""))
}

struct X690SamplePersonnelRecord: Codable, Equatable, ASN1Codable.ASN1ApplicationTaggedType, ASN1Codable.ASN1ImplicitlyTaggedType {
    static let tagNumber: UInt = 0

    enum CodingKeys: String, CodingKey, ASN1MetadataCodingKey {
        case name
        case title
        case number
        case dateOfHire
        case nameOfSpouse
        case children

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case title:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case dateOfHire:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case nameOfSpouse:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            case children:
                metadata = ASN1Metadata(tag: .taggedTag(3), tagging: .implicit)
            default:
                metadata = nil
            }

            return metadata
        }
    }

    var name: X690SampleName
    @VisibleString
    var title: String = ""
    var number: X690SampleEmployeeNumber
    var dateOfHire: X690SampleDate = .init(wrappedValue: VisibleString<String>(wrappedValue: ""))
    var nameOfSpouse: X690SampleName = .init()
    var children: [X690SampleChildInformation] = .init()
}

public enum x690sample {
    public enum ASN1TagNumber$0: ASN1TagNumberRepresentable {}
    public enum ASN1TagNumber$1: ASN1TagNumberRepresentable {}
    public enum ASN1TagNumber$2: ASN1TagNumberRepresentable {}
    public enum ASN1TagNumber$3: ASN1TagNumberRepresentable {}
}
