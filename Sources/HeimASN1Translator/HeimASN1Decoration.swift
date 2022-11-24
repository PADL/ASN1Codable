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

struct HeimASN1Decoration: Codable {
    var type: String
    var name: String
    var isOptional: Bool
    var isExternal: Bool
    var isPointer: Bool
    var isVoidStar: Bool
    var isStructStar: Bool
    var copyFunction: String
    var freeFunction: String
    var headerName: String

    enum CodingKeys: String, CodingKey {
        case type
        case name
        case isOptional = "optional"
        case isExternal = "external"
        case isPointer = "pointer"
        case isVoidStar = "void_star"
        case isStructStar = "struct_star"
        case copyFunction = "copy_function"
        case freeFunction = "free_function"
        case headerName = "header_name"
    }
}
