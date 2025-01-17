import Foundation

public protocol OSFILEDirectoryManager {
    func createDirectory(atURL: URL, includeIntermediateDirectories: Bool) throws
    func removeDirectory(atURL: URL, includeIntermediateDirectories: Bool) throws
    func listDirectory(atURL: URL) throws -> [URL]
}

public protocol OSFILEFileManager {
    func readFile(atURL: URL, withEncoding: OSFILEEncoding) throws -> String
    func getFileURL(atPath: String, withSearchPath: OSFILESearchPath) throws -> URL
    func deleteFile(atURL: URL) throws
    func saveFile(atURL: URL, withEncodingAndData: OSFILEEncodingValueMapper, includeIntermediateDirectories: Bool) throws -> URL
    func appendData(_ data: OSFILEEncodingValueMapper, atURL: URL, includeIntermediateDirectories: Bool) throws
    func getItemAttributes(atPath: String) throws -> OSFILEItemAttributeModel
    func renameItem(fromURL: URL, toURL: URL) throws
    func copyItem(fromURL: URL, toURL: URL) throws
}
