// WhenCaseTests.swift
// Machines
// 
// Created by Morgan McColl.
// Copyright © 2023 Morgan McColl. All rights reserved.
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
import VHDLParsing
import XCTest

// swiftlint:disable type_body_length

/// Test the `WhenCase` extensions.
final class WhenCaseTests: XCTestCase {

    /// A test machine.
    var machine = Machine.testMachine()

    // swiftlint:disable line_length

    /// The checkTransition code.
    let checkTransitionCode = """
    when CheckTransition =>
        case currentState is
            when STATE_Initial =>
                if (false) then
                    targetState <= STATE_Suspended;
                    internalState <= OnExit;
                elsif ((ringlet_counter >= integer(ceil(real(50.0) * RINGLETS_PER_MS))) or (ringlet_counter >= integer(ceil(real(2.0) * RINGLETS_PER_S))) or (ringlet_counter >= integer(ceil(real(20000.0))))) then
                    targetState <= STATE_Suspended;
                    internalState <= OnExit;
                elsif (true) then
                    targetState <= STATE_Suspended;
                    internalState <= OnExit;
                else
                    internalState <= Internal;
                end if;
            when STATE_Suspended =>
                if (xx = "11") then
                    targetState <= STATE_State0;
                    internalState <= OnExit;
                elsif (x = '1') then
                    targetState <= STATE_State0;
                    internalState <= OnExit;
                elsif (true) then
                    targetState <= STATE_Initial;
                    internalState <= OnExit;
                else
                    internalState <= Internal;
                end if;
            when others =>
                internalState <= Internal;
        end case;
    """

    /// The expected `readSnapshot` code for the test machine.
    let readSnapshotExpected = """
    when ReadSnapshot =>
        x <= EXTERNAL_x;
        if (command = COMMAND_RESTART) then
            parX <= PARAMETER_parX;
            parXs <= PARAMETER_parXs;
        end if;
        if ((command = COMMAND_RESTART) and (currentState /= STATE_Initial)) then
            currentState <= STATE_Initial;
            suspended <= '0';
            suspendedFrom <= STATE_Initial;
            targetState <= STATE_Initial;
            if (previousRinglet = STATE_Suspended) then
                internalState <= OnResume;
            elsif (previousRinglet = STATE_Initial) then
                internalState <= NoOnEntry;
            else
                internalState <= OnEntry;
            end if;
        elsif ((command = COMMAND_RESUME) and ((currentState = STATE_Suspended) and (suspendedFrom /= STATE_Suspended))) then
            suspended <= '0';
            currentState <= suspendedFrom;
            targetState <= suspendedFrom;
            if (previousRinglet = suspendedFrom) then
                internalState <= NoOnEntry;
            else
                internalState <= OnResume;
            end if;
        elsif ((command = COMMAND_SUSPEND) and (currentState /= STATE_Suspended)) then
            suspendedFrom <= currentState;
            suspended <= '1';
            currentState <= STATE_Suspended;
            targetState <= STATE_Suspended;
            if (previousRinglet = STATE_Suspended) then
                internalState <= NoOnEntry;
            else
                internalState <= OnSuspend;
            end if;
        elsif (currentState = STATE_Suspended) then
            suspended <= '1';
            if (previousRinglet /= STATE_Suspended) then
                internalState <= OnSuspend;
            else
                internalState <= NoOnEntry;
            end if;
        elsif (previousRinglet = STATE_Suspended) then
            internalState <= OnResume;
            suspended <= '0';
            suspendedFrom <= currentState;
        else
            suspended <= '0';
            suspendedFrom <= currentState;
            if (previousRinglet /= currentState) then
                internalState <= OnEntry;
            else
                internalState <= NoOnEntry;
            end if;
        end if;
    """

    /// The NoOnEntry code.
    let noOnEntryCode = """
    when NoOnEntry =>
        internalState <= CheckTransition;
    """

    /// The OnEntry code.
    let onEntryCode = """
    when OnEntry =>
        case currentState is
            when STATE_Initial =>
                x <= '1';
                xx <= "00";
                ringlet_counter <= 0;
            when STATE_Suspended =>
                x <= '1';
                xx <= "00";
            when STATE_State0 =>
                x <= '1';
                xx <= "00";
            when others =>
                null;
        end case;
        internalState <= CheckTransition;
    """

