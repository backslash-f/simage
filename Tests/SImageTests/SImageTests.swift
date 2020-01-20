import XCTest
@testable import SImage

final class SImageTests: XCTestCase {
    func testExample() {
        XCTAssertEqual(SgsImage().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
