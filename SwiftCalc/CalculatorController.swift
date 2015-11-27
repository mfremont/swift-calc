//
//  CalculatorController.swift
//  SwiftCalc
//
//  Created by Matthew Fremont on 6/7/15.
//  Copyright (c) 2015 Matthew Fremont. All rights reserved.
//

import UIKit

public class CalculatorController: UIViewController {

    var calculator = RPNCalculator()
    
    let numberFormatter = NSNumberFormatter()

    @IBOutlet weak var display: UILabel!
    
    var displayValue: Double? {
        get {
            if let displayText = display.text {
                return numberFormatter.numberFromString(displayText)!.doubleValue
            } else {
                return nil
            }
        }
        set {
            if newValue != nil {
                display.text = String(newValue!)
                programDisplay.text = calculator.description + " ="
            } else {
                // preserve layout height of display if new value is nil
                display.text = " "
                programDisplay.text = calculator.stackDepth > 0 ? calculator.description + " =" : " "
            }
        }
    }
    
    @IBOutlet weak var programDisplay: UILabel!
    
    let SYM_PI = "π"
    
    var _operandInput = ""
    
    public var operandInput: String {
        get {
            return _operandInput
        }
    }
    
    @IBAction public func backspacePressed() {
        if !operandInput.isEmpty {
            _operandInput.removeAtIndex(operandInput.endIndex.predecessor())
            if !operandInput.isEmpty {
                display.text = operandInput
            } else {
                displayValue = calculator.evaluate()
            }
        }
    }

    @IBAction public func clearPressed() {
        calculator.clear()
        _operandInput = ""
        displayValue = nil
    }

    @IBAction public func decimalPointPressed() {
        if operandInput.isEmpty {
            _operandInput = "0."
            display.text = _operandInput
        } else if operandInput.characters.indexOf(".") == nil {
            // operand does not already contain a decimal point
            _operandInput += "."
            display.text = _operandInput
        }
    }
    
    @IBAction public func digitPressed(sender: UIButton) {
        let digit = sender.currentTitle!
        _operandInput += digit
        display.text = operandInput
    }
    
    @IBAction public func enterPressed() {
        pushOperand()
    }
    
    
    @IBAction public func constantPressed(sender: UIButton) {
        pushOperand()
        let symbol = sender.currentTitle!
        switch symbol {
            case SYM_PI:
                pushOperand(M_PI, withSymbol: symbol)
            default:
                break
        }
    }
    
    @IBAction public func operationPressed(sender: UIButton) {
        pushOperand()
        let operatorSymbol = sender.currentTitle!
        pushOperator(operatorSymbol)
    }
 
    @IBAction public func toggleSignPressed() {
        let operand = operandInput
        if operand.hasPrefix("-") {
            _operandInput = operand.substringFromIndex(operand.startIndex.successor())
        } else {
            _operandInput = "-" + operand
        }
        display.text = _operandInput
    }
    
    /**
     Pushes the current operand input onto the calculator stack and updates the display. This is a
     no-op if the operand input is empty.
     */
    func pushOperand() {
        if let operand = doubleFromString(_operandInput) {
            displayValue = calculator.pushOperand(operand)
            _operandInput = ""
        }
    }

    /**
     Pushes the current operand input onto the calculator stack, followed by the symbolic value,
     and updates the display.
     */
    func pushOperand(value: Double, withSymbol symbol: String) {
        displayValue = calculator.pushOperand(value, withSymbol: symbol)
    }
    
    /**
     Pushes the current operand input followed by the operator onto the calculator stack.
     */
    func pushOperator(symbol: String) {
        displayValue = calculator.pushOperator(symbol)
    }
    
    /**
     Converts the string to a `Double`.
     
     - returns: the double value or `nil` if the convertion fails
     */
    func doubleFromString(s: String) -> Double? {
        return numberFormatter.numberFromString(s)?.doubleValue
    }
}

