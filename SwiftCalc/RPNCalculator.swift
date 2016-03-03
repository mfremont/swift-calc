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
            evaluate: (Double, Double) throws -> Double)
        case UnaryOperation(symbol: String, associativity: Associativity,
            evaluate: (Double) throws -> Double)
        
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
    
    public enum EvaluationError : ErrorType {
        case DivideByZero
        case ComplexNumber
        
        /// - parameter symbol: the variable symbol that has no assigned value
        case VariableNotSet(symbol: String)
        
        /// - parameter symbol: the symbol of the operation that could not be evaluated due to missing operands
        case InsufficientOperandsForOperation(symbol: String)
    }

    // MARK: - Instance Properties
    
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
     Errors resulting from the most recent evaluation of the calculator stack. The errors are added to the
     array in the order in which they are encountered during evaluation.
     */
    public var evaluationErrors = [EvaluationError]()
    
    /**
     The count of operators and operands on the stack.
     */
    public var stackDepth: Int {
        return stack.count
    }
    
    /**
     The mapping of variable symbols to their respective values. Used to evaluate variables
     on the calculator stack.
     */
    public var variable = [String: Double]()

    // MARK: - Initialization
    
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
            evaluate: {
                guard $0 != 0 else { throw EvaluationError.DivideByZero }
                return $1 / $0 }))
        
        
        register(.UnaryOperation(symbol: Operator.SquareRoot, associativity: .Right,
            evaluate: {
                guard $0 >= 0 else { throw EvaluationError.ComplexNumber }
                return sqrt($0) }))
        
        register(.UnaryOperation(symbol: Operator.Sin, associativity: .Right,
            evaluate: sin))
        
        register(.UnaryOperation(symbol: Operator.Cos, associativity: .Right,
            evaluate: cos))
    }
    
    /**
     Initializes a new instance with a deep copy of the stack, variable dictionary, and registered operations
     of the specified instance. The `evaluationErrors` property is not copied.
     
     - parameter copyFrom: the instance to copy
     */
    public init(copyFrom calculator: RPNCalculator) {
        self.stack = calculator.stack
        self.operations = calculator.operations
        self.variable = calculator.variable
    }
    
    // MARK: - Stack operations
    
    /**
     Clears the stack.
     */
    public func clear() {
        stack.removeAll(keepCapacity: true)
        evaluationErrors.removeAll()
        variable.removeAll()
    }
    
    /**
     Pushes the value onto the stack.

     - returns: the result returned by `evaluate()` after the push
     */
    public func pushOperand(value: Double) -> Double? {
        stack.append(StackExpression.Value(value))
        return evaluate()
    }
    
    /**
     Pushs the variable identified by symbol onto the stack.
     
     - parameter symbol: the symbol to use for the variable
     
     - returns: the result returned by `evaluate()` after the push
     */
    public func pushOperand(symbol: String) -> Double? {
        stack.append(StackExpression.Variable(symbol: symbol))
        return evaluate()
    }
    
    /**
     Pushes the value onto the stack with a symbol as its description.
    
     - parameters:
        - value: the value
        - withSymbol: the symbol
     
     - returns: the result returned by `evaluate()` after the push
    */
    public func pushOperand(value: Double, withSymbol symbol: String) -> Double? {
        stack.append(StackExpression.SymbolicValue(symbol: symbol, value: value))
        return evaluate()
    }

    /**
     Pushes the operator onto the stack. Unknown operator symbols are ignored.

     - returns: the result returned by `evaluate()` after the push
     */
    public func pushOperator(operatorSymbol: String) -> Double? {
        if let operation = operations[operatorSymbol] {
            stack.append(operation)
        }
        return evaluate()
    }

    /**
     Removes the last (top-most) entry from the stack.
     */
    public func removeLast() {
        if !stack.isEmpty {
            stack.removeLast()
            // TODO clear evaluation errors?
        }
    }
    
    /**
     Evaluates the calculator stack. The `evaluationErrors` property is cleared and any errors that occur during
     evaluation are appended to the array.
     
     - returns: the result of evaluating top-most expression on the stack, 0 if the stack is empty, or `nil` if the stack cannot be evaluated.
    */
    public func evaluate() -> Double? {
        if stack.isEmpty {
            return 0
        } else {
            evaluationErrors.removeAll()
            do {
                let (result, _) = try evaluate(stack)
                return result
            } catch {
                if error is EvaluationError {
                    evaluationErrors.append(error as! EvaluationError)
                }
                return nil
            }
        }
    }
    
    /**
     Evaluates top-most expression on the stack. The stack is descended recursively until either sufficient
     operands have been evaluated for the expression or an error is encountered that prevents the expression
     from being evaluated.
     
     - returns: the result of the evaluation and the remaining stack, or `nil` if the stack is empty
     
     - throws: an error of type `ExpressionError`
    */
    private func evaluate(stack: [StackExpression]) throws -> (Double?, [StackExpression]) {
        if !stack.isEmpty {
            var remainingStack = stack
            let expression = remainingStack.removeLast()
            switch expression {
                case .SymbolicValue(_, let operand):
                    return (operand, remainingStack)
                
                case .Value(let operand):
                    return (operand, remainingStack)
                
                case .Variable(let symbol):
                    if let value = variable[symbol] {
                        return (value, remainingStack)
                    } else {
                        throw EvaluationError.VariableNotSet(symbol: symbol)
                    }
                
                case .BinaryOperation(let symbol, _, let operation):
                    let (operand0, remainingStack0) = try evaluate(remainingStack)
                    let (operand1, remainingStack1) = try evaluate(remainingStack0)
                    if operand0 != nil && operand1 != nil {
                        return try (operation(operand0!, operand1!), remainingStack1)
                    } else {
                        throw EvaluationError.InsufficientOperandsForOperation(symbol: symbol)
                    }
                
                case .UnaryOperation(let symbol, _, let operation):
                    let (operand0, remainingStack0) = try evaluate(remainingStack)
                    if operand0 != nil {
                        return try (operation(operand0!), remainingStack0)
                    } else {
                        throw EvaluationError.InsufficientOperandsForOperation(symbol: symbol)
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
                    var (operand0Description, operand0Associativity, remainingStack0) = describe(remainingStack)
                    if operand0Associativity == .Left {
                        operand0Description = withParens(operand0Description)
                    }
                    var (operand1Description, operand1Associativity, remainingStack1) = describe(remainingStack0)
                    if operand1Associativity == .Left {
                        operand1Description = withParens(operand1Description)
                    }
                    if remainingStack0.isEmpty {
                        // ensure description with missing operand is correct for division and subtraction
                        swap(&operand0Description, &operand1Description)
                    }
                    return ("\(operand1Description) \(opDescription) \(operand0Description)", associativity, remainingStack1)
                
                case .UnaryOperation(_, let associativity, _):
                    let opDescription = expression.description
                    let (operand0, _, remainingStack0) = describe(remainingStack)
                    return ("\(opDescription)(\(operand0))", associativity, remainingStack0)
            }
        }
        return (missingValue, .None, stack)
    }
}