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
import AnyCodable

public typealias ASN1ObjectSetTypeDictionary = [String: [AnyHashable: Codable.Type]]

final class ASN1ObjectSetCodingContext {
    let objectSetType: ASN1ObjectSetCodable.Type
    let encodeAsOctetString: Bool
    var valueType: (any Codable & Hashable)?

    init(objectSetType: ASN1ObjectSetCodable.Type, encodeAsOctetString: Bool) {
        self.objectSetType = objectSetType
        self.encodeAsOctetString = encodeAsOctetString
    }

    func type(_ codingContext: ASN1CodingContext) -> Codable.Type? {
        let type: Codable.Type?

        guard let valueType = self.valueType else {
            debugPrint("Object set type must come before value")
            return nil
        }

        let anyValueType = AnyHashable(valueType)

        if let typeDict = codingContext.objectSetTypeDictionary,
           let typeDict = typeDict[String(reflecting: objectSetType)],
           let userType = typeDict[anyValueType] {
            type = userType
        } else if let knownType = objectSetType.knownTypes[anyValueType] {
            type = knownType
        } else {
            type = nil
        }
        return type
    }
}
