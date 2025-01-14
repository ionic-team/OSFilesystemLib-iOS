import XCTest

import OSFilesystemLib

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
}

private extension OSFLSTFileManagerTests {
    struct Configuration {
        static let fileName = "file"
        static let fileExtension = "txt"
        static let fileContent = "Hello, world!"
    }

    @discardableResult func createFileManager() -> MockFileManager {
        let fileManager = MockFileManager(error: nil, shouldDirectoryHaveContent: false)
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
