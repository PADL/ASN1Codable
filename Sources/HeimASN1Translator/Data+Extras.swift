//
//  Data+Extras.swift
//  HeimASN1Translator
//
//  Created by Luke Howard on 13/11/2022.
//

import Foundation

// https://gist.github.com/reitzig/29d38b948812454a8dedc00a9f61f44f

extension Data {
    /**
     Consumes the specified input stream, creating a new Data object
     with its content.
     - Parameter reading: The input stream to read data from.
     - Note: Closes the specified stream.
     */
    init(reading input: InputStream) {
        self.init()
        input.open()
        
        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        while input.hasBytesAvailable {
            let read = input.read(buffer, maxLength: bufferSize)
            self.append(buffer, count: read)
        }
        buffer.deallocate()
        
        input.close()
    }
}

