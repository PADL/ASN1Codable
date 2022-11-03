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

// FIXME probably a less destructive way to do this

protocol ASN1UniversalTagRepresentable {
    static var tagNo: ASN1Tag { get }
}

extension Optional: ASN1UniversalTagRepresentable where Wrapped: ASN1UniversalTagRepresentable {
    static var tagNo: ASN1Kit.ASN1Tag { return Wrapped.tagNo }
}

extension Bool: ASN1UniversalTagRepresentable {
    static var tagNo: ASN1Tag { return .boolean }
}

extension Int: ASN1UniversalTagRepresentable {
    static var tagNo: ASN1Tag { return .integer }
}

extension UInt: ASN1UniversalTagRepresentable {
    static var tagNo: ASN1Tag { return .integer }
}

extension Data: ASN1UniversalTagRepresentable {
    static var tagNo: ASN1Tag { return .octetString }
}

extension ObjectIdentifier: ASN1UniversalTagRepresentable {
    static var tagNo: ASN1Tag { return .objectIdentifier }
}

extension Array: ASN1UniversalTagRepresentable {
    static var tagNo: ASN1Tag { return .sequence }
}

extension Set: ASN1UniversalTagRepresentable {
    static var tagNo: ASN1Tag { return .set }
}

extension String: ASN1UniversalTagRepresentable {
    static var tagNo: ASN1Tag { return .utf8String }
}
