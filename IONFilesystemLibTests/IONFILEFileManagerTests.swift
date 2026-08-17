import Combine
import XCTest

@testable import IONFilesystemLib

final class IONFILEFileManagerTests: XCTestCase {
    private var sut: IONFILEManager!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        cancellables = .init()
    }

    override func tearDown() {
        cancellables = nil
        sut = nil
    }
}

// MARK: - 'readEntireFile` tests
extension IONFILEFileManagerTests {
    func test_readEntireFile_withStringEncoding_returnsContentSuccessfully() throws {
        // Given
        createFileManager()

        // When
        let fileContent = try fetchEntireContent(
            forFile: (Configuration.fileName, Configuration.fileExtension), withEncoding: .string(encoding: .utf8)
        )

        // Then
        XCTAssertEqual(fileContent, Configuration.fileContent)
    }

    func test_readEntireFile_withByteBufferEncoding_returnsContentSuccessfully() throws {
        // Given
        createFileManager()

        // When
        let fileContent = try fetchEntireContent(
            forFile: (Configuration.fileName, Configuration.fileExtension), withEncoding: .byteBuffer
        )

        // Then
        XCTAssertEqual(fileContent, Configuration.fileContent)
    }

    func test_readEntireFile_thatDoesntExist_returnsError() throws {
        // Given
        createFileManager()
        let fileURL: URL = try XCTUnwrap(.init(string: "/file/directory"))

        // When and Then
        XCTAssertThrowsError(try fetchEntireContent(forURL: fileURL, withEncoding: .string(encoding: .utf8)))
    }
    
    func test_readEntireFile_thatDoesntExist_returnsFileNotFound() throws {
        // Given
        createFileManager(fileExists: false)
        let fileURL = URL(filePath: "/file/directory")

        // When
        XCTAssertThrowsError(try sut.readEntireFile(atURL: fileURL, withEncoding: .string(encoding: .utf8))) {
            //Then
            XCTAssertEqual($0 as? IONFILEFileManagerError, .fileNotFound(atPath: fileURL.urlPath))
        }
    }
    
    func test_readEntireFile_offsetAndLengthWithExampleEncoding_returnsCorrectData() throws {
        // Given
        createFileManager()
        let fileURL = try XCTUnwrap(fetchConfigurationFile())
        let offset = 7
        let length = 5
        let encoding: IONFILEStringEncoding = .utf8
        
        // When
        let result = try sut.readEntireFile(atURL: fileURL, withEncoding: .string(encoding: encoding), andOffset: offset, andLength: length)
        
        // Then
        guard case .string(let resultEncoding, let resultValue) = result else {
            XCTFail("Wrong result type")
            return
        }
        XCTAssertEqual(resultEncoding, encoding)
        XCTAssertEqual(resultValue, "world")
    }
    
    func test_readEntire_offsetAndLengthWithByteBufferEncoding_returnsCorrectData() throws {
        // Given
        createFileManager()
        let fileURL = try XCTUnwrap(fetchConfigurationFile())
        let offset = 7
        let length = 5
        
        // When
        let result = try sut.readEntireFile(atURL: fileURL, withEncoding: .byteBuffer, andOffset: offset, andLength: length)
        
        // Then
        guard case .byteBuffer(let resultValue) = result else {
            XCTFail("Wrong result type")
            return
        }
        XCTAssertEqual(String(data: resultValue, encoding: .utf8), "world")
    }
    
    func test_readEntireFile_offsetLargerThanEOF_returnsEmptyString() throws {
        // Given
        createFileManager()
        let fileURL = try XCTUnwrap(fetchConfigurationFile())
        let offset = 1000
        let length = 5
        let encoding: IONFILEStringEncoding = .utf8
        
        // When
        let result = try sut.readEntireFile(atURL: fileURL, withEncoding: .string(encoding: encoding), andOffset: offset, andLength: length)
        
        // Then
        guard case .string(_, let resultValue) = result else {
            XCTFail("Wrong result type")
            return
        }
        XCTAssertEqual(resultValue, "")
    }
}

// MARK: - 'readFileInChunks' tests
extension IONFILEFileManagerTests {
    func test_readFileInChunks_withStringEncoding_returnsContentSuccessfully() throws {
        // Given
        createFileManager()

        // When
        let fileContent = try fetchChunkedContent(
            forFile: (Configuration.fileName, Configuration.fileExtension), withEncoding: .string(encoding: .utf8)
        )

        // Then
        XCTAssertEqual(fileContent, Configuration.fileContent)
    }

    func test_readFileInChunks_withByteBufferEncoding_returnsContentSuccessfully() throws {
        // Given
        createFileManager()

        // When
        let fileContent = try fetchChunkedContent(
            forFile: (Configuration.fileName, Configuration.fileExtension), withEncoding: .byteBuffer
        )

        // Then
        XCTAssertEqual(fileContent, Configuration.fileContent)
    }

    func test_readFileInChunks_notAbleToReadFile_returnsError() {
        // Given
        createFileManager()

        // When
        XCTAssertThrowsError(try fetchChunkedContent(
            forFile: (Configuration.fileName, Configuration.fileExtension), withEncoding: .string(encoding: .utf8), forceURLError: true
        )) {
            // Then
            XCTAssertEqual($0 as? IONFILEChunkPublisherError, .notAbleToReadFile)
        }
    }

