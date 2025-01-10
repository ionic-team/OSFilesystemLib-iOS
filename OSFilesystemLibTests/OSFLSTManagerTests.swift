import OSFilesystemLib
import XCTest

final class OSFLSTManagerTests: XCTestCase {
    private var sut: OSFLSTManager!

    // MARK: - 'createDirectory' tests
    func test_createDirectory_withoutIntermediateDictionaries_shouldBeSuccessful() throws {
        // Given
        let fileManager = createFileManager()

        let testDirectoryURL = URL(fileURLWithPath: "/test/directory")
        let shouldIncludeIntermediateDirectories = false

        // When
        try sut.createDirectory(atPathURL: testDirectoryURL, includeIntermediateDirectories: shouldIncludeIntermediateDirectories)

        // Then
        XCTAssertEqual(fileManager.capturedPathURL, testDirectoryURL)
        XCTAssertEqual(fileManager.capturedIntermediateDirectories, shouldIncludeIntermediateDirectories)
    }

    func test_createDirectory_withIntermediateDictionaries_shouldBeSuccessful() throws {
        // Given
        let fileManager = createFileManager()

        let testDirectoryURL = URL(fileURLWithPath: "/test/directory")
        let shouldIncludeIntermediateDirectories = true

        // When
        try sut.createDirectory(atPathURL: testDirectoryURL, includeIntermediateDirectories: shouldIncludeIntermediateDirectories)

        // Then
        XCTAssertEqual(fileManager.capturedPathURL, testDirectoryURL)
        XCTAssertEqual(fileManager.capturedIntermediateDirectories, shouldIncludeIntermediateDirectories)
    }

    func test_createDictionary_butFails_shouldReturnAnError() {
        // Given
        createFileManager(shouldThrowError: true)

        let testDirectoryURL = URL(fileURLWithPath: "/test/directory")
        let shouldIncludeIntermediateDirectories = false

        // When
        XCTAssertThrowsError(
            try sut.createDirectory(atPathURL: testDirectoryURL, includeIntermediateDirectories: shouldIncludeIntermediateDirectories)
        ) {
            // Then
            XCTAssertNotNil($0)
        }
    }
}

private extension OSFLSTManagerTests {
    @discardableResult func createFileManager(shouldThrowError: Bool = false) -> MockFileManager {
        let fileManager = MockFileManager(shouldThrowError: shouldThrowError)
        sut = OSFLSTManager(fileManager: fileManager)

        return fileManager
    }
}
