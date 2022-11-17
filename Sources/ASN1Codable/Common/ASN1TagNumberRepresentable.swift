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

// represents a tag number used to specialize a tag generic
public protocol ASN1TagNumberRepresentable {
}

// extracts the tag number from the ASN1TagNumber concrete type
extension ASN1TagNumberRepresentable {
    static var tagNo: UInt {
        let name = String(describing: self)
        let nameComponents = name.components(separatedBy: "$")
        precondition(nameComponents.count == 2)
        return UInt(nameComponents[1])!
    }
}

// FIXME generate these from the compiler in the module

public enum ASN1TagNumber$0: ASN1TagNumberRepresentable {
}

public enum ASN1TagNumber$1: ASN1TagNumberRepresentable {
}

public enum ASN1TagNumber$2: ASN1TagNumberRepresentable {
}

public enum ASN1TagNumber$3: ASN1TagNumberRepresentable {
}

public enum ASN1TagNumber$4: ASN1TagNumberRepresentable {
}

public enum ASN1TagNumber$5: ASN1TagNumberRepresentable {
}

public enum ASN1TagNumber$6: ASN1TagNumberRepresentable {
}

public enum ASN1TagNumber$7: ASN1TagNumberRepresentable {
}

public enum ASN1TagNumber$8: ASN1TagNumberRepresentable {
}

public enum ASN1TagNumber$9: ASN1TagNumberRepresentable {
}

public enum ASN1TagNumber$10: ASN1TagNumberRepresentable {
}