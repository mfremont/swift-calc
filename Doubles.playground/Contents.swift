// Example of how Swift handles binary approximations of decimal fractions

let x = 1.1
let y = x * 0.1
let w = Double("0.11")!
y == w
w - y
let ys = String(format: "%0.24f", y)
let ws = String(format: "%0.24f", w)
y.description
String(y)
w.description
String(w)