    func test_readFileInChunks_thatDoesntExist_returnsError() throws {
        // Given
        createFileManager()
        let fileURL: URL = try XCTUnwrap(.init(string: "/file/directory"))

        // When and Then
        XCTAssertThrowsError(try fetchChunkedContent(forURL: fileURL, withEncoding: .string(encoding: .utf8)))
    }
    
    func test_readFileInChunks_thatDoesntExist_returnsFileNotFound() throws {
        // Given
        createFileManager(fileExists: false)
        let fileURL = URL(filePath: "/file/directory")
        
        // When
        XCTAssertThrowsError(try fetchChunkedContent(forURL: fileURL, withEncoding: .string(encoding: .utf8))) {
            // Then
            XCTAssertEqual($0 as? IONFILEFileManagerError, .fileNotFound(atPath: fileURL.urlPath))
        }
    }
    
    func test_readFileInChunks_withOffsetAndLength_returnsContentSuccessfully() throws {
        // Given
        createFileManager()
        let offset = 7
        let length = 5

        // When
        let fileContent = try fetchChunkedContent(
            forFile: (Configuration.fileName, Configuration.fileExtension), withEncoding: .string(encoding: .utf8), andOffset: offset, andLength: length
        )

        // Then
        XCTAssertEqual(fileContent, "world")
    }
    
    func test_readFileInChunks_offsetLargerThanEOF_returnsEmptyString() throws {
        // Given
        createFileManager()
        let offset = 1000
        let length = 5

        // When
        let fileContent = try fetchChunkedContent(
            forFile: (Configuration.fileName, Configuration.fileExtension), withEncoding: .string(encoding: .utf8), andOffset: offset, andLength: length
        )

        // Then
        XCTAssertEqual(fileContent, "")
    }
}

// MARK: - 'getFileURL' tests
extension IONFILEFileManagerTests {
    func test_getFileURL_fromDirectorySearchPath_containingSingleFile_returnsFileSuccessfully() throws {
        // Given
        let fileURL: URL = try XCTUnwrap(.init(string: "/file/directory"))
        let fileManager = createFileManager(urlsWithinDirectory: [fileURL])
        let filePath = "/test/directory"
        let directoryType = IONFILEDirectoryType.cache

        // When
        let returnedURL = try sut.getFileURL(atPath: filePath, withSearchPath: .directory(type: directoryType))

        // Then
        XCTAssertEqual(fileManager.capturedSearchPathDirectory, .cachesDirectory)
        XCTAssertEqual(fileURL.appendingPathComponent(filePath, isDirectory: true), returnedURL)
    }

    func test_getFileURL_fromDirectorySearchPath_containingMultipleFiles_returnsFirstFileSuccessfully() throws {
        // Given
        let fileURL: URL = try XCTUnwrap(.init(string: "/file/directory"))
        let ignoredFileURL: URL = try XCTUnwrap(.init(string: "another_file/directory"))
        let fileManager = createFileManager(urlsWithinDirectory: [fileURL, ignoredFileURL])
        let filePath = "/test///directory//"
        let directoryType = IONFILEDirectoryType.cache

        // When
        let returnedURL = try sut.getFileURL(atPath: filePath, withSearchPath: .directory(type: directoryType))

        // Then
        XCTAssertEqual(fileManager.capturedSearchPathDirectory, .cachesDirectory)
        XCTAssert(!returnedURL.absoluteString.contains("//"))
        XCTAssertEqual(fileURL.appendingPathComponent("/test/directory", isDirectory: true), returnedURL)
    }

    func test_getFileURL_fromDocumentDirectorySearchPath_returnsFileSuccessfully() throws {
        // Given
        let fileURL: URL = try XCTUnwrap(.init(string: "/file/directory"))
        let fileManager = createFileManager(urlsWithinDirectory: [fileURL])
        let filePath = "/test/directory"
        let directoryType = IONFILEDirectoryType.document

        // When
        let returnedURL = try sut.getFileURL(atPath: filePath, withSearchPath: .directory(type: directoryType))

        // Then
        XCTAssertEqual(fileManager.capturedSearchPathDirectory, .documentDirectory)
        XCTAssertEqual(fileURL.appendingPathComponent(filePath, isDirectory: true), returnedURL)
    }

    func test_getFileURL_fromLibraryDirectorySearchPath_returnsFileSuccessfully() throws {
        // Given
        let fileURL: URL = try XCTUnwrap(.init(string: "/file/directory"))
        let fileManager = createFileManager(urlsWithinDirectory: [fileURL])
        let filePath = "/test/directory"
        let directoryType = IONFILEDirectoryType.library

        // When
        let returnedURL = try sut.getFileURL(atPath: filePath, withSearchPath: .directory(type: directoryType))

        // Then
        XCTAssertEqual(fileManager.capturedSearchPathDirectory, .libraryDirectory)
        XCTAssertEqual(fileURL.appendingPathComponent(filePath, isDirectory: true), returnedURL)
    }

    func test_getFileURL_fromNotSyncedLibraryDirectorySearchPath_returnsFileSuccessfully() throws {
        // Given
        let fileURL: URL = try XCTUnwrap(.init(string: "/file/directory"))
        let fileManager = createFileManager(urlsWithinDirectory: [fileURL])
        let filePath = "/test/directory/"
        let directoryType = IONFILEDirectoryType.notSyncedLibrary

        // When
        let returnedURL = try sut.getFileURL(atPath: filePath, withSearchPath: .directory(type: directoryType))

        // Then
        XCTAssertEqual(fileManager.capturedSearchPathDirectory, .libraryDirectory)
        XCTAssert(!returnedURL.absoluteString.contains("//"))
        XCTAssertEqual(fileURL.appending(path: "NoCloud").appendingPathComponent("/test/directory", isDirectory: true), returnedURL)
    }

