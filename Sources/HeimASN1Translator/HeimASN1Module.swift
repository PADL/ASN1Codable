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

struct HeimASN1Module: Codable {
    enum Tagging: String, Codable {
        case explicit
        case implicit
    }
    
    var module: String
    var tagging: Tagging
    var objid: [ObjectIdentifier]?
}

class HeimASN1ModuleRef: Codable {
    enum CodingKeys: String, CodingKey {
        case name = "imports"
    }
    
    var name: String
    var translator: HeimASN1Translator?
    
    func `import`(translator: HeimASN1Translator) throws {
        let file: URL
        let path = "\(self.name).json"
        
        if let parentURL = translator.url {
            let containingURL = parentURL.deletingLastPathComponent()
            file = containingURL.appendingPathComponent(path)
        } else {
            file = URL(fileURLWithPath: path)
        }

        var options: HeimASN1Translator.Options = translator.options
        options.insert(.isImportedModule)
        
        self.translator = HeimASN1Translator(options: options, typeMaps: translator.typeMaps)
        self.translator!.parent = translator
        try self.translator!.import(file)
    }
}
