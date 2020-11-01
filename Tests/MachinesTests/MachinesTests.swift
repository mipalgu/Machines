import XCTest
@testable import Machines
import XMI

final class MachinesTests: XCTestCase {
    static var allTests = [
        "test_encoder": test_encoder
    ]
    
    func test_encoder() {
        let encoder = XMIEncoder()
        let swiftMachine: Machine = .createSwiftMachine("Test", atPath: URL(fileURLWithPath: "test"))
        guard let data = try? encoder.encode(swiftMachine) else {
            XCTFail("Unable to encode swift machine")
            return
        }
        guard let str = String(data: data, encoding: .utf8) else {
            XCTFail("Unable to interpret data as a utf8 string")
            return
        }
        print(str)
    }
}
