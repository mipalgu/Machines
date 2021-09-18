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
import IO


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
        let wrapper1 = try? FileWrapper(url: path, options: .immediate)
        XCTAssertNotNil(wrapper1)
        let machine = Machine(ucfsmMachine: wrapper1!)
        XCTAssertNotNil(machine)
        let path2 = URL(fileURLWithPath: "\(packageRootPath)/machines/UltrasonicDiscrete_Written.machine")
        let machine2 = machine!
        let wrapper2 = machine2.fileWrapper
        XCTAssertNotNil(wrapper2)
//        XCTAssertNotNil(FileHelpers().deleteItem(atPath: path2))
        let _ = try? wrapper2!.write(to: path2, options: .atomic, originalContentsURL: nil)
        print(wrapper2)
    }
    
//    func test_write2() {
//        let path = URL(fileURLWithPath: "/Users/morgan/src/MiPal/GUNao/fsms/nao/DefaultMachines/WiFiSelector.machine")
//        let machine = Machine(clfsmMachineAtPath: path)
//        XCTAssertNotNil(machine)
//        let result = machine!.write()
//        XCTAssert(result)
//    }

}