    func test_getFileURL_fromTemporaryDirectorySearchPath_returnsFileSuccessfully() throws {
        // Given
        let parentFolderURL: URL = try XCTUnwrap(.init(string: "/file"))
        let fileURL: URL = parentFolderURL.appending(path: "/directory")
        let fileManager = createFileManager(urlsWithinDirectory: [fileURL], mockTemporaryDirectory: parentFolderURL)
        let filePath = "/test/directory"
        let directoryType = IONFILEDirectoryType.temporary

        // When
        let returnedURL = try sut.getFileURL(atPath: filePath, withSearchPath: .directory(type: directoryType))

        // Then
        XCTAssertEqual(fileManager.temporaryDirectory, parentFolderURL)
        XCTAssertEqual(parentFolderURL.appendingPathComponent(filePath, isDirectory: true), returnedURL)
    }

    func test_getFileURL_fromDirectorySearchPath_containingNoFiles_returnsError() {
        // Given
        createFileManager()
        let filePath = "/test/directory"
        let directoryType = IONFILEDirectoryType.cache

        // When
        XCTAssertThrowsError(try sut.getFileURL(atPath: filePath, withSearchPath: .directory(type: directoryType))) {
            // Then
            XCTAssertEqual($0 as? IONFILEFileManagerError, .directoryNotFound(atPath: filePath))
        }
    }

    func test_getFileURL_fromDirectorySearchPath_withNoPath_returnsFileSuccessfully() throws {
        // Given
        let fileURL: URL = try XCTUnwrap(.init(string: "/file/directory"))
        let fileManager = createFileManager(urlsWithinDirectory: [fileURL])
        let emptyFilePath = ""
        let directoryType = IONFILEDirectoryType.cache

        // When
        let returnedURL = try sut.getFileURL(atPath: emptyFilePath, withSearchPath: .directory(type: directoryType))

        // Then
        XCTAssertEqual(fileManager.capturedSearchPathDirectory, .cachesDirectory)
        XCTAssertEqual(fileURL.appendingPathComponent(""), returnedURL)
    }

    func test_getFileURL_rawFile_returnsFileSuccessfully() throws {
        // Given
        createFileManager()
        let filePath = "/test/directory"

        // When
        let returnedURL = try sut.getFileURL(atPath: filePath, withSearchPath: .raw)

        // Then
        XCTAssertEqual(filePath + "/", returnedURL.path())
        XCTAssertTrue(returnedURL.isFileURL)
    }

    func test_getFileURL_doesNotExist_returnsFileSuccessfully() throws {
        // Given
        createFileManager(fileExists: false)
        let filePath = "/test/directory"

        // When
        let returnedURL = try sut.getFileURL(atPath: filePath, withSearchPath: .raw)

        // Then
        XCTAssertEqual(filePath + "/", returnedURL.path())
        XCTAssertTrue(returnedURL.isFileURL)
    }

    func test_getFileURL_rawFile_fromBarePath_isResolvedAsFileURL() throws {
        // Given
        createFileManager(shouldBeDirectory: false)
        let filePath = "/test/directory/random_doc.pdf"

        // When
        let returnedURL = try sut.getFileURL(atPath: filePath, withSearchPath: .raw)

        // Then
        XCTAssertTrue(returnedURL.isFileURL)
        XCTAssertEqual(returnedURL.scheme, "file")
        XCTAssertEqual(returnedURL.absoluteString, "file://" + filePath)
    }

    func test_getFileURL_rawFile_fromBarePath_canActuallyBeRead() throws {
        // Given: a bare path (no "file://" scheme), as returned by e.g. the contacts plugin
        // when writing a contact photo to the temporary directory on iOS.
        createFileManager(shouldBeDirectory: false)
        let configurationFileURL = try XCTUnwrap(fetchConfigurationFile())
        let barePath = configurationFileURL.path

        // When
        let resolvedURL = try sut.getFileURL(atPath: barePath, withSearchPath: .raw)
        let result = try sut.readEntireFile(atURL: resolvedURL, withEncoding: .string(encoding: .utf8))

        // Then
        guard case .string(_, let content) = result else {
            XCTFail("Wrong result type")
            return
        }
        XCTAssertEqual(content, Configuration.fileContent)
    }

    func test_getFileURL_rawFile_fromInvalidPath_returnsError() {
        // Given
        createFileManager()
        let emptyFilePath = ""

        // When
        XCTAssertThrowsError(try sut.getFileURL(atPath: emptyFilePath, withSearchPath: .raw)) {
            // Then
            XCTAssertEqual($0 as? IONFILEFileManagerError, .cantCreateURL(forPath: emptyFilePath))
        }
    }
    
    func test_getFileURL_withFileScheme_returnsFileSuccessfully() throws {
        // Given
        createFileManager()
        let filePath = "file://test/directory"

        // When
        let returnedURL = try sut.getFileURL(atPath: filePath, withSearchPath: .raw)

        // Then
        XCTAssertEqual(filePath + "/", returnedURL.absoluteString)
    }
    
    func test_getFileURL_withFileSchemeTripleSlash_returnsFileSuccessfully() throws {
        // Given
        createFileManager()
        let filePath = "file:///test/directory"

        // When
        let returnedURL = try sut.getFileURL(atPath: filePath, withSearchPath: .raw)

        // Then
        XCTAssertEqual(filePath + "/", returnedURL.absoluteString)
    }
    
