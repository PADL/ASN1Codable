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

    func run(_ options: Options) -> Result<(), Error> {
        let file = URL(fileURLWithPath: (options.input as NSString).expandingTildeInPath)

        guard let inputStream = InputStream(url: file) else {
            return .failure(.failedToOpenInputStream)
        }
        
        let typeMapDictionary: [String:String]?
        
        if let typeMaps = options.typeMaps {
            let pairs: [(String, String)] = typeMaps.map {
                let values = $0.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
                return (String(values[0]), String(values[1]))
            }
            typeMapDictionary = Dictionary(pairs, uniquingKeysWith: { return $1 })
        } else {
            typeMapDictionary = nil
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
        
        let translator = HeimASN1Translator(inputStream: inputStream, outputStream: &outputStream, typeMaps: typeMapDictionary)

        do {
            try translator.translate()
            
            if options.output == nil {
                let data = outputStream.property(forKey: Stream.PropertyKey.dataWrittenToMemoryStreamKey) as! Data
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
        let typeMaps: [String]?

        static func create(_ input: String) -> (_ output: String?) -> (_ typeMaps: [String]?) -> Options {
            return { (_ output: String?) in { (_ typeMaps: [String]?) in
                return Options(input: input, output: output, typeMaps: typeMaps)
            }}
        }
        
        static func evaluate(_ m: CommandMode) -> Result<Options, CommandantError<Error>> {
            return create
                    <*> m <| Option<String>(key: "input", defaultValue: "", usage: "path to JSON output from asn1_compile")
                    <*> m <| Option<String?>(key: "output", defaultValue: nil, usage: "path to Swift output file")
                    <*> m <| Option<[String]?>(key: "map-type", defaultValue: nil, usage: "replace ASN.1 type with user-defined Swift type")
        }
    }
}