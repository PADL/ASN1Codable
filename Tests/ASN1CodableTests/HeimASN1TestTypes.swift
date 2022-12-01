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

class TESTCircular: Codable, Equatable {
    static func == (lhs: TESTCircular, rhs: TESTCircular) -> Bool {
        lhs.name == rhs.name && lhs.next == rhs.next
    }

    var name: String
    var next: TESTCircular?
}

struct TESTDefault: Codable, Equatable {
    enum CodingKeys: String, ASN1MetadataCodingKey {
        case _name = "name"
        case _version = "version"
        case _maxint = "maxint"
        case _works = "works"

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case _name:
                metadata = nil
            case _version:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case _maxint:
                metadata = nil
            case _works:
                metadata = nil
            }

            return metadata
        }
    }

    @UTF8String
    var _name: String?
    var name: String {
        get { self._name ?? "Heimdal" }
        set { self._name = newValue }
    }

    var _version: TESTuint32?
    var version: TESTuint32 {
        get { self._version ?? 8 }
        set { self._version = newValue }
    }

    var _maxint: TESTuint64?
    var maxint: TESTuint64 {
        get { self._maxint ?? 9_223_372_036_854_775_807 }
        set { self._maxint = newValue }
    }

    var _works: Bool?
    var works: Bool {
        get { self._works ?? true }
        set { self._works = newValue }
    }
}

struct TESTLargeTag: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case foo = 127
        case bar = 128
    }

    var foo: Swift.Int32
    var bar: Swift.Int32
}

struct TESTSeq: Codable {
    enum CodingKeys: String, ASN1MetadataCodingKey {
        case tag0
        case tag1
        case tagless
        case tag3

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case tag0:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case tag1:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case tagless:
                metadata = nil
            case tag3:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .explicit)
            }

            return metadata
        }
    }

    var tag0: Swift.Int32 = .init()
    var tag1: TESTLargeTag = .init(foo: 0, bar: 0)
    var tagless: Swift.Int32
    var tag3: Swift.Int32 = .init()
}

enum TESTChoice1: Codable, Equatable, ASN1Codable.ASN1ExtensibleType {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case i1 = 1
        case i2 = 2
    }

    case i1(Swift.Int32)
    case i2(Swift.Int32)
}

enum TESTChoice2: Codable, Equatable, ASN1Codable.ASN1ExtensibleType {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case i1 = 1
    }

    case i1(Swift.Int32)
}

struct TESTImplicitInner: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case foo = 127
    }

    var foo: Swift.Int32
}

struct TESTImplicit: Codable, Equatable {
    enum CodingKeys: Int, ASN1ImplicitTagCodingKey {
        case ti1 = 0
        case ti2 = 1
        case ti3 = 2
    }

    var ti1: Int
    var ti2: TESTImplicitInner
    var ti3: Int
}

struct TESTImplicit2: Codable, Equatable {
    enum CodingKeys: Int, ASN1ImplicitTagCodingKey {
        case ti1 = 0
        case ti3 = 2
        case ti4 = 51
    }

    var ti1: TESTInteger
    var ti3: TESTInteger3
    var ti4: TESTInteger?
}

enum TESTImplicit3Inner: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case i1 = 1
    }

    case i1(Swift.Int32)
}

enum TESTImplicit3: Codable, Equatable {
    enum CodingKeys: Int, ASN1ImplicitTagCodingKey {
        case ti1 = 0
        case ti2 = 5
    }

    case ti1(Int)
    case ti2(TESTImplicit3Inner)
}

enum TESTImplicit4: Codable, Equatable {
    enum CodingKeys: Int, ASN1ImplicitTagCodingKey {
        case ti1 = 0
        case ti2 = 5
    }

    case ti1(Int)
    case ti2(TESTChoice2)
}

struct TESTAllocInner: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case ai = 0
    }

    var ai: TESTInteger
}

