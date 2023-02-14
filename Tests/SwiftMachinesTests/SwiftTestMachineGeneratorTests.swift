//
//  File.swift
//  File
//
//  Created by Morgan McColl on 12/10/21.
//

import IO
import MetaLanguage
@testable import SwiftMachines
import XCTest

final class SwiftTestMachineGeneratorTests: XCTestCase {

    private let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix { $0 != "Tests" }
        .joined(separator: "/")
        .dropFirst()

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
        let testFiles = generator?.generateWrapper(
            tests: [suite], for: "ExampleMachine", with: ["Initial", "Suspended", "State0", "State1"]
        )
        let helper = FileHelpers()
        let url = URL(
            fileURLWithPath: packageRootPath + "/testbuild/ExampleMachine.machine",
            isDirectory: true
        )
        if helper.directoryExists(url.path) {
            _ = helper.deleteItem(atPath: url)
        }
        XCTAssertNotNil(testFiles)
        do {
            try testFiles?.write(to: url, options: .atomic, originalContentsURL: nil)
        } catch {
            print(error)
        }
    }

}
