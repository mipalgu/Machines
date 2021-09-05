/*
 * MachineArrangementGenerator.swift
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
import IO

extension URL {
    
    public func relativePathString(relativeto base: URL) -> String {
        let baseDir = base.isFileURL ? base.standardized.deletingLastPathComponent() : base.standardized
        let target = self.standardized
        let components = zip(baseDir.pathComponents, target.pathComponents).drop { $0 == $1 }.map { _ in ".." }
        let path = (components + target.pathComponents.dropFirst(baseDir.pathComponents.count - components.count)).joined(separator: "/")
        return path
    }
    
}

public final class MachineArrangementGenerator {
    
    public private(set) var errors: [String] = []
    
    private let helpers: FileHelpers
    
    public init(helpers: FileHelpers = FileHelpers()) {
        self.helpers = helpers
    }
    
    public func generateArrangement(_ arrangement: Arrangement, atDirectory arrangementDir: URL, inDirectory buildDir: URL) -> (URL, FileWrapper)? {
        self.errors = []
        guard nil != self.helpers.overwriteDirectory(arrangementDir) else {
            self.errors.append("Unable to create arrangement directory")
            return nil
        }
        guard let wrapper = generateArrangement(arrangement, atDirectory: arrangementDir) else {
            return nil
        }
        do {
            try wrapper.write(to: buildDir, options: .atomic, originalContentsURL: nil)
        } catch let e {
            self.errors.append("\(e)")
            return nil
        }
        return (buildDir, wrapper)
    }
    
    public func generateArrangement(_ arrangement: Arrangement, atDirectory arrangementDir: URL) -> FileWrapper? {
        self.errors = []
        guard let deps = self.createDependencies(arrangement.dependencies, parent: arrangementDir) else {
            return nil
        }
        let wrapper = FileWrapper(directoryWithFileWrappers: [:])
        wrapper.preferredFilename = arrangement.name + ".arrangement"
        wrapper.addFileWrapper(deps)
        return wrapper
    }
    
    private func createDependencies(_ dependencies: [Machine.Dependency], parent: URL) -> FileWrapper? {
        let str = dependencies.map {
            let relativePath = $0.filePath(relativeTo: parent.appendingPathComponent("Machines", isDirectory: false)).relativePath
            if let name = $0.name {
                return name + " -> " + relativePath
            }
            return relativePath
        }.joined(separator: "\n")
        guard let data = str.data(using: .utf8) else {
            self.errors.append("Unable to encode string \(str)")
            return nil
        }
        let wrapper = FileWrapper(regularFileWithContents: data)
        wrapper.preferredFilename = "Machines"
        return wrapper
    }
    
}
