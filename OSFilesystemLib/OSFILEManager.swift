import Foundation

public struct OSFILEManager {
    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
}

extension OSFILEManager: OSFILEDirectoryManager {
    public func createDirectory(atURL pathURL: URL, includeIntermediateDirectories: Bool) throws {
        try fileManager.createDirectory(at: pathURL, withIntermediateDirectories: includeIntermediateDirectories)
    }

    public func removeDirectory(atURL pathURL: URL, includeIntermediateDirectories: Bool) throws {
        if !includeIntermediateDirectories {
            let directoryContents = try listDirectory(atURL: pathURL)
            if !directoryContents.isEmpty {
                throw OSFILEDirectoryManagerError.notEmpty
            }
        }

        try fileManager.removeItem(at: pathURL)
    }

    public func listDirectory(atURL pathURL: URL) throws -> [URL] {
        return try fileManager.contentsOfDirectory(at: pathURL, includingPropertiesForKeys: nil)
    }
}

extension OSFILEManager: OSFILEFileManager {
    public func readFile(atURL fileURL: URL, withEncoding encoding: OSFILEEncoding) throws -> String {
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

    public func getFileURL(atPath path: String, withSearchPath searchPath: OSFILESearchPath) throws -> URL {
        return switch searchPath {
        case .directory(let directorySearchPath):
            try resolveDirectoryURL(for: directorySearchPath.fileManagerSearchPathDirectory, with: path)
        case .raw:
            try resolveRawURL(from: path)
        }
    }

    public func deleteFile(atURL url: URL) throws {
        guard fileManager.fileExists(atPath: url.urlPath) else {
            throw OSFILEFileManagerError.fileNotFound
        }

        try fileManager.removeItem(at: url)
    }

    @discardableResult
    public func saveFile(atURL fileURL: URL, withEncodingAndData encodingMapper: OSFILEEncodingValueMapper, includeIntermediateDirectories: Bool) throws -> URL {
        let fileDirectoryURL = fileURL.deletingLastPathComponent()

        if !fileManager.fileExists(atPath: fileDirectoryURL.urlPath) {
            if includeIntermediateDirectories {
                try createDirectory(atURL: fileDirectoryURL, includeIntermediateDirectories: true)
            } else {
                throw OSFILEFileManagerError.missingParentFolder
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

    public func appendData(_ encodingMapper: OSFILEEncodingValueMapper, atURL url: URL, includeIntermediateDirectories: Bool) throws {
        guard fileManager.fileExists(atPath: url.urlPath) else {
            try saveFile(atURL: url, withEncodingAndData: encodingMapper, includeIntermediateDirectories: includeIntermediateDirectories)
            return
        }

        let dataToAppend: Data
        switch encodingMapper {
        case .byteBuffer(let value):
            dataToAppend = value
        case .string(let encoding, let value):
            guard let valueData = value.data(using: encoding.stringEncoding) else {
                throw OSFILEFileManagerError.cantDecodeData
            }
            dataToAppend = valueData
        }

        let fileHandle = try FileHandle(forWritingTo: url)
        try fileHandle.seekToEnd()
        try fileHandle.write(contentsOf: dataToAppend)
        try fileHandle.close()
    }

    public func getItemAttributes(atPath path: String) throws -> OSFILEItemAttributeModel {
        let attributesDictionary = try fileManager.attributesOfItem(atPath: path)
        return .create(from: attributesDictionary)
    }

    public func renameItem(fromURL originURL: URL, toURL destinationURL: URL) throws {
        try copy(fromURL: originURL, toURL: destinationURL) {
            try fileManager.moveItem(at: originURL, to: destinationURL)
        }
    }

    public func copyItem(fromURL originURL: URL, toURL destinationURL: URL) throws {
        try copy(fromURL: originURL, toURL: destinationURL) {
            try fileManager.copyItem(at: originURL, to: destinationURL)
        }
    }
}

private extension OSFILEManager {
    func readFileAsBase64EncodedString(from fileURL: URL) throws -> String {
        try Data(contentsOf: fileURL).base64EncodedString()
    }

    func readFileAsString(from fileURL: URL, using stringEncoding: String.Encoding) throws -> String {
        try String(contentsOf: fileURL, encoding: stringEncoding)
    }

    func resolveDirectoryURL(for searchPath: FileManager.SearchPathDirectory, with path: String) throws -> URL {
        guard let directoryURL = fileManager.urls(for: searchPath, in: .userDomainMask).first else {
            throw OSFILEFileManagerError.directoryNotFound
        }

        return path.isEmpty ? directoryURL : directoryURL.appendingPathComponent(path)
    }

    func resolveRawURL(from path: String) throws -> URL {
        guard let rawURL = URL(string: path) else {
            throw OSFILEFileManagerError.cantCreateURL
        }
        return rawURL
    }

    func copy(fromURL originURL: URL, toURL destinationURL: URL, performOperation: () throws -> Void) throws {
        guard originURL != destinationURL else {
            return
        }

        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: destinationURL.urlPath, isDirectory: &isDirectory) {
            if !isDirectory.boolValue {
                try deleteFile(atURL: destinationURL)
            }
        }

        try performOperation()
    }
}
