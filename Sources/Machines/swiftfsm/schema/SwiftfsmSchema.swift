/*
 * SwiftfsmSchema.swift
 * Machines
 *
 * Created by Callum McColl on 21/6/21.
 * Copyright © 2021 Callum McColl. All rights reserved.
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

import Attributes

public struct SwiftfsmSchema: SchemaProtocol {
    
    public typealias Root = Machine
    
    public var trigger: AnyTrigger<Machine> = []
    
    var variables = SwiftfsmVariables()
    
    var ringlet = SwiftfsmRinglet()
    
}

public struct SwiftfsmVariables: GroupProtocol {
    
    public let path = Machine.path.attributes[0]

    @TableProperty(
        label: "external_variables",
        columns: [
            .enumerated(label: "access_type", validValues: ["sensor", "actuator", "environment"]),
            .line(label: "label", validation: .required().alphaunderscore().notEmpty()),
            .expression(label: "type", language: .swift, validation: .required().alphaunderscore().notEmpty()),
            .expression(label: "value", language: .swift, validation: .required())
        ],
        available: true,
        validation: .required()
    )
    var externalVariables
    
    @TableProperty(
        label: "machine_variables",
        columns: [
            .enumerated(label: "access_type", validValues: ["let", "var"]),
            .line(label: "label", validation: .required().alphaunderscore().notEmpty()),
            .expression(label: "type", language: .swift, validation: .required().alphaunderscore().notEmpty()),
            .expression(label: "initial_value", language: .swift, validation: .required())
        ],
        available: true,
        validation: .required()
    )
    var machineVariables
    
    @ComplexProperty(base: SwiftfsmParameters(), available: false, label: "parameters")
    var parameters
    
}

public struct SwiftfsmParameters: ComplexProtocol {
    
    public let path = Machine.path.attributes[0].attributes["parameters"].wrappedValue.complexValue
    
    @BoolProperty(label: "enable_parameters", available: true, validation: .required())
    var enableParameters
    
    @TableProperty(
        label: "parameters",
        columns: [
            .line(label: "label", validation: .required().alphaunderscore().notEmpty()),
            .expression(label: "type", language: .swift, validation: .required().alphaunderscore().notEmpty()),
            .expression(label: "default_value", language: .swift, validation: .required())
        ],
        available: false
    )
    var parameters
    
}

public struct SwiftfsmRinglet: GroupProtocol {
    
    public let path = Machine.path.attributes[1]
    
    @BoolProperty(label: "use_custom_ringlet", available: true, validation: .required())
    var useCustomRinglet
    
    @CollectionProperty(label: "actions", available: false, lines: .required().alphaunderscore().notEmpty())
    var actions
    
    @TableProperty(
        label: "ringlet_variables",
        columns: [
            .enumerated(label: "access_type", validValues: ["let", "var"], validation: .required()),
            .line(label: "label", validation: .required().alphaunderscore().notEmpty()),
            .expression(label: "type", language: .swift, validation: .required().alphaunderscorefirst().notEmpty()),
            .expression(label: "initial_value", language: .swift, validation: .required().alphaunderscorefirst().notEmpty())
        ],
        available: false,
        validation: .required()
    )
    var ringletVariables
    
    @CodeProperty(label: "imports", language: .swift, available: false, validation: .required())
    var imports
    
    @CodeProperty(label: "execute", language: .swift, available: false, validation: .required())
    var execute
    
}

public struct SwiftfsmSettings: GroupProtocol {
    
    public let path = Machine.path.attributes[2]
    
    @EnumeratedProperty(label: "suspend_state", validValues: [])
    var suspendState
    
//    @ComplexProperty(base: SwiftfsmModuleDependencies(), available: true, label: "module_dependencies")
//    var moduleDependencies
    
}

//public struct SwiftfsmModuleDependencies: ComplexProtocol {
//    
//    public let path = Machine.path.attributes[2].attributes["module_dependencies"].wrappedValue.complexValue
//    
//    @ComplexCollectionProperty(base: SwiftfsmPackage(), available: true, label: "packages")
//    var packages
//    
//}
//
//public struct SwiftfsmPackage: ComplexProtocol {
//    
//    @CollectionProperty(label: "products", available: true, lines: .required())
//    var products
//    
//    @CollectionProperty(label: "qualifiers", available: true, lines: .required())
//    var qualifiers
//    
//    @CollectionProperty(label: "targets_to_import", available: true, lines: .required())
//    var targetsToImport
//    
//    @LineProperty(label: "url", available: true, validation: .required())
//    var url
//    
//}
