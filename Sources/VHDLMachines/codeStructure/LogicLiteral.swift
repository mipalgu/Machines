// BitLiteral.swift
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

/// The possible values for a single bit logic value in `VHDL`.
public enum LogicLiteral: String, Equatable, Hashable, Codable {

    /// A logic high.
    case high = "'1'"

    /// A logic low.
    case low = "'0'"

    /// The signal is uninitialized.
    case uninitialized = "'U'"

    /// The signal is unknown.
    case unknown = "'X'"

    /// The signal has high impedance.
    case highImpedance = "'Z'"

    /// The signal is weak.
    case weakSignal = "'W'"

    /// The signal is weak so should go to low.
    case weakSignalLow = "'L'"

    /// The signal is weak so should go to high.
    case weakSignalHigh = "'H'"

    /// Don't care about the state of the signal.
    case dontCare = "'-'"

    /// The VHDL representation for this value inside a vector literal.
    @inlinable public var vectorLiteral: String {
        switch self {
        case .high:
            return "1"
        case .low:
            return "0"
        case .uninitialized:
            return "U"
        case .unknown:
            return "X"
        case .highImpedance:
            return "Z"
        case .weakSignal:
            return "W"
        case .weakSignalLow:
            return "L"
        case .weakSignalHigh:
            return "H"
        case .dontCare:
            return "-"
        }
    }

    /// Initialise the `BitLiteral` from the VHDL code.
    /// - Parameter rawValue: The VHDL code representing this literal.
    @inlinable
    public init?(rawValue: String) {
        let value = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard value.count == 3 else {
            return nil
        }
        switch value.uppercased() {
        case "'1'":
            self = .high
        case "'0'":
            self = .low
        case "'U'":
            self = .uninitialized
        case "'X'":
            self = .unknown
        case "'Z'":
            self = .highImpedance
        case "'W'":
            self = .weakSignal
        case "'L'":
            self = .weakSignalLow
        case "'H'":
            self = .weakSignalHigh
        case "'-'":
            self = .dontCare
        default:
            return nil
        }
    }

}