struct TESTAlloc: Codable, Equatable {
    enum CodingKeys: String, ASN1MetadataCodingKey {
        case tagless
        case three
        case tagless2

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case tagless:
                metadata = nil
            case three:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .explicit)
            case tagless2:
                metadata = nil
            }

            return metadata
        }
    }

    var tagless: TESTAllocInner?
    var three: Swift.Int32
    var tagless2: AnyCodable?
}

struct TESTOptional: Codable, Equatable {
    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case zero = 0
        case one = 1
    }

    var zero: Swift.Int32?
    var one: Swift.Int32?
}

typealias TESTSeqOf = [TESTInteger]

typealias TESTSeqSizeOf1 = [TESTInteger]

typealias TESTSeqSizeOf2 = [TESTInteger]

typealias TESTSeqSizeOf3 = [TESTInteger]

typealias TESTSeqSizeOf4 = [TESTInteger]

struct TESTSeqOf2: Codable, Equatable {
    enum CodingKeys: String, CodingKey {
        case strings
    }

    var strings: [GeneralString<String>]
}

// swiftlint:disable discouraged_optional_collection
struct TESTSeqOf3: Codable, Equatable {
    enum CodingKeys: String, CodingKey {
        case strings
    }

    var strings: [GeneralString<String>]?
}

// swiftlint:disable discouraged_optional_collection
struct TESTSeqOf4: Codable, Equatable {
    enum CodingKeys: String, ASN1MetadataCodingKey {
        case b1
        case b2
        case b3

        static func metadata(forKey key: Self) -> ASN1Metadata? {
            let metadata: ASN1Metadata?

            switch key {
            case b1:
                metadata = ASN1Metadata(tag: .taggedTag(0), tagging: .explicit)
            case b2:
                metadata = ASN1Metadata(tag: .taggedTag(1), tagging: .implicit)
            case b3:
                metadata = ASN1Metadata(tag: .taggedTag(2), tagging: .implicit)
            }

            return metadata
        }
    }

    struct B1: Codable, Equatable {
        var s1: Data
        var s2: Data
        var u1: TESTuint64
        var u2: TESTuint64
    }

    var b1: [B1]?

    struct B2: Codable, Equatable {
        var u1: TESTuint64
        var u2: TESTuint64
        var u3: TESTuint64
        var s1: Data
        var s2: Data
        var s3: Data
    }

    var b2: [B2]?

    struct B3: Codable, Equatable {
        var s1: Data
        var u1: TESTuint64
        var s2: Data
        var u2: TESTuint64
        var s3: Data
        var u3: TESTuint64
        var s4: Data
        var u4: TESTuint64
    }

    var b3: [B3]?
}

// swiftlint:disable discouraged_optional_collection
struct TESTSeqOf5: Codable, Equatable {
    struct B: Codable, Equatable {
        var u0: TESTuint64
        var s0: Data
        var u1: TESTuint64
        var s1: Data
        var u2: TESTuint64
        var s2: Data
        var u3: TESTuint64
        var s3: Data
        var u4: TESTuint64
        var s4: Data
        var u5: TESTuint64
        var s5: Data
        var u6: TESTuint64
        var s6: Data
        var u7: TESTuint64
        var s7: Data
    }

    var b: [B]?
}

class TESTPreserve: Codable, Equatable, ASN1PreserveBinary {
    static func == (lhs: TESTPreserve, rhs: TESTPreserve) -> Bool {
        lhs.zero == rhs.zero && lhs.one == rhs.one
    }

    enum CodingKeys: Int, ASN1ExplicitTagCodingKey {
        case zero = 0
        case one = 1
    }

    var _save: Data? = nil
    var zero: TESTInteger = 0
    var one: TESTInteger = 1
}

typealias TESTMechTypeList = [TESTMechType]

public struct TESTExtension: Codable, ASN1Codable.ASN1ObjectSetOctetStringCodable {
    public static let knownTypes: [AnyHashable: Codable.Type] = [
        id_test_default: TESTDefault.self,
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
        get { self._critical ?? false }
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
    var extensions: [TESTExtension]
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
