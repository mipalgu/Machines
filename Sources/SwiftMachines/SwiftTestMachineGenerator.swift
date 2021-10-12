//
//  File.swift
//  File
//
//  Created by Morgan McColl on 12/10/21.
//

import Foundation
import MetaLanguage
import SwiftParsing
import SwiftTests


/// A generator for creating a TestMachine file and TestFile for a specific machine
public struct SwiftTestMachineGenerator {
    
    let testGenerator: SwiftGenerator
    
    /// Creates a generator for a machine.
    /// - Parameters:
    ///   - testGenerator: A standard test generator which doesn't include machine generation.
    public init(testGenerator: SwiftGenerator = SwiftGenerator()) {
        self.testGenerator = testGenerator
    }
    
    /// Creates a FileWrapper for the folder containing the TestMachine and the Tests files.
    /// - Parameters:
    ///   - tests: The tests for the machine.
    ///   - machine: The machine which is being tested.
    ///   - states: The names of all states within the machine
    /// - Returns: A FileWrapper for the folder containing the TestMachine class and the tests file.
    public func generateWrapper(tests: TestSuite, for machineName: String, with states: [String]) -> FileWrapper? {
        guard
            let classDec = generateTestMachine(for: machineName, with: states),
            let newTestSuite = createNewTestSuit(from: tests, for: machineName),
            let classData = classDec.data(using: .utf8),
            let testWrapper = testGenerator.generateWrapper(suite: newTestSuite),
            let testsName = testWrapper.preferredFilename
        else {
            return nil
        }
        let classFileName = "\(machineName)TestMachine.swift"
        let classWrapper = FileWrapper(regularFileWithContents: classData)
        classWrapper.preferredFilename = classFileName
        let folderWrapper = FileWrapper(
            directoryWithFileWrappers: [
                testsName: testWrapper,
                classFileName: classWrapper
            ]
        )
        folderWrapper.preferredFilename = "\(machineName)Tests"
        return folderWrapper
    }
    
    /// Creates string for 2 files. One is the test machine, the other is the tests for that machine.
    /// - Parameters:
    ///   - tests: The abstract tests for a machine.
    ///   - machine: The machine under test.
    ///   - states: The state names of the machine under test.
    /// - Returns: A tupel containing the TestMachine file contents and the Tests contents respectively.
    public func generate(tests: TestSuite, for machineName: String, with states: [String]) -> (String, String)? {
        guard
            let classDec = generateTestMachine(for: machineName, with: states),
            let testString = generateTests(tests: tests, for: machineName)
        else {
            return nil
        }
        return (classDec, testString)
    }
    
    private func generateTestMachine(for machineName: String, with states: [String]) -> String? {
        guard let classDec = createNewTestMachine(for: machineName, with: states) else {
            return nil
        }
        return [
            "import SwiftTestMachines\n@testable import \(machineName)Machine",
            classDec
        ].joined(separator: "\n\n")
    }
    
    private func generateTests(tests: TestSuite, for machineName: String) -> String? {
        guard let newTest = createNewTestSuit(from: tests, for: machineName) else {
            return nil
        }
        return newTest.swiftRepresentation
    }
    
    private func createNewTestMachine(for machineName: String, with states: [String]) -> String? {
        let trimmedNamed = machineName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard states.count > 0, !trimmedNamed.isEmpty else {
            return nil
        }
        let fsmVar = fsmVar(machine: trimmedNamed)
        let stateVars = states.map(stateVariable).joined(separator: "\n\n")
        let convenienceInit = "convenience init() "
            + "self.init(name: \"\(trimmedNamed)\", create: make_\(trimmedNamed))".createBlock
        return "final class \(trimmedNamed)TestMachine: TestMachine "
            + ["\n\(fsmVar)", stateVars, "\(convenienceInit)\n"].joined(separator: "\n\n").createBlock
    }
    
    private func createNewTestSuit(from tests: TestSuite, for machineName: String) -> TestSuite? {
        let setupCode = "ME = \(machineName)TestMachine()"
        guard
            let newVariable = MetaLanguage.Variable(rawValue: "@swift variable var ME: \(machineName)TestMachine?"),
            let newSetupCode = tests.setup == nil ? .languageCode(code: setupCode, language: .swift) : appendToCode(code: tests.setup!, new: setupCode)
        else {
            return nil
        }
        let newVariables = (tests.variables ?? []) + [newVariable]
        return TestSuite(
            name: tests.name,
            tests: tests.tests,
            variables: newVariables,
            setup: newSetupCode,
            tearDown: tests.tearDown
        )
    }
    
    private func appendToCode(code: Code, new string: String) -> Code? {
        switch code {
        case .languageCode(let code, let language):
            guard language == .swift else {
                return nil
            }
            let newCode = [string, code].joined(separator: "\n")
            return .languageCode(code: newCode, language: .swift)
        }
    }
    
    private func fsmVar(machine named: String) -> String {
        let type = "\(named)FiniteStateMachine"
        let blockCode = "case .parameterisedFSM(let fsm):\n"
            + "return fsm.base as! \(type)\n".indent
            + "case .controllableFSM(let fsm):\n"
            + "return fsm.base as! \(type)".indent
        return "private var fsm: \(type) "
            + ("switch machine " + blockCode.createBlock(indent: 0)).createBlock
    }
    
    private func stateVariable(for state: String) -> String {
        "var \(state.startLowerCased)State: State_\(state) "
            + "fsm.allStates[\"\(state)\"]! as! State_\(state)".createBlock
    }
    
}

extension String {
    
    var startLowerCased: String {
        guard let firstChar = self.first else {
            return self
        }
        return firstChar.lowercased() + self.dropFirst()
    }
    
}
