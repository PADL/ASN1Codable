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

extension ASN1EncoderImpl {
    final class KeyedContainer<Key>: ASN1EncodingContainer where Key: CodingKey {
        var containers: [ASN1EncodingContainer] = []
        let codingPath: [CodingKey]
        let userInfo: [CodingUserInfoKey: Any]
        var context: ASN1EncodingContext

        init(
            codingPath: [CodingKey],
            userInfo: [CodingUserInfoKey: Any],
            context: ASN1EncodingContext = ASN1EncodingContext()
        ) {
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.context = context
        }

        func nestedCodingPath(forKey key: CodingKey) -> [CodingKey] {
            // a special case to allow for the single value decoder to deal with
            // enums with ASN1TagCoding key discriminants
            if self.context.enumCodingState == .enumCase { return self.codingPath }

            return self.codingPath + [key]
        }
    }
}

extension ASN1EncoderImpl.KeyedContainer: KeyedEncodingContainerProtocol {
    private func addContainer(_ container: ASN1EncodingContainer) {
        self.containers.append(container)
    }

    func encodeNil(forKey key: Key) throws {
        var container = self.nestedSingleValueContainer(forKey: key, context: ASN1EncodingContext())
        try container.encodeNil()
    }

    func encode(_ value: Bool, forKey key: Key) throws {
        var container = self.nestedSingleValueContainer(forKey: key, context: self.context.encodingSingleValue(value))
        try container.encode(value)
    }

    func encode(_ value: Int, forKey key: Key) throws {
        var container = self.nestedSingleValueContainer(forKey: key, context: self.context.encodingSingleValue(value))
        try container.encode(value)
    }

    func encode(_ value: Int8, forKey key: Key) throws {
        var container = self.nestedSingleValueContainer(forKey: key, context: self.context.encodingSingleValue(value))
        try container.encode(value)
    }

    func encode(_ value: Int16, forKey key: Key) throws {
        var container = self.nestedSingleValueContainer(forKey: key, context: self.context.encodingSingleValue(value))
        try container.encode(value)
    }

    func encode(_ value: Int32, forKey key: Key) throws {
        var container = self.nestedSingleValueContainer(forKey: key, context: self.context.encodingSingleValue(value))
        try container.encode(value)
    }

    func encode(_ value: Int64, forKey key: Key) throws {
        var container = self.nestedSingleValueContainer(forKey: key, context: self.context.encodingSingleValue(value))
        try container.encode(value)
    }

    func encode(_ value: UInt, forKey key: Key) throws {
        var container = self.nestedSingleValueContainer(forKey: key, context: self.context.encodingSingleValue(value))
        try container.encode(value)
    }

    func encode(_ value: UInt8, forKey key: Key) throws {
        var container = self.nestedSingleValueContainer(forKey: key, context: self.context.encodingSingleValue(value))
        try container.encode(value)
    }

    func encode(_ value: UInt16, forKey key: Key) throws {
        var container = self.nestedSingleValueContainer(forKey: key, context: self.context.encodingSingleValue(value))
        try container.encode(value)
    }

    func encode(_ value: UInt32, forKey key: Key) throws {
        var container = self.nestedSingleValueContainer(forKey: key, context: self.context.encodingSingleValue(value))
        try container.encode(value)
    }

    func encode(_ value: UInt64, forKey key: Key) throws {
        var container = self.nestedSingleValueContainer(forKey: key, context: self.context.encodingSingleValue(value))
        try container.encode(value)
    }

    func encode(_ value: String, forKey key: Key) throws {
        var container = self.nestedSingleValueContainer(forKey: key, context: self.context.encodingSingleValue(value))
        try container.encode(value)
    }

    func encode(_ value: Float, forKey key: Key) throws {
        var container = self.nestedSingleValueContainer(forKey: key, context: self.context.encodingSingleValue(value))
        try container.encode(value)
    }

    func encode(_ value: Double, forKey key: Key) throws {
        var container = self.nestedSingleValueContainer(forKey: key, context: self.context.encodingSingleValue(value))
        try container.encode(value)
    }

    /*
     func encodeIfPresent<T>(_ value: T?, forKey key: Key) throws where T : Encodable {
         var container = self.nestedSingleValueContainer(forKey: key, context: self.context.encodingSingleValue(value))

         if let value = value {
             try container.encode(value)
         } else {
             try container.encodeNil()
         }
     }
      */

    func encode(key: Key) throws {
        let value = key.stringValue
        var container = self.nestedSingleValueContainer(forKey: key, context: self.context.encodingSingleValue(value))
        try container.encode(value)
    }

    func encode<T>(_ value: T, forKey key: Key) throws where T: Encodable {
        if self.context.isCodingKeyRepresentableDictionary {
            try self.encode(key: key)
        }
        var container = self.nestedSingleValueContainer(forKey: key, context: self.context.encodingSingleValue(value))
        try container.encode(value)
    }

    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let container = ASN1EncoderImpl.UnkeyedContainer(codingPath: self.nestedCodingPath(forKey: key),
                                                         userInfo: self.userInfo,
                                                         context: self.context)
        container.context.encodingNestedContainer()
        self.addContainer(container)

        return container
    }

    func nestedContainer<NestedKey>(
        keyedBy _: NestedKey.Type,
        forKey key: Key
    ) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        let container = ASN1EncoderImpl.KeyedContainer<NestedKey>(codingPath: self.nestedCodingPath(forKey: key),
                                                                  userInfo: self.userInfo,
                                                                  context: self.context)
        container.context.encodingNestedContainer()
        self.addContainer(container)

        return KeyedEncodingContainer(container)
    }

    func superEncoder() -> Encoder {
        ASN1EncoderImpl.ReferencingEncoder(self, key: ASN1Key.super)
    }

    func superEncoder(forKey key: Key) -> Encoder {
        ASN1EncoderImpl.ReferencingEncoder(self, key: key)
    }
}

extension ASN1EncoderImpl.KeyedContainer {
    var object: ASN1Object? {
        let object: ASN1Object?

        if self.context.enumCodingState != .none {
            precondition(self.containers.count <= 1)
            object = self.containers.first?.object
        } else {
            let values = self.containers.compactMap(\.object)

            object = ASN1Kit.create(tag: self.context.encodeAsSet ? .universal(.set) : .universal(.sequence),
                                    data: .constructed(values))
        }

        return object
    }

    private func selectAutomaticTagForEnumCase() {
        guard self.context.enumCodingState == .enumCase,
              let codingKey = self.codingPath.last else {
            return
        }

        if codingKey is any ASN1CodingKey {
            // predefined keys are incompatible with automatic tagging
            self.context.automaticTaggingContext = nil
        }

        if let taggingContext = self.context.automaticTaggingContext {
            taggingContext.selectTag(codingKey)
        }
    }

    private func nestedSingleValueContainer(
        forKey key: Key,
        context: ASN1EncodingContext
    ) -> SingleValueEncodingContainer {
        let container = ASN1EncoderImpl.SingleValueContainer(codingPath: self.nestedCodingPath(forKey: key),
                                                             userInfo: self.userInfo,
                                                             context: context)

        self.selectAutomaticTagForEnumCase() // FIXME: does this belong here?

        self.addContainer(container)
        return container
    }
}
