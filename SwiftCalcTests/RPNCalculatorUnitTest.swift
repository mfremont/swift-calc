//
//  RPNCalculatorUnitTest.swift
//  
//
//  Created by Matthew Fremont on 11/21/15.
//
//

import XCTest
import Nimble

import SwiftCalc

protocol CalculatorExpression: CustomStringConvertible {
    /**
     Push the expression onto the calculator.
     
     - returns: the value returned by the calculator
     */
    func push(calculator: RPNCalculator) -> Double?
}

func describe(input: [CalculatorExpression]) -> String {
    return (input.map { $0.description }).joinWithSeparator("⏎ ")
}

class RPNCalculatorUnitTest: XCTestCase {
    struct Operand: CalculatorExpression {
        let value: Double
        
        init(_ value: Double) {
            self.value = value
        }
        
        func push(calculator: RPNCalculator) -> Double? {
            return calculator.pushOperand(value)
        }
        
        var description: String {
            return String(value)
        }
    }
 
    struct SymbolicOperand: CalculatorExpression {
        let value: Double
        let symbol: String
        
        init(_ value: Double, withSymbol symbol: String) {
            self.value = value
            self.symbol = symbol
        }
        
        func push(calculator: RPNCalculator) -> Double? {
            return calculator.pushOperand(value, withSymbol: symbol)
        }
        
        var description: String {
            return symbol
        }
    }

    struct Operator: CalculatorExpression {
        let symbol: String
        
        init(_ symbol: String) {
            self.symbol = symbol
        }
        
        func push(calculator: RPNCalculator) -> Double? {
            return calculator.pushOperator(symbol)
        }
        
        var description: String {
            return symbol
        }
    }
    
    struct Variable: CalculatorExpression {
        let symbol: String
        
        init(_ symbol: String) {
            self.symbol = symbol
        }
        
        func push(calculator: RPNCalculator) -> Double? {
            return calculator.pushOperand(symbol)
        }
        
        var description: String {
            return symbol
        }
    }
    
    let Add = Operator(RPNCalculator.Operator.Add)
    let Subtract = Operator(RPNCalculator.Operator.Subtract)
    let Divide = Operator(RPNCalculator.Operator.Divide)
    let Multiply = Operator(RPNCalculator.Operator.Multiply)
    let SquareRoot = Operator(RPNCalculator.Operator.SquareRoot)
    let Cos = Operator(RPNCalculator.Operator.Cos)
    let Sin = Operator(RPNCalculator.Operator.Sin)
    let Pi = SymbolicOperand(M_PI, withSymbol: "π")
    
    /**
     Pushes the input onto the calculator stack.
     
     - paramters:
        - calculator: the calculator instance
        - withInput: the input expressions
     
     - returns: result returned by calculator for each input
     */
    func given(calculator: RPNCalculator, withInput input:[CalculatorExpression]) -> [Double?] {
        return input.map { $0.push(calculator) }
    }

    /**
     Matches the error `VariableNotSet(symbol: expectedSymbol)`.
     */
    func beErrorIsVariableNotSet(expectedSymbol: String) -> MatcherFunc<RPNCalculator.EvaluationError> {
        return MatcherFunc { expression, message in
            message.postfixMessage = "be VariableNotSet(symbol: \(expectedSymbol))"
            if let actual = try expression.evaluate(),
                case let .VariableNotSet(actualSymbol) = actual {
                    return expectedSymbol == actualSymbol
            }
            return false
        }
    }

    /**
     Matches the error `InsufficientOperandsForOperation(symbol: expectedSymbol)`.
     */
    func beErrorIsInsufficientOperandsForOperation(expectedSymbol: String) -> MatcherFunc<RPNCalculator.EvaluationError> {
        return MatcherFunc { expression, message in
            message.postfixMessage = "be InsufficientOperandsForOperation(symbol: \(expectedSymbol))"
            if let actual = try expression.evaluate(),
                case let .InsufficientOperandsForOperation(actualSymbol) = actual {
                    return expectedSymbol == actualSymbol
            }
            return false
        }
    }

    /**
     Matches the error `DivideByZero`.
     */
    func beErrorIsDivideByZero() -> MatcherFunc<RPNCalculator.EvaluationError> {
        return MatcherFunc { expression, message in
            message.postfixMessage = "be DivideByZero()"
            let actual = try expression.evaluate()!
            switch actual {
                case .DivideByZero:
                    return true
                default:
                    return false
            }
        }
    }

