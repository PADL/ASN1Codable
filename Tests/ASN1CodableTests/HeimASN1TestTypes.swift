/// HeimASN1Translator generated 2022-11-26 11:52:16 +0000
/// asn1json2swift translate --conform-type Name:Hashable,Name:Equatable,Foo:Hashable --map-type DirectoryString:String,Certificate:@class --input
/// defines ASN.1 module TEST with explicit tagging
/// imports ASN.1 module heim

import ASN1Codable
import Foundation
import AnyCodable
import BigNumber

typealias TESTuint32 = Swift.UInt32

typealias TESTuint64 = Swift.UInt64

typealias TESTint64 = Swift.Int64

typealias TESTInteger = Swift.Int32

typealias TESTInteger2 = ASN1ContextTagged<TEST.ASN1TagNumber$4, ASN1Codable.ASN1ImplicitTagging, TESTInteger>

typealias TESTInteger3 = ASN1ContextTagged<TEST.ASN1TagNumber$5, ASN1Codable.ASN1ImplicitTagging, TESTInteger2>

typealias TESTCONTAINING = Data

typealias TESTENCODEDBY = Data

var testDer: ObjectIdentifier = ASN1Kit.ObjectIdentifier(rawValue: "2.1.2.1")!

typealias testContainingEncodedBy = Data

typealias testContainingEncodedBy2 = Data

var testValue1: Int = 1

typealias testUserConstrained = Data

typealias TESTOSSize1 = Data

typealias TESTBitString = ASN1RawRepresentableBitString<_TESTBitString>
struct _TESTBitString: OptionSet, Codable {
    var rawValue: UInt32

    init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    static let zero = _TESTBitString(rawValue: 1 << 0)
    static let eight = _TESTBitString(rawValue: 1 << 8)
    static let thirtyone = _TESTBitString(rawValue: 1 << 31)
}


typealias TESTBitString64 = ASN1RawRepresentableBitString<_TESTBitString64>
struct _TESTBitString64: OptionSet, Codable {
    var rawValue: UInt64

    init(rawValue: UInt64) {
        self.rawValue = rawValue
    }

    static let zero = _TESTBitString64(rawValue: 1 << 0)
    static let eight = _TESTBitString64(rawValue: 1 << 8)
    static let thirtyone = _TESTBitString64(rawValue: 1 << 31)
    static let thirtytwo = _TESTBitString64(rawValue: 1 << 32)
    static let sixtythree = _TESTBitString64(rawValue: 1 << 63)
}



typealias TESTMechType = ObjectIdentifier

var id_test_default: ObjectIdentifier = ASN1Kit.ObjectIdentifier(rawValue: "1.2.3.4")!

struct TESTOutOfOrderBar: Codable {
    enum CodingKeys: String, CodingKey {
        case aMember
    }

    var aMember: BigNumber.BInt
}

struct TESTOutOfOrderFoo: Codable {
    enum CodingKeys: String, CodingKey {
        case bar
    }

    var bar: TESTOutOfOrderBar
}

struct TESTDefault: Codable {
    enum CodingKeys: String, CodingKey {
        case _name = "name"
        case _version = "version"
        case _maxint = "maxint"
        case _works = "works"
    }

    @UTF8String
    var _name: String?
    var name: String {
        get { return self._name ?? "Heimdal" }
        set { self._name = newValue }
    }
    @ASN1ContextTagged<TEST.ASN1TagNumber$0, ASN1Codable.ASN1ExplicitTagging, TESTuint32?>
    var _version: TESTuint32?
    var version: TESTuint32 {
        get { return self._version ?? 8 }
        set { self._version = newValue }
    }
    var _maxint: TESTuint64?
    var maxint: TESTuint64 {
        get { return self._maxint ?? 9223372036854775807 }
        set { self._maxint = newValue }
    }
    var _works: Bool?
    var works: Bool {
        get { return self._works ?? true }
        set { self._works = newValue }
    }
}

struct TESTLargeTag: Codable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case foo = 127
        case bar = 128
    }

    var foo: Swift.Int32
    var bar: Swift.Int32
}

struct TESTSeq: Codable {
    enum CodingKeys: String, CodingKey {
        case tag0
        case tag1
        case tagless
        case tag3
    }

    @ASN1ContextTagged<TEST.ASN1TagNumber$0, ASN1Codable.ASN1ExplicitTagging, Swift.Int32>
    var tag0: Swift.Int32 = Swift.Int32()
    @ASN1ContextTagged<TEST.ASN1TagNumber$1, ASN1Codable.ASN1ExplicitTagging, TESTLargeTag>
    var tag1: TESTLargeTag = TESTLargeTag(foo: 0, bar: 0)
    var tagless: Swift.Int32
    @ASN1ContextTagged<TEST.ASN1TagNumber$2, ASN1Codable.ASN1ExplicitTagging, Swift.Int32>
    var tag3: Swift.Int32 = Swift.Int32()
}

enum TESTChoice1: Codable, ASN1Codable.ASN1ExtensibleType {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case i1 = 1
        case i2 = 2
    }

    case i1(Swift.Int32)
    case i2(Swift.Int32)
}

