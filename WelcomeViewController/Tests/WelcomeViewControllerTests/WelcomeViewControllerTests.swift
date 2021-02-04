import XCTest
@testable import WelcomeViewController

final class WelcomeViewControllerTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(WelcomeViewController().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
