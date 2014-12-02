# 字符串进阶

## 计算字符串长度

我们有两种方法可以计算字符串的长度。

### distance(str.startIndex, str.endIndex)
    
`distance` 的定义如下：

    func distance<T : ForwardIndexType>(start: T, end: T) -> T.Distance

从定义来看， `distance` 可以输入起点和终点，然后返回期间的距离，传入的参数必须实现了 `ForwardIndexType` 协议。

接下来再看下 `String` 的 `startIndex` 和 `endIndex` 。这两个 index 都是 `String.Index` 类型的，用来定义字符的位置，它是遵守 `BidirectionalIndexType` 这个协议的，而这个协议继承自 `ForwardIndexType` 这个协议，所以它可以作为参数传入。



### countElements(str)

`countElements` 的定义如下：

    func countElements<T : _CollectionType>(x: T) -> T.Index.Distance

只需要是 `_CollectionType` 类型的参数即可，返回的是传入参数的索引值的步长。也就是说其实不一定返回的都是数字，也有可能是其他值。这个有待探索了。



## 前进几个单位

人如其名， `advance` 就是将值向前推进几个单位然后返回。比如 `advance(1,2)` 就是将1前进2个单位，返回的就是3。

定义如下：

    func advance<T : ForwardIndexType>(start: T, n: T.Distance) -> T

有了这个我们可以做很多事情。

比如获取字符：

    var str = "Hello, WHY"
    str[advance(str.startIndex, 7)] // W

比如截取子串：

    var str = "Hello, WHY"
    str[advance(str.startIndex, 7)...advance(str.startIndex, 9)] // WHY

为什么需要套个 `advance` 才可以返回子串呢？因为 `String` 下标的写法，定义是这样的：

    extension String : Sliceable {
        subscript (subRange: Range<String.Index>) -> String { get }
    } 

下标的参数必须是 `Range<String.Index>` 类型，而 `advance` 返回的是输入的参数的类型，也就是 `String.Index` ，而 `...` 返回了 `Range` 类型刚好满足条件。


## 一些首尾操作

我们可以通过以下函数进行一些简单的首尾元素的操作：

    last(str) // 获取最后一个元素
    first(str) // 获取第一个元素
    dropFirst(str) // 移除第一个元素
    dropLast(str) // 移除最后一个元素

看下定义发现只要是 `CollectionType` 的就可以了，所以也可以传入数字数组：

    var a = [1,2,3]
    last(a)         // 3
    first(a)        // 1
    dropFirst(a)    // 2,3
    dropLast(a)     // 1,2

## 筛选和其他

我们可以通过 `filter` 对字符串进行筛选。比如下面这段代码去掉了字符串中的元音字母：

    filter(str, {!contains("aeiou", $0)}) // 移除元音

这个和前面数组的用法是一样的，同样的还有 `map` 和 `reduce` ：
    
    map(str, { "$\($0)"})
    reduce(str,"",{ "\($0)-\($1)" })

## 获取字符串的范围

我们可以通过 `indices` 返回字符串的范围：

    var str = "Hello, why"
    indices(str)    // 0..<10

`indices` 函数定义如下，只要是集合类型的作为入参即可：

    func indices<C : CollectionType>(x: C) -> Range<C.Index>


## 是否包含

可以通过 `contains` 检查是否包含子串：

    contains("Hello", "e")  // true

定义如下：

    func contains<S : SequenceType where S.Generator.Element : Equatable>(seq: S, x: S.Generator.Element) -> Bool

只要元素是 `Equatable` 的，都可以通过 `contains` 检查序列中是否存在这个元素。比如数组：

    contains([1,2,3], 5)  // false



## 组合实现逆序

我们可以通过各种组合快速实现字符串逆序的功能：

    var str = "Hello, why"
    var revStr = ""
    for _ in str {
        revStr.append(last(str)!)
        str = dropLast(str)
    }
    println(revStr) // yhw ,olleH

当然你也可以直接用 `reserve` 函数：

    var str = "Hello, why"
    reverse(str)


## 组合实现查找子串

我们可以通过一套组合拳实现子串的查找：

    extension String {
        // 返回子串的搜索结果，返回 Range 的数组
        func rangesOfString(findStr:String) -> [Range<String.Index>] {
            // 存储返回的结果
            var arr = [Range<String.Index>]()
            // 存储开始的位置
            var startIndex = self.startIndex
            // 如果包含子串的第一个字符
            if contains(self, first(findStr)!) {
                // 获取起始位置
                startIndex = find(self,first(findStr)!)!
                // 初始化计数
                var i = distance(self.startIndex, startIndex)
                // 当 i 小于可能值的时候 (等于情况是边界条件，即刚好子串出现在最后)
                while i <= countElements(self) - countElements(findStr) {
                    // 按照子串的长度截取子串
                    var tempStr = self[advance(self.startIndex, i)..<advance(self.startIndex, i+countElements(findStr))]
                    // 如果子串匹配成功
                    if tempStr == findStr {
                        // 存储结果
                        arr.append(Range(start:advance(self.startIndex, i),end:advance(self.startIndex, i+countElements(findStr))))
                        // 将计数器位置推进到匹配结果的尾部继续匹配
                        i = i+countElements(findStr)
                    }
                    i++
                }
            }
            return arr
        }
    }


    "hello, why hello".rangesOfString("hello")  // [0..<5,11..<16]



## 精子符号 ~>

Swift 中有个神奇的精子符号：`~>` 。定义是这个样子的：

    func ~><T : _ForwardIndexType>(start: T, rest: (_Advance, T.Distance)) -> T
    func ~><T : _ForwardIndexType>(start: T, rest: (_Advance, (T.Distance, T))) -> T
    func ~><T : _BidirectionalIndexType>(start: T, rest: (_Advance, T.Distance)) -> T
    func ~><T : _BidirectionalIndexType>(start: T, rest: (_Advance, (T.Distance, T))) -> T
    func ~><T : _RandomAccessIndexType>(start: T, rest: (_Advance, (T.Distance))) -> T
    func ~><T : _RandomAccessIndexType>(start: T, rest: (_Advance, (T.Distance, T))) -> T
    func ~><T : _RandomAccessIndexType>(start: T, rest: (_Distance, (T))) -> T.Distance
    func ~><T : _ForwardIndexType>(start: T, rest: (_Distance, T)) -> T.Distance

我们可以这样调用：

    let advanceBy5 = _advance(5)    // (_Advance, Int)
    1~>advanceBy5   // 6

后来搜到了这篇文章：[Tilde Arrow in Swift](http://andelf.github.io/blog/2014/06/25/tilde-arrow-in-swift/)。

嗯看的我瞬间崩溃了完全看不懂。献上膝盖下午慢慢看。。。


*** 

## References

- [A pure Swift method for returning ranges of a String instance](http://sketchytech.blogspot.com/2014/08/swift-pure-swift-method-for-returning.html)
- [A Look At Swift's Elusive ~> Operator](http://natecook.com/blog/2014/11/swifts-elusive-tilde-gt-operator/?utm_campaign=This_Week_in_Swift_19&utm_medium=email&utm_source=This%2BWeek%2Bin%2BSwift)
- [Swift Standard Library](http://andelf.github.io/blog/2014/06/06/swift-standard-library/)