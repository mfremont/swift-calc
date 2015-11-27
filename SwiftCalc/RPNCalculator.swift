//
//  RPNCalculator.swift
//  SwiftCalc
//
//  Created by Matthew Fremont on 6/7/15.
//  Copyright (c) 2015 Matthew Fremont. All rights reserved.
//

import Foundation

public class RPNCalculator {
    private enum Associativity {
        case None, Left, Right
    }
    
    private enum StackExpression: CustomStringConvertible {
        case SymbolicValue(symbol: String, value: Double)
        case Value(Double)
        case Variable(symbol: String)
        case BinaryOperation(symbol: String, associativity: Associativity,
            evaluate: (Double, Double) -> Double)
        case UnaryOperation(symbol: String, associativity: Associativity,
            evaluate: (Double) -> Double)
        
        var description: String {
            switch self {
                case .SymbolicValue(let symbol, _):
                    return symbol
                case .Value(let value):
                    return "\(value)"
                case .Variable(let symbol):
                    return symbol
                case .BinaryOperation(let symbol, _, _):
                    return symbol
                case .UnaryOperation(let symbol, _, _):
                    return symbol
            }
        }
    }
    
    private var stack = [StackExpression]()
    private var operations = [String:StackExpression]()
    
    public struct Operator {
        public static let Add = "+"
        public static let Subtract = "-"
        public static let Multiply = "×"
        public static let Divide = "÷"
        public static let SquareRoot = "√"
        public static let Sin = "sin"
        public static let Cos = "cos"
    }
    
    public init() {
        func register(operation: StackExpression) {
            operations[operation.description] = operation
        }
        
        register(.BinaryOperation(symbol: Operator.Add, associativity: .Left,
            evaluate: { $0 + $1 }))
        
        
        register(.BinaryOperation(symbol: Operator.Subtract, associativity: .Left,
            // top-most expression on stack is subtrahend
            evaluate: { $1 - $0 }))
            
        register(.BinaryOperation(symbol: Operator.Multiply, associativity: .Left,
            evaluate: { $0 * $1 }))
        
        register(.BinaryOperation(symbol: Operator.Divide, associativity: .Left,
            // top-most expression on stack is divisor
            evaluate: { $1 / $0 }))
        
        register(.UnaryOperation(symbol: Operator.SquareRoot, associativity: .Right,
            evaluate: { sqrt($0) }))
        
        register(.UnaryOperation(symbol: Operator.Sin, associativity: .Right,
            evaluate: sin))
        
        register(.UnaryOperation(symbol: Operator.Cos, associativity: .Right,
            evaluate: cos))
    }
    
    /**
     The number of operator and operands on the stack.
     */
    public var stackDepth: Int {
        return stack.count
    }
    
    /**
     The mapping of variable symbols to their respective values. Used to evaluate variables
     on the calculator stack.
     */
    public var variable = [String: Double]()

    
    /**
     A string representation of the stack using infix and functional notation. If there are too few
     operands on the stack for an operation, this is indicated with "?" as a placeholder. Multiple
     complete expressions on the stack are represented as a commma-separated list. Finally, an empty
     stack is represented by the empty string.
     */
    public var description: String {
        var descriptions = [String]()
        var expressionDescription: String
        var remainingStack = stack
        while (!remainingStack.isEmpty) {
            (expressionDescription, _, remainingStack) = describe(remainingStack)
            descriptions.append(expressionDescription)
        }
        return descriptions.reverse().joinWithSeparator(", ")
    }
    
    /**
     Clears the stack.
    */
    public func clear() {
        stack.removeAll(keepCapacity: true)
    }
    
    /**
    Pushes the value onto the stack.
    */
    public func pushOperand(value: Double) -> Double? {
        stack.append(StackExpression.Value(value))
        return evaluate()
    }
    
