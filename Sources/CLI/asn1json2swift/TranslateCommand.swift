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

import Commandant
import Foundation
import HeimASN1Translator

struct TranslateCommand: CommandProtocol {
  enum Error: Swift.Error {
    case failedToOpenInputStream
    case failedToOpenOutputStream
    case translationError(Swift.Error)
  }

  let verb: String = "translate"
  let function: String = "Translate asn1compile JSON output to Swift"

  var provenanceInformation: String {
    let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent
    let provenanceInformation = ([executableName] +
      CommandLine.arguments[1 ..< CommandLine.arguments.count - 1]).joined(separator: " ")

    return provenanceInformation
  }

  func run(_ options: Options) -> Result<Void, Error> {
    let file = URL(fileURLWithPath: (options.input as NSString).expandingTildeInPath)

    var typeMapDictionary = [String: String]()

    if let typeMaps = options.typeMaps {
      let pairs: [(String, String)] = typeMaps.compactMap {
        let values = $0.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
        if values.count != 2 { return nil }
        return (String(values[0]), String(values[1]))
      }
      typeMapDictionary = Dictionary(pairs) { $1 }
    }

    var conformancesDictionary: [String: NSMutableArray] = [:]

    if let conformances = options.conformances {
      conformances.forEach {
        let values = $0.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
        let typeName = String(values[0])
        let conformances = conformancesDictionary[typeName] ?? NSMutableArray()
        conformances.add(String(values[1]))
        conformancesDictionary[typeName] = conformances
      }
    }

    var outputStream: OutputStream

    if let output = options.output {
      guard let o = OutputStream(toFileAtPath: output, append: false) else {
        return .failure(.failedToOpenOutputStream)
      }
      outputStream = o
    } else {
      outputStream = OutputStream(toMemory: ())
    }

    let translator = HeimASN1Translator(typeMaps: typeMapDictionary,
                                        additionalConformances: conformancesDictionary as? [String: [String]],
                                        provenanceInformation: provenanceInformation)

    do {
      try translator.import(file)
      outputStream.open()
      try translator.translate(&outputStream)
      outputStream.close()

      if options.output == nil {
        guard let data = outputStream.property(forKey:
          Stream.PropertyKey.dataWrittenToMemoryStreamKey) as? Data else {
          return .failure(.failedToOpenOutputStream)
        }
        let string = String(data: data, encoding: .utf8)!
        print("\(string)")
      }
    } catch {
      return .failure(.translationError(error))
    }

    return .success(())
  }

  struct Options: OptionsProtocol {
    let input: String
    let output: String?
    // swiftlint:disable discouraged_optional_collection
    let typeMaps: [String]?
    // swiftlint:disable discouraged_optional_collection
    let conformances: [String]?

    static func create(_ input: String) ->
      (_ output: String?) ->
      (_ typeMaps: [String]?) ->
      (_ conformances: [String]?) -> Options {
      { (_ output: String?) in { (_ typeMaps: [String]?) in { (_ conformances: [String]?) in
        Options(input: input, output: output, typeMaps: typeMaps, conformances: conformances)
      }}}
    }

    static func evaluate(_ m: CommandMode) -> Result<Options, CommandantError<Error>> {
      self.create
        <*> m <| Option<String>(key: "input",
                                defaultValue: "",
                                usage: "path to JSON output from asn1_compile")
        <*> m <| Option<String?>(key: "output",
                                 defaultValue: nil,
                                 usage: "path to Swift output file")
        <*> m <| Option<[String]?>(key: "map-type",
                                   defaultValue: nil,
                                   usage: "replace ASN.1 type with user-defined Swift type")
        <*> m <| Option<[String]?>(key: "conform-type",
                                   defaultValue: nil,
                                   usage: "add Swift protocol conformance to type")
    }
  }
}
