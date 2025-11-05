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

import ArgumentParser
import Foundation
import HeimASN1Translator

struct TranslateCommand: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "translate",
    abstract: "Translate asn1compile JSON output to Swift"
  )

  enum Error: Swift.Error {
    case failedToOpenInputStream
    case failedToOpenOutputStream
    case translationError(Swift.Error)
  }

  @Option(name: .long, help: "path to JSON output from asn1_compile")
  var input: String = ""

  @Option(name: .long, help: "path to Swift output file")
  var output: String?

  @Option(name: .long, parsing: .upToNextOption, help: "replace ASN.1 type with user-defined Swift type")
  var mapType: [String] = []

  @Option(name: .long, parsing: .upToNextOption, help: "add Swift protocol conformance to type")
  var conformType: [String] = []

  var provenanceInformation: String {
    let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent
    let provenanceInformation = ([executableName] +
      CommandLine.arguments[1 ..< CommandLine.arguments.count - 1]).joined(separator: " ")

    return provenanceInformation
  }

  func run() throws {
    let file = URL(fileURLWithPath: (input as NSString).expandingTildeInPath)

    var typeMapDictionary = [String: String]()

    if !mapType.isEmpty {
      let pairs: [(String, String)] = mapType.compactMap {
        let values = $0.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
        if values.count != 2 { return nil }
        return (String(values[0]), String(values[1]))
      }
      typeMapDictionary = Dictionary(pairs) { $1 }
    }

    var conformancesDictionary: [String: NSMutableArray] = [:]

    if !conformType.isEmpty {
      conformType.forEach {
        let values = $0.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
        let typeName = String(values[0])
        let conformances = conformancesDictionary[typeName] ?? NSMutableArray()
        conformances.add(String(values[1]))
        conformancesDictionary[typeName] = conformances
      }
    }

    var outputStream: OutputStream

    if let output = output {
      guard let o = OutputStream(toFileAtPath: output, append: false) else {
        throw Error.failedToOpenOutputStream
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

      if output == nil {
        guard let data = outputStream.property(forKey:
          Stream.PropertyKey.dataWrittenToMemoryStreamKey) as? Data else {
          throw Error.failedToOpenOutputStream
        }
        let string = String(data: data, encoding: .utf8)!
        print("\(string)")
      }
    } catch let error as Error {
      throw error
    } catch {
      throw Error.translationError(error)
    }
  }
}
