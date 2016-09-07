//: Example that demonstrates use of class from workspace

let calculator = RPNCalculator()

calculator.pushOperand(1.11)
calculator.pushOperand(0.1)
calculator.pushOperator(RPNCalculator.Operator.Multiply)
calculator.description
