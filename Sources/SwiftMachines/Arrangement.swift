/*
 * Arrangement.swift
 * SwiftMachines
 *
 * Created by Callum McColl on 23/10/20.
 * Copyright © 2020 Callum McColl. All rights reserved.
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

public struct Arrangement {
    
    public var name: String
    
    public var filePath: URL
    
    public var dependencies: [Machine.Dependency]
    
    public var dispatchTable: DispatchTable?
    
    public var machines: [(URL, Machine)] {
        return self.dependencies.map { ($0.filePath(relativeTo: self.filePath), $0.machine(relativeTo: self.filePath)) }
    }
    
    public var flattenedMachines: [(URL, Machine)] {
        var urls = Set<URL>()
        func _process(_ machines: [(URL, Machine)]) -> [(URL, Machine)] {
            return machines.flatMap { (url, machine) -> [(URL, Machine)] in
                let machineUrl = url.resolvingSymlinksInPath().absoluteURL
                if urls.contains(machineUrl) {
                    return []
                }
                urls.insert(machineUrl)
                return [(url, machine)] + _process(machine.dependencies.map { ($0.filePath(relativeTo: url), $0.machine(relativeTo: url)) } )
            }
        }
        return _process(self.machines)
    }
    
    public var namespacedDependencies: (Set<String>, [NamespacedDependency]) {
        var names: Set<String> = []
        var machines: [URL: Machine] = [:]
        let parser = MachineParser()
        func process(_ url: URL, prefix: String, previous previousNames: [URL: String]) -> NamespacedDependency? {
            guard let machine = machines[url] ?? parser.parseMachine(atPath: url.path) else {
                return nil
            }
            machines[url] = machine
            if nil != previousNames[url] {
                return nil
            }
            let name = prefix + machine.name
            names.insert(name)
            var newPreviousNames = previousNames
            newPreviousNames[url] = name
            return NamespacedDependency(
                name: prefix,
                dependencies: machine.dependencies.compactMap {
                    process(
                        $0.filePath(relativeTo: url),
                        prefix: name + ".",
                        previous: newPreviousNames
                    )
                }
            )
        }
        let deps = self.dependencies.compactMap {
            process($0.filePath(relativeTo: self.filePath), prefix: "", previous: [:])
        }
        return (names, deps)
    }
    
    public init(name: String, filePath: URL, dependencies: [Machine.Dependency], dispatchTable: DispatchTable? = nil) {
        self.name = name
        self.filePath = filePath
        self.dependencies = dependencies
        self.dispatchTable = dispatchTable
    }
    
}
