import Foundation

public struct OSFLSTManager {
    private let fileManager: FileManager

    public init(fileManager: FileManager) {
        self.fileManager = fileManager
    }
}

extension OSFLSTManager: OSFLSTDirectoryManager {
    public func createDirectory(atPath path: String, includeIntermediateDirectories: Bool) throws {
        let pathURL = URL.create(with: path)
        try fileManager.createDirectory(at: pathURL, withIntermediateDirectories: includeIntermediateDirectories)
    }

    public func removeDirectory(atPath path: String, includeIntermediateDirectories: Bool) throws {
        let pathURL = URL.create(with: path)
        if !includeIntermediateDirectories {
            let directoryContents = try listDirectory(atPath: path)
            if !directoryContents.isEmpty {
                throw OSFLSTDirectoryManagerError.notEmpty
            }
        }

        try fileManager.removeItem(at: pathURL)
    }

    public func listDirectory(atPath path: String) throws -> [URL] {
        let pathURL = URL.create(with: path)
        return try fileManager.contentsOfDirectory(at: pathURL, includingPropertiesForKeys: nil)
    }
}

extension OSFLSTManager: OSFLSTFileManager {
    public func readFile(atPath path: String, withEncoding encoding: OSFLSTEncoding) throws -> String {
        let fileURL = URL.create(with: path)

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

    public func getFileURL(atPath path: String, withSearchPath searchPath: OSFLSTSearchPath) throws -> URL {
        return switch searchPath {
        case .directory(let directorySearchPath):
            try resolveDirectoryURL(for: directorySearchPath.fileManagerSearchPathDirectory, with: path)
        case .raw:
            try resolveRawURL(from: path)
        }
    }

    public func deleteFile(atPath path: String) throws {
        guard fileManager.fileExists(atPath: path) else {
            throw OSFLSTFileManagerError.fileNotFound
        }

        try fileManager.removeItem(atPath: path)
    }

    @discardableResult public func saveFile(atPath path: String, withEncodingAndData encodingMapper: OSFLSTEncodingValueMapper, includeIntermediateDirectories: Bool) throws -> URL {
        let fileURL = URL.create(with: path)
        let fileDirectoryURL = fileURL.deletingLastPathComponent()

        if !fileManager.fileExists(atPath: fileDirectoryURL.urlPath) {
            if includeIntermediateDirectories {
                try createDirectory(atPath: fileDirectoryURL.urlPath, includeIntermediateDirectories: true)
            } else {
                throw OSFLSTFileManagerError.missingParentFolder
            }
        }

        switch encodingMapper {
        case .byteBuffer(let value):
            try value.write(to: fileURL)
        case .string(let encoding, let value):
            try value.write(to: fileURL, atomically: false, encoding: encoding.stringEncoding)
        }

        return fileURL
    }

    public func appendData(_ encodingMapper: OSFLSTEncodingValueMapper, atPath path: String, includeIntermediateDirectories: Bool) throws {
        guard fileManager.fileExists(atPath: path) else {
            try saveFile(atPath: path, withEncodingAndData: encodingMapper, includeIntermediateDirectories: includeIntermediateDirectories)
            return
        }

        let dataToAppend: Data
        switch encodingMapper {
        case .byteBuffer(let value):
            dataToAppend = value
        case .string(let encoding, let value):
            guard let valueData = value.data(using: encoding.stringEncoding) else {
                throw OSFLSTFileManagerError.cantDecodeData
            }
            dataToAppend = valueData
        }

        let fileHandle = FileHandle(forWritingAtPath: path)
        try fileHandle?.seekToEnd()
        try fileHandle?.write(contentsOf: dataToAppend)
        try fileHandle?.close()
    }

    public func getItemAttributes(atPath path: String) throws -> OSFLSTItemAttributeModel {
        let attributesDictionary = try fileManager.attributesOfItem(atPath: path)
        return .create(from: attributesDictionary)
    }

    public func renameItem(fromPath origin: String, toPath destination: String) throws {
        try copy(fromPath: origin, toPath: destination) {
            try fileManager.moveItem(atPath: origin, toPath: destination)
        }
    }

    public func copyItem(fromPath origin: String, toPath destination: String) throws {
        try copy(fromPath: origin, toPath: destination) {
            try fileManager.copyItem(atPath: origin, toPath: destination)
        }
    }

    private func readFileAsBase64EncodedString(from fileURL: URL) throws -> String {
        try Data(contentsOf: fileURL).base64EncodedString()
    }

    private func readFileAsString(from fileURL: URL, using stringEncoding: String.Encoding) throws -> String {
        try String(contentsOf: fileURL, encoding: stringEncoding)
    }

    private func resolveDirectoryURL(for searchPath: FileManager.SearchPathDirectory, with path: String) throws -> URL {
        guard let directoryURL = fileManager.urls(for: searchPath, in: .userDomainMask).first else {
            throw OSFLSTFileManagerError.directoryNotFound
        }

        return path.isEmpty ? directoryURL : directoryURL.appendingPathComponent(path)
    }

    private func resolveRawURL(from path: String) throws -> URL {
        guard let rawURL = URL(string: path) else {
            throw OSFLSTFileManagerError.cantCreateURL
        }
        return rawURL
    }

    private func copy(fromPath origin: String, toPath destination: String, performOperation: () throws -> Void) throws {
        guard origin != destination else {
            return
        }

        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: destination, isDirectory: &isDirectory) {
            if !isDirectory.boolValue {
                try deleteFile(atPath: destination)
            }
        }

        try performOperation()
    }
}
