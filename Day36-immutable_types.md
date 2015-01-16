# [Swift90Days](https://github.com/callmewhy/Swift90Days) - 状态可变的不可变类型

## 背景

摘录了一部分[原文](http://www.andrewcbancroft.com/2015/01/06/immutable-types-changing-state-swift/)的内容记录一下，观点未必完全正确，但是有参考的必要。

## 简介

函数式编程中有个很重要的概念：不可变。但是在实际的开发过程中，又常常为这三个字所困扰：对象的状态总归是经常要变化的，如何才能既可变又不可变？

在函数式编程里，对于状态的改变，我们可以简单的返回一个新的对象，而不是修改对象的状态。

## 对比

不妨先看一看 `mutating` 的方式：

    class Scorekeeper {
        var runningScore: Int
        
        init (score: Int = 0) {
            self.runningScore = score
        }
        
        func incrementScoreBy(points: Int) {
            runningScore += points
        }
    }
     
    let scoreKeeper = Scorekeeper()
    scoreKeeper.incrementScoreBy(5)
    println(scoreKeeper.runningScore)
    // prints 5


再看一下 `immutable` 的方式：

    class Scorekeeper {
        let runningScore: Int
        
        init (score: Int = 0) {
            self.runningScore = score
        }
        
        func incrementScoreBy(points: Int) -> Scorekeeper {
            return Scorekeeper(score: self.runningScore + points)
        }
    }
     
    let scorekeeper = Scorekeeper()
    let scorekeeperWithIncreasedScore = scorekeeper.incrementScoreBy(5)
    println(scorekeeperWithIncreasedScore.runningScore)


## 观察

对比一下上面的两个例子：

- 第一个例子使用 `var` 定义 `Scorekeeper` 实例对象，因为它必须是可变的。
- 第二个例子使用 `let` 定于 `Scorekeeper` 实例对象，因为这个对象没有任何变化。
- 第一个例子容易产生有趣而不可预知的副作用。如果多个外部对象持有了 `scorekeeper` 这个实例，那么现在有两种方式改变 `runningScore` ：一种是重新给 `runningScore` 赋值，另一种是调用 `incrementScoreBy()` 这个方法。不管是哪一种方法，因为状态是可编辑的，所以都有可能会导致不可预知的问题。
- 第二个例子则不会有无法预知的问题，因为 `runningScore` 是无法直接编辑的 (它是常量) 。而 `incrementScoreBy()` 返回的是一个全新的变量，所以所有的持有 `scorekeeper` 的外部对象在访问的时候都能获取到理想的结果。
- 第一个例子的 `incrementScoreBy()` 方法没有返回值。想象一下如果我要写个单元测试，第一眼看过去很容易不知所措。
- 第二个例子的 `incrementScoreBy()` 返回一个新的对象，单元测试对我来说就清晰多了。

## 结论

避免直接的状态变化让我受益匪浅，在现有的 iOS 框架里，“不可变”无疑是充满挑战的，而且完全的“不可变”也是不可能的。

即使如此，我觉得从这件事情中也受益很多，至少引导我进行了一些良心的思考。这便足够了。


***

参考文档：

- [Immutable Types with Changing State in Swift](http://www.andrewcbancroft.com/2015/01/06/immutable-types-changing-state-swift/)
- [How can you do anything useful without mutable state?](http://stackoverflow.com/questions/1020653/how-can-you-do-anything-useful-without-mutable-state)