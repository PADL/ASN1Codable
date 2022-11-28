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
    enum CodingKeys: String, CodingKey {
        case name
        case dateOfBirth
    }

    var name: X690SampleName
    @ASN1ContextTagged<x690sample.ASN1TagNumber$0, ASN1Codable.ASN1ExplicitTagging, X690SampleDate>

    // FIXME: compiler needs to support nested wrapped initializers
    var dateOfBirth: X690SampleDate = .init(wrappedValue: VisibleString<String>(wrappedValue: ""))
}

struct X690SamplePersonnelRecord: Codable, Equatable, ASN1Codable.ASN1ApplicationTaggedType, ASN1Codable.ASN1ImplicitlyTaggedType {
    static let tagNumber: UInt = 0

    enum CodingKeys: String, CodingKey {
        case name
        case title
        case number
        case dateOfHire
        case nameOfSpouse
        case children
    }

    var name: X690SampleName
    @ASN1ContextTagged<x690sample.ASN1TagNumber$0, ASN1Codable.ASN1ExplicitTagging, VisibleString<String>>

    @VisibleString
    var title: String = ""

    var number: X690SampleEmployeeNumber
    @ASN1ContextTagged<x690sample.ASN1TagNumber$1, ASN1Codable.ASN1ExplicitTagging, X690SampleDate>

    // FIXME: compiler needs to support nested wrapped initializers
    var dateOfHire: X690SampleDate = .init(wrappedValue: VisibleString<String>(wrappedValue: ""))

    @ASN1ContextTagged<x690sample.ASN1TagNumber$2, ASN1Codable.ASN1ExplicitTagging, X690SampleName>
    var nameOfSpouse: X690SampleName = .init()

    @ASN1ContextTagged<x690sample.ASN1TagNumber$3, ASN1Codable.ASN1ImplicitTagging, [X690SampleChildInformation]>
    var children: [X690SampleChildInformation] = .init()
}

public enum x690sample {
    public enum ASN1TagNumber$0: ASN1TagNumberRepresentable {}
    public enum ASN1TagNumber$1: ASN1TagNumberRepresentable {}
    public enum ASN1TagNumber$2: ASN1TagNumberRepresentable {}
    public enum ASN1TagNumber$3: ASN1TagNumberRepresentable {}
}
