//
//  File.swift
//  
//
//  Created by Morgan McColl on 26/4/21.
//

import Foundation
@testable import VHDLMachines
import XCTest
@testable import Machines

public class VHDLMachinesConverterTests: XCTestCase {
    
    private let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Tests" }).joined(separator: "/").dropFirst()
 
    public static var allTests: [(String, (VHDLMachinesConverterTests) -> () throws -> Void)] {
        return [
            ("test_initialMachine", test_initialMachine),
//            ("test_write2", test_write2)
        ]
    }
    
    public override func setUp() {
        super.setUp()
    }
    
    func test_initialMachine() {
        print("Hello VHDL Tests!")
        let path = URL(fileURLWithPath: "\(packageRootPath)/machines/VHDLMachines.machine")
        let machine =  VHDLMachinesConverter().initialVHDLMachine(filePath: path)
        let isValid: ()? = try? machine.validate()
        XCTAssertNotNil(isValid)
    }
    
}
