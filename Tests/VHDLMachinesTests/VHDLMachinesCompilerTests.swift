//
//  File.swift
//  
//
//  Created by Morgan McColl on 19/5/21.
//

import Foundation
import IO
@testable import Machines
@testable import VHDLMachines
import XCTest

/// Test class for ``VHDLCompiler``.
class VHDLMachinesCompilerTests: XCTestCase {

    /// The compiler under test.
    let compiler = VHDLCompiler()

    /// The test machine filePath.
    var testMachinePath: URL {
        factory.machinePath.appendingPathComponent("TestMachine.machine", isDirectory: true)
    }

    /// A test machine.
    var machine: VHDLMachines.Machine {
        VHDLMachines.Machine(
            name: "TestMachine",
            path: testMachinePath,
            includes: ["library IEEE;", "use IEEE.std_logic_1164.ALL;"],
            externalSignals: [
                ExternalSignal(
                    type: "std_logic",
                    name: "x",
                    mode: .input,
                    defaultValue: "'1'",
                    comment: "A std_logic variable."
                ),
                ExternalSignal(
                    type: "std_logic_vector(1 downto 0)",
                    name: "xx",
                    mode: .output,
                    defaultValue: "\"00\"",
                    comment: "A variable called xx."
                )
            ],
            generics: [
                VHDLVariable(
                    type: "integer",
                    name: "y",
                    defaultValue: "0",
                    range: (0, 65535),
                    comment: "A uint16 variable called y."
                ),
                VHDLVariable(
                    type: "boolean",
                    name: "yy",
                    defaultValue: "false",
                    range: nil,
                    comment: "A variable called yy"
                )
            ],
            clocks: [
                Clock(name: "clk", frequency: 50, unit: .MHz), Clock(name: "clk2", frequency: 20, unit: .kHz)
            ],
            drivingClock: 0,
            dependentMachines: [:],
            machineVariables: [
                VHDLVariable(
                    type: "integer",
                    name: "machineVar1",
                    defaultValue: "12",
                    range: nil,
                    comment: "machine var 1"
                ),
                VHDLVariable(
                    type: "boolean",
                    name: "machineVar2",
                    defaultValue: "false",
                    range: nil,
                    comment: "machine var 2"
                )
            ],
            machineSignals: [
                MachineSignal(type: "std_logic", name: "machineSignal1", defaultValue: nil, comment: nil),
                MachineSignal(
                    type: "std_logic_vector(2 downto 0)",
                    name: "machineSignal2",
                    defaultValue: "\"11\"",
                    comment: "machine signal 2"
                )
            ],
            isParameterised: true,
            parameterSignals: [
                Parameter(type: "std_logic", name: "parX", defaultValue: "'1'", comment: "Parameter parX"),
                Parameter(
                    type: "std_logic_vector(1 downto 0)",
                    name: "parXs",
                    defaultValue: "\"01\"",
                    comment: "Parameter parXs"
                )
            ],
            returnableSignals: [
                ReturnableVariable(type: "std_logic", name: "retX", comment: "Returnable retX"),
                ReturnableVariable(
                    type: "std_logic_vector(1 downto 0)", name: "retXs", comment: "Returnable retXs"
                )
            ],
            states: [
                defaultState(name: "Initial"), defaultState(name: "Suspended"), defaultState(name: "State0")
            ],
            transitions: [
                VHDLMachines.Transition(condition: "false", source: 0, target: 1),
                VHDLMachines.Transition(
                    condition: "after_ms(50) or after(2) or after_rt(20000) or after_ps(x * (5 + (2 - 3)))",
                    source: 0,
                    target: 1
                ),
                VHDLMachines.Transition(condition: "true", source: 0, target: 1),
                VHDLMachines.Transition(condition: "xx = '1'", source: 1, target: 2),
                VHDLMachines.Transition(condition: "x = '1'", source: 1, target: 2),
                VHDLMachines.Transition(condition: "true", source: 1, target: 0)
            ],
            initialState: 0,
            suspendedState: 1,
            architectureHead: "some code\n    with indentation\nend;",
            architectureBody: "some async code\n    with indentation\nend;"
        )
    }

    /// Factory generating PingPong arrangements.
    let factory = PingPongArrangement()

    /// IO Helper.
    let helper = FileHelpers()

    /// FileWrapper for the test machine.
    var testMachineFileWrapper: FileWrapper? {
        VHDLGenerator().generate(machine: machine)
    }

    /// Create test paths for machines.
    override func setUp() {
        if !helper.directoryExists(factory.pingMachinePath.absoluteString) {
            _ = helper.createDirectory(atPath: factory.pingMachinePath)
        }
        if !helper.directoryExists(testMachinePath.absoluteString) {
            guard let wrapper = testMachineFileWrapper else {
                return
            }
            _ = try? wrapper.write(to: factory.machinePath, originalContentsURL: nil)
        }
    }

    /// Remove test machines.
    override func tearDown() {
        _ = helper.deleteItem(atPath: testMachinePath)
        _ = helper.deleteItem(atPath: factory.pingMachinePath)
    }

    /// Default state creation.
    private func defaultState(name: String) -> VHDLMachines.State {
        VHDLMachines.State(
            name: name,
            actions: [
                "OnEntry": "x <= '1';\nxx <= '0'; -- \(name) onEntry",
                "OnExit": "x <= '0'; -- \(name) OnExit",
                "OnResume": "x <= '0'; -- \(name) OnResume",
                "OnSuspend": "xx <= '1'; -- \(name) onSuspend",
                "Internal": "x <= '1'; -- \(name) Internal"
            ],
            actionOrder: [["onresume", "onentry"], ["onexit", "internal"], ["onsuspend"]],
            signals: [],
            variables: [],
            externalVariables: []
        )
    }

    /// Test can compile initial machine.
    func testInitialMachine() {
        XCTAssertTrue(compiler.compile(machine))
    }

    func testCompileWorksWhenParentFolderExists() {
        if !helper.directoryExists(testMachinePath.absoluteString) {
            guard helper.createDirectory(atPath: testMachinePath) else {
                XCTFail("Failed to create directory!")
                return
            }
        }
        XCTAssertTrue(compiler.compile(machine))
    }

    /// Test the VHDL code generation is correct for the Ping Machine.
    func testPingMachineCodeGeneration() {
        let machine = factory.pingMachine
        let code = compiler.generateVHDLFile(machine)
        XCTAssertEqual(code, factory.pingCode)
    }

    /// Test VHDL compilation.
    func testCompilationForEmptyFolder() {
        if helper.directoryExists(factory.pingMachinePath.absoluteString) {
            _ = helper.deleteItem(atPath: factory.pingMachinePath)
        }
        let machine = factory.pingMachine
        XCTAssertTrue(compiler.compile(machine))
    }

}
