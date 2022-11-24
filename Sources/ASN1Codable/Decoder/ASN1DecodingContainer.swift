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

protocol ASN1DecodingContainer {
    var codingPath: [CodingKey] { get }
    var object: ASN1Object { get }
    var context: ASN1DecodingContext { get set }
    var currentIndex: Int { get }
}

extension ASN1DecodingContainer {
    var count: Int? {
        return self.object.data.fold({ primitive in
            return 1
        }, { items in
            return items.count
        })
    }

    var isAtEnd: Bool {
        guard let count = self.count else {
            return true
        }
        
        return self.currentIndex >= count
    }

    private var _isEmptySequence: Bool {
        return self.object.constructed && self.object.data.items?.count == 0
    }
    
    private func _validate() throws {
        let isUnkeyedContainer = self is UnkeyedDecodingContainer

        if !self.object.constructed && self.context.enumCodingState == .none && !self.object.isNull {
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "\(isUnkeyedContainer ? "Unkeyed" : "Keyed") container expected a constructed ASN.1 object")
            throw DecodingError.dataCorrupted(context)
        } else if isUnkeyedContainer, !self._isEmptySequence, self.isAtEnd {
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Unkeyed decoding container is already at end of ASN.1 object")
            throw DecodingError.dataCorrupted(context)
        }
    }
    
    private func _validateNestedContainer(_ object: ASN1Object) throws {
        if object.constructed, object.tag.isUniversal {
            if self.context.encodeAsSet && object.tag != .universal(.set) {
                let context = DecodingError.Context(codingPath: codingPath,
                                                    debugDescription: "Expected \(ASN1DecodedTag.universal(.set)), but received tag \(object.tag)")
                throw DecodingError.dataCorrupted(context)
            } else if object.tag != .universal(.sequence) {
                let context = DecodingError.Context(codingPath: codingPath,
                                                    debugDescription: "Expected a \(ASN1DecodedTag.universal(.sequence)), but received tag \(object.tag)")
                throw DecodingError.dataCorrupted(context)
            }
        } else if self.context.enumCodingState != .enum {
            let context = DecodingError.Context(codingPath: codingPath,
                                                debugDescription: "Expected a constructed type, instead received tag \(object.tag)")
            throw DecodingError.dataCorrupted(context)
        }
    }
    
    private func _currentObject(for type: Decodable.Type? = nil, nestedContainer: Bool) throws -> ASN1Object {
        let object: ASN1Object
        if self.context.enumCodingState != .none || self.object.isNull {
            object = self.object
        } else if self.isAtEnd {
            // if we've reached the end of the SEQUENCE or SET, we still need to initialise
            // the remaining wrapped objects; pad the object set with null instances.
            object = ASN1NullObject
        } else if self.object.constructed, let items = self.object.data.items, self.currentIndex < items.count  {
            object = items[self.currentIndex]
        } else {
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Object \(self.object) is not constructed, or has less than \(self.currentIndex) items")
            throw DecodingError.dataCorrupted(context)
        }
        
        try self._validate()
        
        if nestedContainer {
            try self._validateNestedContainer(object)
        }
        
        return object
    }
    
    func currentObject(for type: Decodable.Type? = nil, nestedContainer: Bool = false) throws -> ASN1Object {
        do {
            return try self._currentObject(for: type, nestedContainer: nestedContainer)
        } catch {
            if let type = type, case DecodingError.dataCorrupted(let context) = error {
                // retype the error as a typeMismatch, which the field is OPTIONAL
                // will tell the caller it is safe to skip this field
                throw DecodingError.typeMismatch(type, context)
            } else {
                throw error
            }
        }
    }
}
