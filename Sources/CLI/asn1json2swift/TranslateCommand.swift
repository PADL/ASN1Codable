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
        case translationError(Swift.Error)
    }

    let verb: String = "translate"
    let function: String = "Translate asn1compile JSON output to Swift"

    func run(_ options: Options) -> Result<(), Error> {
        let file = URL(fileURLWithPath: (options.file as NSString).expandingTildeInPath)

        guard let inputStream = InputStream(url: file) else {
            return .failure(.failedToOpenInputStream)
        }
        
        var outputStream: OutputStream = OutputStream(toMemory: ())
        let translator = HeimASN1Translator(inputStream: inputStream, outputStream: &outputStream)

        do {
            try translator.translate()
            let data = outputStream.property(forKey: Stream.PropertyKey.dataWrittenToMemoryStreamKey) as! Data
            let string = String(data: data, encoding: .utf8)!
            print("\(string)")
        } catch {
            return .failure(.translationError(error))
        }
        
        return .success(())
    }

    struct Options: OptionsProtocol {
        let file: String

        static func create(_ file: String) -> Options {
            return Options(file: file)
        }
        
        static func evaluate(_ m: CommandMode) -> Result<Options, CommandantError<Error>> {
            //swiftlint:disable:previous identifier_name
            return create
                    <*> m <| Option(key: "file", defaultValue: "", usage: "path to JSON output from asn1compile")
        }
    }
}

/*
 static func create(_ file: String) -> Options {
     return { (string: String) in { (json: Bool) in { (reencode: Bool) in { (san: Bool) in
         Options(file: file,
                 string: string,
                 json: json,
                 reencode: reencode,
                 san: san)
     }
     }
     }
     }
 }

 */
