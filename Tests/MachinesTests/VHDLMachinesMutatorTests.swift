//
//  File.swift
//  
//
//  Created by Morgan McColl on 19/5/21.
//

import Foundation
import XCTest
@testable import Machines
import Attributes

public class VHDLMachinesMutatorTests: XCTestCase {
    
    private var machine: Machines.Machine?
    private let clockFrequencies: Set<String> = ["Hz", "kHz", "MHz", "GHz", "THz"]
    
    private var variables: [String: Attribute] {
        machine?.attributes[0].attributes ?? [:]
    }
    
    private var mutator: MachineMutator? {
        machine?.mutator
    }
 
    public static var allTests: [(String, (VHDLMachinesMutatorTests) -> () throws -> Void)] {
        return [
            ("test_hello_world", test_hello_world),
            ("test_newClockAddsToDrivingClock", test_newClockAddsToDrivingClock)
//            ("test_write2", test_write2)
        ]
    }
    
    public override func setUp() {
        machine = Machines.Machine.initialMachine(forSemantics: .vhdl)
        super.setUp()
    }
    
    func test_hello_world() {
        print("Hello VHDL Mutator Tests!")
        XCTAssertNotNil(machine)
        XCTAssertNotNil(mutator)
    }
    
    func test_newClockAddsToDrivingClock() {
        let path = Machine.path.attributes[0].attributes["clocks"].wrappedValue.blockAttribute.tableValue
        let currentClocks = machine?.attributes[0].attributes["clocks"]?.tableValue ?? []
        let value = [
            LineAttribute(type: .line, value: "clk2")!,
            LineAttribute(type: .integer, value: "20")!,
            LineAttribute(type: .enumerated(validValues: clockFrequencies), value: "Hz")!
        ]
        let inserted = currentClocks + [value]
        let _ = machine?.addItem(value, to: path)
        let insertedValues = machine?.attributes[0].attributes["clocks"]?.tableValue
        let currentDrivingClock = variables["driving_clock"]?.enumeratedValue
        XCTAssertNotNil(insertedValues)
        XCTAssertEqual(inserted, insertedValues)
        let drivingClocks = variables["driving_clock"]?.enumeratedValidValues
        XCTAssertNotNil(drivingClocks)
        XCTAssertTrue(drivingClocks!.contains("clk2"))
        currentClocks.forEach {
            XCTAssertTrue(drivingClocks!.contains($0[0].lineValue))
        }
        XCTAssertNotNil(currentDrivingClock)
        let newDrivingClock = variables["driving_clock"]?.enumeratedValue
        XCTAssertNotNil(newDrivingClock)
        XCTAssertEqual(newDrivingClock, currentDrivingClock)
    }
    
}