    /**
     Matches the error `ComplexNumber`.
     */
    func beErrorIsComplexNumber() -> MatcherFunc<RPNCalculator.EvaluationError> {
        return MatcherFunc { expression, message in
            message.postfixMessage = "be ComplexNumber()"
            let actual = try expression.evaluate()!
            switch actual {
            case .ComplexNumber:
                return true
            default:
                return false
            }
        }
    }

    func testInitialEmptyStack() {
        let calculator = RPNCalculator()
        
        expect(calculator.evaluate()) == 0
        expect(calculator.evaluationErrors).to(beEmpty())
        expect(calculator.description) == ""
    }
    
    func testClear() {
        let calculator = RPNCalculator()
        given(calculator, withInput: [Operand(1.1), Operand(5)])
        let variableSymbol = "x"
        let variableValue = 9.6
        calculator.variable[variableSymbol] = variableValue
        
        calculator.clear()

        expect(calculator.stackDepth) == 0
        expect(calculator.evaluate()) == 0
        expect(calculator.description) == ""
        expect(calculator.variable[variableSymbol]).to(beNil())
    }

    // TODO: verify that clear() clears errors
    
    func testRemoveLast() {
        let calculator = RPNCalculator()
        given(calculator, withInput: [Operand(1.1), Operand(5)])
        
        calculator.removeLast()
        
        expect(calculator.stackDepth) == 1
        expect(calculator.evaluate()).to(beCloseTo(1.1, within: 1e-10))
        expect(calculator.description) == "1.1"
    }

    func testRemoveLastOneOperand() {
        let calculator = RPNCalculator()
        given(calculator, withInput: [Operand(1.1)])
        
        calculator.removeLast()
        
        expect(calculator.stackDepth) == 0
        expect(calculator.evaluate()) == 0
        expect(calculator.evaluationErrors).to(beEmpty())
        expect(calculator.description) == ""
    }
    
    func testRemoveLastEmptyStack() {
        let calculator = RPNCalculator()
        
        calculator.removeLast()
        
        expect(calculator.stackDepth) == 0
        expect(calculator.evaluate()) == 0
        expect(calculator.evaluationErrors).to(beEmpty())
        expect(calculator.description) == ""
    }
    
    func testPushOperandValue() {
        let calculator = RPNCalculator()

        let operand = 2.71828
        let result = calculator.pushOperand(operand)
        
        expect(result!) == operand
        expect(calculator.evaluate()) == operand
        expect(calculator.evaluationErrors).to(beEmpty())
        expect(calculator.description) == String(operand)
    }
    
    func testPushOperandSymbolicValue() {
        let calculator = RPNCalculator()
        
        let operand = M_PI
        let operandSymbol = "π"
        let result = calculator.pushOperand(operand, withSymbol: operandSymbol)
        
        expect(result!) == operand
        expect(calculator.evaluate()) == operand
        expect(calculator.evaluationErrors).to(beEmpty())
        expect(calculator.description) == operandSymbol
    }
    
    func testPushOperandVariableNoValue() {
        let calculator = RPNCalculator()

        let variableSymbol = "𝜙"
        let result = calculator.pushOperand(variableSymbol)
        
        expect(result).to(beNil())
        expect(calculator.evaluate()).to(beNil())
        expect(calculator.evaluationErrors[0]).to(beErrorIsVariableNotSet(variableSymbol))
        expect(calculator.description) == variableSymbol
    }
    
    func testPushOperandVariableWithValue() {
        let calculator = RPNCalculator()
        
        let variableSymbol = "𝜙"
        let variableValue = M_PI_4
        let result0 = calculator.pushOperand(variableSymbol)
        calculator.variable[variableSymbol] = variableValue
        
        expect(result0).to(beNil())
        expect(calculator.evaluate()) == variableValue
        expect(calculator.evaluationErrors).to(beEmpty())
        expect(calculator.description) == variableSymbol
    }

    
    func testPushOperandVariablePreAssignValue() {
        let calculator = RPNCalculator()
        
        let variableSymbol = "x"
        let variableValue = sqrt(2.0)
        calculator.variable[variableSymbol] = variableValue
        let result = calculator.pushOperand(variableSymbol)
        
        expect(result) == variableValue
        expect(calculator.evaluate()) == variableValue
        expect(calculator.evaluationErrors).to(beEmpty())
        expect(calculator.description) == variableSymbol
    }

