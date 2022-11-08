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

class HeimASN1OpenType: Codable, CustomStringConvertible {
    var openType: Bool = false
    var arrayType: Bool = false
    var className: String = ""
    var objectSetName: String = ""
    var typeIdMember: String = ""
    var openTypeMember: String = ""
    var typeIdField: String = ""
    var openTypeField: String = ""
    var members: [HeimASN1TypeDef] = []
    var openTypeIds: [String]? = []

    enum CodingKeys: String, CodingKey {
        case openType = "opentype"
        case arrayType = "arraytype"
        case className = "classname"
        case objectSetName = "objectsetname"        // Known ...
        case typeIdMember = "typeidmember"          // type-id (ASN.1 name)
        case openTypeMember = "opentypemember"      // value (ASN.1 name)
        case typeIdField = "typeidfield"
        case openTypeField = "opentypefield"
        case members = "members"
        case openTypeIds = "opentypeids"
    }
 
    var description: String {
        return "OpenType \(className) with \(members.count) members"
    }
    
    func typeId(for member: HeimASN1TypeDef) -> String? {
        guard let index = self.members.firstIndex(of: member) else {
            return nil
        }
        
        return self.openTypeIds?[index]
    }
}
