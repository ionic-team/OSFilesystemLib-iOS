import Foundation

public protocol OSFLSTDirectoryManager {
    func createDirectory(atPathURL: URL, includeIntermediateDirectories: Bool) throws
}

public struct OSFLSTManager {
    private let fileManager: FileManager

    public init(fileManager: FileManager) {
        self.fileManager = fileManager
    }
}

extension OSFLSTManager: OSFLSTDirectoryManager {
    public func createDirectory(atPathURL pathURL: URL, includeIntermediateDirectories: Bool) throws {
        try fileManager.createDirectory(at: pathURL, withIntermediateDirectories: includeIntermediateDirectories)
    }
}