    func testAddition() {
        let calculator = RPNCalculator()
        
        let pushResult = given(calculator, withInput: [Operand(2), Operand(3), Add])
        let expected = 5.0
        // result returned by pushing operator
        expect(pushResult.last!) == expected
        // is the same as result of evaluate()
        expect(calculator.evaluate()) == expected
        expect(calculator.evaluationErrors).to(beEmpty())
        expect(calculator.description) == "2.0 + 3.0"
        
        calculator.clear()
        given(calculator, withInput: [Operand(2), Operand(-3), Add])
        expect(calculator.evaluate()) == -1.0
        expect(calculator.evaluationErrors).to(beEmpty())
        expect(calculator.description) == "2.0 + -3.0"
        
        calculator.clear()
        given(calculator, withInput: [Operand(1.1), Operand(0.1), Add])
        // result is sum of two binary appoximations
        expect(calculator.evaluate()).to(beCloseTo(1.2, within: 1e-10))
        expect(calculator.evaluationErrors).to(beEmpty())
        expect(calculator.description) == "1.1 + 0.1"
        
        calculator.clear()
        given(calculator, withInput: [Operand(969.99), Add])
        expect(calculator.evaluate()).to(beNil())
        expect(calculator.evaluationErrors[0]).to(beErrorIsInsufficientOperandsForOperation("+"))
        expect(calculator.description) == "? + 969.99"
    }
    
    func testSubtraction() {
        let calculator = RPNCalculator()
        
        given(calculator, withInput: [Operand(3), Operand(2), Subtract])
        expect(calculator.evaluate()) == 1.0
        expect(calculator.evaluationErrors).to(beEmpty())
        expect(calculator.description) == "3.0 - 2.0"
        
        calculator.clear()
        given(calculator, withInput: [Operand(2), Operand(3), Subtract])
        expect(calculator.evaluate()) == -1.0
        expect(calculator.evaluationErrors).to(beEmpty())
        expect(calculator.description) == "2.0 - 3.0"
        
        calculator.clear()
        given(calculator, withInput: [Operand(2), Operand(-3), Subtract])
        expect(calculator.evaluate()) == 5.0
        expect(calculator.evaluationErrors).to(beEmpty())
        expect(calculator.description) == "2.0 - -3.0"
     
        calculator.clear()
        given(calculator, withInput: [Operand(1.2), Operand(0.1), Subtract])
        // result is a binary approximation
        expect(calculator.evaluate()).to(beCloseTo(1.1, within: 1e-10))
        expect(calculator.evaluationErrors).to(beEmpty())
        expect(calculator.description) == "1.2 - 0.1"
        
        calculator.clear()
        given(calculator, withInput: [Operand(969.99), Subtract])
        expect(calculator.evaluate()).to(beNil())
        expect(calculator.evaluationErrors[0]).to(beErrorIsInsufficientOperandsForOperation("-"))
        expect(calculator.description) == "? - 969.99"
    }
    
    func testDivision() {
        let calculator = RPNCalculator()
        
        given(calculator, withInput: [Operand(3), Operand(2), Divide])
        expect(calculator.evaluate()) == 1.5
        expect(calculator.evaluationErrors).to(beEmpty())
        expect(calculator.description) == "3.0 ÷ 2.0"
        
        calculator.clear()
        given(calculator, withInput: [Operand(6), Operand(-2), Divide])
        expect(calculator.evaluate()) == -3.0
        expect(calculator.evaluationErrors).to(beEmpty())
        expect(calculator.description) == "6.0 ÷ -2.0"

        calculator.clear()
        given(calculator, withInput: [Operand(0.111), Divide])
        expect(calculator.evaluate()).to(beNil())
        expect(calculator.evaluationErrors[0]).to(beErrorIsInsufficientOperandsForOperation("÷"))
        expect(calculator.description) == "? ÷ 0.111"
    }
    
    func testDivisionByZero() {
        let calculator = RPNCalculator()

        given(calculator, withInput: [Operand(3), Operand(0), Divide])
        expect(calculator.evaluate()).to(beNil())
        expect(calculator.evaluationErrors[0]).to(beErrorIsDivideByZero())
        expect(calculator.description) == "3.0 ÷ 0.0"
    }
    
    func testMultiplication() {
        let calculator = RPNCalculator()
        
        given(calculator, withInput: [Operand(8), Operand(7), Multiply])
        expect(calculator.evaluate()) == 56
        expect(calculator.evaluationErrors).to(beEmpty())
        expect(calculator.description) == "8.0 × 7.0"

        calculator.clear()
        given(calculator, withInput: [Operand(-0.3), Operand(7), Multiply])
        expect(calculator.evaluate()) == -2.1
        expect(calculator.evaluationErrors).to(beEmpty())
        expect(calculator.description) == "-0.3 × 7.0"
        
        calculator.clear()
        given(calculator, withInput: [Operand(0.111), Multiply])
        expect(calculator.evaluate()).to(beNil())
        expect(calculator.evaluationErrors[0]).to(beErrorIsInsufficientOperandsForOperation("×"))
        expect(calculator.description) == "? × 0.111"
    }
    
