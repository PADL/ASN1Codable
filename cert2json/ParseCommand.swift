//
// Copyright (c) 2022 gematik GmbH
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

import ASN1Kit
import ASN1CodingKit
import Commandant
import DataKit
import Foundation

struct ParseCommand: CommandProtocol {
    enum Error: Swift.Error {
        case unsupportedMode(_: String)
        case base64DecodingError
        case decodingError(Swift.Error)
        case encodingError
    }

    let verb: String = "parse"
    let function: String = "Parse ASN.1 encoded file or from cmd-line input"

    func run(_ options: Options) -> Result<(), Error> {
        let file = URL(fileURLWithPath: (options.file as NSString).expandingTildeInPath)
        let fileContents = try? file.readFileContents()
        guard !options.string.isEmpty || fileContents != nil else {
            return .failure(.unsupportedMode("No string or valid file path passed"))
        }

        do {
            let data: Data?
            
            if let fileContents = fileContents {
                var didBegin = false
                var base64: String = ""
                
                String(data: fileContents, encoding: .ascii)?.enumerateLines { string, stop in
                    if string == "-----BEGIN CERTIFICATE-----" {
                        didBegin = true
                    } else if string == "-----END CERTIFICATE-----" {
                        stop = true
                    } else {
                        if didBegin {
                            base64 += string
                        }
                    }
                }
                data = Data(base64Encoded: base64)
            } else {
                data = Data(base64Encoded: options.string)
            }
            
            guard let data = data else {
                return .failure(.base64DecodingError)
            }

            let decoder = ASN1Decoder()
            let cert = try decoder.decode(Certificate.self, from: data)
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted

            guard let jsonData = try String(data: encoder.encode(cert), encoding: .utf8) else {
                return .failure(.encodingError)
            }

            print("\(jsonData)")

            let encoder2 = ASN1Encoder()
            let encoded = try encoder2.encode(cert)
            
            return .success(())
        } catch let error {
            return .failure(.decodingError(error))
        }
    }

    struct Options: OptionsProtocol {
        let file: String
        let string: String
        let verbose: Bool

        static func create(_ file: String) -> (String) -> (Bool) -> Options {
            return { (string: String) in { (verbose: Bool) in
                    Options(
                            file: file,
                            string: string,
                            verbose: verbose)
                }
            }
        }

        static func evaluate(_ m: CommandMode) -> Result<Options, CommandantError<Error>> {
            //swiftlint:disable:previous identifier_name
            return create
                    <*> m <| Option(key: "file", defaultValue: "", usage: "path to PEM encoded file")
                    <*> m <| Option(key: "string", defaultValue: "", usage: "string passed as ASN.1 encoded base64")
                    <*> m <| Option(key: "verbose", defaultValue: false, usage: "show verbose logging")
        }
    }
}
