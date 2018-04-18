import XCTest
@testable import Machines

final class MachinesTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Machines().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
