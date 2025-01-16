import Foundation

public protocol OSFILEDirectoryManager {
    func createDirectory(atPath: String, includeIntermediateDirectories: Bool) throws
    func removeDirectory(atPath: String, includeIntermediateDirectories: Bool) throws
    func listDirectory(atPath: String) throws -> [URL]
}

public protocol OSFILEFileManager {
    func readFile(atPath: String, withEncoding: OSFILEEncoding) throws -> String
    func getFileURL(atPath: String, withSearchPath: OSFILESearchPath) throws -> URL
    func deleteFile(atPath: String) throws
    func saveFile(atPath: String, withEncodingAndData: OSFILEEncodingValueMapper, includeIntermediateDirectories: Bool) throws -> URL
    func appendData(_ data: OSFILEEncodingValueMapper, atPath: String, includeIntermediateDirectories: Bool) throws
    func getItemAttributes(atPath: String) throws -> OSFILEItemAttributeModel
    func renameItem(fromPath: String, toPath: String) throws
    func copyItem(fromPath: String, toPath: String) throws
}
