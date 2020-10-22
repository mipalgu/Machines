/*
 * MachineArrangementParser.swift
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

public final class MachineArrangementParser {
    
    public private(set) var errors: [String] = []
    
    public init() {}
    
    public func parseArrangement(atDirectory url: URL) -> Arrangement? {
        self.errors = []
        let machinesFile = url.appendingPathComponent("Machines", isDirectory: false)
        guard
            let name = self.parseArrangementName(fromURL: url),
            let dependencies = self.parseMachines(inArrangement: url, fromFile: machinesFile)
        else {
            return nil
        }
        return Arrangement(name: name, filePath: url, dependencies: dependencies)
    }
    
    private func parseArrangementName(fromURL url: URL) -> String? {
        guard let name = url.lastPathComponent.components(separatedBy: ".").first else {
            return nil
        }
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            return nil
        }
        return trimmed
    }
    
    private func parseMachines(inArrangement arrangementDir: URL, fromFile url: URL) -> [Machine.Dependency]? {
        guard let str = try? String(contentsOf: url) else {
            self.errors.append("Unable to read file \(url.path)")
            return nil
        }
        let lines = str.components(separatedBy: .newlines).lazy.map { $0.trimmingCharacters(in: .whitespaces)}.filter { $0 != "" }
        guard let dependencies: [Machine.Dependency] = lines.failMap({
            let components = $0.components(separatedBy: "->")
            guard let first = components.first else {
                return nil
            }
            let name: String?
            let filePath: String
            if components.count == 1 {
                name = nil
                filePath = $0
            } else {
                name = first
                filePath = components.dropFirst().joined(separator: "->")
            }
            let fileURL: URL
            if #available(OSX 10.11, *) {
                fileURL = URL(fileURLWithPath: filePath.trimmingCharacters(in: .whitespaces), isDirectory: false, relativeTo: arrangementDir).absoluteURL
            } else {
                fileURL = URL(fileURLWithPath: filePath.trimmingCharacters(in: .whitespaces), isDirectory: false)
            }
            guard let machineName = fileURL.lastPathComponent.components(separatedBy: ".").first else {
                self.errors.append("Unable to parse machine name from file path \(fileURL.path)")
                return nil
            }
            return Machine.Dependency(name: name?.trimmingCharacters(in: .whitespaces), machineName: machineName.trimmingCharacters(in: .whitespaces), filePath: fileURL)
        }) else {
            return nil
        }
        return dependencies
    }
    
}
