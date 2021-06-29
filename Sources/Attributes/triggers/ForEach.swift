/*
 * ForEach.swift
 * Attributes
 *
 * Created by Callum McColl on 30/6/21.
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

public struct ForEach<SearchPath: SearchablePath, Trigger: TriggerProtocol>: TriggerProtocol where Trigger.Root == SearchPath.Root {
    
    private let path: SearchPath
    
    private let builder: (Path<SearchPath.Root, SearchPath.Value>) -> Trigger
    
    public init(_ path: SearchPath, @TriggerBuilder<SearchPath.Root> each builder: @escaping (Path<SearchPath.Root, SearchPath.Value>) -> Trigger) {
        self.path = path
        self.builder = builder
    }
    
    public func performTrigger(_ root: inout SearchPath.Root, for path: AnyPath<SearchPath.Root>) -> Result<Bool, AttributeError<SearchPath.Root>> {
        var changed = false
        for subpath in self.path.paths(in: root) {
            let trigger = builder(subpath)
            let result = trigger.performTrigger(&root, for: path)
            switch result {
            case .success(let shouldNotify):
                changed = changed || shouldNotify
                continue
            case .failure(let error):
                return .failure(error)
            }
        }
        return .success(changed)
    }
    
    public func isTriggerForPath(_ path: AnyPath<SearchPath.Root>, in root: SearchPath.Root) -> Bool {
        self.path.isAncestorOrSame(of: path, in: root)
    }
    
}

extension ForEach where Trigger == WhenChanged<Path<SearchPath.Root, SearchPath.Value>, IdentityTrigger<SearchPath.Root>> {
    
    public func when<NewTrigger: TriggerProtocol>(
        _ condition: @escaping (Root) -> Bool,
        @TriggerBuilder<Root> then builder: @escaping (Trigger) -> NewTrigger
    ) -> ForEach<SearchPath, WhenChanged<Path<SearchPath.Root, SearchPath.Value>, ConditionalTrigger<NewTrigger>>> where NewTrigger.Root == Root {
        ForEach<SearchPath, WhenChanged<Path<SearchPath.Root, SearchPath.Value>, ConditionalTrigger<NewTrigger>>>(self.path) { (actualPath) -> WhenChanged<Path<SearchPath.Root, SearchPath.Value>, ConditionalTrigger<NewTrigger>> in
            WhenChanged<Path<SearchPath.Root, SearchPath.Value>, ConditionalTrigger<NewTrigger>>(
                actualPath: actualPath,
                trigger: ConditionalTrigger<NewTrigger>(condition: condition, trigger: builder(self.builder(actualPath)))
            )
        }
    }
    
    public func sync<TargetPath: SearchablePath>(target: TargetPath) -> ForEach<SearchPath, SyncTrigger<Path<SearchPath.Root, SearchPath.Value>, TargetPath>> where TargetPath.Root == Root, TargetPath.Value == SearchPath.Value {
        ForEach<SearchPath, SyncTrigger<Path<SearchPath.Root, SearchPath.Value>, TargetPath>>(path) {
            SyncTrigger(source: $0, target: target)
        }
    }

    public func makeAvailable<FieldsPath: PathProtocol, AttributesPath: PathProtocol>(field: Field, after order: [String], fields: FieldsPath, attributes: AttributesPath) -> ForEach<SearchPath, MakeAvailableTrigger<Path<SearchPath.Root, SearchPath.Value>, FieldsPath, AttributesPath>> where FieldsPath.Root == Root, FieldsPath.Value == [Field], AttributesPath.Value == [String: Attribute] {
        ForEach<SearchPath, MakeAvailableTrigger<Path<SearchPath.Root, SearchPath.Value>, FieldsPath, AttributesPath>>(path) {
            MakeAvailableTrigger(field: field, after: order, source: $0, fields: fields, attributes: attributes)
        }
    }

    public func makeUnavailable<FieldsPath: PathProtocol>(field: Field, fields: FieldsPath) -> ForEach<SearchPath, MakeUnavailableTrigger<Path<SearchPath.Root, SearchPath.Value>, FieldsPath>> where FieldsPath.Root == Root, FieldsPath.Value == [Field] {
        ForEach<SearchPath, MakeUnavailableTrigger<Path<SearchPath.Root, SearchPath.Value>, FieldsPath>>(path) {
            MakeUnavailableTrigger(field: field, source: $0, fields: fields)
        }
    }
    
}
