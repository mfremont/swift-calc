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

import SwiftCalc

class CalculatorControllerSpec: QuickSpec {
    override func spec() {
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
            context("when clear is pressed") {
                it("clears the display and operand") {
                    controller.clearPressed()
                    
                    expect(display.text) == " "
                    expect(controller.operandInput) == ""
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
                it("no result is displayed and the input operand is consumed") {
                    inputOperation(controller, operation: RPNCalculator.Operator.Multiply)
                    
                    expect(display.text) == " "
                    expect(controller.operandInput) == ""
                    expect(programDisplay.text) == "? × 1.0 ="
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
            context("when the square root is requested") {
                let expectedDisplayText = "nan"
                it("displays \(expectedDisplayText)") {
                    inputOperation(controller, operation: RPNCalculator.Operator.SquareRoot)
                    
                    expect(display.text) == expectedDisplayText
                    expect(programDisplay.text) == "√(\(initialOperand)) ="
                }
            }
        }
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

func doubleValue(s: String) -> Double? {
    return NSNumberFormatter().numberFromString(s)?.doubleValue
}



