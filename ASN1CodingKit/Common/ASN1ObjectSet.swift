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

public enum ASN1ObjectSet {
    private typealias ASN1ObjectSetTypeDictionary = [String: [ObjectIdentifier: Any.Type]]

    public static func type(for oid: ObjectIdentifier,
                            in objectSetType: Any.Type,
                            with knownTypes: [ObjectIdentifier: Any.Type],
                            userInfo: [CodingUserInfoKey: Any]) throws -> Codable.Type {
        let type: Any.Type?
        
        if let typeDict = userInfo[CodingUserInfoKey.ASN1ObjectSetTypeDictionary] as? ASN1ObjectSetTypeDictionary,
           let typeDict = typeDict[String(reflecting: objectSetType)],
           let userType = typeDict[oid] {
            type = userType
        } else if let knownType = knownTypes[oid] {
            type = knownType
        } else {
            type = nil
        }
        
        guard let witness = type.self as? Codable.Type else {
            throw ASN1Error.unsupported("Unknown open type OID \(oid)")
        }
        
        return witness
    }
}
