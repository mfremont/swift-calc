//
//  CalculatorControllerSpec.swift
//  SwiftCalc
//
//  Created by Matthew Fremont on 6/30/15.
//  Copyright (c) 2015 Matthew Fremont. All rights reserved.
//

import Foundation
import UIKit
import Quick
import Nimble

@testable import SwiftCalc

class CalculatorControllerSpec: QuickSpec {
    override func spec() {
        let displayPlaceholderText = " "
        var controller: CalculatorController!
        var display: UILabel!
        var programDisplay: UILabel!
        
        beforeEach {
            let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            controller = storyboard.instantiateViewControllerWithIdentifier("CalculatorControllerID") as! CalculatorController
            // trigger view initialization
            let rootView = controller.view
            display = rootView.viewWithTag(1) as! UILabel
            programDisplay = rootView.viewWithTag(2) as! UILabel
        }
        
        context("given no operand") {
            context("when decimal point is pressed") {
                it("makes operand a decimal fraction") {
                    let expected = "0."
                    
                    controller.decimalPointPressed()
                    
                    expect(controller.operandInput) == expected
                    expect(display.text) == expected
                }
            }
            context("when sign is toggled") {
                it("makes operand negative") {
                    controller.toggleSignPressed()
                    expect(controller.operandInput) == "-"
                    
                    inputOperandDigit(controller, digit: "999")
                    
                    expect(controller.operandInput) == "-999"
                    expect(display.text) == "-999"
                }
            }
        }
        
        context("given operand 1") {
            let initialOperand = "1"
            beforeEach {
                inputOperandDigit(controller, digit: "1")
            }
            
            context("when decimal point is pressed") {
                it("makes operand a decimal fraction") {
                    let expected = initialOperand + "."
                    
                    controller.decimalPointPressed()
                    
                    expect(controller.operandInput) == expected
                    expect(display.text) == expected
                }
            }
            context("when operand sign is toggled") {
                it("makes operand negative") {
                    let expected = "-" + initialOperand
                    
                    controller.toggleSignPressed()
                    
                    expect(controller.operandInput) == expected
                    expect(display.text) == expected
                }
            }
            context("when multiplication operation is pressed") {
                it("error message is displayed and the input operand is consumed") {
                    inputOperation(controller, operation: RPNCalculator.Operator.Multiply)
                    
                    let expectedErrorMessage = String(format: NSLocalizedString("ErrorInsufficientOperands", comment: ""), RPNCalculator.Operator.Multiply)
                    expect(display.text) == expectedErrorMessage
                    expect(display.backgroundColor) == controller.errorBackgroundColor
                    expect(controller.operandInput) == ""
                    expect(programDisplay.text) == "1.0 × ? ="
                }
            }
        }
        
        context("given operand 1.1") {
            let initialOperand = "1.1"
            beforeEach {
                inputOperandDigit(controller, digit: "1")
                controller.decimalPointPressed()
                inputOperandDigit(controller, digit: "1")
            }
            context("when decimal point is pressed") {
                it("the operand is not changed") {
                    controller.decimalPointPressed()
                    
                    expect(controller.operandInput) == initialOperand
                    expect(display.text) == initialOperand
                }
            }
            context("when operand sign is toggled") {
                it("makes operand negative") {
                    let expected = "-" + initialOperand
                    controller.toggleSignPressed()
                    
                    expect(controller.operandInput) == expected
                    expect(display.text) == expected
                }
            }
            context("when π is pressed") {
                it("the current input and the symbol are pushed onto the stack") {
                    let symbol = "π"
                    let button = UIButton()
                    button.setTitle(symbol, forState: UIControlState.Normal)
                    controller.constantPressed(button)
                    
                    expect(controller.operandInput).to(beEmpty())
                    expect(display.text) == String(M_PI)
                    expect(programDisplay.text) == "\(initialOperand), \(symbol) ="
                }
            }
        }
        
        context("given operand -0.111") {
            let initialOperand = "-0.111"
            beforeEach {
                inputOperand(controller, fromString: initialOperand)
            }
            context("when operand sign is toggled") {
                it("makes operand positive") {
                    let expected = String(doubleValue(initialOperand)! * -1)
                    
                    controller.toggleSignPressed()
                    
                    expect(controller.operandInput) == expected
                    expect(display.text) == expected
                }
            }
            context("when multiplied by 2") {
                let expectedDisplayText = "-0.222"
                it("displays \(expectedDisplayText)") {
                    controller.enterPressed()
                    inputOperandDigit(controller, digit: "2")
                    // operation should automatically push input operand
                    inputOperation(controller, operation: RPNCalculator.Operator.Multiply)
                    
                    expect(display.text) == expectedDisplayText
                    expect(programDisplay.text) == initialOperand + " × 2.0 ="
                }
            }
            context("when multiplied by -0.111") {
                let expectedDisplayText = "0.012321"
                it("displays \(expectedDisplayText)") {
                    controller.enterPressed()
                    inputOperand(controller, fromString: "-0.111")
                    controller.enterPressed()
                    inputOperation(controller, operation: RPNCalculator.Operator.Multiply)
                    
                    expect(display.text) == expectedDisplayText
                    expect(programDisplay.text) == initialOperand + " × " + initialOperand + " ="
                }
            }
        }
        
        context("variable") {
            let variableSymbol = "x"
            
            it("stores 0 if the stack is empty") {
                inputStoreVariable(controller, symbol: variableSymbol)
                expect(display.text) == "0.0"
                
                // When the variable is used
                inputUseVariable(controller, symbol: variableSymbol)
                
                // Then the stored value is recalled
                expect(programDisplay.text) == "\(variableSymbol) ="
                expect(display.text) == "0.0"
            }
            it("stores current operand input as the variable") {
                // Given an empty stack
                // And the operand input
                let operand = "1.1"
                inputOperand(controller, fromString: operand)
                
                inputStoreVariable(controller, symbol: variableSymbol)
                
                // Then the operand input is cleared
                expect(controller.operandInput).to(beEmpty())
                expect(display.text) == "0.0"
                
                // When the variable is used
                inputUseVariable(controller, symbol: variableSymbol)
                
                // Then the stored value is recalled
                expect(programDisplay.text) == variableSymbol + " ="
                expect(display.text) == operand
            }
            it("stores current stack value as the variable") {
                // Given the value on the stack and no pending operand
                let operand = "0.707"
                inputOperand(controller, fromString: operand)
                controller.enterPressed()
                
                // When the variable is stored
                inputStoreVariable(controller, symbol: variableSymbol)
                
                // Then the operand is left on the top of the stack
                expect(programDisplay.text) == operand + " ="
                expect(display.text) == operand
                
                // When the variable is used
                inputUseVariable(controller, symbol: variableSymbol)
                
                // Then the stored value is recalled
                expect(programDisplay.text) == "\(operand), \(variableSymbol) ="
                expect(display.text) == operand
            }
            context("used in an expression before set") {
                let operand0 = "7.0"
                beforeEach {
                    inputOperand(controller, fromString: operand0)
                    controller.enterPressed()
                    inputUseVariable(controller, symbol: variableSymbol)
                    inputOperation(controller, operation: RPNCalculator.Operator.Add)
                }
                it("the expression has a value when a value is stored") {
                    let operand1 = "9"
                    inputOperand(controller, fromString: operand1)
                    inputStoreVariable(controller, symbol: variableSymbol)
                    
                    expect(programDisplay.text) == "\(operand0) + \(variableSymbol) ="
                    expect(display.text) == "16.0"
                }
            }
        }
        
        context("clear") {
            context("given input operand") {
                let operand = "1.111"
                beforeEach {
                    inputOperand(controller, fromString: operand)
                }
                
                it("press removes last digit input") {
                    let expectedInputOperand = operand.substringToIndex(operand.endIndex.predecessor())
                    controller.clearPressed()
                    
                    expect(controller.operandInput) == expectedInputOperand
                    expect(programDisplay.text) == displayPlaceholderText
                    expect(display.text) == expectedInputOperand
                }
                it("press does not remove anything from the stack") {
                    controller.enterPressed()
                    inputOperand(controller, fromString: "1")

                    controller.clearPressed()
                    controller.clearPressed()
                    
                    expect(display.text) == operand
                    expect(programDisplay.text) == operand + " ="
                }
                it("double-tap clears input and re-evaluates") {
                    controller.enterPressed()
                    inputOperand(controller, fromString: "9.9")
                    
                    let simulatedRecognizer = MockUITapGestureRecognizer(simulatedState: .Ended)
                    controller.handleClearInputGesture(simulatedRecognizer)
                    
                    expect(programDisplay.text) == operand + " ="
                    expect(display.text) == operand
                    expect(controller.operandInput).to(beEmpty())
                }
                it("cancelled double-tap does not clear input") {
                    controller.enterPressed()
                    let operandInput = "9.9"
                    inputOperand(controller, fromString: operandInput)
                    
                    let simulatedRecognizer = MockUITapGestureRecognizer(simulatedState: .Cancelled)
                    controller.handleClearInputGesture(simulatedRecognizer)
                    
                    expect(programDisplay.text) == operand + " ="
                    expect(display.text) == operandInput
                    expect(controller.operandInput) == operandInput
                }
                it("began double-tap does not clear input") {
                    controller.enterPressed()
                    let operandInput = "9.9"
                    inputOperand(controller, fromString: operandInput)
                    
                    let simulatedRecognizer = MockUITapGestureRecognizer(simulatedState: .Began)
                    controller.handleClearInputGesture(simulatedRecognizer)
                    
                    expect(programDisplay.text) == operand + " ="
                    expect(display.text) == operandInput
                    expect(controller.operandInput) == operandInput
                }
                it("completed long press gesture clears the stack, display, and operand") {
                    controller.enterPressed()
                    
                    let simulatedRecognizer = MockUILongPressGestureRecognizer(simulatedState: .Ended)
                    controller.handleClearAllGesture(simulatedRecognizer)
                    
                    expect(programDisplay.text) == displayPlaceholderText
                    expect(display.text) == displayPlaceholderText
                    expect(controller.operandInput).to(beEmpty())
                }
                it("cancelled long press gesture does not alter calculator state") {
                    controller.enterPressed()
                    
                    let simulatedRecognizer = MockUILongPressGestureRecognizer(simulatedState: .Cancelled)
                    controller.handleClearAllGesture(simulatedRecognizer)
                    
                    expect(programDisplay.text) == operand + " ="
                    expect(display.text) == operand
                }
                it("began long press gesture does not alter calculator state") {
                    controller.enterPressed()
                    
                    let simulatedRecognizer = MockUILongPressGestureRecognizer(simulatedState: .Began)
                    controller.handleClearAllGesture(simulatedRecognizer)
                    
                    expect(programDisplay.text) == operand + " ="
                    expect(display.text) == operand
                }
            }
            
            context("given the operands") {
                it("double-tap clears the last operand on the stack") {
                    let operand0 = "0.707"
                    let operand1 = "1.212"
                    inputOperand(controller, fromString: operand0)
                    controller.enterPressed()
                    inputOperand(controller, fromString: operand1)
                    controller.enterPressed()
                    
                    let simulatedRecognizer = MockUITapGestureRecognizer(simulatedState: .Ended)
                    controller.handleClearInputGesture(simulatedRecognizer)
                    
                    expect(programDisplay.text) == operand0 + " ="
                    expect(display.text) == operand0
                }
            }
        }
        
        context("errors") {
            context("the square root of -2") {
                let initialOperand = "-2.0"
                
                it("displays the error message") {
                    inputOperand(controller, fromString: initialOperand)
                    controller.enterPressed()

                    inputOperation(controller, operation: RPNCalculator.Operator.SquareRoot)
                    
                    let expectedExpressionDescription = "√(\(initialOperand)) ="
                    expect(programDisplay.text) == expectedExpressionDescription
                    let expectedErrorMessage = NSLocalizedString("ErrorComplexNumber", comment: "")
                    expect(display.text) == expectedErrorMessage
                }
            }
            context("divide by 0") {
                it("displays the error message") {
                    inputOperand(controller, fromString: "5")
                    controller.enterPressed()
                    inputOperand(controller, fromString: "0")
                    controller.enterPressed()
                    
                    inputOperation(controller, operation: RPNCalculator.Operator.Divide)
                    
                    expect(programDisplay.text) == "5.0 ÷ 0.0 ="
                    let expectedErrorMessage = NSLocalizedString("ErrorDivideByZero", comment: "")
                    expect(display.text) == expectedErrorMessage
                    expect(display.backgroundColor) == controller.errorBackgroundColor
                }
            }
            context("variable not set") {
                let variableSymbol = "x"
                
                context("pushed onto stack by itself") {
                    it("displays the error message") {
                        inputUseVariable(controller, symbol: variableSymbol)
                        
                        expect(programDisplay.text) == variableSymbol + " ="
                        let expectedErrorMessage = String(format: NSLocalizedString("ErrorVariableNotSet", comment:""), variableSymbol)
                        expect(display.text) == expectedErrorMessage
                    }
                }
                context("used in a binary expression") {
                    let operand0 = "7.0"
                    beforeEach {
                        inputOperand(controller, fromString: operand0)
                        controller.enterPressed()
                        inputUseVariable(controller, symbol: variableSymbol)
                        
                        inputOperation(controller, operation: RPNCalculator.Operator.Add)
                    }
                    it("displays the error message") {
                        expect(programDisplay.text) == "\(operand0) + \(variableSymbol) ="
                        let expectedErrorMessage = String(format: NSLocalizedString("ErrorVariableNotSet", comment:""), variableSymbol)
                        expect(display.text) == expectedErrorMessage
                        expect(display.backgroundColor) == controller.errorBackgroundColor
                    }
                    it("clears the error when the variable is set") {
                        let x = "2.2"
                        inputOperand(controller, fromString: x)
                        inputStoreVariable(controller, symbol: variableSymbol)
                        
                        expect(display.text) == "9.2"
                        expect(display.backgroundColor).to(beNil())
                    }
                }
                context("used in a unary expression") {
                    it("the unary expression has no value") {
                        inputUseVariable(controller, symbol: variableSymbol)
                        
                        inputOperation(controller, operation: RPNCalculator.Operator.SquareRoot)
                        
                        
                        expect(programDisplay.text) == "√(\(variableSymbol)) ="
                        let expectedErrorMessage = String(format: NSLocalizedString("ErrorVariableNotSet", comment:""), variableSymbol)
                        expect(display.text) == expectedErrorMessage
                        expect(display.backgroundColor) == controller.errorBackgroundColor
                    }
                }
            }
        }
        
        context("given expression 1 / x") {
            let variableSymbol = "x"
            func f(x: Double) -> Double {
                return 1.0 / x
            }
            beforeEach {
                inputOperand(controller, fromString: "1")
                controller.enterPressed()
                inputUseVariable(controller, symbol: variableSymbol)
                inputOperation(controller, operation: RPNCalculator.Operator.Divide)
            }
            it("segues to a graph view with a copy of the calculator state") {
                let graphViewController = GraphViewController()
                let sender = UIButton()
                let segue = UIStoryboardSegue(identifier: "showGraph", source: controller, destination: graphViewController)
                controller.prepareForSegue(segue, sender: sender)
                
                // the dataSource on the destination controller returns the same result as the calculator
                var x = -2.0
                inputOperand(controller, fromString: "\(x)")
                inputStoreVariable(controller, symbol: variableSymbol)
                expect(graphViewController.dataSource!(x)) == doubleValue(display.text!)
                
                // the dataSource uses a copy of the calculator state at the time of the segue:
                // the preceeding operation that sets a variable value in the calculator controller
                // does not affect the result returned by the dataSource
                x = 3.0
                expect(graphViewController.dataSource!(x)) == f(x)
            }
        }
    }
}

