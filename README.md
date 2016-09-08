# SwiftCalc iOS app

This calculator app is based on the assignments from the
iTunes U course
[Developing iOS 8 Apps with Swift](https://itunes.apple.com/us/course/developing-ios-8-apps-swift/id961180099).

I've also used this project as a means of exploring tools and techniques for applying TDD to iOS 
development with Swift. The unit tests for `CalculatorController` are written in the spec style with
[Quick and Nimble](https://github.com/Quick/Quick) and can be found in
`SwiftCalcTests/CalculatorControllerSpec.swift`. Most of the other unit tests are implemented
as `XCTestCase` subclasses but make use of Nimble matchers to express the expectations.

## Build

As of September 2016, I've been using Xcode 7.3.1 to build the app and run the test suites. Earlier versions
of Xcode 7 may also work, but I haven't tried that in a while. I've also been able to build the app
and run the test cases with Xcode 8.0 beta 6 after running the conversion to Swift 2.3.

The dependencies on Quick and Nimble are manged using [CocoaPods](https://cocoapods.org). CocoaPods must be
installed and the dependencies downloaded _before_ building with Xcode:

1. Install version `brew install cocoapods` or as a ruby gem (see the [Getting Started Guide](https://guides.cocoapods.org/using/getting-started.html for CocoaPods). Version 1.0 or later recommended.
2. run `pod install` from the project root (directory which contains this README and `SwiftCalc.xcworkspace`)

Now, you should be able to build the app and run the tests with Xcode.

## Behavior and design differences from iTunes U course assignments

### Assignment 1

I decided to name the model class `RPNCalculator` rather than `CalculatorBrain` because this better
reflects the nature of the calculator API.

### Assignment 2

#### Variables

Instead of "→M" and "M" labels for the buttons to store and use a variable, I decided on 
"→_x_" and "_x_" as a tribute to the [HP-35](http://www.hpmuseum.org/hp35.htm).

#### Use of parentheses to describe calculator stack

One of the extra-credit behaviors for Assignment 2 is to implement omit parentheses when conventional
associativity of binary operations implies grouping. The example given is that given the input
`3⏎ 5⏎ 4⏎ + +`, the calculator should display the description `3 + 5 + 4` rather than `3 + (5 + 4)`.

Although this makes good sense for conventional arithmetic, because the calculator is implemented using
floating point arithmetic, removing the parenthesis mis-represents how the calculations are performed.

One surprising property of floating point arithmetic with native types such as doubles is that
addition and multiplication are not associative. This occurs when the operands are very different in 
scale. For example, with Swift 2.1 this can observed with expressions such as:

    (0.1 + 0.1e-13) + 0.1e-13 != 0.1 + (0.1e-13 + 0.1e-13)
    (1e7 + 1e-7) + 1e-7 != 1e7 + (1e-7 + 1e-7)

    (1e7 * 1e-7) * 1e-7 != 1e7 * (1e-7 * 1e-7)
    (1.1 * 1.1e-16) * 0.1e-16 != 1.1 * (1.1e-16 * 0.1e-16)

Although this behavior only applies when an expression includes both very large and very small numbers,
I felt it was more appropriate to represent the order in which the calculations are performed rather
than simply created the most compact representation.

#### Clear, backspace, and undo

Another extra-credit behavior is to implement an undo button:

* if there is a pending operand, it behaves as a backspace and removes the last input digit
* otherwise, it should "undo" the last "thing" performed on the calculator model

The requirement does not specify whether the backspace button should be retained.

I decided to implement a variation on this behavior using gestures on the clear button ("C"):

1. Press operates as a backspace, removing the trailing digit from the input operand until the
input is empty; with empty input, it is a no-op.
2. Double-tap will clear the input operand; if there is no input operand it will remove the topmost
entry on the stack.
3. Long press clears the calculator: input operand, stack, and variables.

#### Error Reporting

I used the error reporting exercise as an opportunity to learn a little about exceptions and 
internationalization in Swift. `RPNCalculator.evaluate()` returns `nil` if any errors occur during
evaluation and those errors are reported with the `evaluationErrors` attribute.

Errors are reported in the UI by the `CalculatorController.displayValue` setter. If the new value
is `nil` then the top-most error in the `evaluationErrors` is used to lookup a localized message
using `NSLocalizedString(key:comment)` and the main display is updated with the message.

### Assignment 3

#### Layout for iPad and iPhone 6+ landscape

The calculator is not yet embedded in a Split View Controller for side-by-side viewing
of the calculator and the graph when viewing in landscape on an iPad or iPhone 6+.

#### Size-class adaptions

Size class-specific layouts are not yet implemented. An improvement would be to implement layouts
that are optimized for vertical compact (landscape on phones) and horizontal regular (portrait on
iPads).