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
    
    public struct Dependency: Hashable, Codable {
        
        public var name: String?
        
        public var machineName: String
        
        public var filePath: URL
        
        public var callName: String {
            return self.name ?? self.machineName
        }
        
        public var machine: Machine {
            let parser = MachineParser()
            let path: String = self.filePath.path.hasPrefix("file://") ? String(filePath.path.dropFirst(7)) : self.filePath.path
            guard let machine = parser.parseMachine(atPath: path) else {
                parser.errors.forEach {
                    print($0, stderr)
                }
                exit(EXIT_FAILURE)
            }
            return machine
        }
        
        public init(name: String?, machineName: String, filePath: URL) {
            self.name = name
            self.machineName = machineName
            self.filePath = filePath
        }
        
        public init?(name: String?, filePath: URL) {
            guard let machineName = filePath.lastPathComponent.components(separatedBy: ".").first?.trimmingCharacters(in: .whitespaces) else {
                return nil
            }
            if machineName.isEmpty {
                return nil
            }
            self.init(name: name, machineName: machineName, filePath: filePath)
        }
        
    }

    public var name: String

    public var externalVariables: [Variable]
    
    public var environmentVariables: [Variable] {
        return externalVariables.filter { $0.accessType == .readAndWrite }
    }
    
    public var actuators: [Variable] {
        return externalVariables.filter { $0.accessType == .writeOnly }
    }
    
    public var sensors: [Variable] {
        return externalVariables.filter { $0.accessType == .readOnly }
    }
    
    public var packageDependencies: [PackageDependency]

    public var swiftIncludeSearchPaths: [String]

    public var includeSearchPaths: [String]

    public var libSearchPaths: [String]

    public var imports: String

    public var includes: String?

    public var vars: [Variable]

    public var model: Model?
    
    public var parameters: [Variable]?

    public var returnType: String?

    public var initialState: State

    public var suspendState: State?

    public var states: [State]
    
    public var callables: [Dependency]
    
    public var invocables: [Dependency]
    
    public var subs: [Dependency]
    
    public var dependencies: [Dependency] {
        return self.parameterisedDependencies + self.subs
    }
    
    public var parameterisedDependencies: [Dependency] {
        return self.callables + self.invocables
    }

    /*public var submachines: [(String, Machine)] {
        self.subs.map { $0.machine }
    }
    
    public var callableMachines: [(String, Machine)] {
        self.callables.map { $0.machine }
    }
    
    public var invocableMachines: [(String, Machine)] {
        self.invocables.map { $0.machine }
    }
    
    public var dependantMachines: [(String, Machine)] {
        return self.submachines + self.parameterisedMachines
    }
    
    public var parameterisedMachines: [(String, Machine)] {
        return self.callableMachines + self.invocableMachines
    }*/

    public init(
        name: String,
        externalVariables: [Variable],
        packageDependencies: [PackageDependency],
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
        submachines: [Dependency],
        callableMachines: [Dependency],
        invocableMachines: [Dependency]
    ) {
        self.name = name
        self.externalVariables = externalVariables
        self.packageDependencies = packageDependencies
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
        self.subs = submachines
        self.callables = callableMachines
        self.invocables = invocableMachines
    }

}

extension Machine: Codable, Equatable, Hashable {}
