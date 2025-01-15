import XCTest

@testable import OSFilesystemLib

final class OSFLSTFileManagerTests: XCTestCase {
    private var sut: OSFLSTManager!

    // MARK: - 'readFile` tests
    func test_readFile_withStringEncoding_returnsContentSuccessfully() throws {
        // Given
        createFileManager()

        // When
        let fileContent = try fetchContent(
            forFile: (Configuration.fileName, Configuration.fileExtension), withEncoding: .string(encoding: .utf8)
        )

        // Then
        XCTAssertEqual(fileContent, Configuration.fileContent)
    }

    func test_readFile_withByteBufferEncoding_returnsContentSuccessfully() throws {
        // Given
        createFileManager()

        // When
        let fileContent = try fetchContent(
            forFile: (Configuration.fileName, Configuration.fileExtension), withEncoding: .byteBuffer
        )

        // Then
        XCTAssertEqual(fileContent, Configuration.fileContent)
    }

    // MARK: - 'getFileURL' tests
    func test_getFileURL_fromDirectorySearchPath_containingSingleFile_returnsFileSuccessfully() throws {
        // Given
        let fileURL: URL = try XCTUnwrap(.init(string: "/file/directory"))
        let fileManager = createFileManager(urlsWithinDirectory: [fileURL])
        let filePath = "/test/directory"
        let searchPathDirectory = OSFLSTSearchPathDirectory.cache

        // When
        let returnedURL = try sut.getFileURL(atPath: filePath, withSearchPath: .directory(searchPath: searchPathDirectory))

        // Then
        XCTAssertEqual(fileManager.capturedSearchPathDirectory, searchPathDirectory.fileManagerSearchPathDirectory)
        XCTAssertEqual(fileURL.urlWithAppendingPath(filePath), returnedURL)
    }

    func test_getFileURL_fromDirectorySearchPath_containingMultipleFiles_returnsFirstFileSuccessfully() throws {
        // Given
        let fileURL: URL = try XCTUnwrap(.init(string: "/file/directory"))
        let ignoredFileURL: URL = try XCTUnwrap(.init(string: "another_file/directory"))
        let fileManager = createFileManager(urlsWithinDirectory: [fileURL, ignoredFileURL])
        let filePath = "/test/directory"
        let searchPathDirectory = OSFLSTSearchPathDirectory.cache

        // When
        let returnedURL = try sut.getFileURL(atPath: filePath, withSearchPath: .directory(searchPath: searchPathDirectory))

        // Then
        XCTAssertEqual(fileManager.capturedSearchPathDirectory, searchPathDirectory.fileManagerSearchPathDirectory)
        XCTAssertEqual(fileURL.urlWithAppendingPath(filePath), returnedURL)
    }

    func test_getFileURL_fromDirectorySearchPath_containingNoFiles_returnsError() {
        // Given
        createFileManager()
        let filePath = "/test/directory"
        let searchPathDirectory = OSFLSTSearchPathDirectory.cache

        // When
        XCTAssertThrowsError(try sut.getFileURL(atPath: filePath, withSearchPath: .directory(searchPath: searchPathDirectory))) {
            // Then
            XCTAssertEqual($0 as? OSFLSTFileManagerError, .directoryNotFound)

        }
    }

    func test_getFileURL_fromDirectorySearchPath_withNoPath_returnsFileSuccessfully() throws {
        // Given
        let fileURL: URL = try XCTUnwrap(.init(string: "/file/directory"))
        let fileManager = createFileManager(urlsWithinDirectory: [fileURL])
        let emptyFilePath = ""
        let searchPathDirectory = OSFLSTSearchPathDirectory.cache

        // When
        let returnedURL = try sut.getFileURL(atPath: emptyFilePath, withSearchPath: .directory(searchPath: searchPathDirectory))

        // Then
        XCTAssertEqual(fileManager.capturedSearchPathDirectory, searchPathDirectory.fileManagerSearchPathDirectory)
        XCTAssertEqual(fileURL, returnedURL)
    }

    func test_getFileURL_rawFile_returnsFileSuccessfully() throws {
        // Given
        createFileManager()
        let filePath = "/test/directory"

        // When
        let returnedURL = try sut.getFileURL(atPath: filePath, withSearchPath: .raw)

        // Then
        XCTAssertEqual(filePath, returnedURL.path())
    }

