# 闭包初级入门

## 简介 (真的很简)

闭包的完整形态是这个样子的：

    { (parameters) -> returnType in
        statements
    }

写在一行里就是这样：

    {(parameters) -> (returnType) in statements}


## 参数缩写

我们可以直接用 `$0 $1 $2` 这种来依次定义闭包的参数。比如 `sorted` 函数：

    var reversed = sorted(["c","a","d","b"], { $0 > $1 })   // d c b a

## 尾随闭包

我一直觉得闭包最后这个 `})` 很难看，在 JS 中就随处可见这种情况。如果闭包是函数的最后一个参数，Swift 提供了尾随闭包 (Trailing Closures) 解决这个审美问题：

    // 以下是不使用尾随闭包进行函数调用
    someFunc({
        // 闭包主体部分
    })

    // 以下是使用尾随闭包进行函数调用
    someFunc() {
      // 闭包主体部分
    }

OK那么前面那个排序的可以用尾随闭包这么改写：

    var reversed = sorted(["c","a","d","b"]) { $0 > $1 } // d c b a

还记得我们前面写的 `map` 、 `reduce` 、 `filter` 三元大将吗？用尾随闭包可以让它们变得更好看。比如前面那个选出大于30的数字的 `filter` 就可以这样写：

    var oldArray = [10,20,45,32]
    var filteredArray  = oldArray.filter{
        return $0 > 30
    }

    println(filteredArray) // [45, 32]


## 捕获值

闭包可以捕获上下文的值，然后把它存储下来。至于存储的是引用还是拷贝，Swift 会决定捕获引用还是拷贝值，也会处理变量的内存管理操作。

下面这个例子可以说明很多问题：

    func makeIncrementor(forIncrement amount: Int) -> () -> Int {
        var runningTotal = 0
        func incrementor() -> Int {
            runningTotal += amount
            return runningTotal
        }
        return incrementor
    }

    let incrementByTen = makeIncrementor(forIncrement: 10)
    incrementByTen()    // runningTotal = 10
    incrementByTen()    // runningTotal = 20
    incrementByTen()    // runningTotal = 30

    let incrementByTen2 = makeIncrementor(forIncrement: 10)
    incrementByTen2()    // runningTotal = 10

    let incrementByTen3 = incrementByTen
    incrementByTen()    // runningTotal = 40

因为 `incrementByTen2` 声明了一个全新的闭包，所以 `runningTotal` 并没有继续接着上面的计数。而 `incrementByTen3` 和 `incrementByTen` 指向的是同一个闭包，所以 `runningTotal` 的值是累加的。



*** 

## References

- [Closures](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Closures.html)