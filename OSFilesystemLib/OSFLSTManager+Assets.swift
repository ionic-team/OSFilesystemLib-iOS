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
    func saveFile(atPath: String, withEncodingAndData: OSFLSTEncodingValueMapper, includeIntermediateDirectories: Bool) throws -> URL
    func appendData(_ data: OSFLSTEncodingValueMapper, atPath: String, includeIntermediateDirectories: Bool) throws
    func getItemAttributes(atPath: String) throws -> OSFLSTItemAttributeModel
    func renameItem(fromPath: String, toPath: String) throws
    func copyItem(fromPath: String, toPath: String) throws
}

enum OSFLSTFileManagerError: Error {
    case cantCreateURL
    case cantDecodeData
    case directoryNotFound
    case fileNotFound
    case missingParentFolder
}

public enum OSFLSTEncoding {
    case byteBuffer
    case string(encoding: OSFLSTStringEncoding)
}

public enum OSFLSTEncodingValueMapper {
    case byteBuffer(value: Data)
    case string(encoding: OSFLSTStringEncoding, value: String)
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
