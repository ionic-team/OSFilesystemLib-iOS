import Foundation

class MockFileManager: FileManager {
    var shouldThrowError: Bool

    private(set) var capturedPathURL: URL?
    private(set) var capturedIntermediateDirectories: Bool = false

    init(shouldThrowError: Bool = false) {
        self.shouldThrowError = shouldThrowError
    }
}

enum MockFileManagerError: Error {
    case genericError
}

extension MockFileManager {
    override func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey: Any]? = nil) throws {
        capturedPathURL = url
        capturedIntermediateDirectories = createIntermediates

        if shouldThrowError {
            throw MockFileManagerError.genericError
        }
    }
}
