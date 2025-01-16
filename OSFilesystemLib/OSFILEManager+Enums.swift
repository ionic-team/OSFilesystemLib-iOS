import Foundation

public enum OSFILEEncoding {
    case byteBuffer
    case string(encoding: OSFILEStringEncoding)
}

public enum OSFILEEncodingValueMapper {
    case byteBuffer(value: Data)
    case string(encoding: OSFILEStringEncoding, value: String)
}

public enum OSFILEStringEncoding {
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

public enum OSFILESearchPath {
    case directory(searchPath: OSFILESearchPathDirectory)
    case raw
}

public enum OSFILESearchPathDirectory {
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
