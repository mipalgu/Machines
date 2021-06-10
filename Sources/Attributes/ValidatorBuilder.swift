/*
 * ValidatorBuilder.swift
 * Attributes
 *
 * Created by Callum McColl on 6/11/20.
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

@resultBuilder
public struct ValidatorBuilder<Root> {
    
    public func buildBlock() -> AnyValidator<Root> { [] }

    public func makeValidator(@ValidatorBuilder _ content: () -> [AnyValidator<Root>]) -> AnyValidator<Root> {
        AnyValidator(content())
    }
    
    public static func buildBlock<V0: ValidatorProtocol>(_ v0: V0) -> AnyValidator<Root> where V0.Root == Root {
        return AnyValidator([AnyValidator(v0)])
    }
    
    public static func buildBlock<V0: ValidatorProtocol, V1: ValidatorProtocol>(_ v0: V0, _ v1: V1) -> AnyValidator<Root> where V0.Root == Root, V1.Root == Root {
        return AnyValidator([AnyValidator(v0), AnyValidator(v1)])
    }
    
    public static func buildBlock<
        V0: ValidatorProtocol,
        V1: ValidatorProtocol,
        V2: ValidatorProtocol
    >(_ v0: V0, _ v1: V1, _ v2: V2) -> AnyValidator<Root> where
        V0.Root == Root,
        V1.Root == Root,
        V2.Root == Root
    {
        return AnyValidator([AnyValidator(v0), AnyValidator(v1), AnyValidator(v2)])
    }
    
    public static func buildBlock<
        V0: ValidatorProtocol,
        V1: ValidatorProtocol,
        V2: ValidatorProtocol,
        V3: ValidatorProtocol
    >(_ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3) -> AnyValidator<Root> where
        V0.Root == Root,
        V1.Root == Root,
        V2.Root == Root,
        V3.Root == Root
    {
        return AnyValidator([AnyValidator(v0), AnyValidator(v1), AnyValidator(v2), AnyValidator(v3)])
    }
    
    public static func buildBlock<
        V0: ValidatorProtocol,
        V1: ValidatorProtocol,
        V2: ValidatorProtocol,
        V3: ValidatorProtocol,
        V4: ValidatorProtocol
    >(_ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4) -> AnyValidator<Root> where
        V0.Root == Root,
        V1.Root == Root,
        V2.Root == Root,
        V3.Root == Root,
        V4.Root == Root
    {
        return AnyValidator([
            AnyValidator(v0),
            AnyValidator(v1),
            AnyValidator(v2),
            AnyValidator(v3),
            AnyValidator(v4)
        ])
    }
    
    public static func buildBlock<
        V0: ValidatorProtocol,
        V1: ValidatorProtocol,
        V2: ValidatorProtocol,
        V3: ValidatorProtocol,
        V4: ValidatorProtocol,
        V5: ValidatorProtocol
    >(_ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4, _ v5: V5) -> AnyValidator<Root> where
        V0.Root == Root,
        V1.Root == Root,
        V2.Root == Root,
        V3.Root == Root,
        V4.Root == Root,
        V5.Root == Root
    {
        return AnyValidator([
            AnyValidator(v0),
            AnyValidator(v1),
            AnyValidator(v2),
            AnyValidator(v3),
            AnyValidator(v4),
            AnyValidator(v5)
        ])
    }
    
    public static func buildBlock<
        V0: ValidatorProtocol,
        V1: ValidatorProtocol,
        V2: ValidatorProtocol,
        V3: ValidatorProtocol,
        V4: ValidatorProtocol,
        V5: ValidatorProtocol,
        V6: ValidatorProtocol
    >(_ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4, _ v5: V5, _ v6: V6) -> AnyValidator<Root> where
        V0.Root == Root,
        V1.Root == Root,
        V2.Root == Root,
        V3.Root == Root,
        V4.Root == Root,
        V5.Root == Root,
        V6.Root == Root
    {
        return AnyValidator([
            AnyValidator(v0),
            AnyValidator(v1),
            AnyValidator(v2),
            AnyValidator(v3),
            AnyValidator(v4),
            AnyValidator(v5),
            AnyValidator(v6)
        ])
    }
    
    public static func buildBlock<
        V0: ValidatorProtocol,
        V1: ValidatorProtocol,
        V2: ValidatorProtocol,
        V3: ValidatorProtocol,
        V4: ValidatorProtocol,
        V5: ValidatorProtocol,
        V6: ValidatorProtocol,
        V7: ValidatorProtocol
    >(_ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4, _ v5: V5, _ v6: V6, _ v7: V7) -> AnyValidator<Root> where
        V0.Root == Root,
        V1.Root == Root,
        V2.Root == Root,
        V3.Root == Root,
        V4.Root == Root,
        V5.Root == Root,
        V6.Root == Root,
        V7.Root == Root
    {
        return AnyValidator([
            AnyValidator(v0),
            AnyValidator(v1),
            AnyValidator(v2),
            AnyValidator(v3),
            AnyValidator(v4),
            AnyValidator(v5),
            AnyValidator(v6),
            AnyValidator(v7)
        ])
    }
    
    public static func buildBlock<
        V0: ValidatorProtocol,
        V1: ValidatorProtocol,
        V2: ValidatorProtocol,
        V3: ValidatorProtocol,
        V4: ValidatorProtocol,
        V5: ValidatorProtocol,
        V6: ValidatorProtocol,
        V7: ValidatorProtocol,
        V8: ValidatorProtocol
    >(_ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4, _ v5: V5, _ v6: V6, _ v7: V7, _ v8: V8) -> AnyValidator<Root> where
        V0.Root == Root,
        V1.Root == Root,
        V2.Root == Root,
        V3.Root == Root,
        V4.Root == Root,
        V5.Root == Root,
        V6.Root == Root,
        V7.Root == Root,
        V8.Root == Root
    {
        return AnyValidator([
            AnyValidator(v0),
            AnyValidator(v1),
            AnyValidator(v2),
            AnyValidator(v3),
            AnyValidator(v4),
            AnyValidator(v5),
            AnyValidator(v6),
            AnyValidator(v7),
            AnyValidator(v8)
        ])
    }
    
    public static func buildBlock<
        V0: ValidatorProtocol,
        V1: ValidatorProtocol,
        V2: ValidatorProtocol,
        V3: ValidatorProtocol,
        V4: ValidatorProtocol,
        V5: ValidatorProtocol,
        V6: ValidatorProtocol,
        V7: ValidatorProtocol,
        V8: ValidatorProtocol,
        V9: ValidatorProtocol
    >(_ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4, _ v5: V5, _ v6: V6, _ v7: V7, _ v8: V8, _ v9: V9) -> AnyValidator<Root> where
        V0.Root == Root,
        V1.Root == Root,
        V2.Root == Root,
        V3.Root == Root,
        V4.Root == Root,
        V5.Root == Root,
        V6.Root == Root,
        V7.Root == Root,
        V8.Root == Root,
        V9.Root == Root
    {
        return AnyValidator([
            AnyValidator(v0),
            AnyValidator(v1),
            AnyValidator(v2),
            AnyValidator(v3),
            AnyValidator(v4),
            AnyValidator(v5),
            AnyValidator(v6),
            AnyValidator(v7),
            AnyValidator(v8),
            AnyValidator(v9)
        ])
    }
    
    public static func buildBlock<
        V0: ValidatorProtocol,
        V1: ValidatorProtocol,
        V2: ValidatorProtocol,
        V3: ValidatorProtocol,
        V4: ValidatorProtocol,
        V5: ValidatorProtocol,
        V6: ValidatorProtocol,
        V7: ValidatorProtocol,
        V8: ValidatorProtocol,
        V9: ValidatorProtocol,
        V10: ValidatorProtocol
    >(_ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4, _ v5: V5, _ v6: V6, _ v7: V7, _ v8: V8, _ v9: V9, _ v10: V10) -> AnyValidator<Root> where
        V0.Root == Root,
        V1.Root == Root,
        V2.Root == Root,
        V3.Root == Root,
        V4.Root == Root,
        V5.Root == Root,
        V6.Root == Root,
        V7.Root == Root,
        V8.Root == Root,
        V9.Root == Root,
        V10.Root == Root
    {
        return AnyValidator([
            AnyValidator(v0),
            AnyValidator(v1),
            AnyValidator(v2),
            AnyValidator(v3),
            AnyValidator(v4),
            AnyValidator(v5),
            AnyValidator(v6),
            AnyValidator(v7),
            AnyValidator(v8),
            AnyValidator(v9),
            AnyValidator(v10)
        ])
    }
    
    public static func buildBlock<
        V0: ValidatorProtocol,
        V1: ValidatorProtocol,
        V2: ValidatorProtocol,
        V3: ValidatorProtocol,
        V4: ValidatorProtocol,
        V5: ValidatorProtocol,
        V6: ValidatorProtocol,
        V7: ValidatorProtocol,
        V8: ValidatorProtocol,
        V9: ValidatorProtocol,
        V10: ValidatorProtocol,
        V11: ValidatorProtocol
    >(_ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4, _ v5: V5, _ v6: V6, _ v7: V7, _ v8: V8, _ v9: V9, _ v10: V10, _ v11: V11) -> AnyValidator<Root> where
        V0.Root == Root,
        V1.Root == Root,
        V2.Root == Root,
        V3.Root == Root,
        V4.Root == Root,
        V5.Root == Root,
        V6.Root == Root,
        V7.Root == Root,
        V8.Root == Root,
        V9.Root == Root,
        V10.Root == Root,
        V11.Root == Root
    {
        return AnyValidator([
            AnyValidator(v0),
            AnyValidator(v1),
            AnyValidator(v2),
            AnyValidator(v3),
            AnyValidator(v4),
            AnyValidator(v5),
            AnyValidator(v6),
            AnyValidator(v7),
            AnyValidator(v8),
            AnyValidator(v9),
            AnyValidator(v10),
            AnyValidator(v11)
        ])
    }
    
}
