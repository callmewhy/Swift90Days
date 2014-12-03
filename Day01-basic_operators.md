# [Swift90Days](https://github.com/callmewhy/Swift90Days) - 基本运算符

今天主要看的内容是 Swift 中的基本运算符。记录一下。


## Nil Coalescing Operator
`a ?? b` 中的 `??` 就是是空值合并运算符，会对 `a` 进行判断，如果不为 `nil` 则解包，否则就返回 `b` 。

    var a: String? = "a"
    var b: String? = "b"
    var c = a ?? b      // "a"
    a = nil
    c = a ?? b          // "b"
    b = nil
    c = a ?? b ?? "c"   // "c"


使用的时候有以下两点要求：

- a 必须是 optional 的
- b 必须和 a 类型一致

也就是说，a 一定要有被备胎的可能，b 一定要有做备胎的资格。

其实也就是对三目运算符的简写：

`a != nil ? a! : b` 或者 `a == nil ? b : a!`


当然你也可以通过自定义运算符来实现：

    infix operator ||| {}

    func |||<T> (left: T?, right: T) -> T  {
        if let l = left { 
            return l 
        }
        return right
    }

    var a:String?
    var b = "b"
    var c = a ||| b

C# 中也有个 [`??`](http://msdn.microsoft.com/en-us/library/ms173224.aspx) ，感兴趣的可以去了解一下。


## Range Operator

区间运算符分为闭区间 (`...`) 和左闭右开区间 (`..<`) 两种，前者是算头算尾，后者是算头不算尾。

可以应用在 switch 中：

    switch aNumber
    {
    case 0...5:
        println("This number is between 0 and 5")
    case 6...10:
        println("This number is between 6 and 10")
    default:
        println("This number is not between 0 and 10")
    }

区间运算符其实返回的是一个 `Range<T>` 对象，是一个连续无关联序列索引的集合。

话说以前左闭右开是 `..` ，这样和 Ruby 的就刚好完全相反了。。。

不过有人就是想用 `..` ，那么可以[这样](http://angelovillegas.com/2014/07/15/swift-range-operators/)自己写一个：

    infix operator .. { associativity none precedence 135}

    func .. (lhs: Int, rhs: Int) -> Range<Int> {
        return lhs..<rhs
    }

    for i in 0..10 {
        println("index \(i)")
    }


你也可以用 generate() 来遍历：

    var range = 1...4
    var generator = range.generate()    // {startIndex 1, endIndex 5}
    generator.next() // 1
    generator.next() // 2
    generator.next() // 3
    generator.next() // 4
    generator.next() // nil

`.generate()` 返回一个 `RangeGenerator<T>` 的结构体，可以用来遍历 `Range<T>` 中的值。


以前还有个 [`(5...1).by(-1)`](http://ericasadun.com/2014/06/18/swift-the-lone-range-r/) 的用法，不过现在好像没用了。

区间运算符返回的是一个 `ClosedInterval` 或者 `HalfOpenInterval` 的东西，类型只要是 Comparable 就可以了。所以我们也可以把 String 放到 `...` 里。

比如猫神的 [Swifter Tips](http://swifter.tips/) 中有一章的代码如下，通过 String 的 ClosedInterval 来输出字符串中的小写字母：

    let test = "Hello"
    let interval = "a"..."z"

    for c in test {
        if interval.contains(String(c)) {
            println("\(c)")
        }
    }


## SubString

Ruby 中用点点点来获取 SubString 的方法很方便：

    2.1.3 :001 > a="abc"
     => "abc"
    2.1.3 :002 > a[0]
     => "a"
    2.1.3 :003 > a[0..1]
     => "ab"

而 Swift 中的 ClosedInterval 是没有 subscript 的。但是任性的我们就是要用 `[1...3]` 这种方法怎么办呢？
自己动手丰衣足食，写个 extension 吧，只需要加个 `subscript` 就可以了，然后下标的类型是 `Range<Int>` 就可以了：

    extension String {
        subscript (r: Range<Int>) -> String {
            get {
                let startIndex = advance(self.startIndex, r.startIndex)
                let endIndex = advance(startIndex, r.endIndex - r.startIndex)
                
                return self[Range(start: startIndex, end: endIndex)]
            }
        }
    }

    var s = "Hello, playground"

    println(s[0...5]) // ==> "Hello,"
    println(s[0..<5]) // ==> "Hello"

如果要搜索目标字符串之后再截取 substring 可以这样：

    let name = "Joris Kluivers"

    let start = name.startIndex
    let end = find(name, " ")

    if (end != nil) {
        let firstName = name[start..<end!]
    } else {
        // no space found
    }


*** 

## References

- [Swift Operators](http://nshipster.com/swift-operators/)
- [Does Swift have a null coalescing operator](http://stackoverflow.com/questions/24082959/does-swift-have-a-null-coalescing-operator-and-if-not-what-is-an-example-of-a-c)
- [Swift: Range Operators](http://angelovillegas.com/2014/07/15/swift-range-operators/)
- [How do you use String.substringWithRange? ](http://stackoverflow.com/questions/24044851/how-do-you-use-string-substringwithrange-or-how-do-ranges-work-in-swift)
- [Advanced Operators](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/AdvancedOperators.html)
- [Collection Types](https://developer.apple.com/library/ios/documentation/swift/conceptual/Swift_Programming_Language/CollectionTypes.html)
- [Swift Range Operators](http://angelovillegas.com/2014/07/15/swift-range-operators/)
- [Loops, Switch Statements, and Ranges in Swift](http://www.codingexplorer.com/loops-switch-statements-ranges-swift/)
- [Swifter Tips](http://swifter.tips/)