    func testSquareRoot() {
        let calculator = RPNCalculator()
        
        given(calculator, withInput: [Operand(4), SquareRoot])
        expect(calculator.evaluate()) == 2.0
        expect(calculator.evaluationErrors).to(beEmpty())
        expect(calculator.description) == "√(4.0)"

        calculator.clear()
        given(calculator, withInput: [Operand(2.2), SquareRoot])
        expect(calculator.evaluate()) == sqrt(2.2)
        expect(calculator.evaluationErrors).to(beEmpty())
        expect(calculator.description) == "√(2.2)"
        
        calculator.clear()
        given(calculator, withInput: [SquareRoot])
        expect(calculator.evaluate()).to(beNil())
        expect(calculator.evaluationErrors[0]).to(beErrorIsInsufficientOperandsForOperation("√"))
        expect(calculator.description) == "√(?)"
    }

    func testSquareRootNegativeValue() {
        let calculator = RPNCalculator()

        given(calculator, withInput: [Operand(-3.3), SquareRoot])
        expect(calculator.evaluate()).to(beNil())
        expect(calculator.evaluationErrors[0]).to(beErrorIsComplexNumber())
        expect(calculator.description) == "√(-3.3)"
    }
    
    func testSin() {
        let calculator = RPNCalculator()

        given(calculator, withInput: [Operand(M_PI_2), Sin])
        expect(calculator.evaluate()) == 1.0
        expect(calculator.evaluationErrors).to(beEmpty())
        expect(calculator.description) == "sin(\(M_PI_2))"
        
        calculator.clear()
        given(calculator, withInput: [Operand(-M_PI_2), Sin])
        expect(calculator.evaluate()) == -1.0
        expect(calculator.evaluationErrors).to(beEmpty())
        expect(calculator.description) == "sin(-\(M_PI_2))"

        calculator.clear()
        given(calculator, withInput: [Operand(0), Sin])
        expect(calculator.evaluate()) == 0.0
        expect(calculator.evaluationErrors).to(beEmpty())
        expect(calculator.description) == "sin(0.0)"
        
        calculator.clear()
        given(calculator, withInput: [Sin])
        expect(calculator.evaluate()).to(beNil())
        expect(calculator.evaluationErrors[0]).to(beErrorIsInsufficientOperandsForOperation("sin"))
        expect(calculator.description) == "sin(?)"
    }
    
    func testCos() {
        let calculator = RPNCalculator()

        given(calculator, withInput: [Operand(M_PI_2), Cos])
        expect(calculator.evaluate()).to(beCloseTo(0.0, within: 1e-10))
        expect(calculator.evaluationErrors).to(beEmpty())
        expect(calculator.description) == "cos(\(M_PI_2))"
        
        calculator.clear()
        given(calculator, withInput: [Operand(-M_PI_2), Cos])
        expect(calculator.evaluate()).to(beCloseTo(0.0, within: 1e-10))
        expect(calculator.evaluationErrors).to(beEmpty())
        expect(calculator.description) == "cos(-\(M_PI_2))"
        
        calculator.clear()
        given(calculator, withInput: [Operand(0), Cos])
        expect(calculator.evaluate()) == 1.0
        expect(calculator.evaluationErrors).to(beEmpty())
        expect(calculator.description) == "cos(0.0)"
        
        calculator.clear()
        given(calculator, withInput: [Cos])
        expect(calculator.evaluate()).to(beNil())
        expect(calculator.evaluationErrors[0]).to(beErrorIsInsufficientOperandsForOperation("cos"))
        expect(calculator.description) == "cos(?)"
    }

    func testSymbolicOperand() {
        let calculator = RPNCalculator()

        given(calculator, withInput: [Operand(2), Pi, Multiply])
        expect(calculator.evaluate()) == M_PI * 2
        expect(calculator.evaluationErrors).to(beEmpty())
        expect(calculator.description) == "2.0 × π"
    }
    
    func testVariableNotSetInExpression() {
        let calculator = RPNCalculator()
       
        let variableSymbol = "x"
        given(calculator, withInput: [Operand(2), Variable("x"), Add])
        expect(calculator.evaluate()).to(beNil())
        expect(calculator.evaluationErrors[0]).to(beErrorIsVariableNotSet(variableSymbol))
        expect(calculator.description) == "2.0 + \(variableSymbol)"
    }
    
    func testVariable() {
        let calculator = RPNCalculator()

        given(calculator, withInput: [Operand(2), Variable("x"), Multiply])
        calculator.variable["x"] = 1.707
        expect(calculator.evaluate()) == 3.414
        expect(calculator.description) == "2.0 × x"
    }
    
