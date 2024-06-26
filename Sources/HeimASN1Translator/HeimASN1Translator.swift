//
// Copyright (c) 2022 PADL Software Pty Ltd
//
// Licensed under the Apache License, Version 2.0 (the License);
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an 'AS IS' BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import ASN1Kit

let HeimASN1TranslatorUserInfoKey: CodingUserInfoKey = .init(rawValue: "HeimASN1TranslatorUserInfoKey")!

protocol HeimASN1Emitter {
  func emit(_ outputStream: inout OutputStream) throws
}

extension OutputStream: TextOutputStream {
  public func write(_ string: String) {
    self.write(string, maxLength: string.count)
  }
}

public final class HeimASN1Translator {
  public struct Options: OptionSet {
    public let rawValue: UInt

    public init(rawValue: UInt) {
      self.rawValue = rawValue
    }

    public static let disablePropertyWrappers = Options(rawValue: 1 << 0)
    static let isImportedModule = Options(rawValue: 1 << 1)
  }

  enum Error: Swift.Error {
    case failedToOpenInputStream(URL)
  }

  enum TypeMap: Equatable {
    case `class`
    case objc
    case external
    case alias(String)
  }

  let options: Options
  let typeMaps: [String: TypeMap]
  weak var parent: HeimASN1Translator?
  private let provenanceInformation: String?
  let additionalConformances: [String: [String]]
  private(set) var module: HeimASN1Module?
  private var imports = [HeimASN1ModuleRef]()
  private var typeRefCache = Set<String>()
  private var typeDefsByName = [String: HeimASN1TypeDef]()
  private var typeDefsByGeneratedName = [String: HeimASN1TypeDef]()
  private var typeDefs = [HeimASN1TypeDef]()
  private(set) var url: URL?
  private var tagValues = Set<UInt>()

  public init(
    options: Options = Options(),
    typeMaps: [String: String]? = nil,
    additionalConformances: [String: [String]]? = nil,
    provenanceInformation: String? = nil
  ) {
    self.options = options
    self.typeMaps = (typeMaps ?? [:]).mapValues {
      switch $0 {
      case "@class":
        return TypeMap.class
      case "@objc":
        return TypeMap.objc
      case "@external":
        return TypeMap.external
      default:
        return TypeMap.alias($0)
      }
    }
    self.additionalConformances = additionalConformances ?? [:]
    self.provenanceInformation = provenanceInformation
  }

  init(
    options: Options = Options(),
    typeMaps: [String: TypeMap]? = nil,
    additionalConformances: [String: [String]]? = nil
  ) {
    self.options = options
    self.typeMaps = typeMaps ?? [:]
    self.additionalConformances = additionalConformances ?? [:]
    self.provenanceInformation = nil
  }

  func cacheTypeRef(_ ref: String) {
    self.typeRefCache.insert(ref)
  }

  func typeRefExists(_ ref: String) -> Bool {
    self.typeRefCache.contains(ref)
  }

  func resolveTypeRef(_ ref: String) -> HeimASN1TypeDef? {
    self.imports.reduce(self.typeDefsByName[ref]) {
      $0 ?? $1.translator?.resolveTypeRef(ref)
    }
  }

  lazy var swiftImports: Set<String> = {
    var swiftImports = Set<String>()

    swiftImports.insert("Foundation")
    swiftImports.insert("BigNumber")
    swiftImports.insert("AnyCodable")
    swiftImports.insert("ASN1Codable")

    self.apply { typeDef, _ in
      if let decoration = typeDef.decorate {
        decoration.forEach {
          if !$0.headerName.isEmpty { swiftImports.insert($0.headerName) }
        }
      }
    }

    return swiftImports
  }()

  private func emitSwiftImports(_ outputStream: inout OutputStream) {
    self.swiftImports.forEach { outputStream.write("import \($0)\n") }
  }

  func didEmitWrapperWithTagNumber(_ tagValue: UInt) {
    self.tagValues.insert(tagValue)
  }

