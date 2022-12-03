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

struct KeyValue<Key: Hashable & Codable, Value: Codable>: Codable, Hashable {
    static func == (lhs: KeyValue<Key, Value>, rhs: KeyValue<Key, Value>) -> Bool {
        guard lhs.key == rhs.key else {
            return false
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.key)
    }

    var key: Key
    var value: Value
}

protocol KeyValueSetDictionaryCodable<Key, Value> {
    associatedtype Key: Codable & Hashable
    associatedtype Value: Codable
    init(keyValueSet: Set<KeyValue<Key, Value>>)
    var keyValueSet: Set<KeyValue<Key, Value>> { get }
}

extension Dictionary: KeyValueSetDictionaryCodable where Key: Codable, Value: Codable {
    init(keyValueSet: Set<KeyValue<Key, Value>>) {
        self = Dictionary(uniqueKeysWithValues: keyValueSet.map {
            ($0.key, $0.value)
        })
    }

    var keyValueSet: Set<KeyValue<Key, Value>> {
        Set(self.map { KeyValue(key: $0, value: $1) })
    }
}