    func testDescriptionMultipleExpressions() {
        let calculator = RPNCalculator()

        given(calculator, withInput: [Operand(3), Operand(5), Add, Pi, Cos])
        expect(calculator.evaluate()) == -1
        expect(calculator.evaluationErrors).to(beEmpty())
        expect(calculator.description) == "3.0 + 5.0, cos(π)"
    }
    
    func testDescriptionNoGroupingUnaryOperation() {
        let calculator = RPNCalculator()
        
        given(calculator, withInput: [Operand(0.02), Operand(0.02), Add, SquareRoot])
        expect(calculator.evaluate()) == 0.2
        expect(calculator.evaluationErrors).to(beEmpty())
        expect(calculator.description) == "√(0.02 + 0.02)"
    }

    func testDescriptionGroupingUnaryOperation() {
        let calculator = RPNCalculator()
        
        given(calculator, withInput: [Operand(3), Operand(5), Operand(1), Add, Add, SquareRoot])
        expect(calculator.evaluate()) == 3
        expect(calculator.evaluationErrors).to(beEmpty())
        expect(calculator.description) == "√(3.0 + (5.0 + 1.0))"
    }

    func testDescriptionGroupingAddition() {
        let calculator = RPNCalculator()
        
        given(calculator, withInput: [Operand(3), Operand(5), Operand(4), Add, Add])
        expect(calculator.evaluate()) == 12
        expect(calculator.evaluationErrors).to(beEmpty())
        // addition with binary floating point numbers is not associative when operands differ greatly
        // in magnitude: 
        //   (0.1 + 0.1e-13) + 0.1e-13 != 0.1 + (0.1e-13 + 0.1e-13)
        //   (1e7 + 1e-7) + 1e-7 != 1e7 + (1e-7 + 1e-7)
        expect(calculator.description) == "3.0 + (5.0 + 4.0)"
    }
    
    func testDescriptionGroupingSubtraction() {
        let calculator = RPNCalculator()
        
        given(calculator, withInput: [Operand(3), Operand(5), Operand(4), Subtract, Subtract])
        expect(calculator.evaluate()) == 2
        expect(calculator.evaluationErrors).to(beEmpty())
        expect(calculator.description) == "3.0 - (5.0 - 4.0)"
    }
  
    func testDescriptionGroupingMultiplication() {
        let calculator = RPNCalculator()
        
        given(calculator, withInput: [Operand(3), Operand(5), Operand(4), Multiply, Multiply])
        expect(calculator.evaluate()) == 60
        expect(calculator.evaluationErrors).to(beEmpty())
        // multiplication with binary floating point numbers is not associative when operands differ greatly
        // in magnitude:
        //    (1e7 * 1e-7) * 1e-7 != 1e7 * (1e-7 * 1e-7)
        //    (1.1 * 1.1e-16) * 0.1e-16 != 1.1 * (1.1e-16 * 0.1e-16)
        expect(calculator.description) == "3.0 × (5.0 × 4.0)"
    }

    
    func testDescriptionGroupingDivision() {
        let calculator = RPNCalculator()
        
        given(calculator, withInput: [Operand(3), Operand(5), Operand(4), Divide, Divide])
        expect(calculator.evaluate()) == 3.0 / (5.0 / 4.0)
        expect(calculator.evaluationErrors).to(beEmpty())
        expect(calculator.description) == "3.0 ÷ (5.0 ÷ 4.0)"
    }

    func testDescriptionGroupRhs() {
        let calculator = RPNCalculator()
        
        given(calculator, withInput: [Operand(3), Operand(5), Operand(4), Add, Subtract])
        expect(calculator.evaluate()) == -6
        expect(calculator.evaluationErrors).to(beEmpty())
        expect(calculator.description) == "3.0 - (5.0 + 4.0)"
    }

    func testDescriptionGroupLhs() {
        let calculator = RPNCalculator()
        
        given(calculator, withInput: [Operand(3), Operand(5), Add, Operand(4), Subtract])
        expect(calculator.evaluate()) == 4
        expect(calculator.evaluationErrors).to(beEmpty())
        expect(calculator.description) == "(3.0 + 5.0) - 4.0"
    }

    func testDescriptionMixedPrecedence() {
        let calculator = RPNCalculator()
    
        given(calculator, withInput: [Operand(3), Operand(5), Operand(4), Add, Multiply])
        expect(calculator.evaluate()) == 27
        expect(calculator.evaluationErrors).to(beEmpty())
        expect(calculator.description) == "3.0 × (5.0 + 4.0)"
    }
}