  private func emitTagNumberTypes(_ outputStream: inout OutputStream) {
    guard !self.tagValues.isEmpty else {
      return
    }

    // FIXME: these need to be at least as visible as any fields that use them so,
    // just make them public for now

    if let module = self.module {
      outputStream.write("public enum \(module.module) {\n")
    }

    self.tagValues.sorted().forEach {
      outputStream
        .write(
          "\(self.module == nil ? "" : "\t")public enum ASN1TagNumber$\($0): ASN1Codable.ASN1TagNumberRepresentable {}\n"
        )
    }

    if self.module != nil {
      outputStream.write("}\n")
    }
  }

  func decode(_ data: Data, range: Range<Data.Index>) throws {
    let jsonDecoder = JSONDecoder()

    jsonDecoder.userInfo[HeimASN1TranslatorUserInfoKey] = self

    do {
      let type = try jsonDecoder.decode(HeimASN1TypeDef.self, from: data.subdata(in: range))
      self.typeDefsByName[type.name] = type
      self.typeDefsByGeneratedName[type.generatedName] = type
      self.typeDefs.append(type)
    } catch {
      if let error = error as? DecodingError,
         case .keyNotFound(let codingKey, _) = error,
         codingKey.stringValue == "name" {
        do {
          self.module = try jsonDecoder.decode(HeimASN1Module.self, from: data.subdata(in: range))
        } catch {
          if let error = error as? DecodingError,
             case .keyNotFound(let codingKey, _) = error,
             codingKey.stringValue == "module" {
            let moduleRef = try jsonDecoder.decode(HeimASN1ModuleRef.self, from: data.subdata(in: range))

            if moduleRef.name != "heim" {
              try moduleRef.import(translator: self)
            }

            self.imports.append(moduleRef)
          }
        }
      } else {
        throw error
      }
    }
  }

  public func `import`(_ url: URL) throws {
    guard let inputStream = InputStream(url: url) else {
      throw Error.failedToOpenInputStream(url)
    }

    precondition(self.url == nil)
    self.url = url
    try self.import(inputStream)
  }

  func `import`(_ inputStream: InputStream) throws {
    let data = Data(reading: inputStream)

    var start: Data.Index = 0
    var end: Data.Index = data.count

    while end > 0 {
      do {
        // taste the data
        try self.decode(data, range: start ..< data.count)

        // if this acutally worked, get out
        end = 0
      } catch {
        if let error = error as? DecodingError,
           case .dataCorrupted(let context) = error,
           let underlyingError = context.underlyingError as? CocoaError,
           let errorIndex = underlyingError.userInfo["NSJSONSerializationErrorIndex"] as? Data.Index {
          let range = start ..< (start + errorIndex)
          // decode the data
          try self.decode(data, range: range)

          start += errorIndex
          end = data.count - start
        } else {
          throw error
        }
      }
    }
  }

  public func translate(_ outputStream: inout OutputStream) throws {
    outputStream.write("/// HeimASN1Translator generated \(Date())\n")

    if let provenanceInformation = self.provenanceInformation {
      outputStream.write("/// \(provenanceInformation)\n")
    }
    if let module {
      outputStream.write("/// defines ASN.1 module \(module.module) with \(module.tagging) tagging\n")
    }
    self.imports.forEach {
      outputStream.write("/// imports ASN.1 module \($0.name)\n")
    }

    outputStream.write("\n")

    self.emitSwiftImports(&outputStream)

    outputStream.write("\n")

    try self.typeDefs.forEach {
      try $0.emit(&outputStream)
      outputStream.write("\n")
    }

    self.emitTagNumberTypes(&outputStream)
  }
}

extension HeimASN1Translator {
  private func apply(
    with typeDef: HeimASN1TypeDef,
    _ block: (_ type: HeimASN1TypeDef, _ stop: inout Bool) -> Void,
    _ stop: inout Bool
  ) {
    block(typeDef, &stop)
    if stop { return }
    if let type = typeDef.type, let type = type.typeDefValue {
      self.apply(with: type, block, &stop)
      if stop { return }
    }
    if let tType = typeDef.tType, let tType = tType.typeDefValue {
      self.apply(with: tType, block, &stop)
      if stop { return }
    }
  }

  func apply(_ block: (_ type: HeimASN1TypeDef, _ stop: inout Bool) -> Void) {
    var stop = false
    self.typeDefs.forEach { typeDef in
      self.apply(with: typeDef, block, &stop)
      if stop { return }
    }
  }
}