    func test_getFileURL_rawFile_fromInvalidPath_returnsError() {
        // Given
        createFileManager()
        let emptyFilePath = ""

        // When
        XCTAssertThrowsError(try sut.getFileURL(atPath: emptyFilePath, withSearchPath: .raw)) {
            // Then
            XCTAssertEqual($0 as? OSFLSTFileManagerError, .cantCreateURL)
        }
    }

    // MARK: - 'deleteFile' tests
    func test_deleteFile_shouldBeSuccessful() throws {
        // Given
        let fileManager = createFileManager()
        let filePath = "/test/directory"

        // When
        try sut.deleteFile(atPath: filePath)

        // Then
        XCTAssertEqual(fileManager.capturedPath, filePath)
    }

    func test_deleteFile_thatDoesntExist_shouldReturnError() {
        // Given
        createFileManager(fileExists: false)
        let filePath = "/test/directory"

        // When
        XCTAssertThrowsError(try sut.deleteFile(atPath: filePath)) {
            // Then
            XCTAssertEqual($0 as? OSFLSTFileManagerError, .fileNotFound)
        }
    }

    func test_deleteFile_thatFailsWhileDeleting_shouldReturnError() {
        // Given
        let error = MockFileManagerError.deleteFileError
        createFileManager(error: error)
        let filePath = "/test/directory"

        // When
        XCTAssertThrowsError(try sut.deleteFile(atPath: filePath)) {
            // Then
            XCTAssertEqual($0 as? MockFileManagerError, error)
        }
    }

    // MARK: - 'saveFile' tests
    func test_saveFile_withStringEncoding_savesFileSuccessfullyAndReturnsItsURL() throws {
        // Given
        let fileManager = createFileManager()
        let fileURL = try XCTUnwrap(fetchConfigurationFile())
            .deletingLastPathComponent()
            .appending(path: "\(Configuration.newFileName).\(Configuration.fileExtension)")
        let stringEncoding = OSFLSTStringEncoding.ascii
        let contentToSave = Configuration.stringEncodedFileContent
        let shouldIncludeIntermediateDirectories = false

        // When
        let savedFileURL = try sut.saveFile(
            atPath: fileURL.path(),
            withEncodingAndData: .string(encoding: stringEncoding, value: contentToSave),
            includeIntermediateDirectories: shouldIncludeIntermediateDirectories
        )

        // Then
        XCTAssertEqual(fileManager.capturedIntermediateDirectories, shouldIncludeIntermediateDirectories)
        XCTAssertEqual(savedFileURL, fileURL)

        let savedFileContent = try fetchContent(
            forFile: (Configuration.newFileName, Configuration.fileExtension), withEncoding: .string(encoding: stringEncoding)
        )
        XCTAssertEqual(savedFileContent, contentToSave)

        try sut.deleteFile(atPath: fileURL.absoluteString)  // keep things clean by deleting created file
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
        let savedFileURL = try sut.saveFile(
            atPath: fileURL.path(),
            withEncodingAndData: .byteBuffer(value: contentToSaveData),
            includeIntermediateDirectories: shouldIncludeIntermediateDirectories
        )

        // Then
        XCTAssertEqual(fileManager.capturedIntermediateDirectories, shouldIncludeIntermediateDirectories)
        XCTAssertEqual(savedFileURL, fileURL)

        let savedFileContent = try fetchContent(
            forFile: (Configuration.newFileName, Configuration.fileExtension), withEncoding: .byteBuffer
        )
        XCTAssertEqual(savedFileContent, contentToSave)

        try sut.deleteFile(atPath: fileURL.absoluteString)  // keep things clean by deleting created file
    }

