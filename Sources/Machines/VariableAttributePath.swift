/*
 * VariableAttributePath.swift
 * Machines
 *
 * Created by Callum McColl on 3/11/20.
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

public protocol MachinePathProtocol {
    
    associatedtype Value
    
    var path: WritableKeyPath<Machine, Value> { get }
    
}

struct VariablePath: MachinePathProtocol {
    
    var path: WritableKeyPath<Machine, Variable>
    
    var label: ValuePath<String> {
        return ValuePath(path: self.path.appending(path: \.label))
    }
    
    var type: ValuePath<String> {
        return ValuePath(path: self.path.appending(path: \.type))
    }
    
    var extraFields: ExtraFieldsPath {
        return ExtraFieldsPath(path: self.path.appending(path: \.extraFields))
    }
    
}

struct ExtraFieldsPath: MachinePathProtocol {
    
    var path: WritableKeyPath<Machine, [String: LineAttribute]>
    
    func attribute(key: String) -> LineAttributePath {
        LineAttributePath(path: path.appending(path: \.self[key]!))
    }
    
}

struct ExtraFieldsTypePath: MachinePathProtocol {
    
    var path: WritableKeyPath<Machine, [String: LineAttributeType]>
    
}

struct LineAttributePath: MachinePathProtocol {
    
    var path: WritableKeyPath<Machine, LineAttribute>
    
}

struct ComplexAttributePath: MachinePathProtocol {
    
    var path: WritableKeyPath<Machine, [String: Attribute]>
    
}

struct ComplexAttributeTypePath: MachinePathProtocol {
    
    var path: WritableKeyPath<Machine, [String: AttributeType]>
    
}

struct VariablesArrayPath: MachinePathProtocol {
    
    var path: WritableKeyPath<Machine, [Variable]>
    
    func index(_ index: Int) -> VariablePath {
        return VariablePath(path: path.appending(path: \.self[index]))
    }
    
}

public struct MachinePath: MachinePathProtocol {
    
    public let path: WritableKeyPath<Machine, Machine> = \.self
    
    var name: ValuePath<String> {
        return ValuePath(path: path.appending(path: \.name))
    }
    
    var filePath: ValuePath<URL> {
        return ValuePath(path: path.appending(path: \.filePath))
    }
    
    var initialState: ValuePath<StateName> {
        return ValuePath(path: path.appending(path: \.initialState))
    }
    
    var suspendState: ValuePath<StateName> {
        return ValuePath(path: path.appending(path: \.suspendState))
    }
    
    var states: StatesPath {
        StatesPath(path: path.appending(path: \.states))
    }
    
    var transitions: TransitionArrayPath {
        TransitionArrayPath(path: path.appending(path: \.transitions))
    }
    
    var variables: VariableListArrayPath {
        VariableListArrayPath(path: path.appending(path: \.variables))
    }
    
    var attributes: AttributeGroupArrayPath {
        return AttributeGroupArrayPath(path: path.appending(path: \.attributes))
    }
    
    var metaData: AttributeGroupArrayPath {
        return AttributeGroupArrayPath(path: path.appending(path: \.metaData))
    }
    
}

struct StatesPath: MachinePathProtocol {
    
    var path: WritableKeyPath<Machine, [State]>
    
    func index(_ index: Int) -> StatePath {
        return StatePath(path: path.appending(path: \.self[index]))
    }
    
}

struct StatePath: MachinePathProtocol {
    
    var path: WritableKeyPath<Machine, State>
    
    var name: ValuePath<String> {
        return ValuePath(path: path.appending(path: \.name))
    }
    
    var actions: ActionsPath {
        return ActionsPath(path: path.appending(path: \.actions))
    }
    
    var variables: VariableListArrayPath {
        return VariableListArrayPath(path: path.appending(path: \.variables))
    }
    
    var attributes: AttributeGroupArrayPath {
        return AttributeGroupArrayPath(path: path.appending(path: \.attributes))
    }
    
    var metaData: AttributeGroupArrayPath {
        return AttributeGroupArrayPath(path: path.appending(path: \.metaData))
    }
    
}

struct ActionsPath: MachinePathProtocol {
    
    var path: WritableKeyPath<Machine, [String: Code]>
    
}

struct VariableListArrayPath: MachinePathProtocol {
    
    var path: WritableKeyPath<Machine, [VariableList]>
    
    func index(_ index: Int) -> VariableListPath {
        return VariableListPath(path: path.appending(path: \.self[index]))
    }
    
}

struct VariableListPath: MachinePathProtocol {
    
    var path: WritableKeyPath<Machine, VariableList>
    
    var name: ValuePath<String> {
        return ValuePath(path: path.appending(path: \.name))
    }
    
    var enabled: ValuePath<Bool> {
        return ValuePath(path: path.appending(path: \.enabled))
    }
    
    var extraFields: ExtraFieldsTypePath {
        return ExtraFieldsTypePath(path: path.appending(path: \.extraFields))
    }
    
    var attributes: ComplexAttributePath {
        return ComplexAttributePath(path: path.appending(path: \.attributes))
    }
    
    var metaData: ComplexAttributePath {
        return ComplexAttributePath(path: path.appending(path: \.metaData))
    }
    
}

struct AttributeGroupArrayPath: MachinePathProtocol {
    
    var path: WritableKeyPath<Machine, [AttributeGroup]>
    
    func index(_ index: Int) -> AttributeGroupPath {
        return AttributeGroupPath(path: path.appending(path: \.self[index]))
    }
    
}

struct AttributeGroupPath: MachinePathProtocol {
    
    var path: WritableKeyPath<Machine, AttributeGroup>
    
    var name: ValuePath<String> {
        return ValuePath(path: path.appending(path: \.name))
    }
    
    var variables: OptionalVariableListPath {
        return OptionalVariableListPath(path: path.appending(path: \.variables))
    }
    
    var fields: ComplexAttributeTypePath {
        return ComplexAttributeTypePath(path: path.appending(path: \.fields))
    }
    
    var attributes: ComplexAttributePath {
        return ComplexAttributePath(path: path.appending(path: \.attributes))
    }
    
    var metaData: ComplexAttributePath {
        return ComplexAttributePath(path: path.appending(path: \.metaData))
    }
    
}

struct OptionalVariableListPath: MachinePathProtocol {
    
    var path: WritableKeyPath<Machine, VariableList?>
    
    var value: VariableListPath {
        VariableListPath(path: path.appending(path: \.self!))
    }
    
}

struct ValuePath<Value>: MachinePathProtocol {
    
    var path: WritableKeyPath<Machine, Value>
    
}

struct TransitionArrayPath: MachinePathProtocol {
    
    var path: WritableKeyPath<Machine, [Transition]>
    
    func index(_ index: Int) -> TransitionPath {
        return TransitionPath(path: path.appending(path: \.self[index]))
    }
    
}

struct TransitionPath: MachinePathProtocol {
    
    var path: WritableKeyPath<Machine, Transition>
    
    var condition: OptionalValuePath<Expression> {
        OptionalValuePath(path: path.appending(path: \.condition))
    }
    
    var source: OptionalValuePath<String> {
        OptionalValuePath(path: path.appending(path: \.source))
    }
    
    var target: OptionalValuePath<String> {
        OptionalValuePath(path: path.appending(path: \.target))
    }
    
    var attributes: AttributeGroupArrayPath {
        return AttributeGroupArrayPath(path: path.appending(path: \.attributes))
    }
    
    var metaData: AttributeGroupArrayPath {
        return AttributeGroupArrayPath(path: path.appending(path: \.metaData))
    }
    
}

struct OptionalValuePath<T>: MachinePathProtocol {
    
    var path: WritableKeyPath<Machine, T?>
    
    var some: ValuePath<T> {
        ValuePath(path: path.appending(path: \.self!))
    }
    
}
