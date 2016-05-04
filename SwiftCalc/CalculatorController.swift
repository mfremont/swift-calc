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

    // moderately saturated orange-yellow
    let errorBackgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.55, alpha:1.0)
    var defaultBackgroundColor: UIColor?
    
    let numberFormatter = NSNumberFormatter()
    // default text to preserve layout height of display label views
    let displayPlaceholderText = " "

    @IBOutlet weak var graphButton: UIButton!
    @IBOutlet weak var useVariableButton: UIButton!
    @IBOutlet weak var display: UILabel!
    
    var displayValue: Double? {
        get {
            if let displayText = display.text {
                return doubleFromString(displayText)
            } else {
                return nil
            }
        }
        set {
            let evaluationError = !calculator.evaluationErrors.isEmpty
            if newValue != nil {
                display.text = String(newValue!)
                display.backgroundColor = defaultBackgroundColor
            } else {
                var errorMessage: String?
                if evaluationError {
                    // display top-most error
                    let error = calculator.evaluationErrors[0]
                    switch error {
                        case .DivideByZero:
                            errorMessage = NSLocalizedString("ErrorDivideByZero", comment: "error message: divide by zero")
                        case .ComplexNumber:
                            errorMessage = NSLocalizedString("ErrorComplexNumber", comment:  "error message: result is complex number")
                        case .InsufficientOperandsForOperation(let symbol):
                            let messageFormat = NSLocalizedString("ErrorInsufficientOperands", comment: "error message: insufficient operands for operation")
                            errorMessage = String(format: messageFormat, symbol)
                        case .VariableNotSet(let symbol):
                            let messageFormat = NSLocalizedString("ErrorVariableNotSet", comment: "error message: variable not set")
                            errorMessage = String(format: messageFormat, symbol)
                    }
                }
                if errorMessage != nil {
                    display.text = errorMessage!
                    display.backgroundColor = errorBackgroundColor
                } else {
                    display.text = displayPlaceholderText
                    display.backgroundColor = defaultBackgroundColor
                }
            }
            
            if calculator.stackDepth > 0 {
                programDisplay.text = calculator.description + " ="
            } else {
                programDisplay.text = displayPlaceholderText
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
    
    // MARK: - View Controller Lifecycle
    
    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showGraph" {
            if let graphViewController = segue.destinationViewController as? GraphViewController {
                let graphCalculator = RPNCalculator(copyFrom: calculator)
                graphViewController.title = graphCalculator.description
                let variableSymbol = useVariableButton.currentTitle ?? "x"
                graphViewController.dataSource = { (x: Double) -> Double? in
                    graphCalculator.variable[variableSymbol] = x
                    return graphCalculator.evaluate()
                }
            }
        }
    }
    
    override public func viewDidLoad() {
        defaultBackgroundColor = display.backgroundColor
    }
    
    // MARK: - UI component callbacks
    
    @IBAction public func clearPressed() {
        removeOperandInputLast()
    }

    @IBAction public func handleClearAllGesture(sender: UILongPressGestureRecognizer) {
        if sender.state == .Ended {
            clearAll()
        }
    }

    @IBAction public func handleClearInputGesture(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            if !operandInput.isEmpty {
                clearOperandInput()
            } else {
                calculator.removeLast()
            }
            displayValue = calculator.evaluate()
        }
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
    
    @IBAction public func storeVariablePressed(sender: UIButton) {
        let buttonTitle = sender.currentTitle!
        let symbol = buttonTitle.substringFromIndex(buttonTitle.startIndex.successor())
        calculator.variable[symbol] = displayValue ?? 0
        clearOperandInput()
        displayValue = calculator.evaluate()
    }
    
    @IBAction public func useVariablePressed(sender: UIButton) {
        let symbol = sender.currentTitle!
        displayValue = calculator.pushOperand(symbol)
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
    
    // MARK: - Internal helper methods
    
    /**
     Clears the calculator model, operand input, and display.
     */
    func clearAll() {
        calculator.clear()
        clearOperandInput()
        displayValue = nil
    }
    
    /**
     Clears the operand input buffer.
     */
    func clearOperandInput() {
        _operandInput.removeAll()
    }

    func removeOperandInputLast() {
        if !operandInput.isEmpty {
            _operandInput.removeAtIndex(operandInput.endIndex.predecessor())
            if !operandInput.isEmpty {
                display.text = operandInput
            } else {
                displayValue = calculator.evaluate()
            }
        }
    }
    
    /**
     Pushes the current operand input onto the calculator stack and updates the display. This is a
     no-op if the operand input is empty.
     */
    func pushOperand() {
        if let operand = doubleFromString(_operandInput) {
            displayValue = calculator.pushOperand(operand)
            clearOperandInput()
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