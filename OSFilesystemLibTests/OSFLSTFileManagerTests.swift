import XCTest

@testable import OSFilesystemLib

final class OSFLSTFileManagerTests: XCTestCase {
    private var sut: OSFLSTManager!

    // MARK: - 'readFile` tests
    func test_readFile_withStringEncoding_returnsContentSuccessfully() throws {
        // Given
        createFileManager()

        // When
        let fileContent = try fetchContent(forFile: (Configuration.fileName, Configuration.fileExtension), withEncoding: .string(encoding: .utf8))

        // Then
        XCTAssertEqual(fileContent, Configuration.fileContent)
    }

    func test_readFile_withByteBufferEncoding_returnsContentSuccessfully() throws {
        // Given
        createFileManager()

        // When
        let fileContent = try fetchContent(forFile: (Configuration.fileName, Configuration.fileExtension), withEncoding: .byteBuffer)

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
}

private extension OSFLSTFileManagerTests {
    struct Configuration {
        static let fileName = "file"
        static let fileExtension = "txt"
        static let fileContent = "Hello, world!"
    }

    @discardableResult func createFileManager(urlsWithinDirectory: [URL] = []) -> MockFileManager {
        let fileManager = MockFileManager(urlsWithinDirectory: urlsWithinDirectory)
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
}
