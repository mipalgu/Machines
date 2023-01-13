// ArrangementTests.swift
// Machines
// 
// Created by Morgan McColl.
// Copyright © 2022 Morgan McColl. All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above
//    copyright notice, this list of conditions and the following
//    disclaimer in the documentation and/or other materials
//    provided with the distribution.
// 
// 3. All advertising materials mentioning features or use of this
//    software must display the following acknowledgement:
// 
//    This product includes software developed by Morgan McColl.
// 
// 4. Neither the name of the author nor the names of contributors
//    may be used to endorse or promote products derived from this
//    software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 
// -----------------------------------------------------------------------
// This program is free software; you can redistribute it and/or
// modify it under the above terms or under the terms of the GNU
// General Public License as published by the Free Software Foundation;
// either version 2 of the License, or (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, see http://www.gnu.org/licenses/
// or write to the Free Software Foundation, Inc., 51 Franklin Street,
// Fifth Floor, Boston, MA  02110-1301, USA.
// 

@testable import VHDLMachines
import XCTest

/// Tests the ``Arrangement`` type.
final class ArrangementTests: XCTestCase {

    /// The machines in the arrangement.
    let machines = [
        "M1": URL(fileURLWithPath: "/path/to/M1"),
        "M2": URL(fileURLWithPath: "/path/to/M2")
    ]

    /// The clocks in the arrangement.
    let clocks = [
        Clock(name: VariableName(text: "clk"), frequency: 100, unit: .MHz)
    ]

    /// The external signals in the arrangement.
    let externalSignals = [
        ExternalSignal(
            type: .stdLogic,
            name: VariableName(text: "x"),
            mode: .input,
            defaultValue: .logic(value: .high),
            comment: Comment(text: "Signal x.")
        ),
        ExternalSignal(
            type: .stdLogic,
            name: VariableName(text: "y"),
            mode: .output,
            defaultValue: .logic(value: .low),
            comment: Comment(text: "Signal y.")
        )
    ]

    /// The arrangement signals.
    let signals = [
        LocalSignal(
            type: .stdLogic,
            name: VariableName(text: "z"),
            defaultValue: .logic(value: .low),
            comment: Comment(text: "Signal z.")
        )
    ]

    /// The parent machines in the arrangement.
    let parents = ["M1"]

    /// The path to the arrangement.
    let path = URL(fileURLWithPath: "/path/to/arrangement")

    /// The arrangement to test.
    lazy var arrangement = Arrangement(
        machines: machines,
        externalSignals: externalSignals,
        signals: signals,
        clocks: clocks,
        parents: parents,
        path: path
    )

    /// Initialises the arrangement to test.
    override func setUp() {
        self.arrangement = Arrangement(
            machines: machines,
            externalSignals: externalSignals,
            signals: signals,
            clocks: clocks,
            parents: parents,
            path: path
        )
    }

    /// Test init sets properties correctly.
    func testInit() {
        XCTAssertEqual(self.arrangement.machines, self.machines)
        XCTAssertEqual(self.arrangement.externalSignals, self.externalSignals)
        XCTAssertEqual(self.arrangement.signals, self.signals)
        XCTAssertEqual(self.arrangement.clocks, self.clocks)
        XCTAssertEqual(self.arrangement.parents, self.parents)
        XCTAssertEqual(self.arrangement.path, self.path)
    }

    /// Tests getters and setters update properties correctly.
    func testGettersAndSetters() {
        let newMachines = [
            "M3": URL(fileURLWithPath: "/path/to/M3"),
            "M4": URL(fileURLWithPath: "/path/to/M4")
        ]
        let newExternalSignals = [
            ExternalSignal(
                type: .stdLogic,
                name: VariableName(text: "z"),
                mode: .input,
                defaultValue: .logic(value: .high),
                comment: Comment(text: "Signal z.")
            ),
            ExternalSignal(
                type: .stdLogic,
                name: VariableName(text: "w"),
                mode: .output,
                defaultValue: .logic(value: .low),
                comment: Comment(text: "Signal w.")
            )
        ]

        let newSignals = [
            LocalSignal(
                type: .stdLogic,
                name: VariableName(text: "x2"),
                defaultValue: .logic(value: .high),
                comment: Comment(text: "Signal x2.")
            )
        ]
        let newClocks = [
            Clock(name: VariableName(text: "clk2"), frequency: 100, unit: .MHz)
        ]
        let newParents = ["M2"]
        let newPath = URL(fileURLWithPath: "/path/to/new/arrangement")
        self.arrangement.machines = newMachines
        self.arrangement.externalSignals = newExternalSignals
        self.arrangement.signals = newSignals
        self.arrangement.clocks = newClocks
        self.arrangement.parents = newParents
        self.arrangement.path = newPath
        XCTAssertEqual(self.arrangement.machines, newMachines)
        XCTAssertEqual(self.arrangement.externalSignals, newExternalSignals)
        XCTAssertEqual(self.arrangement.signals, newSignals)
        XCTAssertEqual(self.arrangement.clocks, newClocks)
        XCTAssertEqual(self.arrangement.parents, newParents)
        XCTAssertEqual(self.arrangement.path, newPath)
    }

    /// Test initial function creates default arrangement correctly.
    func testInitial() {
        let url = URL(fileURLWithPath: "Arrangement.arrangement", isDirectory: true)
        let arrangement = Arrangement.initial(url: url)
        let machineURL = URL(fileURLWithPath: "./Machine.machine", isDirectory: true)
        let machine = Machine.initial(path: machineURL)
        let expected = Arrangement(
            machines: ["Machine": machineURL],
            externalSignals: [],
            signals: [],
            clocks: machine.clocks,
            parents: ["Machine"],
            path: url
        )
        XCTAssertEqual(arrangement, expected)
    }

}
