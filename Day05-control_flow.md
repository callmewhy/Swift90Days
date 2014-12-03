# [Swift90Days](https://github.com/callmewhy/Swift90Days) - 控制流

控制流基本上大同小异，在此列举几个比较有趣的地方。

## switch

### Break

文档原文是 `No Implicit Fallthrough` ，粗暴的翻译一下就是：不存在隐式贯穿。其中 `Implicit` 是一个经常出现的词，中文原意是：“含蓄的，暗示的，隐蓄的”。在 Swift 中通常表示默认处理。比如这里的隐式贯穿，就是指传统的多个 `case` 如果没有 `break` 就会从上穿到底的情况。再例如 `implicitly unwrapped optionals` ，隐式解析可选类型，则是默认会进行解包操作不用手动通过 `!` 进行解包。

回到 `switch` 的问题，看下下面这段代码：

    let anotherCharacter: Character = "a"

    switch anotherCharacter {
    case "a":
        println("The letter a")
    case "A":
        println("The letter A")
    default:
        println("Not the letter A")
    }

可以看到虽然匹配到了 `case "a"` 的情况，但是在当前 case 结束之后便直接跳出，没有继续往下执行。如果想继续贯穿到下面的 case 可以通过 `fallthrough` 实现。


### Tuple

我们可以在 switch 中使用元祖 (tuple) 进行匹配。用 `_` 表示所有值。比如下面这个例子，判断坐标属于什么区域：

    let somePoint = (1, 1)

    switch somePoint {
    case (0, 0):    // 位于远点
        println("(0, 0) is at the origin")
    case (_, 0):    // x为任意值，y为0，即在 X 轴上
        println("(\(somePoint.0), 0) is on the x-axis")
    case (0, _):    // y为任意值，x为0，即在 Y 轴上
        println("(0, \(somePoint.1)) is on the y-axis")
    case (-2...2, -2...2):  // 在以原点为中心，边长为4的正方形内。
        println("(\(somePoint.0), \(somePoint.1)) is inside the box")
    default:
        println("(\(somePoint.0), \(somePoint.1)) is outside of the box")
    }

    // "(1, 1) is inside the box"

如果想在 case 中用这个值，那么可以用过值绑定 (value bindings) 解决：

    let somePoint = (0, 1)

    switch somePoint {
    case (0, 0):
        println("(0, 0) is at the origin")
    case (let x, 0):
        println("x is \(x)")
    case (0, let y):
        println("y is \(y)")
    default:
        println("default")
    }

### Where

case 中可以通过 where 对参数进行匹配。比如我们想打印 y=x 或者 y=-x这种45度仰望的情况，以前是通过 if 解决，现在可以用 switch 搞起：

    let yetAnotherPoint = (1, -1)

    switch yetAnotherPoint {
    case let (x, y) where x == y:
        println("(\(x), \(y)) is on the line x == y")
    case let (x, y) where x == -y:
        println("(\(x), \(y)) is on the line x == -y")
    case let (x, y):
        println("(\(x), \(y)) is just some arbitrary point")
    }
    // "(1, -1) is on the line x == -y”




## Control Transfer Statements

Swift 有四个控制转移状态：

- continue - 针对 loop ，直接进行下一次循环迭代。告诉循环体：我这次循环已经结束了。
- break - 针对  control flow (loop + switch)，直接结束整个控制流。在 loop 中会跳出当前 loop ，在 switch 中是跳出当前 switch 。如果 switch 中某个 case 你实在不想进行任何处理，你可以直接在里面加上 break 来忽略。
- fallthrough - 在 switch 中，将代码引至下一个 case 而不是默认的跳出 switch。
- return - 函数中使用


## 其他

看到一个有趣的东西：[Swift Cheat Sheet](http://mhm5000.gitbooks.io/swift-cheat-sheet/)，里面是纯粹的代码片段，如果突然短路忘了语法可以来看看。

比如 [Control Flow](http://mhm5000.gitbooks.io/swift-cheat-sheet/content/control_flow/README.html) 部分，有如下代码，基本覆盖了所有的点：

    // for loop (array)
    let myArray = [1, 1, 2, 3, 5]
    for value in myArray {
        if value == 1 {
            println("One!")
        } else {
            println("Not one!")
        }
    }

    // for loop (dictionary)
    var dict = [
        "name": "Steve Jobs",
        "title": "CEO",
        "company": "Apple"
    ]
    for (key, value) in dict {
        println("\(key): \(value)")
    }

    // for loop (range)
    for i in -1...1 { // [-1, 0, 1]
        println(i)
    }
    // use .. to exclude the last number

    // for loop (ignoring the current value of the range on each iteration of the loop)
    for _ in 1...3 {
        // Do something three times.
    }

    // while loop
    var i = 1
    while i < 1000 {
        i *= 2
    }

    // do-while loop
    do {
        println("hello")
    } while 1 == 2

    // Switch
    let vegetable = "red pepper"
    switch vegetable {
    case "celery":
        let vegetableComment = "Add some raisins and make ants on a log."
    case "cucumber", "watercress":
        let vegetableComment = "That would make a good tea sandwich."
    case let x where x.hasSuffix("pepper"):
        let vegetableComment = "Is it a spicy \(x)?"
    default: // required (in order to cover all possible input)
        let vegetableComment = "Everything tastes good in soup."
    }

    // Switch to validate plist content
    let city:Dictionary<String, AnyObject> = [
        "name" : "Qingdao",
        "population" : 2_721_000,
        "abbr" : "QD"
    ]
    switch (city["name"], city["population"], city["abbr"]) {
        case (.Some(let cityName as NSString),
            .Some(let pop as NSNumber),
            .Some(let abbr as NSString))
        where abbr.length == 2:
            println("City Name: \(cityName) | Abbr.:\(abbr) Population: \(pop)")
        default:
            println("Not a valid city")
    }








*** 

## References

- [Control Flow](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/ControlFlow.html)
- [Swift Cheat Sheet](http://mhm5000.gitbooks.io/swift-cheat-sheet/)