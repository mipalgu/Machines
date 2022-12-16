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
        let path2 = URL(fileURLWithPath: "\(packageRootPath)/machines/UltrasonicDiscrete_Written.machine")
        guard
            let wrapper1 = try? FileWrapper(url: path, options: .immediate),
            let machine = Machine(ucfsmMachine: wrapper1),
            let wrapper2 = machine.fileWrapper
        else {
            XCTFail("Found nil")
            return
        }
        _ = try? wrapper2.write(to: path2, options: .atomic, originalContentsURL: nil)
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