    /// The onExit code.
    let onExitCode = """
    when OnExit =>
        case currentState is
            when STATE_Initial =>
                x <= '0';
            when STATE_Suspended =>
                x <= '0';
            when STATE_State0 =>
                x <= '0';
            when others =>
                null;
        end case;
        internalState <= WriteSnapshot;
    """

    /// The onResume code.
    let onResumeCode = """
    when OnResume =>
        case currentState is
            when STATE_Initial =>
                x <= '0';
                x <= '1';
                xx <= "00";
                ringlet_counter <= 0;
            when STATE_Suspended =>
                x <= '0';
                x <= '1';
                xx <= "00";
            when STATE_State0 =>
                x <= '0';
                x <= '1';
                xx <= "00";
            when others =>
                null;
        end case;
        internalState <= CheckTransition;
    """

    /// The onSuspend code.
    let onSuspendCode = """
    when OnSuspend =>
        case suspendedFrom is
            when STATE_Initial =>
                xx <= "11";
            when STATE_Suspended =>
                xx <= "11";
            when STATE_State0 =>
                xx <= "11";
            when others =>
                null;
        end case;
        x <= '1';
        xx <= "00";
        internalState <= CheckTransition;
    """

    /// The internal code.
    let internalCode = """
    when Internal =>
        case currentState is
            when STATE_Initial =>
                x <= '1';
                ringlet_counter <= ringlet_counter + 1;
            when STATE_Suspended =>
                x <= '1';
            when STATE_State0 =>
                x <= '1';
            when others =>
                null;
        end case;
        internalState <= WriteSnapshot;
    """

    /// The writeSnapshot code.
    let writeSnapshotCode = """
    when WriteSnapshot =>
        EXTERNAL_xx <= xx;
        internalState <= ReadSnapshot;
        previousRinglet <= currentState;
        currentState <= targetState;
        if (currentState = STATE_Suspended) then
            OUTPUT_retX <= retX;
            OUTPUT_retXs <= retXs;
        end if;
    """

    // swiftlint:enable line_length

    /// Create test data before every test.
    override func setUp() {
        machine = Machine.testMachine()
    }

    /// Test the checkTransition generation.
    func testCheckTransitionCode() {
        let checkTransition = WhenCase(machine: machine, action: .checkTransition)
        XCTAssertEqual(checkTransition?.rawValue, checkTransitionCode)
    }

    /// Test the noOnEntry generation.
    func testNoOnEntryCode() {
        let noOnEntry = WhenCase(machine: machine, action: .noOnEntry)
        XCTAssertEqual(noOnEntry?.rawValue, noOnEntryCode)
    }

    /// Test onEntry generation.
    func testOnEntryCode() {
        let onEntry = WhenCase(machine: machine, action: .onEntry)
        XCTAssertEqual(onEntry?.rawValue, onEntryCode)
    }

    /// Test onExit generation.
    func testOnExitCode() {
        let onExit = WhenCase(machine: machine, action: .onExit)
        XCTAssertEqual(onExit?.rawValue, onExitCode)
    }

    /// Test onResume generation.
    func testOnResumeCode() {
        let onResume = WhenCase(machine: machine, action: .onResume)
        XCTAssertEqual(onResume?.rawValue, onResumeCode)
    }

    /// Test onResume for non-suspensible machine.
    func testOnResumeNotSuspensible() {
        machine.suspendedState = nil
        let onResume = WhenCase(machine: machine, action: .onResume)
        XCTAssertNil(onResume)
    }

    /// Test onSuspend generation.
    func testOnSuspendCode() {
        let onSuspend = WhenCase(machine: machine, action: .onSuspend)
        XCTAssertEqual(onSuspend?.rawValue, onSuspendCode)
    }

    /// Test onSuspend for non-suspensible machine.
    func testOnSuspendedNotSuspensible() {
        machine.suspendedState = nil
        let onSuspend = WhenCase(machine: machine, action: .onSuspend)
        XCTAssertNil(onSuspend)
    }

    /// Test internal code generation.
    func testInternalCode() {
        let internalCase = WhenCase(machine: machine, action: .internal)
        XCTAssertEqual(internalCase?.rawValue, internalCode)
    }

