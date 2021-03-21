//
//  File.swift
//  
//
//  Created by Morgan McColl on 21/3/21.
//

@testable import UCFSMMachines
import XCTest
import CXXBase


public class UCFSMMachinesGeneratorTests: XCTestCase {

    public static var allTests: [(String, (UCFSMMachinesGeneratorTests) -> () throws -> Void)] {
        return [
            ("test_write", test_write)
        ]
    }

    private let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Tests" }).joined(separator: "/").dropFirst()

    private var parser: UCFSMParser!

    public override func setUp() {
        super.setUp()
        self.parser = UCFSMParser()
    }
    
    func test_write() {
        let path = URL(fileURLWithPath: "\(packageRootPath)/machines/UltrasonicDiscrete.machine")
        let machine = parser.parseMachine(location: path)
        XCTAssertNotNil(machine)
        let path2 = URL(fileURLWithPath: "\(packageRootPath)/machines/UltrasonicDiscrete_Written.machine")
        var machine2 = machine!
        machine2.path = path2
        let generator = CXXGenerator()
        let result = generator.generate(machine: machine2)
        XCTAssert(result)
    }

}
