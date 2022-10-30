//
//  ASN1EncoderImpl.swift
//  ASN1CodingKit
//
//  Created by Luke Howard on 30/10/2022.
//

import Foundation
import ASN1Kit

internal final class ASN1EncoderImpl {
    fileprivate var container: ASN1EncodingContainer?
    
    let codingPath: [CodingKey]
    let userInfo: [CodingUserInfoKey: Any]
    var state: ASN1CodingState
    
    init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any], state: ASN1CodingState) {
        self.codingPath = codingPath
        self.userInfo = userInfo
        self.state = state
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
                                            state: self.state)
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
                                         state: self.state)
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
        precondition(self.container == nil)

        let container = SingleValueContainer(codingPath: self.codingPath,
                                             userInfo: self.userInfo,
                                             state: self.state)
        self.container = container

        return container
    }
}

extension ASN1EncoderImpl {
    static func isEnum<T>(_ value: T) -> Bool {
        let reflection = Mirror(reflecting: value)

        return reflection.displayStyle == .enum
    }
}
