import Foundation

public protocol OSFLSTDirectoryManager {
    func createDirectory(atPath: String, includeIntermediateDirectories: Bool) throws
    func removeDirectory(atPath: String, includeIntermediateDirectories: Bool) throws
}

enum OSFLSTDirectoryManagerError: Error {
    case notEmpty
}

public struct OSFLSTManager {
    private let fileManager: FileManager

    public init(fileManager: FileManager) {
        self.fileManager = fileManager
    }
}

extension OSFLSTManager: OSFLSTDirectoryManager {
    public func createDirectory(atPath path: String, includeIntermediateDirectories: Bool) throws {
        let pathURL = URL(fileURLWithPath: path)
        try fileManager.createDirectory(at: pathURL, withIntermediateDirectories: includeIntermediateDirectories)
    }

    public func removeDirectory(atPath path: String, includeIntermediateDirectories: Bool) throws {
        let pathURL = URL(fileURLWithPath: path)
        if !includeIntermediateDirectories {
            let directoryContents = try fileManager.contentsOfDirectory(at: pathURL, includingPropertiesForKeys: nil)
            if !directoryContents.isEmpty {
                throw OSFLSTDirectoryManagerError.notEmpty
            }
        }
        
        try fileManager.removeItem(at: pathURL)
    }
}
