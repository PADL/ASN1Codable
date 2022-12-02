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

/// a dictionary that uses \_DictionaryCodingKey to encode itself
protocol StringCodingKeyRepresentableDictionary {}
extension Dictionary: StringCodingKeyRepresentableDictionary where Key == String {}

protocol IntCodingKeyRepresentableDictionary {}
extension Dictionary: IntCodingKeyRepresentableDictionary where Key == Int {}

protocol AnyCodingKeyRepresentableDictionary {}
@available(macOS 12.3, *)
extension Dictionary: AnyCodingKeyRepresentableDictionary where Key: CodingKeyRepresentable {}
