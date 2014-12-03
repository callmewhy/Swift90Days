# [Swift90Days](https://github.com/callmewhy/Swift90Days) - 可选类型

(对于可选类型的理解可以参见猫神的这篇[行走于 Swift 的世界中](http://onevcat.com/2014/06/walk-in-swift/)，在此整理一些关键的部分。)


## Optinal Value

Swift 中的 Optinal Value 就像是一个盒子，可能装着值，也可能什么都没装。

我们可以用 `?` 定义一个可选类型的整数 ：

    var num: Int?  
    num = nil  //nil  
    num = 3    //{Some 3}  

可选类型的真实身份其实是 `Optional` 类型，常用的 `?` 是 Apple 提供的语法糖。使用 `Optional` 的写法是这样的：

    var num: Optional<Int>
    num = Optional<Int>()   // nil
    num = Optional<Int>(3)  // {Some 3}

点进去看下 `Optional` 的定义：

    enum Optional<T> : Reflectable, NilLiteralConvertible {
        case None
        case Some(T)

        /// Construct a `nil` instance.
        init()

        /// Construct a non-\ `nil` instance that stores `some`.
        init(_ some: T)

        /// If `self == nil`, returns `nil`.  Otherwise, returns `f(self!)`.
        func map<U>(f: (T) -> U) -> U?

        /// Returns a mirror that reflects `self`.
        func getMirror() -> MirrorType

        /// Create an instance initialized with `nil`.
        init(nilLiteral: ())
    }

这样一来，`var num: Int? = 3` 其实就是 `Optional.Some(3)`。

在这里，`?` 声明了一个 `Optional<T>` 类型的变量，然后做了判断：

- 如果等号右边是 nil ，则赋值为 `Optional.None` 
- 如果等号右边不是 nil ，则通过 `init(_ some: T)` 初始化并返回 `Optional.Some(T)` 。



## Force Unwraps

在遭遇可选类型的时候，我们可以在 Optional 变量后面加上 `!` 进行强制解包。这样虽然减少了代码量，但是容易带来隐患，使用的时候务必要慎重。就像是过马路一样，一定要仔细看好两边车辆，否则悲剧随时可能发生。

而实际上，很多时候可以避免使用 `!` ，用其他方法取而代之。

来看这样一个例子：

    let ages = [
        "Tim":  53,  "Angela": 54,  "Craig":   44,
        "Jony": 47,  "Chris":  37,  "Michael": 34,
    ]
    let people = sorted(ages.keys, <).filter { ages[$0]! < 50 }
    println(people) // "[Chris, Craig, Jony, Michael]"

在这里先对 `ages` 进行了排序，然后筛选出年纪小于 50 的人。因为是对字典取值，会出现 `nil` ，所以 `ages[$0]` 是 optional 的，需要进行解包。

当然也可以用 `if let` ：

    let people = sorted(ages.keys, <).filter {
        if let age = ages[$0] {
            return age < 50
        }
        return false;
    }

但是本来一行就能搞定的问题却拖沓到了五行才解决。实际上，换个思路，我们完全不需要遭遇可选类型：

    let people = filter(ages) { $0.1 < 50 }.map { $0.0 }.sorted(<)

`filter` 中 $0 表示传入的 key-value ，$0.1 表示 value，`map` 中 $0 表示传入的 key-value ，$0.0 表示 key 。或许这样可读性比较差，可以通过 tuple 包装一下入参：

    let people = filter(ages) { (k,v) in v < 50 }.map { (k,v) in k }.sorted(<)


在平时的开发中，我们可以用 `if let` 或者 `??` 替换掉 `!` 。如果确实确实肯定不会出问题再去用 `!` 。


## Implicitly Unwrapped Optionals

同样是 `!` 符号，如果放在类型后面，则表示隐式解析可选类型 (Implicitly Unwrapped Optionals)：

    var num: Int!
    num = 1     // 1
    num = nil   // nil

通过 `!` 定义的变量，实质上只是对 Optional 的变量多了一层封装，帮我们完成了原本需要手动解包的过程。

在什么场合下可以使用隐式解析可选类型呢？

### 场景1：无法在初始化方法中定义的常量

有些尴尬的情况，我们想定义常量属性，无奈它的初始化依赖于其他属性值。如果你用可选类型，实在是麻烦，因为你确信无疑它肯定会在调用之前就完成初始化，不可能是 `nil` ，这个时候你可以用 `!` 进行定义。

举个例子：

    class MyView : UIView {
        @IBOutlet var button : UIButton
        var buttonOriginalWidth : CGFloat!
        
        override func viewDidLoad() {
            self.buttonOriginalWidth = self.button.frame.size.width
        }
    }

这部分内容在 [Day11](https://github.com/callmewhy/Swift90Days/blob/master/Day11-initialization.md) 中有涉及，其实更好的方法是用 lazy 延时加载，不再赘述。

### 场景2：与 objc 进行交互

隐式解析可选类型似乎是为了照顾 objc 这个历史包袱而存在。比如 `UITableView` 中：

    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell? { return nil }

我们很清楚的知道，在调用的时候 `tableView` 和 `indexPath` 不可能为 `nil` ，如果还要 `if let` 这样解包实在是浪费时间。如果是纯粹的 Swift 语言写的，绝对不会定义成 optional 类型。

### 什么时候不该用

除了上述的情况2 ，其他情况都不该用 (包括情况1)。


*** 

## References

- [Running Totals and Force Unwraps](http://airspeedvelocity.net/2014/11/27/running-totals-and-force-unwraps/)
- [Uses for Implicitly Unwrapped Optionals in Swift](http://www.drewag.me/posts/uses-for-implicitly-unwrapped-optionals-in-swift)
- [Walk in Swift](http://onevcat.com/2014/06/walk-in-swift/)