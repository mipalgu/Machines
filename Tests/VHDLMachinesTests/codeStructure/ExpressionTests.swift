// ExpressionTests.swift
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
import XCTest

/// Test class for ``Expression``.
final class ExpressionTests: XCTestCase {

    /// Test raw values are correct.
    func testRawValues() {
        XCTAssertEqual(Expression.variable(name: "a").rawValue, "a")
        XCTAssertEqual(
            Expression.addition(lhs: .variable(name: "a"), rhs: .variable(name: "b")).rawValue, "a + b"
        )
        XCTAssertEqual(
            Expression.subtraction(lhs: .variable(name: "a"), rhs: .variable(name: "b")).rawValue, "a - b"
        )
        XCTAssertEqual(
            Expression.multiplication(lhs: .variable(name: "a"), rhs: .variable(name: "b")).rawValue, "a * b"
        )
        XCTAssertEqual(
            Expression.division(lhs: .variable(name: "a"), rhs: .variable(name: "b")).rawValue, "a / b"
        )
        XCTAssertEqual(Expression.precedence(value: .variable(name: "a")).rawValue, "(a)")
        XCTAssertEqual(Expression.comment(comment: "a").rawValue, "-- a")
        XCTAssertEqual(
            Expression.expressionWithComment(expression: .variable(name: "a"), comment: "b").rawValue,
            "a; -- b"
        )
    }

    /// Test init successfully creates `Expression` for simple statements.
    func testSimpleInit() {
        XCTAssertEqual(Expression(rawValue: "-- a"), .comment(comment: "a"))
        XCTAssertEqual(Expression(rawValue: "a"), .variable(name: "a"))
        XCTAssertEqual(Expression(rawValue: "a;"), .variable(name: "a"))
        XCTAssertEqual(
            Expression(rawValue: "a; -- b"),
            .expressionWithComment(expression: .variable(name: "a"), comment: "b")
        )
        XCTAssertEqual(Expression(rawValue: "(a)"), .precedence(value: .variable(name: "a")))
        XCTAssertEqual(
            Expression(rawValue: "a * b"),
            .multiplication(lhs: .variable(name: "a"), rhs: .variable(name: "b"))
        )
        XCTAssertEqual(
            Expression(rawValue: "a / b"),
            .division(lhs: .variable(name: "a"), rhs: .variable(name: "b"))
        )
        XCTAssertEqual(
            Expression(rawValue: "a + b"),
            .addition(lhs: .variable(name: "a"), rhs: .variable(name: "b"))
        )
        XCTAssertEqual(
            Expression(rawValue: "a - b"),
            .subtraction(lhs: .variable(name: "a"), rhs: .variable(name: "b"))
        )
    }

    /// Test init works for statement with multiple sub expressions.
    func testMultipleInit() {
        let raw = "(a - b) + c"
        let expected = Expression.addition(
            lhs: .precedence(
                value: .subtraction(lhs: .variable(name: "a"), rhs: .variable(name: "b"))
            ),
            rhs: .variable(name: "c")
        )
        let result = Expression(rawValue: raw)
        XCTAssertEqual(result, expected)
    }

    /// Test init works for statement with multiple sub expressions in different order.
    func testMultipleInit2() {
        let raw = "a * (b - c)"
        let expected = Expression.multiplication(
            lhs: .variable(name: "a"),
            rhs: .precedence(
                value: .subtraction(lhs: .variable(name: "b"), rhs: .variable(name: "c"))
            )
        )
        let result = Expression(rawValue: raw)
        XCTAssertEqual(result, expected)
    }

    /// Test complex expression is created correctly.
    func testComplexInit() {
        let raw = "(a - b) + c * d / e; -- a nice comment!"
        let expected = Expression.expressionWithComment(
            expression: .multiplication(
                lhs: .addition(
                    lhs: .precedence(
                        value: .subtraction(
                            lhs: .variable(name: "a"),
                            rhs: .variable(name: "b")
                        )
                    ),
                    rhs: .variable(name: "c")
                ),
                rhs: .division(lhs: .variable(name: "d"), rhs: .variable(name: "e"))
            ),
            comment: "a nice comment!"
        )
        let result = Expression(rawValue: raw)
        XCTAssertEqual(result, expected)
    }

    /// Test another complex expression is created correctly.
    func testComplexInit2() {
        let raw = "a + b * (c + d) / e; -- a nice comment!"
        let expected = Expression.expressionWithComment(
            expression: .multiplication(
                lhs: .addition(
                    lhs: .variable(name: "a"),
                    rhs: .variable(name: "b")
                ),
                rhs: .division(
                    lhs: .precedence(
                        value: .addition(
                            lhs: .variable(name: "c"),
                            rhs: .variable(name: "d")
                        )
                    ),
                    rhs: .variable(name: "e")
                )
            ),
            comment: "a nice comment!"
        )
        let result = Expression(rawValue: raw)
        XCTAssertEqual(result, expected)
    }

    /// Test another complex raw value.
    func testComplexInit3() {
        let raw = "a + b * c + d / e; -- a nice comment!"
        let expected = Expression.expressionWithComment(
            expression: .multiplication(
                lhs: .addition(
                    lhs: .variable(name: "a"),
                    rhs: .variable(name: "b")
                ),
                rhs: .addition(
                    lhs: .variable(name: "c"),
                    rhs: .division(lhs: .variable(name: "d"), rhs: .variable(name: "e"))
                )
            ),
            comment: "a nice comment!"
        )
        let result = Expression(rawValue: raw)
        XCTAssertEqual(result, expected)
    }

    /// Test raw value works for complex expression.
    func testComplexRawValue() {
        let expected = "a + b * c + d / e; -- a nice comment!"
        let expression = Expression.expressionWithComment(
            expression: .multiplication(
                lhs: .addition(
                    lhs: .variable(name: "a"),
                    rhs: .variable(name: "b")
                ),
                rhs: .addition(
                    lhs: .variable(name: "c"),
                    rhs: .division(lhs: .variable(name: "d"), rhs: .variable(name: "e"))
                )
            ),
            comment: "a nice comment!"
        )
        XCTAssertEqual(expected, expression.rawValue)
    }

}
