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

public final class ASN1Decoder {
    public var userInfo: [CodingUserInfoKey: Any] = [:]

    public init() {
    }

    public func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        do {
            let object = try ASN1Kit.ASN1Decoder.decode(asn1: data)
            let decoder = ASN1DecoderImpl(object: object, userInfo: userInfo)
            let box = try Box<T>(from: decoder)
            return box.value
        } catch let error as ASN1Error {
            let context = DecodingError.Context(codingPath: [],
                                                debugDescription: "ASN.1 decoding error",
                                                underlyingError: error)
            throw DecodingError.dataCorrupted(context)
        }
    }
}

#if canImport(Combine)
import Combine
            
extension ASN1Decoder: TopLevelDecoder {
    public typealias Output = Data
}
#endif
