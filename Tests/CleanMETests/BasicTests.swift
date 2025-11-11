import XCTest
@testable import CleanME

final class BasicTests: XCTestCase {
    
    func testScanEngineInitialization() {
        let scanEngine = ScanEngine()
        XCTAssertNotNil(scanEngine)
        XCTAssertEqual(scanEngine.scanResults.count, 0)
        XCTAssertFalse(scanEngine.isScanning)
    }
    
    func testSecurityManagerInitialization() {
        let securityManager = SecurityManager()
        XCTAssertNotNil(securityManager)
    }
    
    func testAppSettingsInitialization() {
        let appSettings = AppSettings()
        XCTAssertNotNil(appSettings)
    }
    
    func testCleanupItemCreation() {
        let item = CleanupItem(
            fileName: "test.txt",
            filePath: "/test/path",
            fileSize: 1024,
            fileType: .cache,
            lastModified: Date()
        )
        XCTAssertEqual(item.fileName, "test.txt")
        XCTAssertEqual(item.fileSize, 1024)
    }
}
