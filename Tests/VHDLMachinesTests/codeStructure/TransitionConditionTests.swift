// TransitionConditionTests.swift
// Machines
// 
// Created by Morgan McColl.
// Copyright © 2023 Morgan McColl. All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above
//    copyright notice, this list of conditions and the following
//    disclaimer in the documentation and/or other materials
//    provided with the distribution.
// 
// 3. All advertising materials mentioning features or use of this
//    software must display the following acknowledgement:
// 
//    This product includes software developed by Morgan McColl.
// 
// 4. Neither the name of the author nor the names of contributors
//    may be used to endorse or promote products derived from this
//    software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 
// -----------------------------------------------------------------------
// This program is free software; you can redistribute it and/or
// modify it under the above terms or under the terms of the GNU
// General Public License as published by the Free Software Foundation;
// either version 2 of the License, or (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, see http://www.gnu.org/licenses/
// or write to the Free Software Foundation, Inc., 51 Franklin Street,
// Fifth Floor, Boston, MA  02110-1301, USA.
// 

@testable import VHDLMachines
import VHDLParsing
import XCTest

/// Test class for ``TransitionCondition``.
final class TransitionConditionTests: XCTestCase {

    /// A variable `x`.
    let x = Expression.variable(name: .x)

    /// A variable `y`
    let y = Expression.variable(name: .y)

    /// A variable `z`
    let z = Expression.variable(name: .z)

    /// Test that raw values are correct.
    func testRawValue() {
        let after = AfterStatement(amount: x, period: .ns)
        XCTAssertEqual(TransitionCondition.after(statement: after).rawValue, after.rawValue)
        XCTAssertEqual(TransitionCondition.conditional(condition: .literal(value: true)).rawValue, "true")
        XCTAssertEqual(
            TransitionCondition.boolean(expression: .and(
                lhs: .literal(value: .boolean(value: true)), rhs: x
            )).rawValue,
            "true and x"
        )
        XCTAssertEqual(TransitionCondition.variable(name: .x).rawValue, "x")
        XCTAssertEqual(TransitionCondition.precedence(condition: .variable(name: .x)).rawValue, "(x)")
        XCTAssertEqual(
            TransitionCondition.and(lhs: .variable(name: .x), rhs: .variable(name: .y)).rawValue, "x and y"
        )
        XCTAssertEqual(
            TransitionCondition.or(lhs: .variable(name: .x), rhs: .variable(name: .y)).rawValue, "x or y"
        )
        XCTAssertEqual(
            TransitionCondition.nand(lhs: .variable(name: .x), rhs: .variable(name: .y)).rawValue, "x nand y"
        )
        XCTAssertEqual(
            TransitionCondition.nor(lhs: .variable(name: .x), rhs: .variable(name: .y)).rawValue, "x nor y"
        )
        XCTAssertEqual(
            TransitionCondition.xor(lhs: .variable(name: .x), rhs: .variable(name: .y)).rawValue, "x xor y"
        )
        XCTAssertEqual(
            TransitionCondition.xnor(lhs: .variable(name: .x), rhs: .variable(name: .y)).rawValue, "x xnor y"
        )
        XCTAssertEqual(
            TransitionCondition.not(value: .variable(name: .x)).rawValue, "not x"
        )
    }

