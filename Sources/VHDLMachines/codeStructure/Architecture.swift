// Architecture.swift
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

public struct Architecture: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    public let head: Block

    public let body: Block

    public let name: VariableName

    public var rawValue: String {
        return """
        architecture Behavioral of \(name.rawValue) is
        \(head.rawValue.indent(amount: 1))
        begin
        \(body.rawValue.indent(amount: 1))
        end Behavioral;
        """
    }

    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let startString = "architecture Behavioral of "
        guard trimmedString.lowercased().hasPrefix(startString) else {
            return nil
        }
        let architectureDef = trimmedString.dropFirst(startString.count)
        let components = architectureDef.components(separatedBy: "is")
        guard components.count >= 2, let name = VariableName(rawValue: components[0]) else {
            return nil
        }
        let headAndBody = components[1...].joined(separator: "is")
        guard
            let headIndex = headAndBody.startIndex(for: "begin"),
            let headBlock = Block(rawValue: String(headAndBody[headAndBody.startIndex..<headIndex]))
        else {
            return nil
        }
        let bodyCode = String(headAndBody[headIndex...].dropFirst("begin".count))
        guard
            let endIndex = bodyCode.startIndex(for: "end Behavioral;"),
            let bodyBlock = Block(rawValue: String(bodyCode[bodyCode.startIndex..<endIndex]))
        else {
            return nil
        }
        self.head = headBlock
        self.body = bodyBlock
        self.name = name
    }

    public init?<T>(representation: T) where T: MachineVHDLRepresentable {
        // guard let name = VariableName(rawValue: representation.machine.name) else {
        //     return nil
        // }
        // let actions = representation.actionRepresentation.values.sorted {
        //     $0.name.rawValue < $1.name.rawValue
        // }
        // let internalState = LocalSignal.internalState(actionType: representation.actionType)
        // let states = representation.statesRepresentations.compactMap {
        //     ConstantSignal(
        //         name: VariableName.name(for: $0),
        //         type: representation.stateType,
        //         value: .literal(value: .vector(value: $1)),
        //         comment: nil
        //     )
        // }
        // guard states.count == representation.statesRepresentations.count else {
        //     return nil
        // }
        // let statements: [Statement] = [
        //     .expression(value: .comment(comment: Comment(text: "Internal State Representation Bits")))
        // ] + actions.map { Statement.constant(value: $0) } + [.definition(signal: internalState)] +
        //     [.expression(value: .comment(comment: Comment(text: "State Representation Bits")))] +
        //     states.map { Statement.constant(value: $0) } +
        //     LocalSignal.stateTrackers(representation: representation).map {
        //         Statement.definition(signal: $0)
        //     } + [Statement.expression(value: .comment(comment: Comment(text: "Suspension Commands")))] +
        //     SuspensionCommand.suspensionConstants.map { Statement.constant(value: $0) } +
        //     [Statement.expression(value: .comment(comment: Comment(text: "After Variables")))] +
        //     [.definition(signal: LocalSignal.ringletCounter), .constant(value: representation.clockPeriod)] +
        //     representation.ringletConstants.map { Statement.constant(value: $0) }
        // let head = Block.statements(lines: statements)
        // self.name = name
        // self.head = head
        return nil
    }

    public init?(machine: Machine) {
        guard let representation = MachineRepresentation(machine: machine) else {
            return nil
        }
        self.init(representation: representation)
    }

}
