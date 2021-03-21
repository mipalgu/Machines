//
//  File.swift
//  
//
//  Created by Morgan McColl on 21/3/21.
//

@testable import UCFSMMachines
import XCTest
import CXXBase
import CLFSMMachines


public class UCFSMMachinesGeneratorTests: XCTestCase {

    public static var allTests: [(String, (UCFSMMachinesGeneratorTests) -> () throws -> Void)] {
        return [
            ("test_write", test_write),
//            ("test_write2", test_write2)
        ]
    }

    private let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Tests" }).joined(separator: "/").dropFirst()

    public override func setUp() {
        super.setUp()
    }
    
    func test_write() {
        let path = URL(fileURLWithPath: "\(packageRootPath)/machines/UltrasonicDiscrete.machine")
        let machine = Machine(ucfsmMachineAtPath: path)
        XCTAssertNotNil(machine)
        let path2 = URL(fileURLWithPath: "\(packageRootPath)/machines/UltrasonicDiscrete_Written.machine")
        var machine2 = machine!
        machine2.path = path2
        let result = machine2.write()
        XCTAssert(result)
    }
    
//    func test_write2() {
//        let path = URL(fileURLWithPath: "/Users/morgan/src/MiPal/GUNao/fsms/nao/DefaultMachines/WiFiSelector.machine")
//        let machine = Machine(clfsmMachineAtPath: path)
//        XCTAssertNotNil(machine)
//        let result = machine!.write()
//        XCTAssert(result)
//    }

}
