//
//  File.swift
//  
//
//  Created by Morgan McColl on 26/4/21.
//

import Foundation
@testable import Machines
@testable import VHDLMachines
import XCTest

/// Test for converter.
public class VHDLMachinesConverterTests: XCTestCase {

    /// All tests.
    public static var allTests: [(String, (VHDLMachinesConverterTests) -> () throws -> Void)] {
        [
            // ("test_initialMachine", test_initialMachine),
//            ("test_write2", test_write2)
        ]
    }

    /// Package root directory.
    private let packageRootPath = URL(fileURLWithPath: #file).pathComponents
        .prefix { $0 != "Tests" }
        .joined(separator: "/")
        .dropFirst()

    /// Setup
    override public func setUp() {
        super.setUp()
    }

    // func test_initialMachine() {
//        print("Hello VHDL Tests!")
//        let path = URL(fileURLWithPath: "\(packageRootPath)/machines/VHDLMachines.machine")
//        let machine =  VHDLMachinesConverter().initialVHDLMachine(filePath: path)
//        let isValid: ()? = try? machine.validate()
//        XCTAssertNotNil(isValid)
    // }

}
