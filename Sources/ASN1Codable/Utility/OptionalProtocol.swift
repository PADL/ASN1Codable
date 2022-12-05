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

protocol OptionalProtocol {
    static var wrappedType: Any.Type { get }
}

extension Optional: OptionalProtocol {
    static var wrappedType: Any.Type { Wrapped.self }
}

func isNilOrWrappedNil<T>(_ value: T) -> Bool {
    var wrappedValue: Any = value

    // swiftlint:disable force_cast
    while wrappedValue is any ASN1TaggedValue {
        wrappedValue = (wrappedValue as! any ASN1TaggedValue).wrappedValue
    }

    if let wrappedValue = wrappedValue as? ExpressibleByNilLiteral,
       let wrappedValue = wrappedValue as? Any?,
       case .none = wrappedValue {
        return true
    } else {
        return false
    }
}
