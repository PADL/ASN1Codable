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

extension Bool: ASN1UniversalTagRepresentable {
  static var tagNo: ASN1Tag { .boolean }
}

extension Int: ASN1UniversalTagRepresentable {
  static var tagNo: ASN1Tag { .integer }
}

extension Int8: ASN1UniversalTagRepresentable {
  static var tagNo: ASN1Tag { .integer }
}

extension Int16: ASN1UniversalTagRepresentable {
  static var tagNo: ASN1Tag { .integer }
}

extension Int32: ASN1UniversalTagRepresentable {
  static var tagNo: ASN1Tag { .integer }
}

extension Int64: ASN1UniversalTagRepresentable {
  static var tagNo: ASN1Tag { .integer }
}

extension UInt: ASN1UniversalTagRepresentable {
  static var tagNo: ASN1Tag { .integer }
}

extension UInt8: ASN1UniversalTagRepresentable {
  static var tagNo: ASN1Tag { .integer }
}

extension UInt16: ASN1UniversalTagRepresentable {
  static var tagNo: ASN1Tag { .integer }
}

extension UInt32: ASN1UniversalTagRepresentable {
  static var tagNo: ASN1Tag { .integer }
}

extension UInt64: ASN1UniversalTagRepresentable {
  static var tagNo: ASN1Tag { .integer }
}

extension Data: ASN1UniversalTagRepresentable {
  static var tagNo: ASN1Tag { .octetString }
}

extension ObjectIdentifier: ASN1UniversalTagRepresentable {
  static var tagNo: ASN1Tag { .objectIdentifier }
}

extension Array: ASN1UniversalTagRepresentable {
  static var tagNo: ASN1Tag { .sequence }
}

extension Set: ASN1UniversalTagRepresentable {
  static var tagNo: ASN1Tag { .set }
}