enum TESTChoice2: Codable, ASN1Codable.ASN1ExtensibleType {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case i1 = 1
    }

    case i1(Swift.Int32)
}



struct TESTImplicitInner: Codable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case foo = 127
    }

    var foo: Swift.Int32
}

struct TESTImplicit: Codable {
    enum CodingKeys: Int, ASN1ImplicitTagCodingKey {
        case ti1 = 0
        case ti2 = 1
        case ti3 = 2
    }

    var ti1: Int
    var ti2: TESTImplicitInner
    var ti3: Int
}

struct TESTImplicit2: Codable {
    enum CodingKeys: Int, ASN1ImplicitTagCodingKey {
        case ti1 = 0
        case ti3 = 2
        case ti4 = 51
    }

    var ti1: TESTInteger
    var ti3: TESTInteger3
    var ti4: TESTInteger?
}

enum TESTImplicit3Inner: Codable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case i1 = 1
    }

    case i1(Swift.Int32)
}

enum TESTImplicit3: Codable {
    enum CodingKeys: Int, ASN1ImplicitTagCodingKey {
        case ti1 = 0
        case ti2 = 5
    }

    case ti1(Int)
    case ti2(TESTImplicit3Inner)
}

enum TESTImplicit4: Codable {
    enum CodingKeys: Int, ASN1ImplicitTagCodingKey {
        case ti1 = 0
        case ti2 = 5
    }

    case ti1(Int)
    case ti2(TESTChoice2)
}

struct TESTAllocInner: Codable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case ai = 0
    }

    var ai: TESTInteger
}

struct TESTAlloc: Codable {
    enum CodingKeys: String, CodingKey {
        case tagless
        case three
        case tagless2
    }

    var tagless: TESTAllocInner?
    @ASN1ContextTagged<TEST.ASN1TagNumber$1, ASN1Codable.ASN1ExplicitTagging, Swift.Int32>
    var three: Swift.Int32 = Swift.Int32()
    var tagless2: AnyCodable?
}

struct TESTOptional: Codable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case zero = 0
        case one = 1
    }

    var zero: Swift.Int32?
    var one: Swift.Int32?
}

typealias TESTSeqOf = Array<TESTInteger>

typealias TESTSeqSizeOf1 = Array<TESTInteger>

typealias TESTSeqSizeOf2 = Array<TESTInteger>

typealias TESTSeqSizeOf3 = Array<TESTInteger>

typealias TESTSeqSizeOf4 = Array<TESTInteger>

struct TESTSeqOf2: Codable {
    enum CodingKeys: String, CodingKey {
        case strings
    }

    var strings: Array<GeneralString<String>>
}

struct TESTSeqOf3: Codable {
    enum CodingKeys: String, CodingKey {
        case strings
    }

    var strings: Array<GeneralString<String>>?
}

struct TESTPreserve: Codable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case zero = 0
        case one = 1
    }

    var zero: TESTInteger
    var one: TESTInteger
}

typealias TESTMechTypeList = Array<TESTMechType>

public struct TESTExtension: Codable, ASN1Codable.ASN1ObjectSetOctetStringCodable {
    public static let knownTypes: [AnyHashable : Codable.Type] = [
        id_test_default : TESTDefault.self,
    ]

    enum CodingKeys: String, CodingKey {
        case extnID
        case _critical = "critical"
        case extnValue
    }

    @ASN1ObjectSetType
    var extnID: ObjectIdentifier
    var _critical: Bool?
    var critical: Bool {
        get { return self._critical ?? false }
        set { self._critical = newValue }
    }
    @ASN1ObjectSetValue
    var extnValue: (any Codable)?
}

struct TESTExtensible: Codable {
    enum CodingKeys: String, CodingKey {
        case version
        case extensions
    }

    var version: BigNumber.BInt
    var extensions: Array<TESTExtension>
}

struct my_vers {
    var v: Int
}

struct TESTDecorated: Codable {
    var version2: TESTuint32?
    var version3 = my_vers(v: 0)
    var privthing: Any?

    enum CodingKeys: String, CodingKey {
        case version
    }

    var version: TESTuint32
}

struct TESTNotDecorated: Codable {
    enum CodingKeys: String, CodingKey {
        case version
    }

    var version: TESTuint32
}

enum TESTDecoratedChoice: Codable {
    case version(TESTuint32)
}

enum TESTNotDecoratedChoice: Codable {
    case version(TESTuint32)
}

public enum TEST {
    public enum ASN1TagNumber$0: ASN1TagNumberRepresentable {}
    public enum ASN1TagNumber$1: ASN1TagNumberRepresentable {}
    public enum ASN1TagNumber$2: ASN1TagNumberRepresentable {}
    public enum ASN1TagNumber$3: ASN1TagNumberRepresentable {}
    public enum ASN1TagNumber$4: ASN1TagNumberRepresentable {}
    public enum ASN1TagNumber$5: ASN1TagNumberRepresentable {}
}