    /**
     Pushs the variable identified by symbol onto the stack.
     
     :symbol: the symbol for the variable
     
     - returns: the valuation of the stack after the push
     */
    public func pushOperand(symbol: String) -> Double? {
        stack.append(StackExpression.Variable(symbol: symbol))
        return evaluate()
    }
    
    /**
    Pushes the value onto the stack with a symbol as its description.
    
    :value: the value
    :withSymbol: the symbol
    */
    public func pushOperand(value: Double, withSymbol symbol: String) -> Double? {
        stack.append(StackExpression.SymbolicValue(symbol: symbol, value: value))
        return evaluate()
    }

    /**
     Pushes the operator onto the stack. Unknown operator symbols are ignored.
     */
    public func pushOperator(operatorSymbol: String) -> Double? {
        if let operation = operations[operatorSymbol] {
            stack.append(operation)
        }
        return evaluate()
    }

    /**
     Evaluates the stack.
     
     - returns: the result of evaluating the stack, 0 if the stack is empty, or `nil` if the stack cannot be evaluated.
    */
    public func evaluate() -> Double? {
        if stack.isEmpty {
            return 0
        } else {
            let (result, _) = evaluate(stack)
            return result
        }
    }
    
    private func evaluate(stack: [StackExpression]) -> (Double?, [StackExpression]) {
        if !stack.isEmpty {
            var remainingStack = stack
            let expression = remainingStack.removeLast()
            switch expression {
                case .SymbolicValue(_, let operand):
                    return (operand, remainingStack)
                
                case .Value(let operand):
                    return (operand, remainingStack)
                
                case .Variable(let symbol):
                    return (variable[symbol], remainingStack)
                
                case .BinaryOperation(_, _, let operation):
                    let (operand0, remainingStack0) = evaluate(remainingStack)
                    if operand0 != nil {
                        let (operand1, remainingStack1) = evaluate(remainingStack0)
                        if operand1 != nil {
                            return (operation(operand0!, operand1!), remainingStack1)
                        }
                    }
                
                case .UnaryOperation(_, _, let operation):
                    let (operand0, remainingStack0) = evaluate(remainingStack)
                    if operand0 != nil {
                        return (operation(operand0!), remainingStack0)
                    }
            }
        }
        return (nil, stack)
    }
    
    /**
     Builds a description of the expressions on the stack. If the stack is empty, "?" is returned for
     the description.
     
     - returns: the description, the associativity of the expression, and the remaining items on the stack
     */
    private func describe(stack: [StackExpression]) -> (String, Associativity, [StackExpression]) {
        let missingValue = "?"
        func withParens(s: String) -> String {
            return "(" + s + ")"
        }
        if !stack.isEmpty {
            var remainingStack = stack
            let expression = remainingStack.removeLast()
            switch expression {
                case .SymbolicValue:
                    return (expression.description, .None, remainingStack)
                    
                case .Value:
                    return (expression.description, .None, remainingStack)
                    
                case .Variable:
                    return (expression.description, .None, remainingStack)
                    
                case .BinaryOperation(_, let associativity, _):
                    let opDescription = expression.description
                    var (rhsDescription, rhsAssociativity, rhsRemainingStack) = describe(remainingStack)
                    if rhsAssociativity == .Left {
                        rhsDescription = withParens(rhsDescription)
                    }
                    var (lhsDescription, lhsAssociativity, lhsRemainingStack) = describe(rhsRemainingStack)
                    if lhsAssociativity == .Left {
                        lhsDescription = withParens(lhsDescription)
                    }
                    return ("\(lhsDescription) \(opDescription) \(rhsDescription)", associativity, lhsRemainingStack)
                
                case .UnaryOperation(_, let associativity, _):
                    let opDescription = expression.description
                    let (operand0, _, remainingStack0) = describe(remainingStack)
                    return ("\(opDescription)(\(operand0))", associativity, remainingStack0)
            }
        }
        return (missingValue, .None, stack)
    }
}