    /// Test the raw value init for boolean expressions.
    func testBooleanInit() {
        XCTAssertEqual(TransitionCondition(rawValue: "x and y"), .boolean(expression: .and(lhs: x, rhs: y)))
        XCTAssertEqual(
            TransitionCondition(rawValue: "(x and y)"),
            .precedence(condition: .boolean(expression: .and(lhs: x, rhs: y)))
        )
        XCTAssertEqual(TransitionCondition(rawValue: "x or y"), .boolean(expression: .or(lhs: x, rhs: y)))
        XCTAssertEqual(TransitionCondition(rawValue: "x nand y"), .boolean(expression: .nand(lhs: x, rhs: y)))
        XCTAssertEqual(TransitionCondition(rawValue: "x nor y"), .boolean(expression: .nor(lhs: x, rhs: y)))
        XCTAssertEqual(TransitionCondition(rawValue: "x xor y"), .boolean(expression: .xor(lhs: x, rhs: y)))
        XCTAssertEqual(TransitionCondition(rawValue: "x xnor y"), .boolean(expression: .xnor(lhs: x, rhs: y)))
        XCTAssertEqual(TransitionCondition(rawValue: "not x"), .boolean(expression: .not(value: x)))
        XCTAssertEqual(
            TransitionCondition(rawValue: "x and (y or z)"),
            .boolean(expression: .and(
                lhs: x, rhs: .precedence(value: .logical(operation: .or(lhs: y, rhs: z)))
            ))
        )
        XCTAssertEqual(
            TransitionCondition(rawValue: "(x > y) or z"),
            .boolean(expression: .or(
                lhs: .precedence(value: .conditional(
                    condition: .comparison(value: .greaterThan(lhs: x, rhs: y))
                )),
                rhs: z
            ))
        )
    }

    /// Test the raw value init for conditional expressions.
    func testConditionalInit() {
        XCTAssertEqual(TransitionCondition(rawValue: "true"), .conditional(condition: .literal(value: true)))
        XCTAssertEqual(
            TransitionCondition(rawValue: "false"), .conditional(condition: .literal(value: false))
        )
        XCTAssertEqual(
            TransitionCondition(rawValue: "x > y"),
            .conditional(condition: .comparison(value: .greaterThan(lhs: x, rhs: y)))
        )
        XCTAssertEqual(
            TransitionCondition(rawValue: "(x > y)"),
            .precedence(condition: .conditional(condition: .comparison(value: .greaterThan(lhs: x, rhs: y))))
        )
        XCTAssertEqual(
            TransitionCondition(rawValue: "x >= y"),
            .conditional(condition: .comparison(value: .greaterThanOrEqual(lhs: x, rhs: y)))
        )
        XCTAssertEqual(
            TransitionCondition(rawValue: "x < y"),
            .conditional(condition: .comparison(value: .lessThan(lhs: x, rhs: y)))
        )
        XCTAssertEqual(
            TransitionCondition(rawValue: "x <= y"),
            .conditional(condition: .comparison(value: .lessThanOrEqual(lhs: x, rhs: y)))
        )
        XCTAssertEqual(
            TransitionCondition(rawValue: "x = y"),
            .conditional(condition: .comparison(value: .equality(lhs: x, rhs: y)))
        )
        XCTAssertEqual(
            TransitionCondition(rawValue: "x /= y"),
            .conditional(condition: .comparison(value: .notEquals(lhs: x, rhs: y)))
        )
    }

    /// Test the raw value init for variable statements.
    func testVariableInit() {
        XCTAssertEqual(TransitionCondition(rawValue: "x"), .variable(name: .x))
        XCTAssertNil(TransitionCondition(rawValue: String(repeating: "x", count: 1024)))
        XCTAssertNil(TransitionCondition(rawValue: "x y"))
    }

    /// Test the raw value init for after statements.
    func testAfterInit() {
        XCTAssertEqual(
            TransitionCondition(rawValue: "after_ns(x)"),
            .after(statement: AfterStatement(amount: x, period: .ns))
        )
        XCTAssertEqual(
            TransitionCondition(rawValue: "(after_ns(x))"),
            .precedence(condition: .after(statement: AfterStatement(amount: x, period: .ns)))
        )
        XCTAssertEqual(
            TransitionCondition(rawValue: "(y and z) or after_ns(x)"),
            .or(
                lhs: .precedence(condition: .boolean(expression: .and(lhs: y, rhs: z))),
                rhs: .after(statement: AfterStatement(amount: x, period: .ns))
            )
        )
        XCTAssertEqual(
            TransitionCondition(rawValue: "y and (z or after_ns(x))"),
            .and(
                lhs: .variable(name: .y),
                rhs: .precedence(condition: .or(
                    lhs: .variable(name: .z), rhs: .after(statement: AfterStatement(amount: x, period: .ns))
                ))
            )
        )
        XCTAssertEqual(
            TransitionCondition(rawValue: "(x or y) and (z or after_ns(10))"),
            .and(
                lhs: .precedence(condition: .boolean(expression: .or(lhs: x, rhs: y))),
                rhs: .precedence(condition: .or(
                    lhs: .variable(name: .z),
                    rhs: .after(statement: AfterStatement(
                        amount: .literal(value: .integer(value: 10)), period: .ns
                    ))
                ))
            )
        )
    }

