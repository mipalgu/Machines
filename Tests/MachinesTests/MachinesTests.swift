import XCTest
@testable import Machines
import XMI

final class MachinesTests: XCTestCase {
    static var allTests = [
        "test_encoder": test_encoder
    ]
    
    func test_encoder() {
        let encoder = XMIEncoder()
        let swiftMachine = Machine.initialSwiftMachine
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
    
    func test_validation() {
        var machine = Machine.initialSwiftMachine
        do {
            try machine.validate()
            _ = try SwiftfsmConverter().convert(machine)
            try machine.modify(attribute: machine.path.states[0].name, value: StateName("Hello"))
        } catch let e as MachinesError {
            XCTFail(e.message + ": " + e.path.description)
        } catch let e {
            XCTFail("Failed to validate: \(e)")
        }
    }
    
}
