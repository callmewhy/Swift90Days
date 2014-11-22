# Swift 中的柯里化

新手上路的学习笔记，如有错误还望指出，不胜感激。

## 上集：什么是柯里化

在了解 Swift 中的柯里化之前，不妨先抛弃 Swift ，纯粹的了解一下柯里化。

维基百科中这样定义[柯里化](http://zh.wikipedia.org/zh/%E6%9F%AF%E9%87%8C%E5%8C%96)：

> 柯里化（英语：Currying）是把接受多个参数的函数变换成接受一个单一参数（最初函数的第一个参数）的函数，并且返回接受余下的参数而且返回结果的新函数的技术。

这定义看的我也是醉了。

再看一下[这篇文章](http://real-wolrd-haskell-note.readthedocs.org/en/latest/chp4.html#currying-partial-function)中的解释：

> 柯里化是将一个接受多个参数的函数变换成一个只接受一个参数的新函数，当有参数传入这个新函数之后，这个新函数又返回一个新函数，以此类推，直到所有参数都被传入之后，函数返回之前通过多个参数计算出来的值。

这样似乎清晰了一点，我们不妨再看一些 JS 的例子来辅助理解。

我们先在 JS 中定义一个 `add(a, b)` 的函数：

    var add = function(a, b){ return a + b }
    add(1, 2) // 3

这个函数就是原始函数，是一个有多个参数的函数，是一个老老实实的普通函数。

柯里化，则将一个有多个参数的函数，转换为一系列函数，每个函数接受一个参数。上面一段代码可以这样进行柯里化：

    var curry = require('curry')
    var add = curry(function(a, b){ return a + b })
    var add100 = add(100)
    add100(1) // 101

如果参数再多一点，比如 `add(1,2,3)` 这样的函数，柯里化之后就是这样：

    var sum3 = 
    (function(a, b, c){ return a + b + c })
    sum3(1)(2)(3) // 6





## 中集：Swift 中的柯里化

## 下集：思考回顾


使用 Mac 的朋友可以下载 [Haskell Platform for Mac](https://www.haskell.org/platform/mac.html) ，然后通过 `ghci` 命令试一试 Haskell 的代码。



*** 

## References

- [Wikipedia - Currying](http://en.wikipedia.org/wiki/Currying)
- [What is the advantage of currying?](http://programmers.stackexchange.com/questions/185585/what-is-the-advantage-of-currying)
- [Currying and Partial Function)](http://real-wolrd-haskell-note.readthedocs.org/en/latest/chp4.html#currying-partial-function)
- [Why Curry Helps](http://hughfdjackson.com/javascript/why-curry-helps/)
- [Function Scala](http://www.ibm.com/developerworks/cn/java/j-lo-funinscala3/)


- [Curried Functions in Swift](http://ijoshsmith.com/2014/06/09/curried-functions-in-swift/)
- [Swift Function Currying](http://blog.xebia.com/2014/11/06/swift-function-currying/)
- [Instance Methods are Curried Functions in Swift](http://oleb.net/blog/2014/07/swift-instance-methods-curried-functions/)
