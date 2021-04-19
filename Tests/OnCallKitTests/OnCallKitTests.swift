import XCTest
@testable import OnCallKit

final class OnCallKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(OnCallKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
