# 函数

## 参数

### 外部变量名

一般情况下你可以不指定外部变量名，直接调用函数：

    func helloWithName(name: String, age: Int, location: String) {
        println("Hello \(name). I live in \(location) too. When is your \(age + 1)th birthday?")
    }

    helloWithName("Mr. Roboto", 5, "San Francisco")

但是分装在类 (或者结构、枚举) 中的时候，会自动分配外部变量名 (第一个除外) ，这时候如果还想直接调用就会报错了：

    class MyFunClass {  
        func helloWithName(name: String, age: Int, location: String) {
            println("Hello \(name). I live in \(location) too. When is your \(age + 1)th birthday?")
        }
        
    }
    let myFunClass = MyFunClass()
    myFunClass.helloWithName("Mr. Roboto", 5,  "San Francisco")

如果你怀念在 OC 中定义函数名的方式，可以继续这样定义，比如 `helloWithName` 这种，隐藏第一个函数的外部名：

    class MyFunClass {
        func helloWithName(name: String, age: Int, location: String) {
            println("Hello \(name). I live in \(location) too. When is your \(age + 1)th birthday?")
        }
    }
    let myFunClass = MyFunClass()
    myFunClass.helloWithName("Mr. Roboto", age: 5, location: "San Francisco")


如果你实在不想要外部变量名，那么可以用 `_` 来代替：

    struct Celsius {
        var temperatureInCelsius: Double
        init(fromFahrenheit fahrenheit: Double) {
            temperatureInCelsius = (fahrenheit - 32.0) / 1.8
        }
        init(fromKelvin kelvin: Double) {
            temperatureInCelsius = kelvin - 273.15
        }
        init(_ celsius: Double) {
            temperatureInCelsius = celsius
        }
    }

    let boilingPointOfWater = Celsius(fromFahrenheit: 212.0)
    // boilingPointOfWater.temperatureInCelsius 是 100.0

    let freezingPointOfWater = Celsius(fromKelvin: 273.15)
    // freezingPointOfWater.temperatureInCelsius 是 0.0

    let bodyTemperature = Celsius(37.0)
    // bodyTemperature.temperatureInCelsius 是 37.0 


对外部参数名的娴熟应用可以极好的抽象初始化过程。可以看看 [json-swift library](https://github.com/owensd/json-swift/blob/master/src/JSValue.swift) 中的应用。




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


### 泛型参数类型

在此借用一下 objc.io 中的例子来演示泛型参数类型的使用：

    // 交换两个值的函数
    func valueSwap<T>(inout value1: T, inout value2: T) {
        let oldValue1 = value1
        value1 = value2
        value2 = oldValue1
    }

    var name1 = "Mr. Potato"
    var name2 = "Mr. Roboto"

    valueSwap(&name1, &name2)   // 交换字符串

    name1 // Mr. Roboto
    name2 // Mr. Potato

    var number1 = 2
    var number2 = 5

    valueSwap(&number1, &number2)   // 交换数字

    number1 // 5
    number2 // 2



## 函数类型

在 Swift 中，函数翻身把歌唱，终于成了一等公民，和其他类型平起平坐。

### 变量

我们可以定义一个变量，这个变量的类型是函数类型：

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

函数也是可以作为结果返回的。比如返回的值是一个参数为 Int 返回值为 Int 的函数，就是这样定义：`func foo() -> (Int) -> Int`。可以看下面这个具体的例子：



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


### 别名

用多了会发现在一大串 `()->` 中又穿插各种 `()->` 是一个非常蛋疼的事情。我们可以用 `typealias` 定义函数别名，其功能和 OC 中的 typedef 以及 shell 中的 alias 的作用基本是一样的。举个例子来看下：


    import Foundation

    typealias lotteryOutputHandler = (String, Int) -> String
    
    // 如果没有 typealias 则需要这样：
    // func luckyNumberForName(name: String, #lotteryHandler: (String, Int) -> String) -> String {
    func luckyNumberForName(name: String, #lotteryHandler: lotteryOutputHandler) -> String {
        let luckyNumber = Int(arc4random() % 100)
        return lotteryHandler(name, luckyNumber)
    }

    luckyNumberForName("Mr. Roboto", lotteryHandler: {name, number in
        return "\(name)'s' lucky number is \(number)"
    })
    // Mr. Roboto's lucky number is 33




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


## 柯里化 (currying)

柯里化背后的基本想法是，函数可以局部应用，意思是一些参数值可以在函数调用之前被指定或者绑定。这个部分函数的调用会返回一个新的函数。

这个具体内容可以参见 [Swift 方法的多面性](http://objccn.io/issue-16-3/) 中 柯里化部分的内容。我们可以这样调用：

    class MyHelloWorldClass {
        
        func helloWithName(name: String) -> String {
            return "hello, \(name)"
        }
    }
    let myHelloWorldClassInstance = MyHelloWorldClass()
    let helloWithNameFunc = MyHelloWorldClass.helloWithName
    helloWithNameFunc(myHelloWorldClassInstance)("Mr. Roboto")
    // hello, Mr. Roboto


## 多返回值

在 Swift 中我们可以利用 tuple 返回多个返回值。比如下面这个例子，返回所有数字的范围：

     func findRangeFromNumbers(numbers: Int...) -> (min: Int, max: Int) {
        var maxValue = numbers.reduce(Int.min,  { max($0,$1) })
        var minValue = numbers.reduce(Int.max,  { min($0,$1) }) 
        return (minValue, maxValue)
    }
    findRangeFromNumbers(1, 234, 555, 345, 423)
    // (1, 555)

而返回值未必都是有值的，我们也可以返回可选类型的结果：


    import Foundation

    func componentsFromUrlString(urlString: String) -> (host: String?, path: String?) {
        let url = NSURL(string: urlString)
        return (url?.host, url?.path)
    }

    let urlComponents = componentsFromUrlString("http://why/233;param?foo=1&baa=2#fragment")

    switch (urlComponents.host, urlComponents.path) {
    case let (.Some(host), .Some(path)):
        println("host \(host) and path \(path)")
    case let (.Some(host), .None):
        println("only host \(host)")
    case let (.None, .Some(path)):
        println("only path \(path)")
    case let (.None, .None):
        println("This is not a url!")
    }

    // "host why and path /233/param"





*** 

## References

- [Functions](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Functions.html)
- [Swift Functions](http://www.objc.io/issue-16/swift-functions.html)
- [Swift 方法的多面性](http://objccn.io/issue-16-3/)
- [Instance Methods are Curried Functions in Swift](http://oleb.net/blog/2014/07/swift-instance-methods-curried-functions/)