import XCTest

@testable import OSFilesystemLib

final class OSFILEDirectoryManagerTests: XCTestCase {
    private var sut: OSFILEManager!

    // MARK: - 'createDirectory' tests
    func test_createDirectory_shouldBeSuccessful() throws {
        // Given
        let fileManager = createFileManager()
        let testDirectory = URL(filePath: "/test/directory")
        let shouldIncludeIntermediateDirectories = false

        // When
        try sut.createDirectory(atURL: testDirectory, includeIntermediateDirectories: shouldIncludeIntermediateDirectories)

        // Then
        XCTAssertEqual(fileManager.capturedPath, testDirectory)
        XCTAssertEqual(fileManager.capturedIntermediateDirectories, shouldIncludeIntermediateDirectories)
    }

    func test_createDirectory_butFails_shouldReturnAnError() {
        // Given
        let error = MockFileManagerError.createDirectoryError
        createFileManager(with: error)
        let testDirectory = URL(filePath: "/test/directory")
        let shouldIncludeIntermediateDirectories = false

        // When
        XCTAssertThrowsError(
            try sut.createDirectory(atURL: testDirectory, includeIntermediateDirectories: shouldIncludeIntermediateDirectories)
        ) {
            // Then
            XCTAssertEqual($0 as? MockFileManagerError, error)
        }
    }

    // MARK: - 'removeDirectory' tests
    func test_removeDirectory_butFails_shouldReturnAnError() {
        let error = MockFileManagerError.deleteDirectoryError
        createFileManager(with: error)
        let testDirectory = URL(filePath: "/test/directory")
        let shouldIncludeIntermediateDirectories = true

        // When
        XCTAssertThrowsError(
            try sut.removeDirectory(atURL: testDirectory, includeIntermediateDirectories: shouldIncludeIntermediateDirectories)
        ) {
            // Then
            XCTAssertEqual($0 as? MockFileManagerError, error)
        }
    }

    func test_removeDirectory_includingIntermediateDirectories_shouldBeSuccessful() throws {
        // Given
        let fileManager = createFileManager()
        let testDirectory = URL(filePath: "/test/directory")
        let shouldIncludeIntermediateDirectories = true

        // When
        try sut.removeDirectory(atURL: testDirectory, includeIntermediateDirectories: shouldIncludeIntermediateDirectories)

        // Then
        XCTAssertEqual(fileManager.capturedPath, testDirectory)
    }

    func test_removeDirectory_excludingIntermediateDirectories_directoryDoesntHaveContent_shouldBeSuccessful() throws {
        // Given
        let fileManager = createFileManager()
        let testDirectory = URL(filePath: "/test/directory")
        let shouldIncludeIntermediateDirectories = false

        // When
        try sut.removeDirectory(atURL: testDirectory, includeIntermediateDirectories: shouldIncludeIntermediateDirectories)

        // Then
        XCTAssertEqual(fileManager.capturedPath, testDirectory)
    }

    func test_removeDirectory_excludingIntermediateDirectories_directoryHasContent_shouldReturnAnError() {
        createFileManager(shouldDirectoryHaveContent: true)
        let testDirectory = URL(filePath: "/test/directory")
        let shouldIncludeIntermediateDirectories = false

        // When
        XCTAssertThrowsError(
            try sut.removeDirectory(atURL: testDirectory, includeIntermediateDirectories: shouldIncludeIntermediateDirectories)
        ) {
            // Then
            XCTAssertEqual($0 as? OSFILEDirectoryManagerError, .notEmpty)
        }
    }

    // MARK: - 'listDirectory' tests
    func test_listDirectory_withNoContent_shouldReturnEmptyArray() throws {
        // Given
        let fileManager = createFileManager()
        let testDirectory = URL(filePath: "/test/directory")

        // When
        let directoryContent = try sut.listDirectory(atURL: testDirectory)

        // Then
        XCTAssertEqual(fileManager.capturedPath, testDirectory)
        XCTAssertTrue(directoryContent.isEmpty)
    }

    // MARK: - 'listDirectory' tests
    func test_listDirectory_withContent_shouldReturnEmptyArray() throws {
        // Given
        let fileManager = createFileManager(shouldDirectoryHaveContent: true)
        let testDirectory = URL(filePath: "/test/directory")

        // When
        let directoryContent = try sut.listDirectory(atURL: testDirectory)

        // Then
        XCTAssertEqual(fileManager.capturedPath, testDirectory)
        XCTAssertEqual(directoryContent, [testDirectory])
    }

    func test_listDirectory_butFails_shouldReturnAnError() {
        // Given
        let error = MockFileManagerError.readDirectoryError
        createFileManager(with: error)
        let testDirectory = URL(filePath: "/test/directory")

        // When
        XCTAssertThrowsError(
            try sut.listDirectory(atURL: testDirectory)
        ) {
            // Then
            XCTAssertEqual($0 as? MockFileManagerError, error)
        }
    }
}

private extension OSFILEDirectoryManagerTests {
    @discardableResult func createFileManager(with error: MockFileManagerError? = nil, shouldDirectoryHaveContent: Bool = false) -> MockFileManager {
        let fileManager = MockFileManager(error: error, shouldDirectoryHaveContent: shouldDirectoryHaveContent)
        sut = OSFILEManager(fileManager: fileManager)

        return fileManager
    }
}