    func test_getFileURL_withNonExistingFile_returnsFileSuccessfullyWithoutTrailingSlash() throws {
        // Given
        createFileManager(fileExists: false, shouldBeDirectory: false)
        let filePath = "/test/directory/random_doc.pdf"

        // When
        let returnedURL = try sut.getFileURL(atPath: filePath, withSearchPath: .raw)

        // Then
        XCTAssertEqual("file://" + filePath, returnedURL.absoluteString)
    }
}

// MARK: - 'deleteFile' tests
extension IONFILEFileManagerTests {
    func test_deleteFile_shouldBeSuccessful() throws {
        // Given
        let fileManager = createFileManager()
        let filePath = URL(filePath: "/test/directory")

        // When
        try sut.deleteFile(atURL: filePath)

        // Then
        XCTAssertEqual(fileManager.capturedPath, filePath)
    }

    func test_deleteFile_thatDoesntExist_shouldReturnError() {
        // Given
        createFileManager(fileExists: false)
        let filePath = URL(filePath: "/test/directory")

        // When
        XCTAssertThrowsError(try sut.deleteFile(atURL: filePath)) {
            // Then
            XCTAssertEqual($0 as? IONFILEFileManagerError, .fileNotFound(atPath: filePath.urlPath))
        }
    }

    func test_deleteFile_thatFailsWhileDeleting_shouldReturnError() {
        // Given
        let error = MockFileManagerError.deleteFileError
        createFileManager(error: error)
        let filePath = URL(filePath: "/test/directory")

        // When
        XCTAssertThrowsError(try sut.deleteFile(atURL: filePath)) {
            // Then
            XCTAssertEqual($0 as? MockFileManagerError, error)
        }
    }
}

// MARK: - 'saveFile' tests
extension IONFILEFileManagerTests {
    func test_saveFile_withStringEncoding_savesFileSuccessfullyAndReturnsItsURL() throws {
        // Given
        let fileManager = createFileManager()
        let fileURL = try XCTUnwrap(fetchConfigurationFile())
            .deletingLastPathComponent()
            .appending(path: "\(Configuration.newFileName).\(Configuration.fileExtension)")
        let stringEncoding = IONFILEStringEncoding.ascii
        let contentToSave = Configuration.stringEncodedFileContent
        let shouldIncludeIntermediateDirectories = false

        // When
        try sut.saveFile(
            atURL: fileURL,
            withEncodingAndData: .string(encoding: stringEncoding, value: contentToSave),
            includeIntermediateDirectories: shouldIncludeIntermediateDirectories
        )

        // Then
        XCTAssertEqual(fileManager.capturedIntermediateDirectories, shouldIncludeIntermediateDirectories)

        let savedFileContent = try fetchEntireContent(forURL: fileURL, withEncoding: .string(encoding: stringEncoding))
        XCTAssertEqual(savedFileContent, contentToSave)

        try sut.deleteFile(atURL: fileURL)  // keep things clean by deleting created file
    }

    func test_saveFile_withByteBufferEncoding_savesFileSuccessfullyAndReturnsItsURL() throws {
        // Given
        let fileManager = createFileManager()
        let fileURL = try XCTUnwrap(fetchConfigurationFile())
            .deletingLastPathComponent()
            .appending(path: "\(Configuration.newFileName).\(Configuration.fileExtension)")
        let contentToSave = Configuration.byteBufferEncodedFileContent
        let contentToSaveData = try XCTUnwrap(contentToSave.data(using: .utf8))
        let shouldIncludeIntermediateDirectories = false

        // When
        try sut.saveFile(
            atURL: fileURL,
            withEncodingAndData: .byteBuffer(value: contentToSaveData),
            includeIntermediateDirectories: shouldIncludeIntermediateDirectories
        )

        // Then
        XCTAssertEqual(fileManager.capturedIntermediateDirectories, shouldIncludeIntermediateDirectories)

        let savedFileContent = try fetchEntireContent(forURL: fileURL, withEncoding: .byteBuffer)
        XCTAssertEqual(savedFileContent, contentToSave)

        try sut.deleteFile(atURL: fileURL)  // keep things clean by deleting created file
    }

    func test_saveFile_parentFolderMissing_shouldCreateIt_savesFileSuccessfullyAndReturnsItsURL() throws {
        // Given
        let fileManager = createFileManager(fileExists: false)
        let parentFolderURL = try XCTUnwrap(fetchConfigurationFile())
            .deletingLastPathComponent()
        let fileURL = parentFolderURL
            .appending(path: "\(Configuration.newFileName).\(Configuration.fileExtension)")
        let stringEncoding = IONFILEStringEncoding.ascii
        let contentToSave = Configuration.stringEncodedFileContent
        let shouldIncludeIntermediateDirectories = true

        // When
        try sut.saveFile(
            atURL: fileURL,
            withEncodingAndData: .string(encoding: stringEncoding, value: contentToSave),
            includeIntermediateDirectories: shouldIncludeIntermediateDirectories
        )

        // Then
        XCTAssertEqual(fileManager.capturedIntermediateDirectories, shouldIncludeIntermediateDirectories)
        XCTAssertEqual(fileManager.capturedPath, parentFolderURL)
        
        fileManager.fileExists = true
        let savedFileContent = try fetchEntireContent(forURL: fileURL, withEncoding: .string(encoding: stringEncoding))
        XCTAssertEqual(savedFileContent, contentToSave)
        
        try sut.deleteFile(atURL: fileURL)  // keep things clean by deleting created file
    }