    /// Test read snapshot generation is correct.
    func testReadSnapshotCode() {
        let readSnapshot = WhenCase(machine: machine, action: .readSnapshot)
        XCTAssertEqual(readSnapshot?.rawValue, readSnapshotExpected)
    }

    /// Test read snapshot for a machine that is not suspensible.
    func testReadSnapshotNotSuspensible() {
        machine.suspendedState = nil
        let readSnapshot = WhenCase(machine: machine, action: .readSnapshot)
        XCTAssertEqual(
            readSnapshot?.rawValue,
            """
            when ReadSnapshot =>
                x <= EXTERNAL_x;
                if (previousRinglet /= currentState) then
                    internalState <= OnEntry;
                else
                    internalState <= NoOnEntry;
                end if;
            """
        )
        machine.initialState = -1
        XCTAssertNil(WhenCase(machine: machine, action: .readSnapshot))
    }

    // swiftlint:disable function_body_length
    // swiftlint:disable line_length

    /// Test read snapshot for a machine that is not parameterised.
    func testReadSnapshotNotParameterised() {
        machine.isParameterised = false
        let readSnapshot = WhenCase(machine: machine, action: .readSnapshot)
        XCTAssertEqual(
            readSnapshot?.rawValue,
            """
            when ReadSnapshot =>
                x <= EXTERNAL_x;
                if ((command = COMMAND_RESTART) and (currentState /= STATE_Initial)) then
                    currentState <= STATE_Initial;
                    suspended <= '0';
                    suspendedFrom <= STATE_Initial;
                    targetState <= STATE_Initial;
                    if (previousRinglet = STATE_Suspended) then
                        internalState <= OnResume;
                    elsif (previousRinglet = STATE_Initial) then
                        internalState <= NoOnEntry;
                    else
                        internalState <= OnEntry;
                    end if;
                elsif ((command = COMMAND_RESUME) and ((currentState = STATE_Suspended) and (suspendedFrom /= STATE_Suspended))) then
                    suspended <= '0';
                    currentState <= suspendedFrom;
                    targetState <= suspendedFrom;
                    if (previousRinglet = suspendedFrom) then
                        internalState <= NoOnEntry;
                    else
                        internalState <= OnResume;
                    end if;
                elsif ((command = COMMAND_SUSPEND) and (currentState /= STATE_Suspended)) then
                    suspendedFrom <= currentState;
                    suspended <= '1';
                    currentState <= STATE_Suspended;
                    targetState <= STATE_Suspended;
                    if (previousRinglet = STATE_Suspended) then
                        internalState <= NoOnEntry;
                    else
                        internalState <= OnSuspend;
                    end if;
                elsif (currentState = STATE_Suspended) then
                    suspended <= '1';
                    if (previousRinglet /= STATE_Suspended) then
                        internalState <= OnSuspend;
                    else
                        internalState <= NoOnEntry;
                    end if;
                elsif (previousRinglet = STATE_Suspended) then
                    internalState <= OnResume;
                    suspended <= '0';
                    suspendedFrom <= currentState;
                else
                    suspended <= '0';
                    suspendedFrom <= currentState;
                    if (previousRinglet /= currentState) then
                        internalState <= OnEntry;
                    else
                        internalState <= NoOnEntry;
                    end if;
                end if;
            """
        )
    }

    // swiftlint:enable function_body_length
    // swiftlint:enable line_length

    /// Test write snapshot generation is correct.
    func testWriteSnapshotCode() {
        let writeSnapshot = WhenCase(machine: machine, action: .writeSnapshot)
        XCTAssertEqual(writeSnapshot?.rawValue, writeSnapshotCode)
    }

    /// Test write snapshot when machine isn't parameterised.
    func testWriteSnapshotNotParameterised() {
        machine.isParameterised = false
        let writeSnapshot = WhenCase(machine: machine, action: .writeSnapshot)
        XCTAssertEqual(
            writeSnapshot?.rawValue,
            """
            when WriteSnapshot =>
                EXTERNAL_xx <= xx;
                internalState <= ReadSnapshot;
                previousRinglet <= currentState;
                currentState <= targetState;
            """
        )
    }

}

// swiftlint:enable type_body_length
