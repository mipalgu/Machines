//
//  File.swift
//  File
//
//  Created by Morgan McColl on 12/10/21.
//

import XCTest
import MetaLanguage
@testable import SwiftMachines

final class SwiftTestMachineGeneratorTests: XCTestCase {
    
    private let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Tests" }).joined(separator: "/").dropFirst()
    
    var testSuite: TestSuite?
    
    var generator: SwiftTestMachineGenerator?
    
    override func setUp() {
        generator = SwiftTestMachineGenerator()
        let examplePath = String(packageRootPath + "/Tests/SwiftMachinesTests/Example/ExampleTest")
        guard let testData = try? String(contentsOfFile: examplePath) else {
            return
        }
        testSuite = TestSuite(rawValue: testData)
    }
    
    func testGenerateMachineTests() {
        guard let suite = testSuite else {
            print("Test Suite is not setup properly")
            XCTAssertTrue(false)
            return
        }
        let testFiles = generator?.generateWrapper(tests: suite, for: "ExampleMachine", with: ["Initial", "Suspended", "State0", "State1"])
        XCTAssertNotNil(testFiles)
        do {
            try testFiles?.write(
                to: URL(
                    fileURLWithPath: packageRootPath + "/testbuild",
                    isDirectory: true
                ),
                options: .atomic,
                originalContentsURL: nil
            )
        } catch {
            print(error)
        }
    }
    
}