    func test_saveFile_parentFolderMissing_shouldntCreateIt_returnsError() throws {
        // Given
        createFileManager(fileExists: false)
        let parentFolderURL = try XCTUnwrap(fetchConfigurationFile())
            .deletingLastPathComponent()
        let fileURL = parentFolderURL
            .appending(path: "\(Configuration.newFileName).\(Configuration.fileExtension)")
        let stringEncoding = IONFILEStringEncoding.ascii
        let contentToSave = Configuration.stringEncodedFileContent
        let shouldIncludeIntermediateDirectories = false

        // When
        XCTAssertThrowsError(try sut.saveFile(
            atURL: fileURL,
            withEncodingAndData: .string(encoding: stringEncoding, value: contentToSave),
            includeIntermediateDirectories: shouldIncludeIntermediateDirectories)
        ) {
            // Then
            XCTAssertEqual($0 as? IONFILEFileManagerError, .missingParentFolder)
        }
    }
}

// MARK: - 'appendData' tests
extension IONFILEFileManagerTests {
    func test_appendData_withStringEncoding_savesFileSuccessfully() throws {
        // Given
        createFileManager()
        let fileURL = try XCTUnwrap(fetchConfigurationFile())
        let stringEncoding = IONFILEStringEncoding.ascii
        let contentToAdd = Configuration.fileExtendedContent

        // When
        try sut.appendData(
            .string(encoding: stringEncoding, value: contentToAdd),
            atURL: fileURL,
            includeIntermediateDirectories: false
        )

        // Then
        let savedFileContent = try fetchEntireContent(forURL: fileURL, withEncoding: .string(encoding: stringEncoding))
        XCTAssertEqual(savedFileContent, Configuration.fileContent + contentToAdd)

        try sut.saveFile(    // keep things clean by resetting file
            atURL: fileURL,
            withEncodingAndData: .string(encoding: stringEncoding, value: Configuration.fileContent),
            includeIntermediateDirectories: false
        )
    }

    func test_appendData_withByteBufferEncoding_savesFileSuccessfully() throws {
        // Given
        createFileManager()
        let fileURL = try XCTUnwrap(fetchConfigurationFile())
        let contentToAdd = Configuration.byteBufferEncodedFileContent
        let contentToAddData = try XCTUnwrap(contentToAdd.data(using: .utf8))

        // When
        try sut.appendData(
            .byteBuffer(value: contentToAddData),
            atURL: fileURL,
            includeIntermediateDirectories: false
        )

        // Then
        let savedFileContent = try fetchEntireContent(forURL: fileURL, withEncoding: .byteBuffer)
        XCTAssertEqual(savedFileContent, Configuration.fileContent + contentToAdd)

        try sut.saveFile(    // keep things clean by resetting file
            atURL: fileURL,
            withEncodingAndData: .string(encoding: .ascii, value: Configuration.fileContent),
            includeIntermediateDirectories: false
        )
    }

    func test_appendData_fileDoesntExist_createsNewFileSuccessfully() throws {
        // Given
        let fileManager = createFileManager(fileExists: false)
        let parentFolderURL = try XCTUnwrap(fetchConfigurationFile())
            .deletingLastPathComponent()
        let fileURL = parentFolderURL
            .appending(path: "\(Configuration.newFileName).\(Configuration.fileExtension)")
        let stringEncoding = IONFILEStringEncoding.ascii
        let contentToAdd = Configuration.stringEncodedFileContent
        let shouldIncludeIntermediateDirectories = true

        // When
        try sut.appendData(
            .string(encoding: stringEncoding, value: contentToAdd),
            atURL: fileURL,
            includeIntermediateDirectories: shouldIncludeIntermediateDirectories
        )

        XCTAssertEqual(fileManager.capturedPath, parentFolderURL)
        XCTAssertEqual(fileManager.capturedIntermediateDirectories, shouldIncludeIntermediateDirectories)

        // Then
        fileManager.fileExists = true
        let savedFileContent = try fetchEntireContent(forURL: fileURL, withEncoding: .string(encoding: stringEncoding))

        XCTAssertEqual(savedFileContent, contentToAdd)

        try sut.deleteFile(atURL: fileURL)  // keep things clean by deleting created file
    }

    func test_appendData_withStringEncoding_textCantBeDecoded_returnsError() throws {
        // Given
        createFileManager()
        let fileURL = try XCTUnwrap(fetchConfigurationFile())
        let stringEncoding = IONFILEStringEncoding.ascii
        let contentToAdd = Configuration.emojiContent   // ASCII can't represent emoji so the conversion will fail.

        // When
        XCTAssertThrowsError(try sut.appendData(
            .string(encoding: stringEncoding, value: contentToAdd),
            atURL: fileURL,
            includeIntermediateDirectories: false)
        ) {
            // Then
            XCTAssertEqual($0 as? IONFILEFileManagerError, .cantDecodeData(usingEncoding: stringEncoding))
        }
    }
}

