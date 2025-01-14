import Foundation

public protocol OSFLSTDirectoryManager {
    func createDirectory(atPath: String, includeIntermediateDirectories: Bool) throws
    func removeDirectory(atPath: String, includeIntermediateDirectories: Bool) throws
    func listDirectory(atPath: String) throws -> [URL]
}

public protocol OSFLSTFileManager {
    func readFile(atPath: String, withEncoding: OSFLSTEncoding) throws -> String
}

enum OSFLSTDirectoryManagerError: Error {
    case notEmpty
}

public enum OSFLSTEncoding {
    case byteBuffer
    case string(encoding: OSFLSTStringEncoding)
}

public enum OSFLSTStringEncoding {
    case ascii
    case utf8
    case utf16

    var stringEncoding: String.Encoding {
        switch self {
        case .ascii: .ascii
        case .utf8: .utf8
        case .utf16: .utf16
        }
    }
}
