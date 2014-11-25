# 闭包

## 简介 (真的很简)

闭包的完整形态是这个样子的：

    { (parameters) -> returnType in
        statements
    }

写在一行里就是这样：

    {(parameters) -> (returnType) in statements}


## 形式

闭包以三种形式存在：

    1.全局的函数都是闭包，它们有自己的名字，但是没有捕获任何值。
    2.内嵌的函数都是闭包，它们有自己的名字，而且从包含他们的函数里捕获值。
    3.闭包表达式都是闭包，它们没有自己的名字，通过轻量级的语法定义并且可以从上下文中捕获值。



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




## 参数缩写

我们可以直接用 `$0 $1 $2` 这种来依次定义闭包的参数。比如 `sorted` 函数：

    var reversed = sorted(["c","a","d","b"], { $0 > $1 })   // d c b a


## 尾随闭包

我一直觉得闭包最后这个 `})` 很难看，在 JS 中随处可见这种情况。如果闭包是函数的最后一个参数，Swift 提供了尾随闭包 (Trailing Closures) 解决这个审美问题：

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


如果除了闭包没有其他参数了，甚至可以把小括号也去掉。

还记得我们前面写的 `map` 、 `reduce` 、 `filter` 三元大将吗？用尾随闭包可以让它们变得更好看。比如前面那个选出大于30的数字的 `filter` 就可以这样写：

    var oldArray = [10,20,45,32]
    var filteredArray  = oldArray.filter{
        return $0 > 30
    }

    println(filteredArray) // [45, 32]

## 变形

变形金刚神马的最有爱了。总结一下 `closure` 的变形大致有以下几种形态：

    [1, 2, 3].map( { (i: Int) ->Int in return i * 2 } )
    [1, 2, 3].map( { i in return i * 2 } )
    [1, 2, 3].map( { i in i * 2 } )
    [1, 2, 3].map( { $0 * 2 } )
    [1, 2, 3].map() { $0 * 2 }
    [1, 2, 3].map { $0 * 2 }


## 对比

通过 UIView 的 `animateWithDuration` 方法对 block 和 closure 进行简单的对比。

block 版本：

    [UIView animateWithDuration:1 animations:^{
        // DO SOMETHING
    } completion:^(BOOL finished) {
        NSLog(@"OVER");
    }];

closure 版本：

    UIView.animateWithDuration(1, animations: { () in 
        // DO SOMETHING
        }, completion:{(Bool)  in
            println("OVER")
        })

可以看到原来的 `^` 符号已经不复存在，取而代之的是加在参数和返回值后面的 `in` 。注意，如果有 `in` 的话，就算没有参数没有返回值也一定需要 `()` ，否则会报错。




## 总结

和 Objective-C 的 [FuckingBlock](http://fuckingblocksyntax.com/) 一样，Swift 出来之后 [FuckingClosure](http://fuckingclosuresyntax.com/) 也就应运而生。总结了 Closure 的常用语法和格式：

    // 作为变量
    var closureName: (parameterTypes) -> (returnType)

    // 作为可选类型的变量
    var closureName: ((parameterTypes) -> (returnType))?

    // 做为一个别名
    typealias closureType = (parameterTypes) -> (returnType)
    
    // 作为函数的参数
    func({(parameterTypes) -> (returnType) in statements})

    // 作为函数的参数
    array.sort({ (item1: Int, item2: Int) -> Bool in return item1 < item2 })
    
    // 作为函数的参数 - 隐含参数类型
    array.sort({ (item1, item2) -> Bool in return item1 < item2 })

    // 作为函数的参数 - 隐含返回类型
    array.sort({ (item1, item2) in return item1 < item2 })

    // 作为函数的参数 - 尾随闭包
    array.sort { (item1, item2) in return item1 < item2 }

    // 作为函数的参数 - 通过数字表示参数
    array.sort { return $0 < $1 }

    // 作为函数的参数 - 尾随闭包且隐含返回类型
    array.sort { $0 < $1 }

    // 作为函数的参数 - 引用已存在的函数
    array.sort(<)


*** 

## References


- [Closures](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Closures.html)
- [Closure Expressions in Swift](http://www.codingexplorer.com/closure-expressions-swift/)
- [Fucking Closure](http://fuckingclosuresyntax.com/)
- [Writing completion blocks with closures in Swift](https://www.codefellows.org/blog/writing-completion-blocks-with-closures-in-swift)
- [Enough About Swift Closures to Choke a Horse](http://www.informit.com/articles/article.aspx?p=2234250)
- [Functions and Closures in Swift](http://code.martinrue.com/posts/functions-and-closures-in-swift)
- [Swift How-To: Writing Trailing Closures](http://www.willowtreeapps.com/blog/10-ways-to-write-a-trailing-closure-in-swift/)