// MARK: - 'getItemAttributes' tests
extension IONFILEFileManagerTests {
    func test_getItemAttributes_forFile_returnsFileAttributeModelSuccessfully() throws {
        // Given
        let currentDate = Date()
        let createHourDifference = 2
        let modificationHourDifference = 1
        let fileSize: UInt64 = 128
        let fileAttributes = Configuration.fileAttributes(
            consideringDate: currentDate, andDifference: (createHourDifference, modificationHourDifference), size: fileSize, isDirectoryType: false
        )
        let fileManager = createFileManager(fileAttributes: fileAttributes)
        let testDirectory = URL(filePath: "/test/directory")

        // When
        let fileAttributesModel = try sut.getItemAttributes(atURL: testDirectory)

        // Then
        XCTAssertEqual(fileManager.capturedPath, testDirectory)
        XCTAssertEqual(fileAttributesModel.creationDateTimestamp, applyHourDifference(
            createHourDifference, toTimestamp: currentDate.millisecondsSinceUnixEpoch
        ))
        XCTAssertEqual(fileAttributesModel.modificationDateTimestamp, applyHourDifference(
            modificationHourDifference, toTimestamp: currentDate.millisecondsSinceUnixEpoch
        ))
        XCTAssertEqual(fileAttributesModel.size, fileSize)
        XCTAssertEqual(fileAttributesModel.type, .file)
    }

    func test_getItemAttributes_omittingValues_returnsFileAttributeModelSuccessfully() throws {
        // Given
        let fileAttributes = Configuration.fileAttributes(
            isDirectoryType: false
        )
        let fileManager = createFileManager(fileAttributes: fileAttributes)
        let testDirectory = URL(filePath: "/test/directory")

        // When
        let fileAttributesModel = try sut.getItemAttributes(atURL: testDirectory)

        // Then
        XCTAssertEqual(fileManager.capturedPath, testDirectory)
        XCTAssertEqual(fileAttributesModel.creationDateTimestamp, 0)
        XCTAssertEqual(fileAttributesModel.modificationDateTimestamp, 0)
        XCTAssertEqual(fileAttributesModel.size, 0)
        XCTAssertEqual(fileAttributesModel.type, .file)
    }

    func test_getItemAttributes_forDirectory_returnsFileAttributeModelSuccessfully() throws {
        // Given
        let currentDate = Date()
        let createHourDifference = 2
        let modificationHourDifference = 1
        let fileSize: UInt64 = 128
        let fileAttributes = Configuration.fileAttributes(
            consideringDate: currentDate, andDifference: (createHourDifference, modificationHourDifference), size: fileSize, isDirectoryType: true
        )
        let fileManager = createFileManager(fileAttributes: fileAttributes)
        let testDirectory = URL(filePath: "/test/directory")

        // When
        let fileAttributesModel = try sut.getItemAttributes(atURL: testDirectory)

        // Then
        XCTAssertEqual(fileManager.capturedPath, testDirectory)
        XCTAssertEqual(fileAttributesModel.creationDateTimestamp, applyHourDifference(
            createHourDifference, toTimestamp: currentDate.millisecondsSinceUnixEpoch
        ))
        XCTAssertEqual(fileAttributesModel.modificationDateTimestamp, applyHourDifference(
            modificationHourDifference, toTimestamp: currentDate.millisecondsSinceUnixEpoch
        ))
        XCTAssertEqual(fileAttributesModel.size, fileSize)
        XCTAssertEqual(fileAttributesModel.type, .directory)
    }

    func test_getItemAttributes_errorWhileRetrieving_returnsError() {
        // Given
        let error = MockFileManagerError.itemAttributesError
        let currentDate = Date()
        let createHourDifference = 2
        let modificationHourDifference = 1
        let fileSize: UInt64 = 128
        let fileAttributes = Configuration.fileAttributes(
            consideringDate: currentDate, andDifference: (createHourDifference, modificationHourDifference), size: fileSize, isDirectoryType: false
        )
        createFileManager(error: error, fileAttributes: fileAttributes)
        let testDirectory = URL(filePath: "/test/directory")

        // When
        XCTAssertThrowsError(try sut.getItemAttributes(atURL: testDirectory)) {
            // Then
            XCTAssertEqual($0 as? MockFileManagerError, error)
        }
    }
    
    func test_getItemAttributes_fileDoesntExist_returnsFileNotFound() {
        // Given
        createFileManager(fileExists: false)
        let testURL = URL(filePath: "/test/missing-file")

        // When
        XCTAssertThrowsError(try sut.getItemAttributes(atURL: testURL)) {
            // Then
            XCTAssertEqual($0 as? IONFILEFileManagerError, .fileNotFound(atPath: testURL.urlPath))
        }
    }
}

// MARK: - 'renameItem' tests
extension IONFILEFileManagerTests {
    func test_renameItem_shouldBeSuccessful() throws {
        // Given
        let fileManager = createFileManager()
        let originPath = URL(filePath: "/test/origin")
        let destinationPath = URL(filePath: "/test/destination")

        // When
        try sut.renameItem(fromURL: originPath, toURL: destinationPath)

        // Then
        XCTAssertEqual(fileManager.capturedOriginPath, originPath)
        XCTAssertEqual(fileManager.capturedDestinationPath, destinationPath)
    }

    func test_renameItem_sameOriginAndDestination_shouldDoNothing() throws {
        // Given
        let fileManager = createFileManager()
        let originPath = URL(filePath: "/test/origin")
        let destinationPath = URL(filePath: "/test/origin")

        // When
        try sut.renameItem(fromURL: originPath, toURL: destinationPath)

        // Then
        XCTAssertNil(fileManager.capturedOriginPath)
        XCTAssertNil(fileManager.capturedDestinationPath)
    }
    
