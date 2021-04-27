/*
 * Arrangement.swift
 * Machines
 *
 * Created by Callum McColl on 28/11/20.
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
import Attributes
import SwiftMachines

public struct Arrangement: Identifiable, PathContainer {
    
    public enum Semantics: String, Hashable, Codable, CaseIterable {
        case other
        case swiftfsm
    }
    
    private let mutator: ArrangementMutator
    
    public private(set) var errorBag: ErrorBag<Arrangement> = ErrorBag()
    
    public private(set) var id: UUID = UUID()
    
    
    public static var path: Path<Arrangement, Arrangement> {
        return Attributes.Path<Arrangement, Arrangement>(path: \.self, ancestors: [])
    }
    
    public var path: Path<Arrangement, Arrangement> {
        return Arrangement.path
    }
    
    /// The name of the arrangement.
    public var name: String {
        return self.filePath.lastPathComponent.components(separatedBy: ".")[0]
    }
    
    /// The underlying semantics which this meta machine follows.
    public var semantics: Semantics
    
    /// The location of the arrangement on the file system.
    public var filePath: URL
    
    /// The root machines of the arrangement.
    public var rootMachines: [MachineDependency]
    
    public var attributes: [AttributeGroup]
    
    public var metaData: [AttributeGroup]
    
    public init(
        semantics: Semantics,
        filePath: URL,
        rootMachines: [MachineDependency] = [],
        attributes: [AttributeGroup],
        metaData: [AttributeGroup]
    ) {
        self.semantics = semantics
        switch semantics {
        case .swiftfsm:
            self.mutator = SwiftfsmConverter()
        case .other:
            fatalError("Use the mutator constructor if you wish to use an undefined semantics")
        }
        self.filePath = filePath
        self.rootMachines = rootMachines
        self.attributes = attributes
        self.metaData = metaData
    }
    
    public init(loadAtFilePath url: URL) throws {
        let parser = SwiftMachines.MachineArrangementParser()
        guard let arrangement = parser.parseArrangement(atDirectory: url) else {
            throw ConversionError(message: parser.errors.last ?? "Unable to parse arrangement at \(url.path)", path: Machine.path)
        }
        self = SwiftfsmConverter().metaArrangement(of: arrangement)
    }
    
    public func flattenedDependencies() throws -> [FlattenedDependency] {
        let allMachines = try self.allMachines()
        func process(_ dependency: MachineDependency) throws -> FlattenedDependency {
            guard let machine = allMachines[dependency.filePath] else {
                throw ConversionError(message: "Unable to parse all dependent machines", path: Machine.path.dependencies)
            }
            let dependencies = try machine.dependencies.map(process)
            return FlattenedDependency(name: dependency.name, machine: machine, dependencies: dependencies)
        }
        return try rootMachines.map(process)
    }
    
    public func allMachines() throws -> [URL: Machine] {
        var dict: [URL: Machine] = [:]
        dict.reserveCapacity(rootMachines.count)
        func recurse(_ dependency: MachineDependency) throws {
            if nil != dict[dependency.filePath.resolvingSymlinksInPath().absoluteURL] {
                return
            }
            let machine = try Machine(filePath: dependency.filePath.resolvingSymlinksInPath().absoluteURL)
            dict[dependency.filePath.resolvingSymlinksInPath().absoluteURL] = machine
            try machine.dependencies.forEach(recurse)
        }
        try rootMachines.forEach(recurse)
        return dict
    }
    
    public func save() throws {
        let swiftArrangement = try SwiftfsmConverter().convert(self)
        let generator = SwiftMachines.MachineArrangementGenerator()
        guard nil != generator.generateArrangement(swiftArrangement) else {
            throw ConversionError(message: generator.errors.last ?? "Unable to save arrangement", path: Machine.path)
        }
    }
    
}

extension Arrangement: Equatable {
    
    public static func == (lhs: Arrangement, rhs: Arrangement) -> Bool {
        return lhs.semantics == rhs.semantics
            && lhs.filePath == rhs.filePath
            && lhs.rootMachines == rhs.rootMachines
            && lhs.attributes == rhs.attributes
            && lhs.metaData == rhs.metaData
    }
    
}

extension Arrangement: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.semantics)
        hasher.combine(self.filePath)
        hasher.combine(self.rootMachines)
        hasher.combine(self.attributes)
        hasher.combine(self.metaData)
    }
    
}

extension Arrangement: Codable {
    
    public enum CodingKeys: CodingKey {
        
        case semantics
        case filePath
        case rootMachines
        case attributes
        case metaData
        
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let semantics = try container.decode(Semantics.self, forKey: .semantics)
        let filePath = try container.decode(URL.self, forKey: .filePath)
        let rootMachines = try container.decode([MachineDependency].self, forKey: .rootMachines)
        let attributes = try container.decode([AttributeGroup].self, forKey: .attributes)
        let metaData = try container.decode([AttributeGroup].self, forKey: .metaData)
        self.init(
            semantics: semantics,
            filePath: filePath,
            rootMachines: rootMachines,
            attributes: attributes,
            metaData: metaData
        )
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.semantics, forKey: .semantics)
        try container.encode(self.filePath, forKey: .filePath)
        try container.encode(self.rootMachines, forKey: .rootMachines)
        try container.encode(self.attributes, forKey: .attributes)
        try container.encode(self.metaData, forKey: .metaData)
    }
    
}
