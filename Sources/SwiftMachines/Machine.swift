/*
 * Machine.swift 
 * Machines 
 *
 * Created by Callum McColl on 19/02/2017.
 * Copyright © 2017 Callum McColl. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above
 *    copyright notice, this list of conditions and the following
 *    disclaimer in the documentation and/or other materials
 *    provided with the distribution.
 *
 * 3. All advertising materials mentioning features or use of this
 *    software must display the following acknowledgement:
 *
 *        This product includes software developed by Callum McColl.
 *
 * 4. Neither the name of the author nor the names of contributors
 *    may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * -----------------------------------------------------------------------
 * This program is free software; you can redistribute it and/or
 * modify it under the above terms or under the terms of the GNU
 * General Public License as published by the Free Software Foundation;
 * either version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see http://www.gnu.org/licenses/
 * or write to the Free Software Foundation, Inc., 51 Franklin Street,
 * Fifth Floor, Boston, MA  02110-1301, USA.
 *
 */

import Foundation

public struct Machine {

    public let name: String

    public let filePath: URL

    public let externalVariables: [ExternalVariables]

    public let swiftIncludeSearchPaths: [String]

    public let includeSearchPaths: [String]

    public let libSearchPaths: [String]

    public let imports: String

    public let includes: String?

    public let vars: [Variable]

    public let model: Model?
    
    public let parameters: [Variable]?

    public let returnType: String?

    public let initialState: State

    public let suspendState: State?

    public let states: [State]

    public let submachines: [Machine]
    
    public let parameterisedMachines: [Machine]

    public init(
        name: String,
        filePath: URL,
        externalVariables: [ExternalVariables],
        swiftIncludeSearchPaths: [String],
        includeSearchPaths: [String],
        libSearchPaths: [String],
        imports: String,
        includes: String?,
        vars: [Variable],
        model: Model? = nil,
        parameters: [Variable]?,
        returnType: String?,
        initialState: State,
        suspendState: State?,
        states: [State],
        submachines: [Machine],
        parameterisedMachines: [Machine]
    ) {
        self.name = name
        self.filePath = filePath
        self.externalVariables = externalVariables
        self.swiftIncludeSearchPaths = swiftIncludeSearchPaths
        self.includeSearchPaths = includeSearchPaths
        self.libSearchPaths = libSearchPaths
        self.imports = imports
        self.includes = includes
        self.vars = vars
        self.model = model
        self.parameters = parameters
        self.returnType = returnType
        self.initialState = initialState
        self.suspendState = suspendState
        self.states = states
        self.submachines = submachines
        self.parameterisedMachines = parameterisedMachines
    }

}

extension Machine: Hashable {

    public var hashValue: Int {
        return "\(self)".hashValue
    }

}

public func ==(lhs: Machine, rhs: Machine) -> Bool {
    return
        lhs.name == rhs.name &&
        lhs.filePath == rhs.filePath &&
        lhs.externalVariables == rhs.externalVariables &&
        lhs.swiftIncludeSearchPaths == rhs.swiftIncludeSearchPaths &&
        lhs.includeSearchPaths == rhs.includeSearchPaths &&
        lhs.libSearchPaths == rhs.libSearchPaths &&
        lhs.includes == rhs.includes &&
        lhs.imports == rhs.imports &&
        lhs.vars == rhs.vars &&
        lhs.model == rhs.model &&
        lhs.parameters == rhs.parameters &&
        lhs.returnType == rhs.returnType &&
        lhs.initialState == rhs.initialState &&
        lhs.suspendState == rhs.suspendState &&
        lhs.states == rhs.states &&
        lhs.submachines == rhs.submachines &&
        lhs.parameterisedMachines == rhs.parameterisedMachines
}
