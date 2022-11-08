import Foundation
import HeimASN1Translator

guard CommandLine.arguments.count == 2 else {
    print("Usage: \(CommandLine.arguments[0]) filename.json")
    exit(1)
}

let file = URL(fileURLWithPath: (CommandLine.arguments[1] as NSString).expandingTildeInPath)
guard let inputStream = InputStream(url: file) else {
    print("Could not open file \(file)")
    exit(2)
}

var outputStream: OutputStream = OutputStream(toMemory: ())
let translator = HeimASN1Translator(inputStream: inputStream, outputStream: &outputStream)

do {
    try translator.translate()
    let data = outputStream.property(forKey: Stream.PropertyKey.dataWrittenToMemoryStreamKey) as! Data
    let string = String(data: data, encoding: .utf8)!
    print("\(string)")
} catch {
    print("\(error)")
}
