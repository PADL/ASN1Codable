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

import ArgumentParser
import Algorithms
import DataKit
import Foundation

struct ParseCommand: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "parse",
    abstract: "Parse ASN.1 encoded file or from cmd-line input"
  )

  enum Error: Swift.Error {
    case fileReadError
    case decodingError
    case encodingError
    case jsonEncodingError
  }

  @Option(name: .long, help: "path to PEM encoded file")
  var file: String = ""

  @Option(name: .long, help: "string passed as ASN.1 encoded base64")
  var string: String = ""

  @Flag(name: .long, help: "output certificate as JSON")
  var json: Bool = false

  @Flag(name: .long, help: "re-encode to ASN.1")
  var reencode: Bool = false

  @Flag(name: .long, help: "display certificate SANs")
  var san: Bool = false

  func data() -> Data? {
    var data: Data?
    let fileContents: Data?

    if !file.isEmpty {
      let fileURL = URL(fileURLWithPath: (file as NSString).expandingTildeInPath)
      fileContents = try? Data(contentsOf: fileURL)
    } else if string.isEmpty {
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
      data = Data(base64Encoded: string)
      if data == nil {
        do {
          data = try Data(hex: string)
        } catch {}
      }
    }

    return data
  }

  func run() throws {
    guard let data = self.data(), !data.isEmpty else {
      throw Error.fileReadError
    }
    guard let cert = CertificateCreateWithData(kCFAllocatorDefault, data as CFData) else {
      throw Error.decodingError
    }

    if json {
      guard let json = CertificateCopyJSONDescription(cert) else {
        throw Error.jsonEncodingError
      }

      print("\(json)")
    }

    if reencode {
      guard let encoded = CertificateCopyDataReencoded(cert) else {
        throw Error.encodingError
      }

      print("-----BEGIN CERTIFICATE-----")
      let chunks = (encoded as Data).base64EncodedString().chunks(ofCount: 64)
      chunks.forEach { print($0) }
      print("-----END CERTIFICATE-----")
    }

    if san, let sans = CertificateCopyDescriptionsFromSAN(cert) {
      (sans as NSArray).forEach { san in
        print("\(san)")
      }
    }
  }
}