    func test_renameItem_fileDoesntExist_returnsFileNotFound() {
        // Given
        createFileManager(fileExists: false)
        let originPath = URL(filePath: "/test/origin")
        let destinationPath = URL(filePath: "/test/destination")

        // When
        XCTAssertThrowsError(try sut.renameItem(fromURL: originPath, toURL: destinationPath)) {
            // Then
            XCTAssertEqual($0 as? IONFILEFileManagerError, .fileNotFound(atPath: originPath.urlPath))
        }
    }

    func test_renameDirectory_alreadyExisting_shouldBeSuccessful() throws {
        // Given
        let fileManager = createFileManager()
        let originPath = URL(filePath: "/test/origin")
        let destinationPath = URL(filePath: "/test/destination")

        // When
        try sut.renameItem(fromURL: originPath, toURL: destinationPath)

        // Then
        XCTAssertEqual(fileManager.capturedOriginPath, originPath)
        XCTAssertEqual(fileManager.capturedDestinationPath, destinationPath)
    }

    func test_renameFile_alreadyExisting_shouldBeSuccessful() throws {
        // Given
        let fileManager = createFileManager(shouldBeDirectory: false)
        let originPath = URL(filePath: "/test/origin")
        let destinationPath = URL(filePath: "/test/destination")

        // When
        try sut.renameItem(fromURL: originPath, toURL: destinationPath)

        // Then
        XCTAssertEqual(fileManager.capturedPath, destinationPath)
        XCTAssertEqual(fileManager.capturedOriginPath, originPath)
        XCTAssertEqual(fileManager.capturedDestinationPath, destinationPath)
    }

    func test_renameFile_copyFails_returnsError() throws {
        // Given
        let error = MockFileManagerError.moveFileError
        createFileManager(error: error)
        let originPath = URL(filePath: "/test/origin")
        let destinationPath = URL(filePath: "/test/destination")

        // When
        XCTAssertThrowsError(try sut.renameItem(fromURL: originPath, toURL: destinationPath)) {
            // Then
            XCTAssertEqual($0 as? MockFileManagerError, error)
        }
    }
}

// MARK: - 'copyItem' tests
extension IONFILEFileManagerTests {
    func test_copyItem_shouldBeSuccessful() throws {
        // Given
        let fileManager = createFileManager()
        let originPath = URL(filePath: "/test/origin")
        let destinationPath = URL(filePath: "/test/destination")

        // When
        try sut.copyItem(fromURL: originPath, toURL: destinationPath)

        // Then
        XCTAssertEqual(fileManager.capturedOriginPath, originPath)
        XCTAssertEqual(fileManager.capturedDestinationPath, destinationPath)
    }

    func test_copyItem_sameOriginAndDestination_shouldDoNothing() throws {
        // Given
        let fileManager = createFileManager()
        let originPath = URL(filePath: "/test/origin")
        let destinationPath = URL(filePath: "/test/origin")

        // When
        try sut.copyItem(fromURL: originPath, toURL: destinationPath)

        // Then
        XCTAssertNil(fileManager.capturedOriginPath)
        XCTAssertNil(fileManager.capturedDestinationPath)

    }
    
    func test_copyItem_fileDoesntExist_returnsFileNotFound() {
        // Given
        createFileManager(fileExists: false)
        let originPath = URL(filePath: "/test/origin")
        let destinationPath = URL(filePath: "/test/destination")
        
        // When
        XCTAssertThrowsError(try sut.copyItem(fromURL: originPath, toURL: destinationPath)) {
            // Then
            XCTAssertEqual($0 as? IONFILEFileManagerError, .fileNotFound(atPath: originPath.urlPath))
        }
    }

    func test_copyDirectory_alreadyExisting_shouldBeSuccessful() throws {
        // Given
        let fileManager = createFileManager()
        let originPath = URL(filePath: "/test/origin")
        let destinationPath = URL(filePath: "/test/destination")

        // When
        try sut.copyItem(fromURL: originPath, toURL: destinationPath)

        // Then
        XCTAssertEqual(fileManager.capturedOriginPath, originPath)
        XCTAssertEqual(fileManager.capturedDestinationPath, destinationPath)
    }

    func test_copyFile_alreadyExisting_shouldBeSuccessful() throws {
        // Given
        let fileManager = createFileManager(shouldBeDirectory: false)
        let originPath = URL(filePath: "/test/origin")
        let destinationPath = URL(filePath: "/test/destination")

        // When
        try sut.copyItem(fromURL: originPath, toURL: destinationPath)

        // Then
        XCTAssertEqual(fileManager.capturedPath, destinationPath)
        XCTAssertEqual(fileManager.capturedOriginPath, originPath)
        XCTAssertEqual(fileManager.capturedDestinationPath, destinationPath)
    }

    func test_copyFile_copyFails_returnsError() throws {
        // Given
        let error = MockFileManagerError.copyFileError
        createFileManager(error: error)
        let originPath = URL(filePath: "/test/origin")
        let destinationPath = URL(filePath: "/test/destination")

        // When
        XCTAssertThrowsError(try sut.copyItem(fromURL: originPath, toURL: destinationPath)) {
            // Then
            XCTAssertEqual($0 as? MockFileManagerError, error)
        }
    }
}

