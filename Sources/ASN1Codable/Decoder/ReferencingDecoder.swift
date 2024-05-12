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

extension ASN1DecoderImpl {
  final class ReferencingDecoder: ASN1DecoderImpl {
    var decodingContainer: ASN1DecodingContainer

    init(_ decodingContainer: ASN1DecodingContainer, at index: Int) {
      self.decodingContainer = decodingContainer
      super.init(object: decodingContainer.object,
                 codingPath: decodingContainer.codingPath,
                 userInfo: decodingContainer.userInfo,
                 context: decodingContainer.context)
      self.codingPath.append(ASN1Key(index: index))
    }

    init(_ decodingContainer: ASN1DecodingContainer, key: CodingKey) {
      self.decodingContainer = decodingContainer
      super.init(object: decodingContainer.object,
                 codingPath: decodingContainer.codingPath,
                 userInfo: decodingContainer.userInfo,
                 context: decodingContainer.context)
      self.codingPath.append(key)
    }

    deinit {
      guard let container = self.container else { return }
      precondition(container.currentIndex >= self.decodingContainer.currentIndex)
      self.decodingContainer.currentIndex = container.currentIndex
    }
  }
}
