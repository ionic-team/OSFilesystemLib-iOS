import Foundation

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

extension OSFLSTManager: OSFLSTFileManager {
    public func readFile(atPath path: String, withEncoding encoding: OSFLSTEncoding) throws -> String {
        let fileURL = URLFactory.create(with: path)

        // Check if the URL requires security-scoped access
        let requiresSecurityScope = fileURL.startAccessingSecurityScopedResource()

        // Use defer to ensure we stop accessing the security-scoped resource
        // only if we started accessing it
        defer {
            if requiresSecurityScope {
                fileURL.stopAccessingSecurityScopedResource()
            }
        }

        return switch encoding {
        case .byteBuffer:
            try readFileAsBase64EncodedString(from: fileURL)
        case .string(let stringEncoding):
            try readFileAsString(from: fileURL, using: stringEncoding.stringEncoding)
        }
    }

    private func readFileAsBase64EncodedString(from fileURL: URL) throws -> String {
        try Data(contentsOf: fileURL).base64EncodedString()
    }

    private func readFileAsString(from fileURL: URL, using stringEncoding: String.Encoding) throws -> String {
        try String(contentsOf: fileURL, encoding: stringEncoding)
    }
}
