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

public enum ASN1Tagging {
    case explicit
    case implicit
    case automatic
}

public protocol ASN1TaggingRepresentable {
    static var tagging: ASN1Tagging { get }
}

public enum ASN1ExplicitTagging: ASN1TaggingRepresentable {
    public static var tagging: ASN1Tagging { return .explicit }
}

public protocol ASN1ExplicitlyTaggedType: ASN1TaggedType {
}

public enum ASN1ImplicitTagging: ASN1TaggingRepresentable {
    public static var tagging: ASN1Tagging { return .implicit }
}

public protocol ASN1ImplicitlyTaggedType: ASN1TaggedType {
}

public enum ASN1AutomaticTagging: ASN1TaggingRepresentable {
    public static var tagging: ASN1Tagging { return .automatic }
}
