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

extension ASN1EncoderImpl {
  final class ReferencingEncoder: ASN1EncoderImpl {
    var encodingContainer: ASN1EncodingContainer

    init(_ encodingContainer: ASN1EncodingContainer, at index: Int) {
      self.encodingContainer = encodingContainer
      super.init(codingPath: encodingContainer.codingPath,
                 userInfo: encodingContainer.userInfo,
                 context: encodingContainer.context)
      self.codingPath.append(ASN1Key(index: index))
    }

    init(_ encodingContainer: ASN1EncodingContainer, key: CodingKey) {
      self.encodingContainer = encodingContainer
      super.init(codingPath: encodingContainer.codingPath,
                 userInfo: encodingContainer.userInfo,
                 context: encodingContainer.context)
      self.codingPath.append(key)
    }

    deinit {
      guard let containers = self.container?.containers else { return }
      encodingContainer.containers.append(contentsOf: containers)
    }
  }
}
