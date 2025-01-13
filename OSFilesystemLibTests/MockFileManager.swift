import Foundation

class MockFileManager: FileManager {
    var error: MockFileManagerError?
    var shouldDirectoryHaveContent: Bool

    private(set) var capturedPath: String?
    private(set) var capturedIntermediateDirectories: Bool = false

    init(error: MockFileManagerError? = nil, shouldDirectoryHaveContent: Bool = false) {
        self.error = error
        self.shouldDirectoryHaveContent = shouldDirectoryHaveContent
    }
}

enum MockFileManagerError: Error {
    case createDirectoryError
    case readDirectoryError
    case deleteDirectoryError
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
}