    /// Test the raw value init for after stataments containing conditional operations.
    func testAfterConditionalInit() {
        XCTAssertEqual(
            TransitionCondition(rawValue: "(x = y) and (z or after_ns(10))"),
            .and(
                lhs: .precedence(condition: .conditional(
                    condition: .comparison(value: .equality(lhs: x, rhs: y))
                )),
                rhs: .precedence(condition: .or(
                    lhs: .variable(name: .z),
                    rhs: .after(statement: AfterStatement(
                        amount: .literal(value: .integer(value: 10)), period: .ns
                    ))
                ))
            )
        )
        XCTAssertEqual(
            TransitionCondition(rawValue: "(x = y) and ((z or after_ns(10)) or after_ms(1))"),
            .and(
                lhs: .precedence(condition: .conditional(
                    condition: .comparison(value: .equality(lhs: x, rhs: y))
                )),
                rhs: .precedence(condition: .or(
                    lhs: .precedence(condition: .or(
                        lhs: .variable(name: .z),
                        rhs: .after(statement: AfterStatement(
                            amount: .literal(value: .integer(value: 10)), period: .ns
                        ))
                    )),
                    rhs: .after(statement: AfterStatement(
                        amount: .literal(value: .integer(value: 1)), period: .ms
                    ))
                ))
            )
        )
    }

    /// Test nil cases for the raw value init.
    func testFailingRawValueInit() {
        XCTAssertNil(TransitionCondition(rawValue: "after_ms(x) or"))
        XCTAssertNil(TransitionCondition(rawValue: "(x and)"))
        XCTAssertNil(TransitionCondition(rawValue: "(after_ms(x)"))
        XCTAssertNil(TransitionCondition(rawValue: "(after_ms(x)) ors true"))
        XCTAssertNil(TransitionCondition(rawValue: "(after_ms(x)) or x y z"))
        XCTAssertNil(TransitionCondition(rawValue: "after_ms(x) ors x"))
    }

    /// Test after boolean expressions.
    func testAfterBooleanInit() {
        XCTAssertEqual(
            TransitionCondition(rawValue: "y or after_ns(x)"),
            .or(lhs: .variable(name: .y), rhs: .after(statement: AfterStatement(amount: x, period: .ns)))
        )
        XCTAssertEqual(
            TransitionCondition(rawValue: "y and after_ns(x)"),
            .and(lhs: .variable(name: .y), rhs: .after(statement: AfterStatement(amount: x, period: .ns)))
        )
        XCTAssertEqual(
            TransitionCondition(rawValue: "y nand after_ns(x)"),
            .nand(lhs: .variable(name: .y), rhs: .after(statement: AfterStatement(amount: x, period: .ns)))
        )
        XCTAssertEqual(
            TransitionCondition(rawValue: "y nor after_ns(x)"),
            .nor(lhs: .variable(name: .y), rhs: .after(statement: AfterStatement(amount: x, period: .ns)))
        )
        XCTAssertEqual(
            TransitionCondition(rawValue: "y xor after_ns(x)"),
            .xor(lhs: .variable(name: .y), rhs: .after(statement: AfterStatement(amount: x, period: .ns)))
        )
        XCTAssertEqual(
            TransitionCondition(rawValue: "y xnor after_ns(x)"),
            .xnor(lhs: .variable(name: .y), rhs: .after(statement: AfterStatement(amount: x, period: .ns)))
        )
    }

}
