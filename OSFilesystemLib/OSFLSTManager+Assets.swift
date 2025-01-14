import Foundation

public protocol OSFLSTDirectoryManager {
    func createDirectory(atPath: String, includeIntermediateDirectories: Bool) throws
    func removeDirectory(atPath: String, includeIntermediateDirectories: Bool) throws
    func listDirectory(atPath: String) throws -> [URL]
}

enum OSFLSTDirectoryManagerError: Error {
    case notEmpty
}

public protocol OSFLSTFileManager {
    func readFile(atPath: String, withEncoding: OSFLSTEncoding) throws -> String
    func getFileURL(atPath: String, withSearchPath: OSFLSTSearchPath) throws -> URL
    func deleteFile(atPath: String) throws
}

enum OSFLSTFileManagerError: Error {
    case cantCreateURL
    case directoryNotFound
    case fileNotFound
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

public enum OSFLSTSearchPath {
    case directory(searchPath: OSFLSTSearchPathDirectory)
    case raw
}

public enum OSFLSTSearchPathDirectory {
    case cache
    case document
    case library

    var fileManagerSearchPathDirectory: FileManager.SearchPathDirectory {
        switch self {
        case .cache: .cachesDirectory
        case .document: .documentDirectory
        case .library: .libraryDirectory
        }
    }
}