private class MockUITapGestureRecognizer: UITapGestureRecognizer {
    let _simulatedState: UIGestureRecognizerState
    
    init(simulatedState: UIGestureRecognizerState) {
        _simulatedState = simulatedState
        super.init(target: nil, action: nil)
    }
    
    override var state: UIGestureRecognizerState {
        return _simulatedState
    }
}

private class MockUILongPressGestureRecognizer: UILongPressGestureRecognizer {
    let _simulatedState: UIGestureRecognizerState
    
    init(simulatedState: UIGestureRecognizerState) {
        _simulatedState = simulatedState
        super.init(target: nil, action: nil)
    }
    
    override var state: UIGestureRecognizerState {
        return _simulatedState
    }
}

func inputOperand(controller: CalculatorController, fromString operandString: String) {
    operandString.characters.forEach { (char: Character) in
        switch char {
        case "-":
            controller.toggleSignPressed()
        case ".":
            controller.decimalPointPressed()
        default:
            inputOperandDigit(controller, digit: String(char))
        }
    }
}

func inputOperandDigit(controller: CalculatorController, digit: String) {
    if !digit.isEmpty {
        let button = UIButton()
        button.setTitle(digit, forState: UIControlState.Normal)
        controller.digitPressed(button)
    }
}

func inputOperation(controller: CalculatorController, operation: String) {
    if !operation.isEmpty {
        let button = UIButton()
        button.setTitle(operation, forState: UIControlState.Normal)
        controller.operationPressed(button)
    }
}

func inputStoreVariable(controller: CalculatorController, symbol: String) {
    if !symbol.isEmpty {
        let button = UIButton()
        button.setTitle("→" + symbol, forState: UIControlState.Normal)
        controller.storeVariablePressed(button)
    }
}

func inputUseVariable(controller: CalculatorController, symbol: String) {
    if !symbol.isEmpty {
        let button = UIButton()
        button.setTitle(symbol, forState: UIControlState.Normal)
        controller.useVariablePressed(button)
    }
}

func doubleValue(s: String) -> Double? {
    return NSNumberFormatter().numberFromString(s)?.doubleValue
}



