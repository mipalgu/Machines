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

/* This takes an object of class Machine and packages it
 */

import IO
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
    
    public func packageDir(forMachine machine: Machine, builtInDirectory buildDir: URL) -> URL {
        buildDir.appendingPathComponent(machine.name + "Machine", isDirectory: true)
    }

    public func packagePath(forMachine machine: Machine, builtInDirectory buildDir: URL) -> String {
        packageDir(forMachine: machine, builtInDirectory: buildDir).path
    }

    public func assemble(_ machine: Machine, atDirectory machineDir: URL, inDirectory directory: URL) -> (URL, FileWrapper)? {
        if
            let data = try? Data(contentsOf: directory.appendingPathComponent("machine.json", isDirectory: false)),
            let previousMachine = try? JSONDecoder().decode(MachineToken<Machine>.self, from: data),
            previousMachine == MachineToken(data: machine),
            let buildDir = try? FileWrapper(url: directory, options: .immediate)
        {
            return (packageDir(forMachine: machine, builtInDirectory: directory), buildDir)
        }
        guard let wrapper = self.assemble(machine, atDirectory: machineDir) else {
            return nil
        }
        return writeAssembledWrapper(wrapper, forMachine: machine, to: directory) ? (packageDir(forMachine: machine, builtInDirectory: directory), wrapper) : nil
    }
    
    public func assemble(_ machine: Machine, atDirectory machineDir: URL) -> FileWrapper? {
        self.assemble(machine, atDirectory: machineDir, isSubMachine: false)
    }
    
    public func writeAssembledWrapper(_ wrapper: FileWrapper, forMachine machine: Machine, to directory: URL) -> Bool {
        do {
            try wrapper.write(to: directory, options: .atomic, originalContentsURL: nil)
        } catch let e {
            self.errors = [e.localizedDescription]
            return false
        }
        let errorMsg = "Unable to assemble machine \(machine.name) in \(directory.path)"
        guard true == self.createAndTagGitRepo(inDirectory: directory.appendingPathComponent(machine.name + "Machine", isDirectory: true)) else {
            self.errors.append(errorMsg)
            return false
        }
        if let data = try? JSONEncoder().encode(MachineToken(data: machine)) {
            _ = try? data.write(to: directory.appendingPathComponent("machine.json", isDirectory: true))
        }
        return true
    }

    private func assemble(_ machine: Machine, atDirectory machineDir: URL, isSubMachine: Bool) -> FileWrapper? {
        let errorMsg = "Unable to assemble machine \(machine.name)"
        let buildDir = FileWrapper(directoryWithFileWrappers: [:])
        guard
            let bridgingPath = self.makeBridgingHeader(forMachine: machine),
            let modulePath = self.makeBridgingModuleMap(forMachine: machine)
        else {
            self.errors.append(errorMsg)
            return nil
        }
        let bridgingPackageDir = FileWrapper(directoryWithFileWrappers: [:])
        bridgingPackageDir.preferredFilename = machine.name + "MachineBridging"
        bridgingPackageDir.addFileWrapper(bridgingPath)
        bridgingPackageDir.addFileWrapper(modulePath)
        guard
            let factoryPath = self.makeFactory(forMachine: machine, atDirectory: machineDir),
            let fsmPath = self.makeFiniteStateMachine(fromMachine: machine)
        else {
            self.errors.append(errorMsg)
            return nil
        }
        let srcDir = FileWrapper(directoryWithFileWrappers: [:])
        srcDir.preferredFilename = machine.name + "Machine"
        srcDir.addFileWrapper(factoryPath)
        srcDir.addFileWrapper(fsmPath)
        if nil != machine.parameters {
            guard
                let parametersPath = self.makeParameters(forMachine: machine),
                let resultsPath = self.makeResultsContainer(forMachine: machine)
            else {
                self.errors.append(errorMsg)
                return nil
            }
            srcDir.addFileWrapper(parametersPath)
            srcDir.addFileWrapper(resultsPath)
        }
        guard
            let fsmVarsPath = self.makeFsmVars(forMachine: machine),
            let statePaths = self.makeStates(forMachine: machine, atDirectory: machineDir),
            let transitionTypePath = self.makeTransition(forMachine: machine)
        else {
            self.errors.append(errorMsg)
            return nil
        }
        srcDir.addFileWrapper(fsmVarsPath)
        srcDir.addFileWrapper(transitionTypePath)
        statePaths.forEach {
            srcDir.addFileWrapper($0)
        }
        guard
            let emptyStateTypePath = self.makeEmptyStateType(forMachine: machine.name, withActions: machine.model?.actions ?? ["onEntry", "onExit", "main"]),
            let callbackStateTypePath = self.makeCallbackStateType(forMachine: machine.name, withActions: machine.model?.actions ?? ["onEntry", "onExit", "main"])
        else {
            self.errors.append(errorMsg)
            return nil
        }
        srcDir.addFileWrapper(emptyStateTypePath)
        srcDir.addFileWrapper(callbackStateTypePath)
        if let model = machine.model {
            guard
                let ringletPath = self.makeRinglet(forRinglet: model.ringlet, inMachine: machine),
                let stateTypePath = self.makeStateType(forMachine: machine.name, fromModel: model)
            else {
                self.errors.append(errorMsg)
                return nil
            }
            srcDir.addFileWrapper(ringletPath)
            srcDir.addFileWrapper(stateTypePath)
        } else {
            guard
                let ringletPath = self.makeMiPalRinglet(withMachineName: machine.name),
                let stateTypePath = self.makeMiPalStateType(forMachine: machine.name)
            else {
                self.errors.append(errorMsg)
                return nil
            }
            srcDir.addFileWrapper(ringletPath)
            srcDir.addFileWrapper(stateTypePath)
        }
        let sourcesDir = FileWrapper(directoryWithFileWrappers: [:])
        sourcesDir.addFileWrapper(bridgingPackageDir)
        sourcesDir.addFileWrapper(srcDir)
        sourcesDir.preferredFilename = "Sources"
        guard
            let package = self.makePackage(forMachine: machine, atDirectory: machineDir, withAddedDependencies: []),
            let gitignore = self.makePackageGitIgnore(),
            let tests = self.makeTests(forMachine: machine)
        else {
            self.errors.append(errorMsg)
            return nil
        }
        let packageDir = FileWrapper(directoryWithFileWrappers: [:])
        packageDir.addFileWrapper(package)
        packageDir.addFileWrapper(gitignore)
        packageDir.addFileWrapper(sourcesDir)
        packageDir.addFileWrapper(tests)
        packageDir.preferredFilename = machine.name + "Machine"
        buildDir.addFileWrapper(packageDir)
        return buildDir
    }
    
    private func encode(inFile name: String, contents: String) -> FileWrapper? {
        guard let data = contents.data(using: .utf8) else {
            self.errors.append("Unable to encode data for file \(name)")
            return nil
        }
        let wrapper = FileWrapper(regularFileWithContents: data)
        wrapper.preferredFilename = name
        return wrapper
    }
    
    private func makeTests(forMachine machine: Machine) -> FileWrapper? {
        let str = """
            import XCTest
            @testable import \(machine.name)Machine

            final class \(machine.name)MachineTests: XCTestCase {
                func testMachine() throws {
                }
            }
            """
        guard let file = encode(inFile: machine.name + "MachineTests.swift", contents: str) else {
            return nil
        }
        let moduleDirectory = FileWrapper(directoryWithFileWrappers: [:])
        moduleDirectory.addFileWrapper(file)
        moduleDirectory.preferredFilename = machine.name + "MachineTests"
        let testsDirectory = FileWrapper(directoryWithFileWrappers: [:])
        testsDirectory.addFileWrapper(moduleDirectory)
        testsDirectory.preferredFilename = "Tests"
        return testsDirectory
    }
    
    private func makePackageGitIgnore() -> FileWrapper? {
        let str = """
            .DS_Store
            /.build
            /Packages
            /*.xcodeproj
            xcuserdata/
            DerivedData/
            .swiftpm/xcode/package.xcworkspace/contents.xcworkspacedata
            """
        return encode(inFile: ".gitignore", contents: str)
    }

    private func makeBridgingHeader(forMachine machine: Machine) -> FileWrapper? {
        encode(inFile: machine.name + "-Bridging-Header.h", contents: machine.includes ?? "")
    }

    private func makeBridgingModuleMap(forMachine machine: Machine) -> FileWrapper? {
        var str = "module \(machine.name)MachineBridging [system] [swift_infer_import_as_member] {\n"
        str += "    header \"\(machine.name)-Bridging-Header.h\"\n\n"
        str += "    export *\n"
        str += "}"
        return encode(inFile: "module.modulemap", contents: str)
    }

    private func makePackage(forMachine machine: Machine, atDirectory machineDir: URL, withAddedDependencies addedDependencies: [(URL)]) -> FileWrapper? {
        let mandatoryPackages: [String] = []
        let mandatoryProducts: [String] = []
        guard
            let constructedDependencies: [String] = machine.packageDependencies.failMap({
                guard let url = URL(string: $0.url.replacingMachineVariables(forMachine: machine, atDirectory: machineDir)) else {
                    self.errors.append("Malformed url in package dependency in machine \(machine.name): \($0.url)")
                    return nil
                }
                let qualifiers = $0.qualifiers.combine("") { $0 + ", " + $1 }
                return ".package(url: \"\(String(url.absoluteURL.standardized.absoluteString.reversed().drop(while: { $0 == "/" }).reversed()))\", \(qualifiers))"
            })
        else {
            return nil
        }
        let addedDependencyList = addedDependencies.map {
            ".package(url: \"\(String($0.absoluteString.reversed().drop(while: { $0 == "/" }).reversed()))\", .branch(\"main\"))"
        }
        let allConstructedDependencies = addedDependencyList + constructedDependencies + mandatoryPackages
        let dependencies = allConstructedDependencies.isEmpty ? "" : "\n        " + allConstructedDependencies.combine("") { $0 + ",\n        " + $1 } + "\n    "
        let products = Set((machine.packageDependencies.flatMap { $0.products } + mandatoryProducts) .map { "\"" + $0 + "\"" })
        let productList = (products + ["\"" + machine.name + "MachineBridging\""]).sorted().combine("") { $0 + ", " + $1 }
        let str = """
            // swift-tools-version:5.1
            import PackageDescription

            let package = Package(
                name: "\(machine.name)Machine",
                products: [
                    .library(
                        name: "\(machine.name)Machine",
                        targets: ["\(machine.name)Machine"]
                    )
                ],
                dependencies: [\(dependencies)],
                targets: [
                    .systemLibrary(name: "\(machine.name)MachineBridging"),
                    .target(name: "\(machine.name)Machine", dependencies: [\(productList)], linkerSettings: [.linkedLibrary("FSM")])
                ]
            )

            """
        return encode(inFile: "Package.swift", contents: str)
    }
    
    private func makeImports(forMachine machine: Machine) -> [String] {
        return Set(machine.packageDependencies.flatMap { $0.targets.map { "import " + $0 } }).sorted()
    }

    private func makeInvoker(forMachine machine: Machine) -> FileWrapper? {
        guard let parameters = machine.parameters else {
            self.errors.append("Cannot create an invoker for a machine which has no parameters")
            return nil
        }
        let parameterList = parameters.lazy.map {
            let str =  $0.label + ": " + $0.type
            guard let initialValue = $0.initialValue else {
                return str
            }
            return str + " = " + initialValue
        }.combine("") { $0 + ", " + $1 }
        let invokeList = parameters.lazy.map { $0.label + ": " + $0.label }.combine("") { $0 + ", " + $1 }
        let returnType = machine.returnType ?? "Void"
        let imports = self.makeImports(forMachine: machine).reduce("") { $0 + "\n" + $1 } + "\n"
        let str = """
            import swiftfsm\(imports)
            public final class \(machine.name)Invoker: Invoker {

                public typealias ReturnType: \(returnType)

                public weak var delegate: InvokerDelegate?

                fileprivate let fsm: AnyScheduleableFiniteStateMachine

                public init(_ fsm: AnyScheduleableFiniteStateMachine) {
                    self.fsm = fsm
                }

                public func invoke(\(parameterList)) -> Promise<\(returnType)> {
                    guard let delegate = self.delegate else {
                        fatalError("\(machine.name)Invoker delegate not set.")
                    }
                    let clone = fsm.clone()
                    clone.restart()
                    let parameters = \(machine.name)Parameters(\(invokeList))
                    clone.parameters = parameters
                    return delegate.invoker(self, invoke: clone)
                }


            }
        """
        return encode(inFile: "Invoker.swift", contents: str)
    }

    private func makeFactory(forMachine machine: Machine, atDirectory machineDir: URL) -> FileWrapper? {
        var str = """
            import swiftfsm
            """
        str += "\n"
        if nil != machine.includes {
            str += "import \(machine.name)MachineBridging\n"
        }
        if (false == machine.packageDependencies.isEmpty) {
            str += self.makeImports(forMachine: machine).reduce("") { $0 + $1 + "\n" }
        }
        str += "\n"
        str += self.makeFactoryFunction(forMachine: machine)
        str += "\n\n"
        guard let subFactory = (nil == machine.parameters ?
            self.makeSubmachineFactoryFunction(forMachine: machine, atDirectory: machineDir) :
            self.makeParameterisedFactoryFunction(forMachine: machine, atDirectory: machineDir))
        else {
            return nil
        }
        str += subFactory
        str += "\n\n"
        return encode(inFile: "factory.swift", contents: str)
    }

    private func makeFactoryFunction(forMachine machine: Machine) -> String {
        let fun = nil == machine.parameters ? "make_submachine_" : "make_parameterised_"
        let type = nil == machine.parameters ? "controllableFSM" : "parameterisedFSM"
        return """
            @_cdecl(\"make_\(machine.name)\")
            public func _make_\(machine.name)(gateway _gateway: UnsafeMutableRawPointer, clock _clock: UnsafeMutableRawPointer, caller _caller: UnsafeMutableRawPointer, callback _callback: UnsafeMutableRawPointer) {
                let gateway = _gateway.assumingMemoryBound(to: FSMGateway.self, capacity: 1).pointee
                let clock = _clock.assumingMemoryBound(to: Timer.self, capacity: 1).pointee
                let caller = _caller.assumingMemoryBound(to: FSM_ID.self, capacity: 1).pointee
                let callback = _callback.assumingMemoryBound(to: ((FSMType, [ShallowDependency]) -> Void).self, capacity: 1).pointee
                let (fsm, dependencies) = make_\(machine.name)(gateway: gateway, clock: clock, caller: caller)
                callback(fsm, dependencies)
            }
            
            public func make_\(machine.name)(name: String = "\(machine.name)", gateway: FSMGateway, clock: Timer, caller: FSM_ID) -> (FSMType, [ShallowDependency]) {
                let (fsm, dependencies) = \(fun)\(machine.name)(name: name, gateway: gateway, clock: clock, caller: caller)
                return (FSMType.\(type)(fsm), dependencies)
            }
            """
    }

    private func makeSubmachineFactoryFunction(forMachine machine: Machine, atDirectory machineDir: URL) -> String? {
        //let nameParam = "name" + (machine.submachines.isEmpty && machine.parameterisedMachines.isEmpty ? " _" : "")
        let fun = "public func make_submachine_\(machine.name)(name machineName: String, gateway: FSMGateway, clock: Timer, caller: FSM_ID) -> (AnyControllableFiniteStateMachine, [ShallowDependency]) {\n"
        guard let content = self.makeFactoryContent(forMachine: machine, atDirectory: machineDir, createParameterisedMachine: false) else {
            return nil
        }
        return fun + content + "}\n\n"
    }
    
    private func makeParameterisedFactoryFunction(forMachine machine: Machine, atDirectory machineDir: URL) -> String? {
        //let nameParam = "name" + (machine.submachines.isEmpty && machine.parameterisedMachines.isEmpty ? " _" : "")
        let fun = "public func make_parameterised_\(machine.name)(name machineName: String, gateway: FSMGateway, clock: Timer, caller: FSM_ID) -> (AnyParameterisedFiniteStateMachine, [ShallowDependency]) {\n"
        guard let content = self.makeFactoryContent(forMachine: machine, atDirectory: machineDir, createParameterisedMachine: true) else {
            return nil
        }
        return fun + content + "}\n\n"
    }
    
    private func makeFactoryContent(forMachine machine: Machine, atDirectory machineDir: URL, createParameterisedMachine: Bool) -> String? {
        var str = ""
        /*for v in machine.externalVariables {
         str += "    let wbds\n"
         }*/
        if (false == machine.externalVariables.isEmpty) {
            str += "    // External Variables.\n"
        }
        for external in machine.externalVariables {
            guard let value = external.initialValue else {
                fatalError("Cannot assemble machine because external variable \(external.label) does not have an initial value.")
            }
            str += "    let external_\(external.label): \(external.type) = \(value)\n"
        }
        if false == machine.subs.isEmpty {
            str += "    // Submachines.\n"
            str += "    var submachines: [() -> AnyControllableFiniteStateMachine] = []\n"
            for m in machine.subs {
                str += "    let \(m.callName)MachineID = gateway.id(of: \"\(m.callName)\")\n"
                str += "    let _\(m.callName)Machine = { gateway.fsm(fromID: \(m.callName)MachineID) }\n"
                str += "    submachines.append(_\(m.callName)Machine)\n"
            }
        }
        if false == machine.parameterisedDependencies.isEmpty {
            str += "    // Parameterised Machines.\n"
            for m in machine.parameterisedDependencies {
                let parameterisedMachine = m.machine(relativeTo: machineDir)
                let (parameterList, _) = self.makeParametersList(forMachine: parameterisedMachine)
                let params = parameterisedMachine.parameters?.map { "\"" + $0.label + "\": " + $0.label } ?? []
                let dictionary = params.isEmpty ? "[:]" : "[" + params.combine("") { $0 + ", " + $1 } + "]"
                str += "    let \(m.callName)MachineID = gateway.id(of: \"\(m.callName)\")\n"
                if nil != machine.callables.first(where: { $0.callName == m.callName }) {
                    str += "    func \(m.callName)(\(parameterList)) -> Promise<\(parameterisedMachine.returnType ?? "Void")> {\n"
                    str += "        return gateway.call(\(m.callName)MachineID, withParameters: \(dictionary), caller: caller)\n"
                    str += "    }\n"
                }
                if nil != machine.invocables.first(where: { $0.callName == m.callName }) {
                    str += "    func \(m.callName)Machine(\(parameterList)) -> Promise<\(parameterisedMachine.returnType ?? "Void")> {\n"
                    str += "        return gateway.invoke(\(m.callName)MachineID, withParameters: \(dictionary), caller: caller)\n"
                    str += "    }\n"
                }
            }
        }
        if nil != machine.parameters {
            str += "    // Parameters.\n"
            str += "    let parameters = SimpleVariablesContainer(vars: \(machine.name)Parameters())\n"
            str += "    let results = SimpleVariablesContainer(vars: \(machine.name)ResultsContainer())\n"
            str += "    // Function to recursively call myself.\n"
            let (parameterList, _) = self.makeParametersList(forMachine: machine)
            let params = machine.parameters?.map { "\"" + $0.label + "\": " + $0.label } ?? []
            let dictionary = params.isEmpty ? "[:]" : "[" + params.combine("") { $0 + ", " + $1 } + "]"
            str += "    let \(machine.name)MachineID = gateway.id(of: machineName)\n"
            str += "    func \(machine.name)(\(parameterList)) -> Promise<\(machine.returnType ?? "Void")> {\n"
            str += "        return gateway.call(\(machine.name)MachineID, withParameters: \(dictionary), caller: caller)\n"
            str += "    }\n"
        }
        str += "    // FSM Variables.\n"
        str += "    let fsmVars = SimpleVariablesContainer(vars: \(machine.name)Vars())\n"
        str += "    // States.\n"
        for state in machine.states {
            let v = true == state.transitions.isEmpty ? "let" : "var"
            str += "    \(v) state_\(state.name) = State_\(state.name)(\n"
            str += "        \"\(state.name)\",\n"
            str += "        gateway: gateway,\n"
            str += "        clock: clock,"
            if nil != machine.parameters {
                str += "\n        \(machine.name): \(machine.name),"
            }
            for m in machine.subs {
                str += "\n        \(m.callName)Machine: _\(m.callName)Machine,"
            }
            for m in machine.callables {
                str += "\n        \(m.callName): \(m.callName),"
            }
            for m in machine.invocables {
                str += "\n        \(m.callName)Machine: \(m.callName)Machine,"
            }
            str = str.trimmingCharacters(in: CharacterSet(charactersIn: ","))
            str += "\n    )\n"
        }
        str += "    // State Transitions.\n"
        let stateType = machine.name + "State"
        let transitionType = machine.name + "StateTransition"
        for state in machine.states {
            for transition in state.transitions {
                guard let c = transition.condition else {
                    str += "    state_\(state.name).addTransition(\(transitionType)(Transition<State_\(state.name), \(stateType)>(state_\(transition.target)) { _ in true }))\n"
                    continue
                }
                var conditionLines = c.components(separatedBy: CharacterSet.newlines)
                if (true == conditionLines.isEmpty) {
                    str += "    state_\(state.name).addTransition(\(transitionType)(Transition<State_\(state.name), \(stateType)>(state_\(transition.target)) { _ in true }))\n"
                    continue
                }
                var condition = ""
                condition += "        let Me = state.Me!\n"
                condition += "        let clock: Timer = state.clock\n"
                for submachine in machine.subs {
                    condition += "        var \(submachine.callName)Machine: AnyControllableFiniteStateMachine {\n"
                    condition += "            return state.\(submachine.callName)Machine\n"
                    condition += "        }\n"
                }
                guard let vars = self.makeStateVariables(forState: state, inMachine: machine, indent: "        ", { "state." + $0.label }) else {
                    return nil
                }
                condition += vars
                condition += self.makeComputedVariables(forState: state, inMachine: machine, includeScope: false, indent: "        ")
                let last = conditionLines.removeLast()
                condition += conditionLines.reduce("") { $0 + "        \($1)\n" }
                let lastTokens = last.components(separatedBy: CharacterSet.whitespaces)
                if let firstLastToken = lastTokens.first {
                    condition += "        \("return" == firstLastToken ? "" : "return ")\(last)\n"
                } else {
                    condition += "        \(last)\n"
                }
                str += "    state_\(state.name).addTransition(\(transitionType)(Transition<State_\(state.name), \(stateType)>(state_\(transition.target)) { state in\n\(condition)    }))\n"
            }
        }
        let externalsListMapped = machine.externalVariables.lazy.map { "        external_" + $0.label + ": external_" + $0.label }
        let externalsList = externalsListMapped.combine("") { $0 + ",\n" + $1 }
        str += "    let ringlet = \(machine.name)Ringlet()\n"
        let suspendState = nil == machine.suspendState ? "Empty\(machine.name)State(\"_Suspend\")" : "state_" + machine.suspendState!.name
        let ringlet = "ringlet"
        let initialPreviousState = "Empty\(machine.name)State(\"_Previous\")"
        let exitState = "Empty\(machine.name)State(\"_Exit\")"
        let fsm: String
        let fsmName = machine.name + "FiniteStateMachine"
        let submachines = machine.subs.isEmpty ? "[]" : "submachines"
        if false == createParameterisedMachine {
            fsm = """
                \(fsmName)(
                        name: machineName,
                        initialState: state_\(machine.initialState.name),\(externalsList.isEmpty ? "" : "\n" + externalsList + ",\n")
                        fsmVars: fsmVars,
                        ringlet: \(ringlet),
                        initialPreviousState: \(initialPreviousState),
                        suspendedState: nil,
                        suspendState: \(suspendState),
                        exitState: \(exitState),
                        submachines: \(submachines)
                    )
                """
        } else {
            let parameters = nil == machine.parameters ? "SimpleVariablesContainer(vars: EmptyVariables())" : "parameters"
            fsm = """
                \(fsmName)(
                        name: machineName,
                        initialState: state_\(machine.initialState.name),\(externalsList.isEmpty ? "" : "\n" + externalsList + ",\n")
                        fsmVars: fsmVars,
                        parameters: \(parameters),
                        results: results,
                        ringlet: \(ringlet),
                        initialPreviousState: \(initialPreviousState),
                        suspendedState: nil,
                        suspendState: \(suspendState),
                        exitState: \(exitState),
                        submachines: \(submachines)
                    )
                """
        }
        str += "    // Create FSM.\n"
        str += "    let fsm = \(fsm)\n"
        for state in machine.states {
            str += "    state_\(state.name).Me = fsm\n"
        }
        let callableDependencies = machine.callables.map { ".callableMachine(name: \"" + $0.callName + "\")" }
        let invocableDependencies = machine.invocables.map { ".invokableMachine(name: \"" + $0.callName + "\")" }
        let subDependencies = machine.subs.map { ".submachine(name: \"" + $0.callName + "\")" }
        let dependencies = (callableDependencies + invocableDependencies + subDependencies).combine("") { $0 + ", " + $1 }
        if nil == machine.parameters {
            str += "    return (AnyControllableFiniteStateMachine(fsm), [" + dependencies + "])\n"
        } else {
            str += "    return (AnyParameterisedFiniteStateMachine(fsm, newMachine: { let tempFSM = make_parameterised_\(machine.name)(name: machineName, gateway: gateway, clock: clock, caller: caller).0; let result = tempFSM.parametersFromDictionary($0); if result == false { fatalError(\"Unable to call \(fsmName) with parameters: \\($0)\") }; return tempFSM }), [" + dependencies + "])\n"
        }
        return str
    }
    
    private func makeParameters(forMachine machine: Machine) -> FileWrapper? {
        guard let machineParameters = machine.parameters else {
            self.errors.append("Attempting to create parameters when they don't exist.")
            return nil
        }
        let str = self.makeVarsContent(
            forMachine: machine,
            name: "\(machine.name)Parameters",
            vars: machineParameters,
            shouldIncludeDictionaryStringConvertible: true,
            shouldIncludeDictionaryConvertible: true
        )
        return encode(inFile: machine.name + "Parameters.swift", contents: str)
    }
    
    private func makeResultsContainer(forMachine machine: Machine) -> FileWrapper? {
        let str = self.makeVarsContent(
            forMachine: machine,
            name: "\(machine.name)ResultsContainer",
            vars: [Variable(accessType: .readAndWrite, label: "result", type: (machine.returnType ?? "Void") + "?", initialValue: "nil")],
            extraConformances: ["MutableResultContainer"]
        )
        return encode(inFile: machine.name + "ResultsContainer.swift", contents: str)
    }

    private func makeFsmVars(forMachine machine: Machine) -> FileWrapper? {
        let str = self.makeVarsContent(forMachine: machine, name: "\(machine.name)Vars", vars: machine.vars)
        return encode(inFile: machine.name + "Vars.swift", contents: str)
    }
    
    private func makeVarsContent(forMachine machine: Machine, name: String, vars: [Variable], extraConformances: [String] = [], shouldIncludeDictionaryStringConvertible: Bool = false, shouldIncludeDictionaryConvertible: Bool = false) -> String {
        var str = "import swiftfsm\n"
        str += self.makeImports(forMachine: machine).reduce("") { $0 + $1 + "\n" }
        str += "\(machine.imports)"
        if (false == machine.imports.isEmpty) {
            str += "\n"
        }
        let defaultConformances = "Variables"
            + (shouldIncludeDictionaryStringConvertible ? ", DictionaryConvertible" : "") + (shouldIncludeDictionaryConvertible ? ", ConvertibleFromDictionary" : "")
        let conformances = extraConformances.reduce(defaultConformances) { $0 + ", " + $1}
        str += "\npublic final class \(name): \(conformances) {\n\n"
        if (false == vars.isEmpty) {
            str += "\(vars.reduce("") { $0 + "    public \(self.varHelpers.makeDeclaration(forVariable: $1, allowModifications: true))\n\n" })"
        }
        // Init.
        let args: [String] = vars.map {
            let trimmedType = $0.type.trimmingCharacters(in: .whitespacesAndNewlines)
            let signature = $0.label + ": " + trimmedType
            if let initialValue = $0.initialValue {
                return signature + " = " + initialValue
            }
            if trimmedType.last == "?" || trimmedType.last == "!" {
                return signature + " = nil"
            }
            return signature + "! = nil"
        }
        let argsStr = args.combine("") { $0 + ", " + $1 }
        str += "    public init(\(argsStr)) {\n"
        for v in vars {
            str += "        self.\(v.label) = \(v.label)\n"
        }
        str += "    }\n\n"
        // Dictionary String Convertible
        if shouldIncludeDictionaryStringConvertible {
            str += "    public required convenience init?(_ dictionary: [String: String]) {\n"
            str += "        self.init()\n"
            str += "        func convert<T>(_ str: String) -> T? {\n"
            str += "            guard let t = (T.self as? LosslessStringConvertible.Type) else { return nil }\n"
            str += "            return t.init(str) as? T\n"
            str += "        }\n"
            for v in vars {
                str += """
                        if let \(v.label)Str = dictionary[\"\(v.label)\"] {
                            guard let \(v.label): \(v.type) = convert(\(v.label)Str) else {
                                return nil
                            }
                            self.\(v.label) = \(v.label)
                        }\n
                """
            }
            str += "    }\n\n"
        }
        // Dictionary Convertible.
        if shouldIncludeDictionaryConvertible {
            str += "    public required convenience init(fromDictionary dictionary: [String: Any?]) {\n"
            str += "        self.init()\n"
            for v in vars {
                str += """
                        guard
                            let \(v.label)_val: Any? = dictionary[\"\(v.label)\"],
                            let \(v.label): \(v.type) = \(v.label)_val as? \(v.type) else {
                            fatalError("Unable to convert dictionary[\\"\(v.label)\\"] to \(v.type) when attempting to initialise \(name)")
                        }
                        self.\(v.label) = \(v.label)\n
                """
            }
            str += "    }\n\n"
        }
        // Clone.
        str += "    public final func clone() -> \(name) {\n"
        str += "        return \(name)("
        str += vars.lazy.map { "\n            \($0.label): ((self.\($0.label) as? Cloneable)?.clone() as? \($0.type)) ?? self.\($0.label)" }.combine("") { $0 + "," + $1 }
        str += "\n        )\n"
        str += "    }\n\n"
        str += "}\n"
        return str
    }

    private func makeRinglet(forRinglet ringlet: Ringlet, inMachine machine: Machine) -> FileWrapper? {
        let stateType = machine.name + "State"
        var str = "import swiftfsm\n"
        str += self.makeImports(forMachine: machine).reduce("") { $0 + $1 + "\n" }
        str += ringlet.imports
        str += "\npublic final class \(machine.name)Ringlet: Ringlet, Cloneable, KripkeVariablesModifier {\n\n"
        str += "    public typealias _StateType = \(stateType)\n\n"
        str += "    public var computedVars: [String: Any] { return [:] }\n\n"
        str += "    public var manipulators: [String: (Any) -> Any] { return [:] }\n\n"
        str += "    public var validVars: [String: [Any]] { return [\"Me\": []] }\n\n"
        str += "    internal var Me: \(machine.name)FiniteStateMachine!\n\n"
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
        str += "    public final func clone() -> \(machine.name)Ringlet {\n"
        str += "        let ringlet = \(machine.name)Ringlet()\n"
        str += ringlet.vars.reduce("") {
            $0 + "        " + self.varHelpers.makeAssignment(withLabel: "ringlet.\($1.label)", andValue: "self.\($1.label)") + "\n"
        }
        str += "        return ringlet\n"
        str += "    }\n\n"
        str += "}\n"
        return encode(inFile: machine.name + "Ringlet.swift", contents: str)
    }
    
    private func makeMiPalRinglet(withMachineName machine: String) -> FileWrapper? {
        let stateType = machine + "State"
        let str = """
            import swiftfsm

            /**
             *  A standard ringlet.
             *
             *  Firstly calls onEntry if we have just transitioned to this state.  If a
             *  transition is possible then the states onExit method is called and the new
             *  state is returned.  If no transitions are possible then the main method is
             *  called and the state is returned.
             */
            public final class \(machine)Ringlet: Ringlet, Cloneable, KripkeVariablesModifier {

                internal var Me: \(machine)FiniteStateMachine!

                public var computedVars: [String: Any] {
                    return [
                        "shouldExecuteOnEntry": self.Me.currentState != self.Me.previousState
                    ]
                }

                public var manipulators: [String : (Any) -> Any] {
                    return [:]
                }

                public var validVars: [String: [Any]] {
                    return [
                        "Me": []
                    ]
                }

                /**
                 *  Create a new `MiPalRinglet`.
                 *
                 */
                public init() {}

                /**
                 *  Execute the ringlet.
                 *
                 *  - Parameter state: The `\(stateType)` that is being executed.
                 *
                 *  - Returns: A state representing the next state to execute.
                 */
                public func execute(state: \(stateType)) -> \(stateType) {
                    // Call onEntry if we have just transitioned to this state.
                    if state != self.Me.previousState {
                        state.onEntry()
                    }
                    // Can we transition to another state?
                    if let t = state.transitions.first(where: { $0.canTransition(state) }) {
                        // Yes - Exit state and return the new state.
                        state.onExit()
                        return t.target
                    }
                    // No - Execute main method and return state.
                    state.main()
                    return state
                }

                public func clone() -> \(machine)Ringlet {
                    let r = \(machine)Ringlet()
                    r.Me = self.Me
                    return r
                }

            }
            """
        return encode(inFile: machine + "Ringlet.swift", contents: str)
    }
    
    

    private func makeStates(forMachine machine: Machine, atDirectory machineDir: URL) -> [FileWrapper]? {
        var paths: [FileWrapper] = []
        paths.reserveCapacity(machine.states.count)
        for state in machine.states {
            guard
                let statePath = self.makeState(state, forMachine: machine, atDirectory: machineDir)
            else {
                return nil
            }
            paths.append(statePath)
        }
        return paths
    }

    private func makeState(_ state: State, forMachine machine: Machine, atDirectory machineDir: URL) -> FileWrapper? {
        var str = "import swiftfsm\n"
        if let _ = machine.includes {
            str += "import \(machine.name)MachineBridging\n"
        }
        str += self.makeImports(forMachine: machine).reduce("") { $0 + $1 + "\n" }
        if (false == state.imports.isEmpty) {
            str += "\(state.imports)\n"
        }
        str += "\n"
        let stateType = machine.name + "State"
        str += "public final class State_\(state.name): \(stateType) {\n\n"
        str += "    public override var validVars: [String: [Any]] {\n"
        str += "        return [\n"
        str += """
                        \"name\": [],
                        \"transitions\": [],
                        \"gateway\": [],
                        \"clock\": [],
                        \"snapshotSensors\": [],
                        \"snapshotActuators\": [],
                        \"Me\": []
            """
        str += "\n        ]\n"
        str += "    }\n\n"
        str += "    fileprivate let gateway: FSMGateway\n\n"
        str += "    public let clock: Timer\n\n"
        for submachine in machine.subs {
            str += "    fileprivate var _\(submachine.callName)Machine: () -> AnyControllableFiniteStateMachine\n"
            str += "    public var \(submachine.callName)Machine: AnyControllableFiniteStateMachine { return self._\(submachine.callName)Machine() }\n"
        }
        if (false == machine.subs.isEmpty) {
            str += "\n"
        }
        if nil != machine.parameters {
            let parameterList = machine.parameters?.lazy.map { $0.type }.combine("") { $0 + ", " + $1 } ?? ""
            str += "    fileprivate var _\(machine.name): (\(parameterList)) -> Promise<\(machine.returnType ?? "Void")>\n"
        }
        for m in machine.callables {
            let parameterisedMachine = m.machine(relativeTo: machineDir)
            let parameterList = parameterisedMachine.parameters?.lazy.map { $0.type }.combine("") { $0 + ", " + $1 } ?? ""
            str += "    fileprivate var _\(m.callName): (\(parameterList)) -> Promise<\(parameterisedMachine.returnType ?? "Void")>\n"
        }
        for m in machine.invocables {
            let parameterisedMachine = m.machine(relativeTo: machineDir)
            let parameterList = parameterisedMachine.parameters?.lazy.map { $0.type }.combine("") { $0 + ", " + $1 } ?? ""
            str += "    fileprivate var _\(m.callName)Machine: (\(parameterList)) -> Promise<\(parameterisedMachine.returnType ?? "Void")>\n"
        }
        if (false == machine.parameterisedDependencies.isEmpty) {
            str += "\n"
        }
        guard let vars = self.makeStateVariables(forState: state, inMachine: machine, indent: "    ") else {
            return nil
        }
        str += vars
        str += self.makeComputedVariables(forState: state, inMachine: machine, indent: "    ")
        // Init.
        str += "    public init(\n"
        str += "        _ name: String,\n"
        str += "        transitions: [Transition<State_\(state.name), \(stateType)>] = [],\n"
        str += "        gateway: FSMGateway\n,"
        str += "        clock: Timer,\n"
        if nil != machine.parameters {
            let parameterList = machine.parameters?.lazy.map { $0.type }.combine("") { $0 + ", " + $1 } ?? ""
            str += "        \(machine.name): @escaping (\(parameterList)) -> Promise<\(machine.returnType ?? "Void")>,\n"
        }
        for submachine in machine.subs {
            str += "        \(submachine.callName)Machine: @escaping () -> AnyControllableFiniteStateMachine,\n"
        }
        for m in machine.callables {
            let parameterisedMachine = m.machine(relativeTo: machineDir)
            let parameterList = parameterisedMachine.parameters?.lazy.map { $0.type }.combine("") { $0 + ", " + $1 } ?? ""
            str += "        \(m.callName): @escaping (\(parameterList)) -> Promise<\(parameterisedMachine.returnType ?? "Void")>,\n"
        }
        for m in machine.invocables {
            let parameterisedMachine = m.machine(relativeTo: machineDir)
            let parameterList = parameterisedMachine.parameters?.lazy.map { $0.type }.combine("") { $0 + ", " + $1 } ?? ""
            str += "        \(m.callName)Machine: @escaping (\(parameterList)) -> Promise<\(parameterisedMachine.returnType ?? "Void")>,\n"
        }
        str = str.trimmingCharacters(in: CharacterSet(charactersIn: ",\n"))
        str += "\n    ) {\n"
        str += "        self.gateway = gateway\n"
        str += "        self.clock = clock\n"
        if nil != machine.parameters {
            str += "        self._\(machine.name) = \(machine.name)\n"
        }
        for submachine in machine.subs {
            str += "        self._\(submachine.callName)Machine = \(submachine.callName)Machine\n"
        }
        for m in machine.callables {
            str += "        self._\(m.callName) = \(m.callName)\n"
        }
        for m in machine.invocables {
            str += "        self._\(m.callName)Machine = \(m.callName)Machine\n"
        }
        let sensors = state.externalVariables.lazy.filter { $0.accessType == .readOnly || $0.accessType == .readAndWrite }
        let sensorlabels = sensors.map { "\"" + $0.label + "\"" }
        let sensorlist = sensorlabels.combine("") { $0 + ", " + $1 }
        let sensorsStr = "[" + sensorlist + "]"
        let actuators = state.externalVariables.lazy.filter { $0.accessType == .writeOnly || $0.accessType == .readAndWrite }
        let actuatorLabels = actuators.map { "\"" + $0.label + "\"" }
        let actuatorList = actuatorLabels.combine("") { $0 + ", " + $1 }
        let actuatorsStr = "[" + actuatorList + "]"
        let transitionType = machine.name + "StateTransition"
        str += "        super.init(name, transitions: transitions.map { \(transitionType)($0) }, snapshotSensors: \(sensorsStr), snapshotActuators: \(actuatorsStr))\n"
        str += "    }\n\n"
        // Recursive machine.
        if nil != machine.parameters {
            let (parameterList, callStr) = self.makeParametersList(forMachine: machine)
            str += "    public func \(machine.name)(\(parameterList)) -> Promise<\(machine.returnType ?? "Void")> {\n"
            str += "        return self._\(machine.name)(\(callStr))\n"
            str += "    }\n\n"
        }
        // Parameterised Machine Functions
        for m in machine.invocables {
            let parameterisedMachine = m.machine(relativeTo: machineDir)
            let (parameterList, callStr) = self.makeParametersList(forMachine: parameterisedMachine)
            str += "    public func \(m.callName)Machine(\(parameterList)) -> Promise<\(parameterisedMachine.returnType ?? "Void")> {\n"
            str += "        return self._\(m.callName)Machine(\(callStr))\n"
            str += "    }\n\n"
        }
        for m in machine.callables {
            let parameterisedMachine = m.machine(relativeTo: machineDir)
            let (parameterList, callStr) = self.makeParametersList(forMachine: parameterisedMachine)
            str += "    public func \(m.callName)(\(parameterList)) -> Promise<\(parameterisedMachine.returnType ?? "Void")> {\n"
            str += "        return self._\(m.callName)(\(callStr))\n"
            str += "    }\n\n"
        }
        // Actions.
        for action in state.actions {
            str += "    public override func \(action.name)() {\n"
            str += "\(action.implementation.components(separatedBy: "\n").reduce("") { $0 + "        \($1)\n" })"
            str += "    }\n\n"
        }
        // Clone.
        str += "    public override final func clone() -> State_\(state.name) {\n"
        str += "        let transitions: [Transition<State_\(state.name), \(stateType)>] = self.transitions.map { $0.cast(to: State_\(state.name).self) }\n"
        str += "        let state = State_\(state.name)(\n"
        str += "            \"\(state.name)\",\n"
        str += "            transitions: transitions,\n"
        str += "            gateway: self.gateway\n,"
        str += "            clock: self.clock,\n"
        if nil != machine.parameters {
            str += "            \(machine.name): self._\(machine.name),\n"
        }
        for submachine in machine.subs {
            str += "            \(submachine.callName)Machine: self._\(submachine.callName)Machine,\n"
        }
        for m in machine.callables {
            str += "            \(m.callName): self._\(m.callName),\n"
        }
        for m in machine.invocables {
            str += "            \(m.callName)Machine: self._\(m.callName)Machine,\n"
        }
        str = str.trimmingCharacters(in: CharacterSet(charactersIn: ",\n"))
        str += "\n        )\n"
        str += state.vars.reduce("") {
            $0 + "        " + self.varHelpers.makeAssignment(withLabel: "state.\($1.label)", andValue: "self.\($1.label)") + "\n"
        }
        str += "        state.Me = self.Me\n"
        str += "        return state\n"
        str += "    }\n\n"
        str += "}\n\n"
        // Extensions.
        let varList = state.vars.lazy.map { "                \($0.label): \\(self.\($0.label))" }.combine("") {$0 + ",\n" + $1 }
        str += "extension State_\(state.name): CustomStringConvertible {\n\n"
        str += "    public var description: String {\n"
        str += "        return \"\"\"\n"
        str += "            {\n"
        str += "                name: \\(self.name),\n"
        str += varList + (varList.isEmpty ? "" : ",\n")
        str += "                transitions: \\(self.transitions.map { $0.target.name })\n"
        str += "            }\n"
        str += "            \"\"\"\n"
        str += "    }\n\n"
        str += "}\n"
        return encode(inFile: "State_" + state.name + ".swift", contents: str)
    }
    
    private func makeParametersList(forMachine machine: Machine) -> (String, String) {
        let parameterList = (machine.parameters ?? []).lazy.map {
            let start = $0.label + ": " + $0.type
            guard let initialValue = $0.initialValue else {
                return start
            }
            return start + " = " + initialValue
        }.combine("") { $0 + ", " + $1 }
        let callParams = machine.parameters?.map { $0.label } ?? []
        let callStr = callParams.combine("") { $0 + ", " + $1 }
        return (parameterList, callStr)
    }
    
    private func makeStateVariables(forState state: State, inMachine machine: Machine, indent: String = "", _ defaultValues: ((Variable) -> String)? = nil) -> String? {
        self.takenVars = Set(machine.externalVariables.map { $0.label })
        (machine.model?.actions ?? ["onEntry", "onExit", "main"]).forEach { self.takenVars.insert($0) }
        if nil != machine.parameters {
            self.takenVars.insert("_" + machine.name)
        }
        (machine.invocables + machine.subs).forEach {
            self.takenVars.insert($0.callName + "Machine")
            self.takenVars.insert("_" + $0.callName + "Machine")
        }
        machine.callables.forEach {
            self.takenVars.insert($0.callName)
            self.takenVars.insert("_" + $0.callName)
        }
        if nil != machine.parameters {
            self.takenVars.insert("parameters")
        }
        self.takenVars.insert("fsmVars")
        self.takenVars.insert("clock")
        self.takenVars.insert("_invoker")
        self.takenVars.insert("name")
        self.takenVars.insert("transitions")
        self.takenVars.insert("Me")
        var str = ""
        // State variables.
        guard
            let _ = state.vars.failMap({ (v: Variable) -> Variable? in
                if "_" == v.label.first {
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
            $0 + indent + self.varHelpers.makeDeclarationAndAssignment(forVariable: $1, defaultValues) + "\n"
        }
        if (false == state.vars.isEmpty) {
            str += "\n"
        }
        return str
    }
    
    private func makeComputedVariables(forState state: State, inMachine machine: Machine, includeScope: Bool = true, indent: String = "") -> String {
        var str = ""
        // FSM variables.
        str += self.createComputedProperty(mutable: true, withLabel: "fsmVars", andType: "\(machine.name)Vars", referencing: "Me.fsmVars.vars", includeScope: includeScope, indent: indent)
        str += self.createComputedProperties(fromVars: machine.vars, withinContainer: "fsmVars", includeScope: includeScope, indent: indent)
        //Parameters
        if let parameters = machine.parameters {
            str += self.createComputedProperty(mutable: true, withLabel: "parameters", andType: "\(machine.name)Parameters", referencing: "Me.parameters.vars", includeScope: includeScope, indent: indent)
            str += self.createComputedProperties(fromVars: parameters, withinContainer: "parameters", includeScope: includeScope, indent: indent)
            str += self.createComputedProperty(mutable: true, withLabel: "result", andType: machine.returnType ?? "Void", referencing: "Me.results.vars.result", includeScope: includeScope, indent: indent, unwrap: true)
        }
        // External variables.
        for external in (state.externalVariables ?? machine.externalVariables) {
            str += self.createComputedProperty(mutable: external.accessType != .readOnly, withLabel: external.label, andType: external.type + ".Class", referencing: "Me.external_\(external.label).val", includeScope: includeScope, indent: indent)
            //str += self.createComputedProperties(fromVars: external.vars, withinContainer: "\(external.label)")
        }
        return str
    }

    private func makeStateType(forMachine machine: String, fromModel model: Model) -> FileWrapper? {
        let stateType = machine + "State"
        let transitionType = machine + "StateTransition"
        var str = "import swiftfsm\n"
        str += "public class \(stateType):\n"
        str += "    StateType,\n"
        str += "    CloneableState,\n"
        str += "    Transitionable,\n"
        str += "    KripkeVariablesModifier,\n"
        str += "    SnapshotListContainer\n"
        str += "{\n\n"
        str += "    public let name: String\n\n"
        str += "    public var transitions: [\(transitionType)]\n\n"
        str += "    public let snapshotSensors: Set<String>?\n\n"
        str += "    public let snapshotActuators: Set<String>?\n\n"
        str += "    internal weak var Me: " + machine + "FiniteStateMachine!\n\n"
        str += "    public var validVars: [String: [Any]] {\n"
        str += "        return [\n"
        str += "            \"name\": [],\n"
        str += "            \"transitions\": [],\n"
        str += "            \"snapshotSensors\": [],\n"
        str += "            \"snapshotActuators\": [],\n"
        str += "            \"Me\": []\n"
        str += "        ]\n"
        str += "    }\n\n"
        str += "    public init(_ name: String, transitions: [\(transitionType)] = [], snapshotSensors: Set<String>?, snapshotActuators: Set<String>?) {\n"
        str += "        self.name = name\n"
        str += "        self.transitions = transitions\n"
        str += "        self.snapshotSensors = snapshotSensors\n"
        str += "        self.snapshotActuators = snapshotActuators\n"
        str += "    }\n\n"
        for action in model.actions {
            str += "    public func \(action)() {}\n\n"
        }
        str += "    public func clone() -> Self {\n"
        str += "        fatalError(\"Please implement your own clone.\")\n"
        str += "    }\n\n"
        str += "}\n"
        return encode(inFile: machine + "State.swift", contents: str)
    }
    
    private func makeMiPalStateType(forMachine machine: String) -> FileWrapper? {
        let stateType = machine + "State"
        let transitionType = machine + "StateTransition"
        let str = """
            import swiftfsm

            /**
             *  The base class for all states that conform to `MiPalAction`s.
             */
            public class \(stateType):
                StateType,
                CloneableState,
                MiPalActions,
                Transitionable,
                KripkeVariablesModifier,
                SnapshotListContainer
            {

                /**
                 *  The name of the state.
                 *
                 *  - Requires: Must be unique for each state.
                 */
                public let name: String

                /**
                 *  An array of transitions that this state may use to move to another
                 *  state.
                 */
                public var transitions: [\(transitionType)]
                
                public let snapshotSensors: Set<String>?
                
                public let snapshotActuators: Set<String>?

                internal weak var Me: \(machine)FiniteStateMachine!

                open var validVars: [String: [Any]] {
                    return [
                        "name": [],
                        "transitions": [],
                        "snapshotSensors": [],
                        "snapshotActuators": [],
                        "Me": []
                    ]
                }

                /**
                 *  Create a new `\(stateType)`.
                 *
                 *  - Parameter name: The name of the state.
                 *
                 *  - transitions: All transitions to other states that this state can use.
                 */
                public init(_ name: String, transitions: [\(transitionType)] = [], snapshotSensors: Set<String>?, snapshotActuators: Set<String>?) {
                    self.name = name
                    self.transitions = transitions
                    self.snapshotSensors = snapshotSensors
                    self.snapshotActuators = snapshotActuators
                }

                /**
                 *  Does nothing.
                 */
                open func onEntry() {}

                /**
                 *  Does nothing.
                 */
                open func main() {}

                /**
                 *  Does nothing.
                 */
                open func onExit() {}

                /**
                 *  Create a copy of `self`.
                 *
                 *  - Warning: Child classes should override this method.  If they do not
                 *  then the application will crash when trying to generate
                 *  `KripkeStructures`.
                 */
                open func clone() -> Self {
                    fatalError("Please implement your own clone")
                }
                
            }
            """
        return encode(inFile: machine + "State.swift", contents: str)
    }

    public func makeEmptyStateType(forMachine machine: String, withActions actions: [String]) -> FileWrapper? {
        let stateType = machine + "State"
        let transitionType = machine + "StateTransition"
        var str = "import swiftfsm\n\n"
        str += "public final class Empty\(stateType): \(stateType) {\n\n"
        str += "    public init(_ name: String, transitions: [Transition<Empty\(stateType), \(stateType)>] = []) {\n"
        str += "        super.init(name, transitions: transitions.map { \(transitionType)($0) }, snapshotSensors: [], snapshotActuators: [])\n"
        str += "    }\n\n"
        for action in actions {
            str += "    public override final func \(action)() {}\n\n"
        }
        str += "    public override final func clone() -> Empty\(stateType) {\n"
        str += "        let transitions: [Transition<Empty\(stateType), \(stateType)>] = self.transitions.map { $0.cast(to: Empty\(stateType).self) }\n"
        str += "        return Empty\(stateType)(self.name, transitions: transitions)\n"
        str += "    }\n\n"
        str += "}\n"
        return encode(inFile: "Empty" + machine + "State.swift", contents: str)
    }

    public func makeCallbackStateType(forMachine machine: String, withActions actions: [String]) -> FileWrapper? {
        let stateType = machine + "State"
        let transitionType = machine + "StateTransition"
        var str = "import swiftfsm\n\n"
        str += "public final class Callback\(stateType): \(stateType) {\n\n"
        for action in actions {
            str += "    private let _\(action): () -> Void\n\n"
        }
        str += "    public init(\n"
        str += "        _ name: String,\n"
        str += "        transitions: [Transition<Callback\(stateType), \(stateType)>] = [],\n"
        str += "        snapshotSensors: Set<String>?,\n"
        str += "        snapshotActuators: Set<String>?,"
        var actionsList = ""
        for action in actions {
            actionsList += "\n        \(action): @escaping () -> Void = {},"
        }
        str += "\(String(actionsList.dropLast()))\n"
        str += "    ) {\n"
        for action in actions {
            str += "        self._\(action) = \(action)\n"
        }
        str += "        super.init(name, transitions: transitions.map { \(transitionType)($0) }, snapshotSensors: snapshotSensors, snapshotActuators: snapshotActuators)\n"
        str += "    }\n\n"
        for action in actions {
            str += "    public final override func \(action)() {\n"
            str += "        self._\(action)()\n"
            str += "    }\n\n"
        }
        str += "    public override final func clone() -> Callback\(stateType) {\n"
        str += "        let transitions: [Transition<Callback\(stateType), \(stateType)>] = self.transitions.map { $0.cast(to: Callback\(stateType).self) }\n"
        str += "        return Callback\(stateType)(self.name, transitions: transitions, snapshotSensors: self.snapshotSensors, snapshotActuators: self.snapshotActuators)\n"
        str += "    }\n\n"
        str += "}\n"
        return encode(inFile: "Callback" + machine + "State.swift", contents: str)
    }
    
    public func makeFiniteStateMachine(fromMachine machine: Machine) -> FileWrapper? {
        let name = machine.name + "FiniteStateMachine"
        var str = "import swiftfsm\n"
        str += self.makeImports(forMachine: machine).reduce("") { $0 + $1 + "\n" } + "\n"
        let conformance = nil == machine.parameters ? "MachineProtocol" : "ParameterisedMachineProtocol"
        let stateType = machine.name + "State"
        let ringlet = machine.name + "Ringlet"
        str += "internal final class " + name + ": " + conformance + " {\n\n"
        // Computed Properties
        str += "    public typealias _StateType = " + stateType + "\n\n"
        str += "    fileprivate var allStates: [String: " + stateType + "] {\n"
        str += "        var stateCache: [String: " + stateType + "] = [:]\n"
        str += "        func fetchAllStates(fromState state: " + stateType + ") {\n"
        str += "            if stateCache[state.name] != nil {\n"
        str += "                return\n"
        str += "            }\n"
        str += "            stateCache[state.name] = state\n"
        str += "            state.transitions.forEach {\n"
        str += "                fetchAllStates(fromState: $0.target)\n"
        str += "            }\n"
        str += "        }\n"
        str += "        fetchAllStates(fromState: self.initialState)\n"
        str += "        fetchAllStates(fromState: self.suspendState)\n"
        str += "        fetchAllStates(fromState: self.exitState)\n"
        str += "        return stateCache\n"
        str += "    }\n\n"
        str += "    public var computedVars: [String: Any] {\n"
        str += "        return [\n"
        str += "            \"currentState\": self.currentState.name,\n"
        str += "            \"fsmVars\": self.fsmVars.vars,\n"
        if nil != machine.parameters {
            str += "            \"parameters\": self.parameters.vars,\n"
            str += "            \"results\": self.results.vars,\n"
        }
        str += "            \"states\": self.allStates,\n"
        str += "        ]\n"
        str += "    }\n\n"
        str += "    /**\n"
        str += "     * All external variables used by the machine.\n"
        str += "     */\n"
        let externalsList = machine.environmentVariables.lazy.map { "AnySnapshotController(self.external_\($0.label))" }.combine("") { $0 + ", " + $1 }
        str += "    public var externalVariables: [AnySnapshotController] {\n"
        str += "        get {\n"
        str += "            return [" + externalsList + "]\n"
        str += "        } set {\n"
        let externalsSwitch = machine.environmentVariables.lazy.map { "                case self.external_\($0.label).name:\n                    self.external_\($0.label).val = external.val as! \($0.type).Class" }.combine("") { $0 + "\n" + $1 }
        str += "            for external in newValue {\n"
        str += "                switch external.name {\n"
        if false == externalsSwitch.isEmpty {
            str += externalsSwitch + "\n"
        }
        str += "                default:\n"
        str += "                    continue\n"
        str += "                }\n"
        str += "            }\n"
        str += "        }\n"
        str += "    }\n\n"
        let snapshotControllerList = machine.sensors.lazy.map { "AnySnapshotController(self.external_\($0.label))" }.combine("") { $0 + ", " + $1 }
        //let sensorList = machine.sensors.lazy.map {"                case self.external_\($0.label).name:\n                    return AnySnapshotController(self.external_\($0.label))"}.combine("") { $0 + "\n" + $1 }
        str += "    public var sensors: [AnySnapshotController] {\n"
        str += "        get {\n"
        str += "            return [\(snapshotControllerList)]\n"
        str += "        } set {\n"
        let sensorsSwitch = machine.sensors.lazy.map { "                case self.external_\($0.label).name:\n                    self.external_\($0.label).val = external.val as! \($0.type).Class" }.combine("") { $0 + "\n" + $1 }
        str += "            for external in newValue {\n"
        str += "                switch external.name {\n"
        if false == sensorsSwitch.isEmpty {
            str += sensorsSwitch + "\n"
        }
        str += "                default:\n"
        str += "                    continue\n"
        str += "                }\n"
        str += "            }\n"
        str += "        }\n"
        str += "    }\n\n"
        let actuatorsList = machine.actuators.lazy.map { "AnySnapshotController(self.external_\($0.label))" }.combine("") { $0 + ", " + $1 }
        str += "    public var actuators: [AnySnapshotController] {\n"
        str += "        get {\n"
        str += "            return [" + actuatorsList + "]\n"
        str += "        } set {\n"
        let actuatorsSwitch = machine.actuators.lazy.map { "                case self.external_\($0.label).name:\n                    self.external_\($0.label).val = external.val as! \($0.type).Class" }.combine("") { $0 + "\n" + $1 }
        str += "            for external in newValue {\n"
        str += "                switch external.name {\n"
        if false == actuatorsSwitch.isEmpty {
            str += actuatorsSwitch + "\n"
        }
        str += "                default:\n"
        str += "                    continue\n"
        str += "                }\n"
        str += "            }\n"
        str += "        }\n"
        str += "    }\n\n"
        str += "    public var snapshotSensors: [AnySnapshotController] {\n"
        str += "        guard let snapshotSensors = self.currentState.snapshotSensors else {\n"
        str += "            return []\n"
        str += "        }\n"
        str += "        return snapshotSensors.map { (label: String) -> AnySnapshotController in\n"
        str += "            switch label {\n"
        for sensor in machine.externalVariables.lazy.filter({ $0.accessType == .readOnly || $0.accessType == .readAndWrite }) {
            str += "            case \"\(sensor.label)\":\n"
            str += "                return AnySnapshotController(self.external_\(sensor.label))\n"
        }
        str += "            default:\n"
        str += "                fatalError(\"Unable to find sensor \\(label).\")\n"
        str += "            }\n"
        str += "        }\n"
        str += "    }\n\n"
        str += "    public var snapshotActuators: [AnySnapshotController] {\n"
        str += "        guard let snapshotActuators = self.currentState.snapshotActuators else {\n"
        str += "            return []\n"
        str += "        }\n"
        str += "        return snapshotActuators.map { (label: String) -> AnySnapshotController in\n"
        str += "            switch label {\n"
        for actuator in machine.externalVariables.lazy.filter({ $0.accessType == .writeOnly || $0.accessType == .readAndWrite }) {
            str += "            case \"\(actuator.label)\":\n"
            str += "                return AnySnapshotController(self.external_\(actuator.label))\n"
        }
        str += "            default:\n"
        str += "                fatalError(\"Unable to find actuator \\(label).\")\n"
        str += "            }\n"
        str += "        }\n"
        str += "    }\n\n"
        str += "    public var validVars: [String: [Any]] {\n"
        str += "        return [\n"
        str += "            \"currentState\": [],\n"
        str += "            \"exitState\": [],\n"
        str += "            \"externalVariables\": [],\n"
        str += "            \"sensors\": [],\n"
        str += "            \"actuators\": [],\n"
        str += "            \"snapshotSensors\": [],\n"
        str += "            \"snapshotActuators\": [],\n"
        str += "            \"fsmVars\": [],\n"
        str += "            \"initialPreviousState\": [],\n"
        str += "            \"initialState\": [],\n"
        str += "            \"name\": [],\n"
        if nil != machine.parameters {
            str += "            \"parameters\": [],\n"
        }
        str += "            \"previousState\": [],\n"
        if nil != machine.parameters {
            str += "            \"results\": [],\n"
        }
        str += "            \"submachineFunctions\": [],\n"
        str += "            \"submachines\": [],\n"
        str += "            \"suspendedState\": [],\n"
        str += "            \"suspendState\": [],\n"
        if !machine.externalVariables.isEmpty {
            let externals = machine.externalVariables.lazy.map { "\"external_\($0.label)\": []" }.combine("") { $0 + ",\n            " + $1 }
            str += "            " + externals + ",\n"
        }
        str += "        ]\n"
        str += "    }\n\n"
        // Properties
        str += "    /**\n"
        str += "     *  The state that is currently executing.\n"
        str += "     */\n"
        str += "    public var currentState: " + stateType + "\n\n"
        str += "    /**\n"
        str += "     *  The state that is used to exit the FSM.\n"
        str += "     */\n"
        str += "    public private(set) var exitState: " + stateType + "\n\n"
        str += "    /**\n"
        str += "     * All FSM variables used by the machine.\n"
        str += "     */\n"
        str += "    public let fsmVars: SimpleVariablesContainer<" + machine.name + "Vars>\n\n"
        str += "    /**\n"
        str += "     *  The initial state of the previous state.\n"
        str += "     *\n"
        str += "     *  `previousState` is set to this value on restart.\n"
        str += "     */\n"
        str += "    public private(set) var initialPreviousState: " + stateType + "\n\n"
        str += "    /**\n"
        str += "     *  The starting state of the FSM.\n"
        str += "     */\n"
        str += "    public private(set) var initialState: " + stateType + "\n\n"
        str += "    /**\n"
        str += "     *  The name of the FSM.\n"
        str += "     *\n"
        str += "     *  - Warning: This must be unique between FSMs.\n"
        str += "     */\n"
        str += "    public let name: String\n\n"
        if nil != machine.parameters {
            str += "    /**\n"
            str += "     * All parameters used by the machine.\n"
            str += "     */\n"
            str += "    public let parameters: SimpleVariablesContainer<" + machine.name + "Parameters>\n\n"
        }
        str += "    /**\n"
        str += "     *  The last state that was executed.\n"
        str += "     */\n"
        str += "    public var previousState: " + stateType + "\n\n"
        if nil != machine.parameters {
            str += "    /**\n"
            str += "     * All results returned by the machine when called.\n"
            str += "     */\n"
            str += "    public let results: SimpleVariablesContainer<" + machine.name + "ResultsContainer>\n\n"
        }
        str += "    /**\n"
        str += "     *  An instance of `Ringlet` that is used to execute the states.\n"
        str += "     */\n"
        str += "    public fileprivate(set) var ringlet: " + ringlet + "\n\n"
        str += "    fileprivate let submachineFunctions: [() -> AnyControllableFiniteStateMachine]\n\n"
        str += "    /**\n"
        str += "     * All submachines of this machine.\n"
        str += "     */\n"
        str += "    public var submachines: [AnyControllableFiniteStateMachine] {\n"
        str += "        get {\n"
        str += "            return self.submachineFunctions.map { $0() }\n"
        str += "        } set {}"
        str += "    }\n\n"
        str += "    /**\n"
        str += "     *  The state that was the `currentState` before the FSM was suspended.\n"
        str += "     */\n"
        str += "    public var suspendedState: " + stateType + "?\n\n"
        str += "    /**\n"
        str += "     *  The state that is set to `currentState` when the FSM is suspended.\n"
        str += "     */\n"
        str += "    public private(set) var suspendState: " + stateType + "\n\n"
        // External Variable Properties
        let externalsMapped = machine.externalVariables.lazy.map { "    public var external_" + $0.label + ": " + $0.type }
        str += externalsMapped.combine("") { $0 + "\n\n" + $1 }
        str += "\n\n"
        // Init
        str += "    internal init(\n"
        str += "        name: String,\n"
        str += "        initialState: " + stateType + ",\n"
        let externalArgs = machine.externalVariables.lazy.map { "        external_\($0.label): " + $0.type }.combine("") { $0 + ",\n" + $1 }
        if false == externalArgs.isEmpty {
            str += externalArgs + ",\n"
        }
        str += "        fsmVars: SimpleVariablesContainer<" + machine.name + "Vars>,\n"
        if nil != machine.parameters {
            str += "        parameters: SimpleVariablesContainer<" + machine.name + "Parameters>,\n"
            str += "        results: SimpleVariablesContainer<" + machine.name + "ResultsContainer>,\n"
        }
        str += "        ringlet: " + ringlet + ",\n"
        str += "        initialPreviousState: " + stateType + ",\n"
        str += "        suspendedState: " + stateType + "?,\n"
        str += "        suspendState: " + stateType + ",\n"
        str += "        exitState: " + stateType + ",\n"
        str += "        submachines: [() -> AnyControllableFiniteStateMachine]\n"
        str += "    ) {\n"
        str += "        self.currentState = initialState\n"
        str += "        self.exitState = exitState\n"
        let externalSetters = machine.externalVariables.lazy.map { "        self.external_\($0.label) = external_\($0.label)" }.combine("") { $0 + "\n" + $1 }
        if false == externalSetters.isEmpty {
            str += externalSetters + "\n"
        }
        str += "        self.fsmVars = fsmVars\n"
        if nil != machine.parameters {
            str += "        self.parameters = parameters\n"
            str += "        self.results = results\n"
        }
        str += "        self.initialState = initialState\n"
        str += "        self.initialPreviousState = initialPreviousState\n"
        str += "        self.name = name\n"
        str += "        self.previousState = initialPreviousState\n"
        str += "        self.ringlet = ringlet\n"
        str += "        self.submachineFunctions = submachines\n"
        str += "        self.suspendedState = suspendedState\n"
        str += "        self.suspendState = suspendState\n"
        str += "        self.allStates.forEach { $1.Me = self }\n"
        str += "        self.ringlet.Me = self\n"
        str += "    }\n\n"
        // Clone
        str += "    public func clone() -> " + name + " {\n"
        str += "        var stateCache: [String: " + stateType + "] = [:]\n"
        str += "        let allStates = self.allStates\n"
        str += "        self.fsmVars.vars = self.fsmVars.vars.clone()\n"
        str += "        var fsm = " + name + "(\n"
        str += "            name: self.name,\n"
        str += "            initialState: self.initialState.clone(),\n"
        let clonedExternalArgs = machine.externalVariables.lazy.map { "            external_\($0.label): self.external_\($0.label)" }.combine("") { $0 + ",\n" + $1 }
        if false == clonedExternalArgs.isEmpty {
            str += clonedExternalArgs + ",\n"
        }
        str += "            fsmVars: SimpleVariablesContainer(vars: self.fsmVars.vars.clone()),\n"
        if nil != machine.parameters {
            str += "            parameters: SimpleVariablesContainer(vars: self.parameters.vars.clone()),\n"
            str += "            results: SimpleVariablesContainer(vars: self.results.vars.clone()),\n"
        }
        str += "            ringlet: self.ringlet.clone(),\n"
        str += "            initialPreviousState: self.initialPreviousState.clone(),\n"
        str += "            suspendedState: self.suspendedState.map { $0.clone() },\n"
        str += "            suspendState: self.suspendState.clone(),\n"
        str += "            exitState: self.exitState.clone(),\n"
        str += "            submachines: self.submachineFunctions\n"
        str += "        )\n"
        str += "        func apply(_ state: " + stateType + ") -> " + stateType + " {\n"
        str += "            if let s = stateCache[state.name] {\n"
        str += "                return s\n"
        str += "            }\n"
        str += "            var state = state\n"
        str += "            state.Me = fsm\n"
        str += "            stateCache[state.name] = state\n"
        str += "            state.transitions = state.transitions.map {\n"
        str += "                if $0.target == state {\n"
        str += "                    return $0\n"
        str += "                }\n"
        str += "                guard let target = allStates[$0.target.name] else {\n"
        str += "                    return $0\n"
        str += "                }\n"
        str += "                return $0.map { _ in apply(target.clone()) }\n"
        str += "            }\n"
        str += "            return state\n"
        str += "        }\n"
        str += "        fsm.initialState = apply(fsm.initialState)\n"
        str += "        fsm.initialPreviousState = apply(fsm.initialPreviousState)\n"
        str += "        fsm.suspendedState = fsm.suspendedState.map { apply($0) }\n"
        str += "        fsm.suspendState = apply(fsm.suspendState)\n"
        str += "        fsm.exitState = apply(fsm.exitState)\n"
        str += "        fsm.currentState = apply(self.currentState.clone())\n"
        str += "        fsm.previousState = apply(self.previousState.clone())\n"
        str += "        return fsm\n"
        str += "    }\n\n"
        // resetResults
        if nil != machine.parameters {
            str += "    public func resetResult() {\n"
            str += "        self.results.vars.result = nil\n"
            str += "    }\n\n"
        }
        str += "}"
        // Extensions.
        let descriptionExternals = machine.externalVariables.lazy.map { "                external_\($0.label): self.external_\($0.label)" }.combine("") { $0 + ",\n" + $1 }
        str += "\n\nextension \(name): CustomStringConvertible {\n\n"
        str += "    var description: String {\n"
        str += "        return \"\"\"\n"
        str += "            {\n"
        str += "                name: \\(self.name),\n"
        str += "\(descriptionExternals)\(descriptionExternals.isEmpty ? "" : ",\n")"
        str += "                fsmVars: \\(self.fsmVars.vars),\n"
        if nil != machine.parameters {
            str += "                parameters: \\(self.parameters.vars),\n"
            str += "                results: \\(self.results.vars),\n"
        }
        str += "                initialState: \\(self.initialState.name),\n"
        str += "                currentState: \\(self.currentState.name),\n"
        str += "                previousState: \\(self.previousState.name),\n"
        str += "                suspendState: \\(self.suspendState.name),\n"
        str += "                suspendedState: \\(self.suspendedState.map { $0.name }),\n"
        str += "                exitState: \\(self.exitState.name),\n"
        str += "                states: \\(self.allStates)\n"
        str += "            }\n"
        str += "            \"\"\"\n"
        str += "    }\n"
        str += "\n}"
        return encode(inFile: name + ".swift", contents: str)
    }

    private func createAndTagGitRepo(inDirectory dir: URL) -> Bool {
        let bin = String(pathToExecutable: "git", foundInEnvironmentVariables: ["GIT"]) ?? "/usr/bin/git"
        let initArgs = ["init"]
        let addArgs = ["add", "."]
        let commitArgs = ["commit", "-am", "\"Initial Commit\""]
        let tagArgs = ["tag", "0.1.0"]
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

    private func createComputedProperties(fromVars vars: [Variable], withinContainer container: String, includeScope: Bool = true, indent: String = "") -> String {
        return vars.reduce("") {
            if true == takenVars.contains($1.label) {
                return $0
            }
            takenVars.insert($1.label)
            return $0 + self.createComputedProperty(mutable: $1.accessType != .readOnly, withLabel: $1.label, andType: $1.type, referencing: "\(container).\($1.label)", includeScope: includeScope, indent: indent)
        }
    }

    private func createComputedProperty(mutable: Bool, withLabel label: String, andType type: String, referencing reference: String, includeScope: Bool = true, indent: String = "", unwrap: Bool = false) -> String {
        return createComputedProperty(accessType: mutable ? .readAndWrite : .readOnly, withLabel: label, andType: type, referencing: reference, includeScope: includeScope, indent: indent, unwrap: unwrap)
    }
    
    private func createComputedProperty(accessType: Variable.AccessType, withLabel label: String, andType type: String, referencing reference: String, includeScope: Bool = true, indent: String = "", unwrap: Bool = false) -> String {
        let getter = "return \(reference)\(unwrap ? "!" : "")"
        let accessor = !includeScope ? "" : "public " + (accessType != .readOnly ? "internal(set) " : "")
        var str = ""
        str += indent + "\(accessor)var \(label): \(type) {\n"
        if accessType != .writeOnly {
            str += indent + "    get {\n"
            str += indent + "        \(getter)\n"
            str += indent + "    }\n"
        } else {
            str += indent + "    get {\n"
            str += indent + "        fatalError(\"Attempting to retrieve value from sink \(reference)\")\n"
            str += indent + "    }\n"
        }
        if accessType != .readOnly {
            str += indent + "    set {\n"
            str += indent + "        \(reference) = newValue\n"
            str += indent + "    }\n"
        }
        str += indent + "}\n\n"
        return str
    }
    
    private func makeTransition(forMachine machine: Machine) -> FileWrapper? {
        let name = machine.name + "StateTransition"
        let stateType = machine.name + "State"
        let str = """
            import swiftfsm
            
            public struct \(name): TransitionType {
                
                internal let base: Any
                
                public let target: \(stateType)
                
                public let canTransition: (\(stateType)) -> Bool
                
                public init<S: \(stateType)>(_ base: Transition<S, \(stateType)>) {
                    self.base = base
                    self.target = base.target
                    self.canTransition = {
                        guard let state = $0 as? S else {
                            fatalError("Unable to cast source state in transition to \\(S.self)")
                        }
                        return base.canTransition(state)
                    }
                }
                
                internal init(base: Any, target: \(stateType), canTransition: @escaping (\(stateType)) -> Bool) {
                    self.base = base
                    self.target = target
                    self.canTransition = canTransition
                }
                
                public func cast<S: \(stateType)>(to type: S.Type) -> Transition<S, \(stateType)> {
                    guard let transition = self.base as? Transition<S, \(stateType)> else {
                        fatalError("Unable to cast bast to Transition<\\(type), \(stateType)>")
                    }
                    return transition
                }
                
                public func map(_ f: (\(stateType)) -> \(stateType)) -> \(name) {
                    return \(name)(base: base, target: f(self.target), canTransition: self.canTransition)
                }
                
            }
            """
        return encode(inFile: name + ".swift", contents: str)
    }

}
