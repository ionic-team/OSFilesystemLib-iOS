import Foundation

class MockFileManager: FileManager {
    var error: MockFileManagerError?
    var shouldDirectoryHaveContent: Bool
    var urlsWithinDirectory: [URL]
    var fileExists: Bool
    var fileAttributes: [FileAttributeKey: Any]
    var shouldBeDirectory: ObjCBool

    private(set) var capturedPath: String?
    private(set) var capturedOriginPath: String?
    private(set) var capturedDestinationPath: String?
    private(set) var capturedIntermediateDirectories: Bool = false
    private(set) var capturedSearchPathDirectory: FileManager.SearchPathDirectory?

    init(error: MockFileManagerError? = nil, shouldDirectoryHaveContent: Bool = false, urlsWithinDirectory: [URL] = [], fileExists: Bool = true, fileAttributes: [FileAttributeKey: Any] = [:], shouldBeDirectory: ObjCBool = true) {
        self.error = error
        self.shouldDirectoryHaveContent = shouldDirectoryHaveContent
        self.urlsWithinDirectory = urlsWithinDirectory
        self.fileExists = fileExists
        self.fileAttributes = fileAttributes
        self.shouldBeDirectory = shouldBeDirectory
    }
}

enum MockFileManagerError: Error {
    case createDirectoryError
    case readDirectoryError
    case deleteDirectoryError
    case deleteFileError
    case itemAttributesError
}

extension MockFileManager {
    override func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey: Any]? = nil) throws {
        capturedPath = url.relativePath
        capturedIntermediateDirectories = createIntermediates

        if let error, error == .createDirectoryError {
            throw error
        }
    }

    override func contentsOfDirectory(at url: URL, includingPropertiesForKeys keys: [URLResourceKey]?, options mask: FileManager.DirectoryEnumerationOptions = []) throws -> [URL] {
        capturedPath = url.relativePath

        var urls = [URL]()
        if shouldDirectoryHaveContent {
            urls += [url]
        }

        if let error, error == .readDirectoryError {
            throw error
        }

        return urls
    }

    override func removeItem(at url: URL) throws {
        capturedPath = url.relativePath

        if let error, error == .deleteDirectoryError {
            throw error
        }
    }

    override func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        capturedSearchPathDirectory = directory

        return urlsWithinDirectory
    }

    override func fileExists(atPath path: String) -> Bool {
        fileExists
    }

    override func fileExists(atPath path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) -> Bool {
        isDirectory?.pointee = shouldBeDirectory

        return fileExists
    }

    override func removeItem(atPath path: String) throws {
        capturedPath = path

        if let error, error == .deleteFileError {
            throw error
        }
    }

    override func attributesOfItem(atPath path: String) throws -> [FileAttributeKey: Any] {
        capturedPath = path

        if let error, error == .itemAttributesError {
            throw error
        }

        return fileAttributes
    }

    override func moveItem(atPath srcPath: String, toPath dstPath: String) throws {
        capturedOriginPath = srcPath
        capturedDestinationPath = dstPath
    }

    override func copyItem(atPath srcPath: String, toPath dstPath: String) throws {
        capturedOriginPath = srcPath
        capturedDestinationPath = dstPath
    }
}
