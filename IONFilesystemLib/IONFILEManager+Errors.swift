import Foundation

public protocol IONFILEError: LocalizedError, Equatable {
}

public enum IONFILEDirectoryManagerError: IONFILEError {
    case notEmpty
    case alreadyExists

    public var errorDescription: String? {
        switch self {
        case .notEmpty: "Directory is not empty."
        case .alreadyExists: "The directory you are trying to create already exists."
        }
    }
}

public enum IONFILEFileManagerError: IONFILEError {
    case cantCreateURL(forPath: String)
    case cantDecodeData(usingEncoding: IONFILEStringEncoding)
    case directoryNotFound(atPath: String)
    case fileNotFound(atPath: String)
    case missingParentFolder
    case pathEscapesDirectory(path: String, directory: String)

    public var errorDescription: String? {
        switch self {
        case .cantCreateURL(let path): "Can't create URL for path '\(path)'."
        case .cantDecodeData(let encoding): "Can't decode data using encoding .\(encoding.rawValue)."
        case .directoryNotFound(let path): "Can't find directory at path '\(path)'."
        case .fileNotFound(let path): "Can't find file at path '\(path)'."
        case .missingParentFolder: "Parent folder doesn't exist."
        case .pathEscapesDirectory(let path, let directory): "Resolved path '\(path)' is outside of directory '\(directory)'."
        }
    }
}

public enum IONFILEChunkPublisherError: IONFILEError {
    case cantEncodeData(usingEncoding: IONFILEStringEncoding)
    case notAbleToReadFile

    public var errorDescription: String? {
        switch self {
        case .cantEncodeData(let encoding): "Can't encode data using encoding .\(encoding.rawValue)."
        case .notAbleToReadFile: "Can't read file."
        }
    }
}
