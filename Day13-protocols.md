# 协议

## 属性协议

我们可以在协议中定义属性，下面的代码就是错误的，因为协议中定义了只读属性，但是却尝试修改其值：

    protocol FullyNamed {
        var fullName: String { get }
    }
    struct Person: FullyNamed{
        var fullName: String
    }
    let john = Person(fullName: "WHY")
    john.fullName = "WHY"   // ERROR!


## 协议合成

一个协议可由多个协议采用 `protocol<SomeProtocol， AnotherProtocol>` 这样的格式进行组合，称为协议合成(protocol composition)。

    protocol Named {
        var name: String { get }
    }
    protocol Aged {
        var age: Int { get }
    }
    struct Person: Named, Aged {
        var name: String
        var age: Int
    }
    func wishHappyBirthday(celebrator: protocol<Named, Aged>) {
        println("Happy birthday \(celebrator.name) - you're \(celebrator.age)!")
    }
    let birthdayPerson = Person(name: "Malcolm", age: 21)
    wishHappyBirthday(birthdayPerson)

## 协议实战

我们来设计一个计数器，实战练习一下协议相关的内容。

首先先定义一个协议，`CounterDataSource` ，这个协议提供了增量值，也就是说，计数器每次计数增加的数值。这个值可以是一个固定值，比如每次增一，也可以是个方法，根据不同情况返回不同的增量值。所以我们的定义如下：

    @objc protocol CounterDataSource {
        optional func incrementForCount(count: Int) -> Int
        optional var fixedIncrement: Int { get }
    }

`@objc` 表示协议是可选的，也可以用来表示暴露给Objective-C的代码，只对类有效。

接下来我们来定义一个计数器，这个计数器里有一个 `CounterDataSource` 类型的数据源。有点像是 `UITableViewDataSource` 的感觉，我们通过这个协议来获取这一次计数增加的步长。如果 `dataSource` 实现了 `incrementForCount` 方法，那么就通过这个方法来获取步长，否则看看能不能通过固定值获取步长：

    @objc class Counter {
        var count = 0
        var dataSource: CounterDataSource?
        func increment() {
            if let amount = dataSource?.incrementForCount?(count) {
                count += amount
            } else if let amount = dataSource?.fixedIncrement? {
                count += amount
            }
        }
    }


可以先用固定值的方法计数：

    class ThreeSource: CounterDataSource {
        let fixedIncrement = 3
    }

    var counter = Counter()
    counter.dataSource = ThreeSource()
    for _ in 1...4 {
        counter.increment()
        println(counter.count)
    }
    // 3
    // 6
    // 9
    // 12

也可以用方法来计数：

    class TowardsZeroSource: CounterDataSource {
    func incrementForCount(count: Int) -> Int {
            if count == 0 {
                return 0
            } else if count < 0 {
                return 1
            } else {
                return -1
            }
        }
    }

    counter.count = -4
    counter.dataSource = TowardsZeroSource()
    for _ in 1...5 {
        counter.increment()
        println(counter.count)
    }
    // -3
    // -2
    // -1
    // 0
    // 0

    

最近时间有限，简单阅读了一下官方文档。以后遇到了再补充吧。


*** 

## References

- [Protocols](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Protocols.html)