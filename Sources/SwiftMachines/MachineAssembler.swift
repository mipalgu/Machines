/*
 * MachineAssembler.swift 
 * Machines 
 *
 * Created by Callum McColl on 20/02/2017.
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

import IO
import Machines
import Foundation
import swift_helpers

public final class MachineAssembler: Assembler, ErrorContainer {

    public private(set) var errors: [String] = []

    private let helpers: FileHelpers

    private let invoker: Invoker

    private let packageInitializer: PackageInitializer

    public var lastError: String? {
        return self.errors.last
    }

    private var takenVars: Set<String> = []

    private let varHelpers: VariableHelpers

    private let varParser: VarParser

    public init(
        helpers: FileHelpers = FileHelpers(),
        invoker: Invoker = Invoker(),
        packageInitializer: PackageInitializer = PackageInitializer(),
        varHelpers: VariableHelpers = VariableHelpers(),
        varParser: VarParser = VarParser()
    ) {
        self.helpers = helpers
        self.invoker = invoker
        self.packageInitializer = packageInitializer
        self.varHelpers = varHelpers
        self.varParser = varParser
    }

    public func packagePath(forMachine machine: Machine) -> String {
        return machine.filePath.appendingPathComponent(".build", isDirectory: true)
            .appendingPathComponent(machine.name + "Machine", isDirectory: true)
            .path
    }

    public func assemble(_ machine: Machine) -> (URL, [URL])? {
        return self.assemble(machine, isSubMachine: false)
    }

    private func assemble(_ machine: Machine, isSubMachine: Bool) -> (URL, [URL])? {
        self.takenVars = Set(machine.externalVariables.map { $0.label }) 
        self.takenVars.insert("fsmVars")
        if nil != machine.parameters {
            self.takenVars.insert("parameters")
        }
        let errorMsg = "Unable to assemble \(machine.filePath.path)"
        var dependencies = (machine.submachines + machine.parameterisedMachines).flatMap { self.assemble($0, isSubMachine: true)?.0 }
        if dependencies.count != (machine.submachines.count + machine.parameterisedMachines.count) {
            self.errors.append("Unable to assemble dependencies.")
            return nil
        }
        guard
            let buildDir = self.helpers.overwriteSubDirectory(".build", inDirectory: machine.filePath)
        else {
            self.errors.append(errorMsg)
            return nil
        }
        var files: [URL] = []
        if let _ = machine.includes {
            guard
                let bridgingPackageDir = self.packageInitializer.initialize(
                    withName: "\(machine.name)MachineBridging",
                    andType: .SystemModule,
                    inDirectory: buildDir
                ),
                let bridgingPath = self.makeBridgingHeader(forMachine: machine, inDirectory: bridgingPackageDir),
                let modulePath = self.makeBridgingModuleMap(forMachine: machine, inDirectory: bridgingPackageDir),
                true == self.createAndTagGitRepo(inDirectory: bridgingPackageDir)
            else {
                self.errors.append(errorMsg)
                return nil
            }
            dependencies.append(bridgingPackageDir)
            files.append(contentsOf: [bridgingPackageDir.appendingPathComponent("Package.swift", isDirectory: false), bridgingPath, modulePath])
        }
        guard
            let packageDir = self.packageInitializer.initialize(withName: "\(machine.name)Machine", inDirectory: buildDir),
            let package = self.makePackage(forMachine: machine, inDirectory: packageDir, withDependencies: dependencies),
            let sourcesDir = self.helpers.overwriteSubDirectory("Sources", inDirectory: packageDir),
            let srcDir = self.helpers.overwriteSubDirectory(machine.name + "Machine", inDirectory: sourcesDir),
            let externals = self.makeExternalExtensions(forMachine: machine, inDirectory: srcDir),
            let factoryPath = self.makeFactory(forMachine: machine, inDirectory: srcDir),
            let fsmVarsPath = self.makeFsmVars(forMachine: machine, inDirectory: srcDir),
            let statePaths = self.makeStates(forMachine: machine, inDirectory: srcDir)
        else {
            self.errors.append(errorMsg)
            return nil
        }
        files.append(contentsOf: [factoryPath, fsmVarsPath, package])
        files.append(contentsOf: externals)
        files.append(contentsOf: statePaths)
        if false == isSubMachine {
            guard let mainPath = self.makeMain(forMachine: machine, inDirectory: srcDir) else {
                self.errors.append(errorMsg)
                return nil
            }
            files.append(mainPath)
        }
        guard let model = machine.model else {
            guard true == self.createAndTagGitRepo(inDirectory: packageDir) else {
                self.errors.append(errorMsg)
                return nil
            }
            return (packageDir, files)
        }
        guard
            let ringletPath = self.makeRinglet(forRinglet: model.ringlet, withMachineName: machine.name, andStateType: model.stateType, inDirectory: srcDir),
            let stateTypePath = self.makeStateType(fromModel: model, inDirectory: srcDir),
            let emptyStateTypePath = self.makeEmptyStateType(fromModel: model, inDirectory: srcDir),
            let callbackStateTypePath = self.makeCallbackStateType(fromModel: model, inDirectory: srcDir)
        else {
            self.errors.append(errorMsg)
            return nil
        }
        files.append(contentsOf: [ringletPath, stateTypePath, emptyStateTypePath, callbackStateTypePath])
        guard true == self.createAndTagGitRepo(inDirectory: packageDir) else {
            self.errors.append(errorMsg)
            return nil
        }
        return (packageDir, files) 
    }

    public func makeBridgingHeader(forMachine machine: Machine, inDirectory path: URL) -> URL? {
        let headerPath = path.appendingPathComponent("\(machine.name)-Bridging-Header.h", isDirectory: false)
        let str = machine.includes ?? ""
        guard true == self.helpers.createFile(atPath: headerPath, withContents: str) else {
            self.errors.append("Unable to create \(headerPath.path)")
            return nil
        }
        return headerPath
    }

    private func makeBridgingModuleMap(forMachine machine: Machine, inDirectory path: URL) -> URL? {
        let modulePath = path.appendingPathComponent("module.modulemap", isDirectory: false)
        var str = "module \(machine.name)MachineBridging [system] [swift_infer_import_as_member] {\n"
        str += "    header \"\(machine.name)-Bridging-Header.h\"\n\n"
        str += "    export *\n"
        str += "}"
        guard true == self.helpers.createFile(atPath: modulePath, withContents: str) else {
            self.errors.append("Unable to create module.modulemap at \(modulePath.path)")
            return nil
        }
        return modulePath
    }

    private func makePackage(forMachine machine: Machine, inDirectory path: URL, withDependencies dependencies: [(URL)]) -> URL? {
        let packagePath = path.appendingPathComponent("Package.swift", isDirectory: false)
        let dependencies = dependencies.map {
            ".package(url: \"\($0.absoluteString)\", .branch(\"master\"))"
        }.reduce(".package(url: \"ssh://git.mipal.net/git/CGUSimpleWhiteboard\", .branch(\"swift-4.2\")),\n        .package(url: \"ssh://git.mipal.net/git/swift_wb\", .branch(\"swift-4.2\"))") { $0 + ",\n        " + $1 }
        let dependencyList: String
        let defaults = "\"GUSimpleWhiteboard\""
        if let first = (machine.submachines + machine.parameterisedMachines).first {
            let list = (machine.submachines + machine.parameterisedMachines).dropFirst().reduce("\"" + first.name + "Machine\"") {
                $0 + ", \"" + $1.name + "Machine\""
            }
            dependencyList = "[" + defaults + ", " + list + "]"
        } else {
            dependencyList = "[" + defaults + "]"
        }
        let str = """
            // swift-tools-version:4.0
            import PackageDescription

            let package = Package(
                name: "\(machine.name)Machine",
                products: [
                    .library(
                        name: "\(machine.name)Machine",
                        type: .dynamic,
                        targets: ["\(machine.name)Machine"]
                    )
                ],
                dependencies: [
                    \(dependencies)
                ],
                targets: [
                    .target(name: "\(machine.name)Machine", dependencies: \(dependencyList))
                ]
            )

            """
        guard true == self.helpers.createFile(atPath: packagePath, withContents: str) else {
            self.errors.append("Unable to create Package.swift at \(packagePath.path)")
            return nil
        }
        return packagePath
    }

    private func makeExternalExtensions(forMachine machine: Machine, inDirectory path: URL) -> [URL]? {
        var arr: [URL] = []
        arr.reserveCapacity(machine.externalVariables.count)
        var completed: Set<String> = []
        for e in machine.externalVariables {
            if (true == completed.contains(e.messageClass)) {
                continue
            }
            guard let file = self.makeExternalExtension(forExternalVariables: e, inDirectory: path) else {
                return nil
            }
            completed.insert(e.messageClass)
            arr.append(file)
        }
        return arr
    }

    private func makeExternalExtension(forExternalVariables externals: ExternalVariables, inDirectory path: URL) -> URL? {
        let file = path.appendingPathComponent("\(externals.messageClass).swift", isDirectory: false)
        var contents: String = ""
        contents += "import FSM\n"
        contents += "import CGUSimpleWhiteboard\n"
        contents += "import GUSimpleWhiteboard\n\n"
        contents += "extension \(externals.messageClass): ExternalVariables {}\n"
        guard true == self.helpers.createFile(atPath: file, withContents: contents) else {
            self.errors.append("Unable to create \(file.path)")
            return nil
        }
        return file
    }

    private func makeInvoker(forMachine machine: Machine, inDirectory path: URL) -> URL? {
        guard let parameters = machine.parameters else {
            self.errors.append("Cannot create an invoker for a machine which has no parameters")
            return nil
        }
        let invokerPath = path.appendingPathComponent("Invoker.swift", isDirectory: false)
        let parameterList = parameters.lazy.map {
            let str =  $0.label + ": " + $0.type
            guard let initialValue = $0.initialValue else {
                return str
            }
            return str + " = " + initialValue
        }.combine("") { $0 + ", " + $1 }
        let invokeList = parameters.lazy.map { $0.label + ": " + $0.label }.combine("") { $0 + ", " + $1 }
        let returnType = machine.returnType ?? "Void"
        let str = """
            import FSM
            import CGUSimpleWhiteboard
            import GUSimpleWhiteboard

            public final class \(machine.name.capitalized)Invoker: Invoker {

                public typealias ReturnType: \(returnType)

                public weak var delegate: InvokerDelegate?

                fileprivate let fsm: AnyScheduleableFiniteStateMachine

                public init(_ fsm: AnyScheduleableFiniteStateMachine) {
                    self.fsm = fsm
                }

                public func invoke(\(parameterList)) -> Promise<\(returnType)> {
                    guard let delegate = self.delegate else {
                        fatalError("\(machine.name.capitalized)Invoker delegate not set.")
                    }
                    let clone = fsm.clone()
                    clone.restart()
                    let parameters = \(machine.name.capitalized)Parameters(\(invokeList))
                    clone.parameters = parameters
                    return delegate.invoker(self, invoke: clone)
                }


            }
        """
        guard true == self.helpers.createFile(atPath: invokerPath, withContents: str) else {
            self.errors.append("Unable to create \(invokerPath.path)")
            return nil
        }
        return invokerPath
    }

    private func makeFactory(forMachine machine: Machine, inDirectory path: URL) -> URL? {
        let factoryPath = path.appendingPathComponent("factory.swift", isDirectory: false)
        var str = """
            import FSM
            import swiftfsm
            
            """
        if (false == machine.externalVariables.isEmpty) {
            str += "import CGUSimpleWhiteboard\n"
            str += "import GUSimpleWhiteboard\n"
        }
        for m in machine.submachines + machine.parameterisedMachines {
            str += "import \(m.name)Machine\n"
        }
        str += "\n"
        str += self.makeFactoryFunction(forMachine: machine)
        str += "\n\n"
        str += nil == machine.parameters ? self.makeSubmachineFactoryFunction(forMachine: machine) : self.makeParameterisedFactoryFunction(forMachine: machine)
        str += "\n\n"
        guard true == self.helpers.createFile(atPath: factoryPath, withContents: str) else {
            self.errors.append("Unable to create \(factoryPath.path)")
            return nil
        }
        return factoryPath
    }

    private func makeFactoryFunction(forMachine machine: Machine) -> String {
        let fun = nil == machine.parameters ? "make_submachine_" : "make_parameterised_"
        return """
            public func make_\(machine.name)(name: String, invoker: Invoker) -> (AnyScheduleableFiniteStateMachine, [Dependency]) {
                let (fsm, dependencies) = \(fun)\(machine.name)(name: name, invoker: invoker)
                return (fsm.asScheduleableFiniteStateMachine, dependencies)
            }
            """
    }

    private func makeSubmachineFactoryFunction(forMachine machine: Machine) -> String {
        //let nameParam = "name" + (machine.submachines.isEmpty && machine.parameterisedMachines.isEmpty ? " _" : "")
        let fun = "public func make_submachine_\(machine.name)(name: String, invoker: Invoker) -> (AnyControllableFiniteStateMachine, [Dependency]) {\n"
        return fun + self.makeFactoryContent(forMachine: machine, createParameterisedMachine: false) + "}\n\n"
    }
    
    private func makeParameterisedFactoryFunction(forMachine machine: Machine) -> String {
        //let nameParam = "name" + (machine.submachines.isEmpty && machine.parameterisedMachines.isEmpty ? " _" : "")
        let fun = "public func make_parameterised_\(machine.name)(name: String, invoker: Invoker) -> (AnyParameterisedFiniteStateMachine, [Dependency]) {\n"
        return fun + self.makeFactoryContent(forMachine: machine, createParameterisedMachine: true) + "}\n\n"
    }
    
    private func makeFactoryContent(forMachine machine: Machine, createParameterisedMachine: Bool) -> String {
        var str = ""
        /*for v in machine.externalVariables {
         str += "    let wbds\n"
         }*/
        if (false == machine.externalVariables.isEmpty) {
            str += "    // External Variables.\n"
        }
        for external in machine.externalVariables {
            str += "    let \(external.label) = SnapshotCollectionController<GenericWhiteboard<\(external.messageClass)>>(\n"
            str += "        \"\(external.wbName.map { $0 + "." } ?? "")\(external.messageType)\",\n"
            str += "        collection: GenericWhiteboard<\(external.messageClass)>(\n"
            str += "            msgType: \(external.messageType),\n"
            if let wbName = external.wbName {
                str += "            wbd: Whiteboard(wbd: gsw_new_whiteboard(\"\(wbName)\")),\n"
            }
            str += "            atomic: \(external.atomic),\n"
            str += "            shouldNotifySubscribers: \(external.shouldNotifySubscribers)\n"
            str += "        )\n"
            str += "    )\n"
        }
        if false == machine.submachines.isEmpty {
            str += "    // Submachines.\n"
            str += "    var submachines: [(AnyScheduleableFiniteStateMachine, [Dependency])] = []\n"
            for m in machine.submachines {
                str += "    let (\(m.name)Machine, \(m.name)MachineDependencies) = make_submachine_\(m.name)(name: name + \".\(machine.name)\", invoker: invoker)\n"
                str += "    submachines.append((\(m.name)Machine.asScheduleableFiniteStateMachine, \(m.name)MachineDependencies))\n"
            }
        }
        if false == machine.parameterisedMachines.isEmpty {
            str += "    // Parameterised Machines.\n"
            str += "    var parameterisedMachines: [(AnyParameterisedFiniteStateMachine, String, [Dependency])] = []\n"
            for m in machine.parameterisedMachines {
                let parameterList = m.parameters?.lazy.map {
                    let start = $0.label + ": " + $0.type
                    guard let initialValue = $0.initialValue else {
                        return start
                    }
                    return start + " = " + initialValue
                    }.combine("") { $0 + ", " + $1 }
                str += "    let (\(m.name)FSM, \(m.name)MachineDependencies) = make_parameterised_\(m.name)(name: name + \"\(m.name)\", invoker: invoker)\n"
                str += "    parameterisedMachines.append((\(m.name)FSM, name + \".\(machine.name)\", \(m.name)MachineDependencies))\n"
                str += "    func \(m.name)Machine(\(parameterList ?? "")) -> Promise<\(m.returnType ?? "Void")> { invoker.invoke(\(m.name)FSM) }\n"
            }
        }
        if nil != machine.parameters {
            str += "    // Parameters.\n"
            str += "    let parameters = SimpleVariablesContainer(vars: \(machine.name)Parameters())\n"
        }
        str += "    // FSM Variables.\n"
        str += "    let fsmVars = SimpleVariablesContainer(vars: \(machine.name)Vars())\n"
        str += "    // States.\n"
        for state in machine.states {
            let v = true == state.transitions.isEmpty ? "let" : "var"
            str += "    \(v) \(state.name) = \(state.name)State(\n"
            str += "        \"\(state.name)\",\n"
            for external in machine.externalVariables {
                str += "        \(external.label): \(external.label),\n"
            }
            if nil != machine.parameters {
                str += "        parameters: parameters,"
            }
            str += "        fsmVars: fsmVars,"
            for m in machine.submachines + machine.parameterisedMachines {
                str += "\n        \(m.name)Machine: \(m.name)Machine,"
            }
            str = str.trimmingCharacters(in: CharacterSet(charactersIn: ","))
            str += "\n    )\n"
        }
        str += "    // State Transitions.\n"
        for state in machine.states {
            for transition in state.transitions {
                guard let c = transition.condition else {
                    str += "    \(state.name).addTransition(Transition(\(transition.target)) { _ in true })\n"
                    continue
                }
                var conditionLines = c.components(separatedBy: CharacterSet.newlines)
                if (true == conditionLines.isEmpty) {
                    str += "    \(state.name).addTransition(Transition(\(transition.target)) { _ in true })\n"
                    continue
                }
                var condition = "        let state = $0 as! \(state.name)State\n"
                let last = conditionLines.removeLast()
                condition += conditionLines.reduce("") { $0 + "        \($1)\n" }
                let lastTokens = last.components(separatedBy: CharacterSet.whitespaces)
                if let firstLastToken = lastTokens.first {
                    condition += "        \("return" == firstLastToken ? "" : "return ")\(last)\n"
                } else {
                    condition += "        \(last)\n"
                }
                str += "    \(state.name).addTransition(Transition(\(transition.target)) {\n\(condition)    })\n"
            }
        }
        let externalsArray: String
        if (true == machine.externalVariables.isEmpty) {
            externalsArray = "[]"
        } else {
            var externals = machine.externalVariables
            let first = externals.removeFirst()
            externalsArray = externals.reduce("[AnySnapshotController(\(first.label))") { $0 + ", AnySnapshotController(\($1.label))" } + "]"
        }
        let suspendState: String
        let ringlet: String
        let initialPreviousState: String
        let exitState: String
        if (nil == machine.model) {
            suspendState = nil == machine.suspendState ? "EmptyMiPalState(\"_Suspend\")" : machine.suspendState!.name
            ringlet = "MiPalRinglet()"
            initialPreviousState = "EmptyMiPalState(\"_Previous\")"
            exitState = "EmptyMiPalState(\"_Exit\")"
        } else {
            str += "    let ringlet = \(machine.name)Ringlet()\n"
            suspendState = nil == machine.suspendState ? "Empty\(machine.model!.stateType)(\"_Suspend\")" : machine.suspendState!.name
            ringlet = "ringlet"
            initialPreviousState = "Empty\(machine.model!.stateType)(\"_Previous\")"
            exitState = "Empty\(machine.model!.stateType)(\"_Exit\")"
        }
        var dependencies: [String] = []
        if false == machine.submachines.isEmpty {
            dependencies.append("submachines.map { Dependency.submachine($0, $1) }")
        }
        if false == machine.parameterisedMachines.isEmpty {
            dependencies.append("parameterisedMachines.map { Dependency.parameterisedMachine($0, $1, $2) }")
        }
        let dependencyList = dependencies.isEmpty ? "[]" : dependencies.combine("") { $0 + " + " + $1 }
        let fsm: String
        if false == createParameterisedMachine {
            fsm = """
                MachineFSM(
                        name + \".\(machine.name)\",
                        initialState: \(machine.initialState.name),
                        externalVariables: \(externalsArray),
                        fsmVars: fsmVars,
                        ringlet: \(ringlet),
                        initialPreviousState: \(initialPreviousState),
                        suspendedState: nil,
                        suspendState: \(suspendState),
                        exitState: \(exitState)
                    )
                """
        } else {
            let parameters = nil == machine.parameters ? "SimpleVariablesContainer(vars: EmptyVariables())" : "parameters"
            fsm = """
                parameterisedFSM(
                        name + \".\(machine.name)\",
                        initialState: \(machine.initialState.name),
                        externalVariables: \(externalsArray),
                        fsmVars: fsmVars,
                        parameters: \(parameters),
                        ringlet: \(ringlet),
                        initialPreviousState: \(initialPreviousState),
                        suspendedState: nil,
                        suspendState: \(suspendState),
                        exitState: \(exitState)
                    )
                """
        }
        str += "    // Create FSM.\n"
        str += "    return (\(fsm), \(dependencyList))\n"
        return str
    }

    private func makeMain(forMachine machine: Machine, inDirectory path: URL) -> URL? {
        let mainPath = path.appendingPathComponent("main.swift", isDirectory: false)
        var str = "import swiftfsm\n\n"
        str += "addFactory(make_\(machine.name))\n"
        guard true == self.helpers.createFile(atPath: mainPath, withContents: str) else {
            self.errors.append("Unable to create \(mainPath.path)")
            return nil
        }
        return mainPath
    }

    private func makeFsmVars(forMachine machine: Machine, inDirectory path: URL) -> URL? {
        let machinePath = path.appendingPathComponent("\(machine.name)Vars.swift", isDirectory: false)
        var str = "import FSM\n"
        str += "import swiftfsm\n"
        str += "import ModelChecking\n"
        str += "import KripkeStructure\n"
        str += "\(machine.imports)"
        if (false == machine.imports.isEmpty) {
            str += "\n"
        }
        str += "\npublic final class \(machine.name)Vars: Variables, Updateable {\n\n"
        if (false == machine.vars.isEmpty) {
            str += "\(machine.vars.reduce("") { $0 + "    \(self.varHelpers.makeDeclarationAndAssignment(forVariable: $1))\n" })"
        }
        str += "    public final func clone() -> \(machine.name)Vars {\n"
        str += "        let vars = \(machine.name)Vars()\n"
        str += machine.vars.reduce("") {
            $0 + "        " + self.varHelpers.makeAssignment(withLabel: "vars.\($1.label)", andValue: "self.\($1.label)") + "\n"
        }
        str += "        return vars\n"
        str += "    }\n\n"
        str += "    public final func update(fromDictionary dictionary: [String: Any]) {\n"
        str += machine.vars.reduce("") {
            $0 + "        " + (true == self.varHelpers.isComplex(variable: $1)
                ? "self.\($1.label).update(fromDictionary: dictionary[\"\($1.label)\"] as! [String: Any])\n"
                : "self.\($1.label) = dictioanry[\"\($1.label)\"] as! \($1.type)\n")
        }
        str += "    }\n\n"
        str += "}\n"
        guard true == self.helpers.createFile(atPath: machinePath, withContents: str) else {
            self.errors.append("Unable to create \(machinePath.path)")
            return nil
        }
        return machinePath
    }

    private func makeRinglet(forRinglet ringlet: Ringlet, withMachineName machine: String, andStateType stateType: String, inDirectory path: URL) -> URL? {
        let ringletPath = path.appendingPathComponent("\(machine)Ringlet.swift")
        var str = "import FSM\n"
        str += "import swiftfsm\n"
        str += "import ModelChecking\n"
        str += "import KripkeStructure\n"
        str += ringlet.imports
        str += "\npublic final class \(machine)Ringlet: Ringlet, Cloneable, Updateable {\n\n"
        str += "    public typealias _StateType = \(stateType)\n\n"
        str += "\(ringlet.vars.reduce("") { $0 + "    \(self.varHelpers.makeDeclarationAndAssignment(forVariable: $1))\n" })\n"
        str += "    public init() {}\n\n"
        str += "    public func execute(state: \(stateType)) -> \(stateType) {\n"
        str += "\(ringlet.execute.components(separatedBy: "\n").reduce("") { $0 + "        \($1)\n" })"
        str += "    }\n\n"
        str += "    private func checkTransitions(forState state: \(stateType)) -> \(stateType)? {\n"
        str += "        return state.transitions.lazy.filter(self.isValid(forState: state)).first?.target\n"
        str += "    }\n\n"
        str += "    private func isValid(forState state: \(stateType)) -> (Transition<\(stateType), \(stateType)>) -> Bool {\n"
        str += "        return { $0.canTransition(state) }\n"
        str += "    }\n\n"
        str += "    public final func clone() -> \(machine)Ringlet {\n"
        str += "        let ringlet = \(machine)Ringlet()\n"
        str += ringlet.vars.reduce("") {
            $0 + "        " + self.varHelpers.makeAssignment(withLabel: "ringlet.\($1.label)", andValue: "self.\($1.label)") + "\n"
        }
        str += "        return ringlet\n"
        str += "    }\n\n"
        str += "    public final func update(fromDictionary dictionary: [String: Any]) {\n"
        str += ringlet.vars.reduce("") {
            $0 + "        " + (true == self.varHelpers.isComplex(variable: $1)
                ? "self.\($1.label).update(fromDictionary: dictionary[\"\($1.label)\"] as! [String: Any])\n"
                : "self.\($1.label) = dictioanry[\"\($1.label)\"] as! \($1.type)\n")
        }
        str += "    }\n\n"
        str += "}\n"
        if (false == self.helpers.createFile(atPath: ringletPath, withContents: str)) {
            return nil
        }
        return ringletPath
    }

    private func makeStates(forMachine machine: Machine, inDirectory path: URL) -> [URL]? {
        var paths: [URL] = []
        paths.reserveCapacity(machine.states.count)
        for state in machine.states {
            guard
                let statePath = self.makeState(state, forMachine: machine, inDirectory: path)
            else {
                return nil
            }
            paths.append(statePath)
        }
        return paths
    }

    private func makeState(_ state: State, forMachine machine: Machine, inDirectory path: URL) -> URL? {
        let statePath = path.appendingPathComponent("\(state.name)State.swift", isDirectory: false)
        var str = "import FSM\nimport swiftfsm\nimport ExternalVariables\n"
        if let _ = machine.includes {
            str += "import \(machine.name)MachineBridging\n"
        }
        if (false == machine.externalVariables.isEmpty) {
            str += "import CGUSimpleWhiteboard\n"
            str += "import GUSimpleWhiteboard\n"
        }
        if (false == state.imports.isEmpty) {
            str += "\(state.imports)\n"
        }
        for m in machine.submachines + machine.parameterisedMachines {
            str += "import \(m.name)Machine\n"
        }
        str += "\n"
        let stateType = nil == machine.model ? "MiPalState" : machine.model!.stateType
        str += "public class \(state.name)State: \(stateType) {\n\n"
        for external in machine.externalVariables {
            str += "    public let _\(external.label): SnapshotCollectionController<GenericWhiteboard<\(external.messageClass)>>\n"
        }
        str += "    private let _fsmVars: SimpleVariablesContainer<\(machine.name)Vars>\n\n"
        for submachine in machine.submachines {
            str += "    public private(set) var \(submachine.name)Machine: AnyControllableFiniteStateMachine\n"
        }
        if (false == machine.submachines.isEmpty) {
            str += "\n"
        }
        for m in machine.parameterisedMachines {
            let parameterList = m.parameters?.lazy.map { $0.type }.combine("") { $0 + ", " + $1 }
            str += "    fileprivate var _\(m.name)Machine: (\(parameterList)) -> Promise<\(m.returnType ?? "Void")>\n"
        }
        if (false == machine.parameterisedMachines.isEmpty) {
            str += "\n"
        }
        // State variables.
        guard
            let _ = state.vars.failMap({ (v: Variable) -> Variable? in
                if "_" == v.label.characters.first {
                    self.errors.append("\(v.label) cannot start with an underscore in state \(state.name)")
                    return nil
                }
                if true == takenVars.contains(v.label) {
                    self.errors.append("\(v.label) is defined twice in state \(state.name)")
                    return nil
                }
                takenVars.insert(v.label)
                return v
            })
        else {
            return nil
        }
        str += state.vars.reduce("") {
            $0 + "    " + self.varHelpers.makeDeclarationAndAssignment(forVariable: $1) + "\n"
        }
        if (false == state.vars.isEmpty) {
            str += "\n"
        }
        // FSM variables.
        str += self.createComputedProperty(withLabel: "fsmVars", andType: "\(machine.name)Vars", referencing: "self._fsmVars.vars")
        str += self.createComputedProperties(fromVars: machine.vars, withinContainer: "self.fsmVars")
        // External variables.
        for external in machine.externalVariables {
            str += self.createComputedProperty(withLabel: external.label, andType: external.messageClass, referencing: "_\(external.label).val")
            //str += self.createComputedProperties(fromVars: external.vars, withinContainer: "\(external.label)")
        }
        // Init.
        str += "    public init(\n"
        str += "        _ name: String,\n"
        str += "        transitions: [Transition<\(state.name)State, \(stateType)>] = [],\n"
        for external in machine.externalVariables {
            str += "        \(external.label): SnapshotCollectionController<GenericWhiteboard<\(external.messageClass)>>,\n"
        }
        str += "        fsmVars: SimpleVariablesContainer<\(machine.name)Vars>,\n"
        for submachine in machine.submachines {
            str += "        \(submachine.name)Machine: AnyControllableFiniteStateMachine,\n"
        }
        for m in machine.parameterisedMachines {
            let parameterList = m.parameters?.lazy.map { $0.type }.combine("") { $0 + ", " + $1 }
            str += "    \(m.name)Machine: (\(parameterList)) -> Promise<\(m.returnType ?? "Void")>,\n"
        }
        str = str.trimmingCharacters(in: CharacterSet(charactersIn: ",\n"))
        str += "\n    ) {\n"
        for external in machine.externalVariables {
            str += "        self._\(external.label) = \(external.label)\n"
        }
        str += "        self._fsmVars = fsmVars\n"
        for submachine in machine.submachines {
            str += "        self.\(submachine.name)Machine = \(submachine.name)Machine\n"
        }
        for m in machine.parameterisedMachines {
            str += "        self._\(m.name)Machine = \(m.name)Machine\n"
        }
        str += "        super.init(name, transitions: cast(transitions: transitions))\n"
        str += "    }\n\n"
        // Parameterised Machine Functions
        for m in machine.parameterisedMachines {
            let parameterList = m.parameters?.lazy.map {
                let start = $0.label + ": " + $0.type
                guard let initialValue = $0.initialValue else {
                    return start
                }
                return start + " = " + initialValue
            }.combine("") { $0 + ", " + $1 }
            let paramsCalled = m.parameters?.lazy.map { $0.label + ": " + $0.label }
            let callList: String? = paramsCalled?.combine("") { $0 + ", " + $1 }
            str += "    public func \(m.name)Machine(\(parameterList ?? "") -> \(m.returnType ?? "Void") { return self._\(m.name)Machine(\(callList ?? "") }"
        }
        // Actions.
        for action in state.actions {
            str += "    public override func \(action.name)() {\n"
            str += "\(action.implementation.components(separatedBy: "\n").reduce("") { $0 + "        \($1)\n" })"
            str += "    }\n\n"
        }
        // Clone.
        str += "    public override final func clone() -> \(state.name)State {\n"
        str += "        let state = \(state.name)State(\n"
        str += "            \"\(state.name)\",\n"
        str += "            transitions: cast(transitions: self.transitions),\n"
        for external in machine.externalVariables {
            str += "            \(external.label): self._\(external.label),\n"
        }
        str += "            fsmVars: self._fsmVars,\n"
        for submachine in machine.submachines {
            str += "            \(submachine.name)Machine: self.\(submachine.name)Machine,\n"
        }
        for m in machine.parameterisedMachines {
            str += "            \(m.name)Machine: self.\(m.name)Machine,\n"
        }
        str = str.trimmingCharacters(in: CharacterSet(charactersIn: ",\n"))
        str += "\n        )\n"
        str += state.vars.reduce("") {
            $0 + "        " + self.varHelpers.makeAssignment(withLabel: "state.\($1.label)", andValue: "self.\($1.label)") + "\n"
        }
        str += "        return state\n"
        str += "    }\n\n"
        str += "}\n"
        if (false == self.helpers.createFile(atPath: statePath, withContents: str)) {
            self.errors.append("Unable to create state at \(statePath.path)")
            return nil
        }
        return statePath
    }

    private func makeStateType(fromModel model: Model, inDirectory path: URL) -> URL? {
        let stateTypePath = path.appendingPathComponent("\(model.stateType).swift", isDirectory: false)
        var str = "import FSM\n"
        str += "import swiftfsm\n"
        str += "import ModelChecking\n"
        str += "import KripkeStructure\n\n"
        str += "public class \(model.stateType):\n"
        str += "    StateType,\n"
        str += "    CloneableState,\n"
        str += "    CustomStringConvertible,\n"
        str += "    CustomDebugStringConvertible,\n"
        str += "    Transitionable,\n"
        str += "    KripkeVariablesModifier\n"
        str += "{\n\n"
        str += "    public let name: String\n\n"
        str += "    public var transitions: [Transition<\(model.stateType), \(model.stateType)>]\n\n"
        str += "    public var validVars: [String: [Any]] {\n"
        str += "        return [:]\n"
        str += "    }\n\n"
        str += "    public init(_ name: String, transitions: [Transition<\(model.stateType), \(model.stateType)>] = []) {\n"
        str += "        self.name = name\n"
        str += "        self.transitions = transitions\n"
        str += "    }\n\n"
        for action in model.actions {
            str += "    public func \(action)() {}\n\n"
        }
        str += "    public func clone() -> Self {\n"
        str += "        fatalError(\"Please implement your own clone.\")\n"
        str += "    }\n\n"
        str += "    public func update(fromDictionary dictionary: [String: Any]) {}\n\n"
        str += "}\n"
        if (false == self.helpers.createFile(atPath: stateTypePath, withContents: str)) {
            self.errors.append("Unable to create \(model.stateType) at \(stateTypePath.path)")
            return nil
        }
        return stateTypePath
    }

    public func makeEmptyStateType(fromModel model: Model, inDirectory path: URL) -> URL? {
        let emptyStateTypePath = path.appendingPathComponent("Empty\(model.stateType).swift", isDirectory: false)
        var str = "import FSM\nimport swiftfsm\n\n"
        str += "public final class Empty\(model.stateType): \(model.stateType) {\n\n"
        for action in model.actions {
            str += "    public override final func \(action)() {}\n\n"
        }
        str += "    public override final func clone() -> Empty\(model.stateType) {\n"
        str += "        return Empty\(model.stateType)(self.name, transitions: self.transitions)\n"
        str += "    }\n\n"
        str += "}\n"
        if (false == self.helpers.createFile(atPath: emptyStateTypePath, withContents: str)) {
            self.errors.append("Unable to create Empty\(model.stateType) at \(emptyStateTypePath.path)")
            return nil
        }
        return emptyStateTypePath
    }

    public func makeCallbackStateType(fromModel model: Model, inDirectory path: URL) -> URL? {
        let callbackStateTypePath = path.appendingPathComponent("Callback\(model.stateType).swift", isDirectory: false)
        var str = "import FSM\nimport swiftfsm\n\n"
        str += "public final class Callback\(model.stateType): \(model.stateType) {\n\n"
        for action in model.actions {
            str += "    private let _\(action): () -> Void\n\n"
        }
        str += "    public init(\n"
        str += "        _ name: String,\n"
        str += "        transitions: [Transition<Callback\(model.stateType), \(model.stateType)>] = [],"
        var actionsList = ""
        for action in model.actions {
            actionsList += "\n        \(action): @escaping () -> Void = {},"
        }
        str += "\(String(actionsList.characters.dropLast()))\n"
        str += "    ) {\n"
        for action in model.actions {
            str += "        self._\(action) = \(action)\n"
        }
        str += "        super.init(name, transitions: cast(transitions: transitions))\n"
        str += "    }\n\n"
        for action in model.actions {
            str += "    public final override func \(action)() {\n"
            str += "        self._\(action)()\n"
            str += "    }\n\n"
        }
        str += "    public override final func clone() -> Callback\(model.stateType) {\n"
        str += "        return Callback\(model.stateType)(self.name, transitions: cast(transitions: self.transitions))\n"
        str += "    }\n\n"
        str += "}\n"
        if (false == self.helpers.createFile(atPath: callbackStateTypePath, withContents: str)) {
            self.errors.append("Unable to create Callback\(model.stateType) at \(callbackStateTypePath.path)")
            return nil
        }
        return callbackStateTypePath
    }

    private func createAndTagGitRepo(inDirectory dir: URL) -> Bool {
        let bin = "/usr/bin/env"
        let initArgs = ["git", "init"]
        let addArgs = ["git", "add", "."]
        let commitArgs = ["git", "commit", "-am", "\"Initial Commit\""]
        let tagArgs = ["git", "tag", "0.1.0"]
        guard
            let cwd = self.helpers.cwd,
            true == self.helpers.changeCWD(toPath: dir),
            true == self.invoker.run(bin, withArguments: initArgs),
            true == self.invoker.run(bin, withArguments: addArgs),
            true == self.invoker.run(bin, withArguments: commitArgs),
            true == self.invoker.run(bin, withArguments: tagArgs),
            true == self.helpers.changeCWD(toPath: cwd)
        else {
            self.errors.append("Unable to initialize swift package")
            return false
        }
        return true
    }

    private func createComputedProperties(fromVars vars: [Variable], withinContainer container: String) -> String {
        return vars.reduce("") {
            if true == takenVars.contains($1.label) {
                return $0
            }
            takenVars.insert($1.label)
            return $0 + self.createComputedProperty(withLabel: $1.label, andType: $1.type, referencing: "\(container).\($1.label)")
        }
    }

    private func createComputedProperty(withLabel label: String, andType type: String, referencing reference: String) -> String {
        var str = ""
        str += "    public private(set) var \(label): \(type) {\n"
        str += "        get {\n"
        str += "            return \(reference)\n"
        str += "        } set {\n"
        str += "            \(reference) = newValue\n"
        str += "        }\n"
        str += "    }\n\n"
        return str
    }

}
