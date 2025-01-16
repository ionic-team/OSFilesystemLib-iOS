import Foundation

public enum OSFILEItemType: Encodable {
    case directory
    case file

    static func create(from fileAttributeType: String?) -> OSFILEItemType {
        fileAttributeType == FileAttributeKey.FileTypeDirectoryValue ? .directory : .file
    }
}

public struct OSFILEItemAttributeModel {
    private(set) public var creationDateTimestamp: Double
    private(set) public var modificationDateTimestamp: Double
    private(set) public var size: UInt64
    private(set) public var type: OSFILEItemType
}

public extension OSFILEItemAttributeModel {
    static func create(from attributeDictionary: [FileAttributeKey: Any]) -> OSFILEItemAttributeModel {
        let creationDate = attributeDictionary[.creationDate] as? Date
        let modificationDate = attributeDictionary[.modificationDate] as? Date
        let size = attributeDictionary[.size] as? UInt64 ?? 0
        let type = attributeDictionary[.type] as? String

        return .init(
            creationDateTimestamp: creationDate?.millisecondsSinceUnixEpoch ?? 0,
            modificationDateTimestamp: modificationDate?.millisecondsSinceUnixEpoch ?? 0,
            size: size,
            type: .create(from: type)
        )
    }
}

extension Date {
    var millisecondsSinceUnixEpoch: Double {
        timeIntervalSince1970 * 1000
    }
}

extension FileAttributeKey {
    static var FileTypeDirectoryValue = "NSFileTypeDirectory"
}
