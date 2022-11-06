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

internal final class ASN1EncoderImpl {
    fileprivate var container: ASN1EncodingContainer?
    
    let codingPath: [CodingKey]
    let userInfo: [CodingUserInfoKey: Any]
    let context: ASN1EncodingContext
    
    init(codingPath: [CodingKey] = [],
         userInfo: [CodingUserInfoKey: Any] = [:],
         taggingEnvironment: ASN1Tagging? = nil) {
        self.codingPath = codingPath
        self.userInfo = userInfo
        if let taggingEnvironment = taggingEnvironment, taggingEnvironment != .default {
            self.context = ASN1EncodingContext(taggingEnvironment: taggingEnvironment)
        } else {
            self.context = ASN1EncodingContext()
        }
    }
    
    init(codingPath: [CodingKey] = [],
         userInfo: [CodingUserInfoKey: Any] = [:],
         context: ASN1EncodingContext = ASN1EncodingContext()) {
        self.codingPath = codingPath
        self.userInfo = userInfo
        self.context = context
    }

    var object: ASN1Object? {
        return self.container?.object
    }
}

extension ASN1EncoderImpl: Encoder {
    /// Returns an encoding container appropriate for holding multiple values
    /// keyed by the given key type.
    ///
    /// You must use only one kind of top-level encoding container. This method
    /// must not be called after a call to `unkeyedContainer()` or after
    /// encoding a value through a call to `singleValueContainer()`
    ///
    /// - parameter type: The key type to use for the container.
    /// - returns: A new keyed encoding container.
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        precondition(self.container == nil)
        
        let container = KeyedContainer<Key>(codingPath: self.codingPath,
                                            userInfo: self.userInfo,
                                            context: self.context)
        self.container = container
        
        return KeyedEncodingContainer(container)
    }
    
    /// Returns an encoding container appropriate for holding multiple unkeyed
    /// values.
    ///
    /// You must use only one kind of top-level encoding container. This method
    /// must not be called after a call to `container(keyedBy:)` or after
    /// encoding a value through a call to `singleValueContainer()`
    ///
    /// - returns: A new empty unkeyed container.
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        precondition(self.container == nil)
        
        let container = UnkeyedContainer(codingPath: self.codingPath,
                                         userInfo: self.userInfo,
                                         context: self.context)
        self.container = container
        
        return container
    }
    
    /// Returns an encoding container appropriate for holding a single primitive
    /// value.
    ///
    /// You must use only one kind of top-level encoding container. This method
    /// must not be called after a call to `unkeyedContainer()` or
    /// `container(keyedBy:)`, or after encoding a value through a call to
    /// `singleValueContainer()`
    ///
    /// - returns: A new empty single value container.
    func singleValueContainer() -> SingleValueEncodingContainer {
        if self.container != nil {
            debugPrint("Warning: replacing single-valued container for path \(self.codingPath)")
        }
        
        let container = SingleValueContainer(codingPath: self.codingPath,
                                             userInfo: self.userInfo,
                                             context: self.context)
        self.container = container
        
        return container
    }
}
