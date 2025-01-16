enum OSFILEDirectoryManagerError: Error {
    case notEmpty
}

enum OSFILEFileManagerError: Error {
    case cantCreateURL
    case cantDecodeData
    case directoryNotFound
    case fileNotFound
    case missingParentFolder
}
