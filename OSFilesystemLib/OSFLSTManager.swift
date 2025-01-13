import Foundation

public protocol OSFLSTDirectoryManager {
    func createDirectory(atPath: String, includeIntermediateDirectories: Bool) throws
    func removeDirectory(atPath: String, includeIntermediateDirectories: Bool) throws
    func listDirectory(atPath: String) throws -> [URL]
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
        let pathURL = URLFactory.create(with: path)
        try fileManager.createDirectory(at: pathURL, withIntermediateDirectories: includeIntermediateDirectories)
    }

    public func removeDirectory(atPath path: String, includeIntermediateDirectories: Bool) throws {
        let pathURL = URLFactory.create(with: path)
        if !includeIntermediateDirectories {
            let directoryContents = try listDirectory(atPath: path)
            if !directoryContents.isEmpty {
                throw OSFLSTDirectoryManagerError.notEmpty
            }
        }
        
        try fileManager.removeItem(at: pathURL)
    }

    public func listDirectory(atPath path: String) throws -> [URL] {
        let pathURL = URLFactory.create(with: path)
        return try fileManager.contentsOfDirectory(at: pathURL, includingPropertiesForKeys: nil)
    }
}

private struct URLFactory {
    static func create(with path: String) -> URL {
        let url: URL

        if #available(iOS 16.0, *) {
            url = .init(filePath: path)
        } else {
            url = .init(fileURLWithPath: path)
        }

        return url
    }
}