    func test_saveFile_parentFolderMissing_shouldCreateIt_savesFileSuccessfullyAndReturnsItsURL() throws {
        // Given
        let fileManager = createFileManager(fileExists: false)
        let parentFolderURL = try XCTUnwrap(fetchConfigurationFile())
            .deletingLastPathComponent()
        let fileURL = parentFolderURL
            .appending(path: "\(Configuration.newFileName).\(Configuration.fileExtension)")
        let stringEncoding = OSFLSTStringEncoding.ascii
        let contentToSave = Configuration.stringEncodedFileContent
        let shouldIncludeIntermediateDirectories = true

        // When
        let savedFileURL = try sut.saveFile(
            atPath: fileURL.path(),
            withEncodingAndData: .string(encoding: stringEncoding, value: contentToSave),
            includeIntermediateDirectories: shouldIncludeIntermediateDirectories
        )

        // Then
        XCTAssertEqual(fileManager.capturedIntermediateDirectories, shouldIncludeIntermediateDirectories)
        XCTAssertEqual(fileManager.capturedPath, parentFolderURL.relativePath)
        XCTAssertEqual(savedFileURL, fileURL)

        let savedFileContent = try fetchContent(
            forFile: (Configuration.newFileName, Configuration.fileExtension), withEncoding: .string(encoding: stringEncoding)
        )
        XCTAssertEqual(savedFileContent, contentToSave)

        fileManager.fileExists = true
        try sut.deleteFile(atPath: fileURL.absoluteString)  // keep things clean by deleting created file
    }

    func test_saveFile_parentFolderMissing_failsCreatingIt_returnsError() throws {
        // Given
        createFileManager(error: .createDirectoryError, fileExists: false)
        let parentFolderURL = try XCTUnwrap(fetchConfigurationFile())
            .deletingLastPathComponent()
        let fileURL = parentFolderURL
            .appending(path: "\(Configuration.newFileName).\(Configuration.fileExtension)")
        let stringEncoding = OSFLSTStringEncoding.ascii
        let contentToSave = Configuration.stringEncodedFileContent
        let shouldIncludeIntermediateDirectories = true

        // When
        XCTAssertThrowsError(try sut.saveFile(
            atPath: fileURL.path(),
            withEncodingAndData: .string(encoding: stringEncoding, value: contentToSave),
            includeIntermediateDirectories: shouldIncludeIntermediateDirectories)
        ) {
            // Then
            XCTAssertEqual($0 as? MockFileManagerError, .createDirectoryError)
        }
    }

    func test_saveFile_parentFolderMissing_shouldntCreateIt_returnsError() throws {
        // Given
        createFileManager(fileExists: false)
        let parentFolderURL = try XCTUnwrap(fetchConfigurationFile())
            .deletingLastPathComponent()
        let fileURL = parentFolderURL
            .appending(path: "\(Configuration.newFileName).\(Configuration.fileExtension)")
        let stringEncoding = OSFLSTStringEncoding.ascii
        let contentToSave = Configuration.stringEncodedFileContent
        let shouldIncludeIntermediateDirectories = false

        // When
        XCTAssertThrowsError(try sut.saveFile(
            atPath: fileURL.path(),
            withEncodingAndData: .string(encoding: stringEncoding, value: contentToSave),
            includeIntermediateDirectories: shouldIncludeIntermediateDirectories)
        ) {
            // Then
            XCTAssertEqual($0 as? OSFLSTFileManagerError, .missingParentFolder)
        }
    }
}

private extension OSFLSTFileManagerTests {
    struct Configuration {
        static let fileName = "file"
        static let newFileName = "new_file"
        static let fileExtension = "txt"
        static let fileContent = "Hello, world!"
        static let stringEncodedFileContent = "Hello, string-encoded world!"
        static let byteBufferEncodedFileContent = "Hello, byte buffer-encoded world!"
    }

    @discardableResult func createFileManager(error: MockFileManagerError? = nil, urlsWithinDirectory: [URL] = [], fileExists: Bool = true) -> MockFileManager {
        let fileManager = MockFileManager(error: error, urlsWithinDirectory: urlsWithinDirectory, fileExists: fileExists)
        sut = OSFLSTManager(fileManager: fileManager)

        return fileManager
    }

    func fetchContent(forFile file: (name: String, extension: String), withEncoding encoding: OSFLSTEncoding) throws -> String {
        let fileURL = try XCTUnwrap(Bundle(for: type(of: self)).url(forResource: file.name, withExtension: file.extension))
        let fileURLContent = try sut.readFile(atPath: fileURL.path(), withEncoding: encoding)

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
}
