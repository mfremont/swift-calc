# SwiftCalc iOS app

This is the Calculator app I developing using Swift 2.1 and Xcode 7.1 for the assignments of the
iTunes U course
[Developing iOS 8 Apps with Swift](https://itunes.apple.com/us/course/developing-ios-8-apps-swift/id961180099).

This project also serves as a means of exploring tools and techniques for applying TDD to iOS 
development with Swift. It utilizes test cases written with [Quick/Nimble](https://github.com/Quick/Quick)
as well as XCTest.

## Build

[CocoaPods](https://cocoapods.org) is utilized to manage dependenies on non-core frameworks and libraries.
These dependencies must be downloaded and installed in the project _before_ building with Xcode:

1. Intall version 0.36 or later, either as a ruby gem or with `brew install Caskroom/cask/cocoapods`.
2. run `pod install` from this directory (which contains `SwiftCalc.xcworkspace`)

Now, you should be able to build the app and run tests in Xcode.

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
