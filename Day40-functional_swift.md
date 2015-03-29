# [Swift90Days](https://github.com/callmewhy/Swift90Days) - 用函数式编程解决逻辑难题

> 这篇翻译的文章，用两种方法解决了同一个逻辑难题。第一种方法的编程风格接近大多数 iOS 开发者，实现了指令式编程的解决方案。第二种方法利用了 Swift 的一些语言特性，实现了函数式编程的解决方案。

> 源代码可以在这里下载：[https://github.com/ijoshsmith/break-a-dollar](https://github.com/ijoshsmith/break-a-dollar)

## 逻辑难题

前阵子朋友和我说起，把1美元分解成更小的面额，有293种方法。换句话说，如果一个哥们儿告诉你他有1美元，那么他的手里有293种可能的组合，有可能是两个50美分，也可能是4个25美分。第二天，我就开始尝试用代码去解决这个问题。这篇博客回顾了当时想到的两种解决方案。


## 美元硬币

对于不熟悉美元硬币的同学，可以先了解一下美元的硬币。如下图所示，1美元(dollar) = 100美分(cent)：

![](https://ijoshsmith.files.wordpress.com/2014/11/coins1.jpg?w=960&h=296)


## 初探问题

思考后我发现用一种比较简单肮脏的手段解决这个问题并不难，但是这还远远不够。我想找到一种优雅的解决方案，所以我尝试从各个角度思考这个问题，最终得到了想要的答案。

解决这个问题的关键在于递归的分解问题。“如何用各种硬币组合拼成1美元”，更宽泛点讲，其实就是“如何用各种硬币组合拼成指定金额”。

举个人民币的例子。你欠人家100块，人家说你100块都不给我。你说好，我给！于是掏出两张50，这便是一个50+50的解决方案。
这时你发现有一张是崭新的50，你不想给他这张50，于是你的问题变成了：如何用手里的碎钱组合出50面额的钱。
后来你把50换成了5张10块，这便是一个50+10*5的解决方案，然后感觉有一张10块是崭新的，要不我换成硬币给他。
于是问题又变成了：如何组合出10面额的钱。就是这样慢慢拆分下去。

点击 [这里](https://github.com/ijoshsmith/break-a-dollar/blob/master/DollarBreak/algorithm_overview.txt) 查看完整的算法回顾。

## 先造硬币

我多次提到“硬币”这个词，实际上一枚硬币也就是一个整数值，代替了它价值多少美分。我写一个枚举类存储所有的硬币面额，然后再用一个静态方法降序返回所有的值：

    enum Coin: Int {
        case SilverDollar = 100
        case HalfDollar   = 50
        case Quarter      = 25
        case Dime         = 10
        case Nickel       = 5
        case Penny        = 1
        
        static func coinsInDescendingOrder() -> [Coin] {
            return [
                Coin.SilverDollar,
                Coin.HalfDollar,
                Coin.Quarter,
                Coin.Dime,
                Coin.Nickel,
                Coin.Penny,
            ]
        }
    }


## 解决方案1：指令式编程 - Imperative

指令式编程的一个重要观点是：变量改变状态。指令式的程序像是一种微型控制器，它告诉计算机如何完成任务。接下来的 Swift 代码大家看起来应该都不陌生，因为 objc 就是一种指令式的编程语言：


    func countWaysToBreakAmout(amount: Int, usingCoins coins:[Coin]) -> Int{
        let coin = coins[0]
        if (coin == .Penny) {
            return 1
        }
        
        var smallerCoins = [Coin]()
        for index in 1..<coins.count {
            smallerCoins.append(coins[index])
        }
        
        var sum = 0
        for coinCount in 0...(amount/coin.rawValue) {
            let remainingAmount = amount - (coin.rawValue * coinCount)
            sum += countWaysToBreakAmout(remainingAmount, usingCoins: smallerCoins)
        }
        
        return sum
    }


仔细看下上面的代码，计算过程一共分三步：

- 首先取出可用数组中的第一个硬币，如果这枚硬币已经是 1 美分，也就是最小的面额，那没有继续拆分的可能性，直接返回1作为结束。
- 然后创建了一个数组 (`smallerCoins`) ，存储比当前硬币更小的硬币，用来作为下次调用的参数。
- 最后计算除去第一次取出的硬币之后，还有多少种解决方案。

这样的代码对于指令式编程来说再平常不过，接下来我们就来看下如何用函数式编程解决这个问题。

## 解决方案2：函数式编程 - Functional

函数式编程的依赖对象，是函数，而不是状态变化。没有太多的共享数据，就意味着发生错误的可能性更小，需要同步数据的次数也越少。 Swift 中函数已经是一等公民，这让[高阶函数](http://zh.wikipedia.org/wiki/%E9%AB%98%E9%98%B6%E5%87%BD%E6%95%B0)变成可能，也就是说，一个函数可以是通过其它函数组装构成的。随着 objc 中 block 的引入， iOS 开发者对这个应该并不陌生。

下面是我的函数式解决方案：

    func countWaysToBreakAmount(amount: Int, usingCoins coins:Slice<Coin>) -> Int{
        let (coin, smallerCoins) = (coins[0], coins[1..<coins.count])
        if (coin == .Penny) {
            return 1
        }
        let coinCounts = [Int](0...amount/coin.rawValue)
        return coinCounts.reduce(0) { (sum, coinCount) in
            let remainingAmount = amount - (coin.rawValue * coinCount)
            return sum + self.countWaysToBreakAmount(remainingAmount, usingCoins: smallerCoins)
        }
    }

第二个参数是 `Slice<Coin>` 而不是数组，因为没必要把硬币拷贝到新的数组里。我们只需要用数组的一个切片就可以，也就是第一行代码里的 `smallerCoins` ，在函数式编程里称之为 `tail` 。我们把数据中的第一个元素称之为 `head` ，剩下来的部分称之为 `tail` 。将数组进行切分在下标越界的情况下也不会引发异常。如果数组中只剩下一个元素，这时 `smallerCoins` 就为空。

我用元组的语法同时获取了 `coin` 和 `smallerCoins` 这两个数据，因为取头取尾可以说是同一个操作。与其写一堆代码去解释如何先取出第一个元素，然后再获取剩下的元素，不如直接用“取出头部和尾部”这样语义化的方式一步到位。

接下来，也并没有采用循环然后改变局部变量的方法来计算剩余的组合数，而是用 `reduce` 这个高阶函数。如果你对 `reduce` 这个函数不太熟悉，可以看下[这篇文章](http://ijoshsmith.com/2014/06/25/understanding-swifts-reduce-method/)有个大概的了解。

首先 `coin` 指当前处理的硬币， `coinCounts` 是一个数组，里面存储了所有当前面额的硬币的可能出现的数目。比如 `amount` 是10， `coin` 是3，那么 `coinCounts` 的值就是，面额为3的硬币可能有多少。显然应该最多出现3个，所以 `coinCounts` 是 [1,2,3] 这样的一列数。然后在分别对每种情况进行分解计算。

## 思考

Swift 对于函数式编程的支持让我感觉的兴奋，Excited！换种方式思考或许是个不小的挑战，但是这都是值得的。几年前我自学了一些 Haskell ，我很欣喜的发现一些函数式思考习惯，让我在 iOS 开发中也能受益匪浅。

示例项目的源代码可以在[这里](https://github.com/ijoshsmith/break-a-dollar)下载。


---

原文地址：

- [Getting into functional programming with Swift](http://ijoshsmith.com/2014/11/30/getting-into-functional-programming-with-swift/)