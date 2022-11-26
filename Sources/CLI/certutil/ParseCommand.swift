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

import Commandant
import Algorithms
import Foundation

struct ParseCommand: CommandProtocol {
    enum Error: Swift.Error {
        case fileReadError
        case decodingError
        case encodingError
        case jsonEncodingError
    }

    let verb: String = "parse"
    let function: String = "Parse ASN.1 encoded file or from cmd-line input"

    func data(options: Options) -> Data? {
        var data: Data?
        let fileContents: Data?

        if !options.file.isEmpty {
            let file = URL(fileURLWithPath: (options.file as NSString).expandingTildeInPath)
            fileContents = try? Data(contentsOf: file)
        } else if options.string.isEmpty {
            return nil
        } else {
            fileContents = nil
        }

        if let fileContents {
            var didBegin = false
            var base64 = ""

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
            if data == nil {
                data = Data(hexString: options.string)
            }
        }

        return data
    }

    func run(_ options: Options) -> Result<Void, Error> {
        guard let data = self.data(options: options), !data.isEmpty else {
            return .failure(.fileReadError)
        }
        guard let cert = CertificateCreateWithData(kCFAllocatorDefault, data as CFData) else {
            return .failure(.decodingError)
        }

        if options.json {
            guard let json = CertificateCopyJSONDescription(cert) else {
                return .failure(.jsonEncodingError)
            }

            print("\(json)")
        }

        if options.reencode {
            guard let encoded = CertificateCopyDataReencoded(cert) else {
                return .failure(.encodingError)
            }

            print("-----BEGIN CERTIFICATE-----")
            let chunks = (encoded as Data).base64EncodedString().chunks(ofCount: 64)
            chunks.forEach { print($0) }
            print("-----END CERTIFICATE-----")
        }

        if options.san, let sans = CertificateCopyDescriptionsFromSAN(cert) {
            (sans as NSArray).forEach { san in
                print("\(san)")
            }
        }

        return .success(())
    }

    struct Options: OptionsProtocol {
        let file: String
        let string: String
        let json: Bool
        let reencode: Bool
        let san: Bool

        static func create(_ file: String) ->
            (_ string: String) ->
            (_ json: Bool) ->
            (_ reencode: Bool) ->
            (_ san: Bool) -> Options {
            { (string: String) in { (json: Bool) in { (reencode: Bool) in { (san: Bool) in
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

        static func evaluate(_ m: CommandMode) -> Result<Options, CommandantError<Error>> {
            // swiftlint:disable:previous identifier_name
            self.create
                <*> m <| Option(key: "file", defaultValue: "", usage: "path to PEM encoded file")
                <*> m <| Option(key: "string", defaultValue: "", usage: "string passed as ASN.1 encoded base64")
                <*> m <| Option(key: "json", defaultValue: true, usage: "output certificate as JSON")
                <*> m <| Option(key: "reencode", defaultValue: false, usage: "re-encode to ASN.1")
                <*> m <| Option(key: "san", defaultValue: false, usage: "display ccertificate SANs")
        }
    }
}
