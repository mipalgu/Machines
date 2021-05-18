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
    
    private var mutator: MachineMutator?
    private var machine: Machines.Machine?
    private let clockFrequencies: Set<String> = ["Hz", "kHz", "MHz", "GHz", "THz"]
    
    private var variables: [String: Attribute] {
        machine?.attributes[0].attributes ?? [:]
    }
 
    public static var allTests: [(String, (VHDLMachinesMutatorTests) -> () throws -> Void)] {
        return [
            ("test_hello_world", test_hello_world),
            ("test_newClockAddsToDrivingClock", test_newClockAddsToDrivingClock)
//            ("test_write2", test_write2)
        ]
    }
    
    public override func setUp() {
        mutator = VHDLMachinesConverter()
        machine = Machines.Machine.initialMachine(forSemantics: .vhdl)
        super.setUp()
    }
    
    func test_hello_world() {
        print("Hello VHDL Mutator Tests!")
        XCTAssertNotNil(machine)
        XCTAssertNotNil(mutator)
    }
    
    func test_newClockAddsToDrivingClock() {
        let path = Machine.path.attributes[0].attributes["clocks"].wrappedValue.tableValue
        let currentClocks = machine?.attributes[0].attributes["clocks"]?.tableValue
        let value = [
            LineAttribute(type: .line, value: "clk2")!,
            LineAttribute(type: .integer, value: "20")!,
            LineAttribute(type: .enumerated(validValues: clockFrequencies), value: "Hz")!
        ]
        let inserted = currentClocks! + [value]
        let attribute = Attribute(blockAttribute: .table(
            inserted,
            columns: [
                BlockAttributeType.TableColumn(name: "name", type: .line),
                BlockAttributeType.TableColumn(name: "frequency", type: .integer),
                BlockAttributeType.TableColumn(name: "unit", type: .enumerated(validValues: clockFrequencies))
            ]
        ))
        machine?.addItem(attribute.tableValue.last ?? [], to: path)
        let insertedValues = machine?.attributes[0].attributes["clocks"]?.tableValue
        XCTAssertNotNil(insertedValues)
        XCTAssertEqual(inserted, insertedValues)
        let drivingClocks = variables["driving_clock"]?.enumeratedValidValues
        XCTAssertNotNil(drivingClocks)
        XCTAssertTrue(drivingClocks!.contains("clk2"))
    }
    
}