private extension IONFILEFileManagerTests {
    struct Configuration {
        static let fileName = "file"
        static let newFileName = "new_file"
        static let fileExtension = "txt"
        static let fileContent = "Hello, world!"
        static let stringEncodedFileContent = "Hello, string-encoded world!"
        static let byteBufferEncodedFileContent = "Hello, byte buffer-encoded world!"
        static let fileExtendedContent = " How are you?"
        static let emojiContent = "🙃"

        static func fileAttributes(
            consideringDate date: Date? = nil,
            andDifference dateDifference: (creation: Int, modification: Int)? = nil,
            size: UInt64? = nil,
            isDirectoryType: Bool
        ) -> [FileAttributeKey: Any] {
            var result: [FileAttributeKey: Any] = [.type: isDirectoryType ? FileAttributeKey.FileTypeDirectoryValue : Configuration.fileName]

            if let date {
                let removeDifferenceToDate: (Int) -> Date? = {
                    Calendar.current.date(byAdding: .hour, value: $0, to: date)
                }
                if let difference = dateDifference?.creation {
                    result[.creationDate] = removeDifferenceToDate(-difference)
                }
                if let difference = dateDifference?.modification {
                    result[.modificationDate] = removeDifferenceToDate(-difference)
                }
            }

            if let size {
                result[.size] = size
            }

            return result
        }
    }

    @discardableResult
    func createFileManager(
        error: MockFileManagerError? = nil,
        urlsWithinDirectory: [URL] = [],
        fileExists: Bool = true,
        fileAttributes: [FileAttributeKey: Any] = [:],
        shouldBeDirectory: ObjCBool = true,
        mockTemporaryDirectory: URL? = nil
    ) -> MockFileManager {
        let fileManager = MockFileManager(
            error: error,
            urlsWithinDirectory: urlsWithinDirectory,
            fileExists: fileExists,
            fileAttributes: fileAttributes,
            shouldBeDirectory: shouldBeDirectory,
            mockTemporaryDirectory: mockTemporaryDirectory
        )
        sut = IONFILEManager(fileManager: fileManager)

        return fileManager
    }

    func fetchEntireContent(forFile file: (name: String, extension: String), withEncoding encoding: IONFILEEncoding) throws -> String {
        let fileURL = try XCTUnwrap(Bundle(for: type(of: self)).url(forResource: file.name, withExtension: file.extension))
        return try fetchEntireContent(forURL: fileURL, withEncoding: encoding)
    }

    @discardableResult
    func fetchEntireContent(forURL fileURL: URL, withEncoding encoding: IONFILEEncoding) throws -> String {
        let content = switch try sut.readEntireFile(atURL: fileURL, withEncoding: encoding) {
        case .byteBuffer(let fileData): fileData.base64EncodedString()
        case .string(_, let fileData): fileData
        }
        return try treat(content: content, withEncoding: encoding)
    }

    func fetchChunkedContent(forFile file: (name: String, extension: String), withEncoding encoding: IONFILEEncoding, forceURLError: Bool = false, andOffset offset: Int = 0, andLength length: Int = -1) throws -> String {
        let fileURL = try XCTUnwrap(Bundle(for: type(of: self)).url(forResource: file.name, withExtension: file.extension))
        return try fetchChunkedContent(forURL: fileURL, withEncoding: encoding, forceURLError: forceURLError, andOffset: offset, andLength: length)
    }

    @discardableResult
    func fetchChunkedContent(forURL url: URL, withEncoding encoding: IONFILEEncoding, forceURLError: Bool = false, andOffset offset: Int = 0, andLength length: Int = -1) throws -> String {
        var fileURL = url
        var contentArray = [String]()
        var error: Error?
        let expectation = XCTestExpectation(description: "Wait for chunks to be processed")

        if forceURLError {
            fileURL.deleteLastPathComponent()
        }
        try sut.readFileInChunks(atURL: fileURL, withEncoding: encoding, andChunkSize: 3, andOffset: offset, andLength: length)   // 3 bytes
            .sink(receiveCompletion: { completion in
                if case .failure(let failure) = completion {
                    error = failure
                }
                expectation.fulfill()
            }, receiveValue: { value in
                let chunkToAdd = switch value {
                case .byteBuffer(let chunkData): chunkData.base64EncodedString()
                case .string(_, let chunkData): chunkData
                }
                contentArray.append(chunkToAdd)
            })
            .store(in: &cancellables)

        // Wait for all chunks to be processed
        wait(for: [expectation], timeout: 1.0)

        if let error { throw error }
        return try treat(content: contentArray.joined(), withEncoding: encoding)
    }

    func treat(content fileURLContent: String, withEncoding encoding: IONFILEEncoding) throws -> String {
        var fileURLUnicodeScalars: String.UnicodeScalarView
        if case .byteBuffer = encoding {
            let fileURLData = try XCTUnwrap(Data(base64Encoded: fileURLContent))
            let fileURLDataString = try XCTUnwrap(String(data: fileURLData, encoding: .utf8))
            fileURLUnicodeScalars = fileURLDataString.unicodeScalars
        } else {
            fileURLUnicodeScalars = fileURLContent.unicodeScalars
        }

        fileURLUnicodeScalars.removeAll(where: CharacterSet.newlines.contains)
        return String(fileURLUnicodeScalars)
    }

    func fetchConfigurationFile() -> URL? {
        Bundle(for: type(of: self)).url(forResource: Configuration.fileName, withExtension: Configuration.fileExtension)
    }

    func applyHourDifference(_ hour: Int, toTimestamp timestamp: Double) -> Double {
        timestamp - Double(hour) * 60.0 * 60.0 * 1000.0
    }
}
