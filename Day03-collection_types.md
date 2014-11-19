# 集合类型

## 数组

### 重复值的初始化

除了普通的初始化方法，我们可以通过 `init(count: Int, repeatedValue: T)` 来初始化一个数组并填充上重复的值：

    // [0.0,0.0,0.0]
    var threeDoubles = [Double](count:3,repeatedValue:0.0)

### 带索引值的遍历

我们可以用 `for in` 遍历数组，如果想要 `index` 的话，可以用 `enumerate<Seq : SequenceType>(base: Seq)` ：

    let arr = ["a","b"]
    for (index, value) in enumerate(arr) {
        println("\(index):\(value)")
    }
    // 0:a
    // 1:b


## 赋值与拷贝

Swift 中数组和字典均是结构体的形式实现的，和 `NSArray` 那一套不太一样，所以赋值的时候其实是给了一份拷贝：

    let hd = Resolution(width: 1920, height: 1080)
    var cinema = hd
    cinema.height = 233
    cinema  // 1920 233
    hd      // 1920 1080


## 高阶函数

Swift 有一些 [Higher Order Functions](http://www.weheartswift.com/higher-order-functions-map-filter-reduce-and-more/) ：map、filter和reduce。使用得当的话可以省去很多不必要的代码。

### map
`map` 可以把一个数组按照一定的规则转换成另一个数组，定义如下：

    func map<U>(transform: (T) -> U) -> U[]

也就是说它接受一个函数叫做 `transform` ，然后这个函数可以把 T 类型的转换成 U 类型的并返回 (也就是 `(T) -> U`)，最终 `map` 返回的是 U 类型的集合。

下面的表达式更有助于理解：

    [ x1, x2, ... , xn].map(f) -> [f(x1), f(x2), ... , f(xn)]

如果用 `for in` 来实现，则需要这样：

    var newArray : Array<T> = []
    for item in oldArray {
        newArray += f(item)
    }


举个例子，我们可以这样把价格数组中的数字前面都加上 ￥ 符号：

    var oldArray = [10,20,45,32]
    var newArray = oldArray.map({money in "￥\(money)"})

    println(newArray) // [￥10, ￥20, ￥45, ￥32]

如果你觉得 `money in` 也有点多余的话可以用 `$0` ：
    
    newArray = oldArray.map({"\($0)€"})



### filter

方法如其名， `filter` 起到的就是筛选的功能，参数是一个用来判断是否筛除的筛选闭包，定义如下：

    func filter(includeElement: (T) -> Bool) -> [T]


还是举个例子说明一下。首先先看下传统的 `for in` 实现的方法：

    var oldArray = [10,20,45,32]
    var filteredArray : Array<Int> = []
    for money in oldArray {
        if (money > 30) {
            filteredArray += money
        }
    }
    println(filteredArray)

奇怪的是这里的代码编译不通过：

    Playground execution failed: <EXPR>:15:9: error: 'Array<Int>' is not identical to 'UInt8'
            filteredArray += money


发现原来是 `+=` 符号不能用于 `append` ，只能用于 `combine` ，在外面包个 `[]` 即可：


    var oldArray = [10,20,45,32]
    var filteredArray : Array<Int> = []
    for money in oldArray {
        if (money > 30) {
            filteredArray += [money]
        }
    }
    println(filteredArray) // [45, 32]


### reduce

`reduce` 函数解决了把数组中的值整合到某个独立对象的问题。定义如下：

    func reduce<U>(initial: U, combine: (U, T) -> U) -> U

好吧看起来略抽象。我们还是从 `for in` 开始。比如我们要把数组中的值都加起来放到 `sum` 里，那么传统做法是：


    var oldArray = [10,20,45,32]
    var sum = 0
    for money in oldArray {
        sum = sum + money
    }
    println(sum) // 107

`reduce` 有两个参数，一个是初始化的值，另一个是一个闭包，闭包有两个输入的参数，一个是原始值，一个是新进来的值，返回的新值也就是下一轮循环中的旧值。写几个小例子试一下：

    var oldArray = [10,20,45,32]
    var sum = 0
    sum = oldArray.reduce(0,{$0 + $1}) // 0+10+20+45+32 = 107
    sum = oldArray.reduce(1,{$0 + $1}) // 1+10+20+45+32 = 108
    sum = oldArray.reduce(5,{$0 * $1}) // 5*10*20*45*32 = 1440000
    sum = oldArray.reduce(0,+) // 0+10+20+45+32 = 107
    println(sum)

大概就是这些。




## 扩展

数组和字典十分常用，而官方的方法功能有限。我们可以学习[ExSwift 中 Array.swift](https://github.com/pNre/ExSwift/blob/master/ExSwift/Array.swift) 的内容，给 Array 添加一些 Extension。






*** 

## References

- [Collection Types](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/CollectionTypes.html)
- [ExSwift/Array.swift](https://github.com/pNre/ExSwift/blob/master/ExSwift/Array.swift)
- [Higher Order Functions: Map, Filter, Reduce and more – Part 1](http://www.weheartswift.com/higher-order-functions-map-filter-reduce-and-more/)
- [{(Int)} is not identical to UInt8](http://stackoverflow.com/questions/25162729/int-is-not-identical-to-uint8)