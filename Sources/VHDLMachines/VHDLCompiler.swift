//
//  File.swift
//  
//
//  Created by Morgan McColl on 19/5/21.
//

import Foundation
import IO

public struct VHDLCompiler {
    
    var helper: FileHelpers = FileHelpers()
    
    public func compile(_ machine: Machine) -> Bool {
        let format = foldWithNewLine(
            components: [
                createIncludes(includes: machine.includes),
                createEntity(machine: machine)
            ],
            initial: ""
        )
        let fileName = "\(machine.name).vhd"
        return helper.createFile(fileName, inDirectory: machine.path, withContents: format) != nil
    }
    
    private func createIncludes(includes: [String]) -> String {
        return includes.reduce("") {
            if $0 == $1 && $0 == "" {
                return ""
            }
            if $0 == "" {
                return String($1)
            }
            return $0 + "\n" + $1
        }
    }
    
    private func createEntity(machine: Machine) -> String {
        """
         entity \(machine.name) is
             \(foldWithNewLine(components: [createGenericsBlock(variables: machine.externalVariables), createPortBlock(clocks: machine.clocks, signals: machine.externalSignals)], initial: ""))
         end \(machine.name);
         """
    }
    
    private func createGenericsBlock(variables: [VHDLVariable]) -> String {
        guard !variables.isEmpty else {
            return ""
        }
        return """
         generic (
            \(foldWithNewLine(components: variables.indices.map {
                if $0 == variables.count - 1 {
                    return variableToGeneric(variable: variables[$0], withSemicolon: true)
                }
                return variableToGeneric(variable: variables[$0], withSemicolon: false)
            },
            initial: ""
           )
           )
         );
         """
    }
    
    private func variableToGeneric(variable: VHDLVariable, withSemicolon: Bool) -> String {
        let semiColon = withSemicolon ? ";" : ""
        guard let range = variable.range else {
            return "\(variable.name): \(variable.type)\(semiColon)"
        }
        guard let defaultValue = variable.defaultValue else {
            return "\(variable.name): \(variable.type) range \(range.0) to \(range.1)\(semiColon)" + (variable.comment == nil ? "" : " -- \(variable.comment!)")
        }
        return "\(variable.name): \(variable.type) range \(range.0) to \(range.1) := \(defaultValue)\(semiColon)" + (variable.comment == nil ? "" : " -- \(variable.comment!)")
    }
    
    private func createPortBlock(clocks: [Clock], signals: [ExternalSignal]) -> String {
        guard !clocks.isEmpty else {
            fatalError("No clock found for machine")
        }
        return """
         port (
             \(foldWithNewLine(components: clocks.map { clockToSignal(clk: $0) }, initial: ""));
             \(foldWithNewLine(components: signals.map { signalToEntityDeclaration(signal: $0) }, initial: "suspended: out std_logic;"))
             command: in std_logic_vector(1 downto 0)
         );
         """
    }
    
    private func clockToSignal(clk: Clock) -> String {
        "\(clk.name): in std_logic"
    }
    
    private func foldWithNewLine(components: [String], initial: String) -> String {
        components.reduce(initial) {
            if $0 == "" {
                return ""
            }
            if $1 == "" {
                return $0
            }
            return $0 + "\n" + $1
        }
    }
    
    private func signalToEntityDeclaration(signal: ExternalSignal) -> String {
        guard let defaultValue = signal.defaultValue else {
            return "\(signal.name): \(signal.mode) \(signal.type);" + (signal.comment == nil ? "" : " --\(signal.comment!)")
        }
        return "\(signal.name): \(signal.mode) \(signal.type) := \(defaultValue);" + (signal.comment == nil ? "" : " --\(signal.comment!)")
    }
    
}
