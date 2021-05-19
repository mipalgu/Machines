//
//  File.swift
//  
//
//  Created by Morgan McColl on 19/5/21.
//

import Foundation

import Foundation
@testable import VHDLMachines
import XCTest
@testable import Machines

public class VHDLMachinesCompilerTests: XCTestCase {
    
    private let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Tests" }).joined(separator: "/").dropFirst()
    
    var machine: VHDLMachines.Machine?
 
    public static var allTests: [(String, (VHDLMachinesCompilerTests) -> () throws -> Void)] {
        return [
            ("test_initialMachine", test_initialMachine),
//            ("test_write2", test_write2)
        ]
    }
    
    private func defaultState(name: String) -> VHDLMachines.State {
        VHDLMachines.State(
            name: name,
            actions: [
                "onentry": "",
                "onexit": "",
                "onresume": "",
                "onsuspend": "",
                "internal": ""
            ],
            actionOrder: [["onresume", "onentry"], ["onexit", "internal"], ["onsuspend"]],
            signals: [],
            variables: [],
            externalVariables: []
        )
    }
    
    public override func setUp() {
        self.machine = VHDLMachines.Machine(
            name: "TestMachine",
            path: URL(fileURLWithPath: "\(packageRootPath)/machines/VHDLCompilerTestMachine.machine"),
            includes: ["library IEEE;", "use IEEE.std_logic_1164.ALL;"],
            externalSignals: [ExternalSignal(type: "std_logic", name: "x", mode: .input, defaultValue: "'1'", comment: "A std_logic variable."), ExternalSignal(type: "std_logic_vector(1 downto 0)", name: "xx", mode: .output, defaultValue: "\"00\"", comment: "A variable called xx.")],
            externalVariables: [VHDLVariable(type: "integer", name: "y", defaultValue: "0", range: (0, 65535), comment: "A uint16 variable called y."), VHDLVariable(type: "boolean", name: "yy", defaultValue: "false", range: nil, comment: "A variable called yy")],
            clocks: [Clock(name: "clk", frequency: 50, unit: .MHz), Clock(name: "clk2", frequency: 20, unit: .kHz)],
            drivingClock: 0,
            dependentMachines: [:],
            machineVariables: [],
            machineSignals: [],
            parameters: [],
            outputs: [],
            states: [defaultState(name: "Initial"), defaultState(name: "Suspended")],
            transitions: [],
            initialState: 0,
            suspendedState: 1,
            architectureHead: nil,
            architectureBody: nil
        )
        super.setUp()
    }
    
    func test_initialMachine() {
        print("Hello VHDL Tests!")
        guard let machine = machine else {
            XCTAssert(false)
            return
        }
        print("File path: \(machine.path.absoluteString)")
        let _ = VHDLCompiler().compile(machine)
        XCTAssertTrue(true)
    }
    
}
