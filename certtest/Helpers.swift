//
//  Helpers.swift
//  asn1bridgetest
//
//  Created by Luke Howard on 23/10/2022.
//

import Foundation


extension Data {
    public func toHexString() -> String {
        return map { String(format: "%02hhX", $0) }.joined()
    }
}

/*
extension Data {
    public init(hex: String) {
        self.init(Array<UInt8>(hex: hex))
    }
}
*/

extension Array {
  @inlinable
  init(reserveCapacity: Int) {
    self = Array<Element>()
    self.reserveCapacity(reserveCapacity)
  }

  @inlinable
  var slice: ArraySlice<Element> {
    self[self.startIndex ..< self.endIndex]
  }
}

extension Array where Element == UInt8 {
  public init(hex: String) {
    self.init(reserveCapacity: hex.unicodeScalars.lazy.underestimatedCount)
    var buffer: UInt8?
    var skip = hex.hasPrefix("0x") ? 2 : 0
    for char in hex.unicodeScalars.lazy {
      guard skip == 0 else {
        skip -= 1
        continue
      }
      guard char.value >= 48 && char.value <= 102 else {
        removeAll()
        return
      }
      let v: UInt8
      let c: UInt8 = UInt8(char.value)
      switch c {
        case let c where c <= 57:
          v = c - 48
        case let c where c >= 65 && c <= 70:
          v = c - 55
        case let c where c >= 97:
          v = c - 87
        default:
          removeAll()
          return
      }
      if let b = buffer {
        append(b << 4 | v)
        buffer = nil
      } else {
        buffer = v
      }
    }
    if let b = buffer {
      append(b)
    }
  }

  public func toHexString() -> String {
      return map { String(format: "%02hhX", $0) }.joined()
  }
}
