# 函数

## 参数

### 默认参数值

可以在函数定义里写上函数的默认值，这样在调用的时候可以不传这个值：

    func add(value1 v1:Int, value2 p1:Int = 2) -> Int{
        return v1 + p1
    }

    add(value1: 2, value2: 4)   // 2 + 4
    add(value1: 1)  // 1 + 2

如果你没有提供外部参数名，设置默认参数值会自动提供默认参数名。


### 可变参数

可变参数 (Variadic Parameters) 可以接受一个以上的参数值。比如计算平均数：

    func arithmeticMean(numbers: Double...) -> Double {
        var total: Double = 0
        for number in numbers { // numbers is [Double]
            total += number
        }
        return total / Double(numbers.count)
    }
    arithmeticMean(1, 2, 3, 4, 5)
    arithmeticMean(3, 8, 19)

如果不止一个参数，需要把可变参数放在最后，否则会报错。应该这样：

    func sumAddValue(addValue:Int=0, numbers: Int...) -> Int {
        var sum = 0
        for number in numbers { // numbers === [Int]
            sum += number + addValue
        }
        return sum
    }
    sumAddValue(addValue: 2, 2,4,5) // (2+2) + (4+2) + (5+2) = 17


### 常量和变量参数

默认参数是常量，无法在函数体中改变参数值。我们可以 `var` 一个新的值就行操作，也可以直接在函数定义中加上 `var` 避免在函数体中定义新的变量。

比如这一个右对齐函数：

    func alignRight(var string: String, count: Int, pad: Character) -> String {
        let amountToPad = count - countElements(string)
        if amountToPad < 1 {
            return string
        }
        let padString = String(pad)
        for _ in 1...amountToPad {
            string = padString + string
        }
        return string
    }
    let originalString = "hello"
    let paddedString = alignRight(originalString, 10, "-")  // "-----hello"


### 输入输出参数 (inout)

在函数体中对变量参数进行的修改并不会改变参数值本身，比如看这个例子：

    func add(var v1:Int) -> Int {
        return ++v1
    }

    var a = 1
    add(a)      // 2
    a           // 1

如果想通过函数修改原始值需要 `inout` ，但是这样是错误的：

    func add(inout v1:Int) -> Int {
        return ++v1
    }

    var a = 1
    add(a)      // 2
    a           // 1

在传入的时候，需要加上 `&` 标记：

    func add(inout v1:Int) -> Int {
        return ++v1
    }

    var a = 1
    add(&a)      // 2
    a           // 1


## 函数类型

### 变量
在 Swift 中，函数翻身把歌唱，终于成了一等公民，和其他类型平起平坐。我们可以定义一个变量，这个变量的类型是函数类型：

    func addTwoInts(a: Int, b: Int) -> Int {
        return a + b
    }
    let anotherMathFunction = addTwoInts
    anotherMathFunction(1,2)    // 3


### 参数
函数既然是类型的一种，那么显然也是可以作为参数传递的：

    func addTwoInts(a: Int, b: Int) -> Int {
        return a + b
    }

    func printMathResult(mathFunction: (Int, Int) -> Int, a: Int, b: Int) {
        println("Result: \(mathFunction(a, b))")
    }
    printMathResult(addTwoInts, 3, 5)   // 将参数2和参数3作为参数传给参数1的函数


### 返回值
那么也是可以作为结果返回的。比如返回的值是一个参数为 Int 返回值为 Int 的函数，就是这样定义：`func foo() -> (Int) -> Int`。可以看下面这个具体的例子：



    func stepForward(input: Int) -> Int {
        return input + 1
    }

    func stepBackward(input: Int) -> Int {
        return input - 1
    }

    func chooseStepFunction(backwards: Bool) -> (Int) -> Int {
        return backwards ? stepBackward : stepForward
    }

    var currentValue = 3

    let moveNearerToZero = chooseStepFunction(currentValue > 0) // 根据参数返回 stepForward 或 stepBackward

    println("Counting to zero:")

    while currentValue != 0 {
        println("\(currentValue)... ")
        currentValue = moveNearerToZero(currentValue)
    }
    println("zero!")

    // 3...
    // 2...
    // 1...
    // zero!


## 嵌套

但是其实并不是所有的函数都需要暴露在外面的，有时候我们定义一个新函数只是为了封装一层，并不是为了复用。这时候可以把函数嵌套进去，比如前面这个例子：

    func chooseStepFunction(backwards: Bool) -> (Int) -> Int {
        func stepForward(input: Int) -> Int { return input + 1 }
        func stepBackward(input: Int) -> Int { return input - 1 }
        return backwards ? stepBackward : stepForward
    }
    var currentValue = -4
    let moveNearerToZero = chooseStepFunction(currentValue < 0)
    // moveNearerToZero now refers to the nested stepForward() function
    while currentValue != 0 {
        println("\(currentValue)... ")
        currentValue = moveNearerToZero(currentValue)
    }
    println("zero!")
    // -4...
    // -3...
    // -2...
    // -1...
    // zero!




*** 

## References

- [Functions](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Functions.html)