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
    case directory(type: OSFILEDirectoryType)
    case raw
}

public enum OSFILEDirectoryType {
    case cache
    case document
    case library
    case notSyncedLibrary
    case temporary
}
