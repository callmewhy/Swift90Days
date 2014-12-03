# 截取字符串

## range

我们可以通过 Range 截取字符串的字串：

    import Foundation
    var str = "Aha, hello, why"
    let rangeOfHello = Range(start: advance(str.startIndex, 5), end: advance(str.startIndex, 10))
    let helloStr = str.substringWithRange(rangeOfHello)
    println(helloStr) // "Hello"

可以通过三点式的语法糖简化一下：

    let rangeOfHello = advance(str.startIndex, 5)..<advance(str.startIndex, 10)


## functional

如果不用 Range ，可以通过递归调用截取子串，比如这样：

    func getSubstringUpToIndex(index: Int, fromString str: String) -> String {
        let (head, tail) = (str[str.startIndex], dropFirst(str))
        if index == 1 {
            return String(head)
        }
        return String(head) + getSubstringUpToIndex(index - 1, fromString: tail)
    }

    getSubstringUpToIndex(5, fromString: "Hello, Why") // Hello


## subscript

在一开始的笔记里有提到如何写扩展来实现下标截取字串：

    import Foundation

    extension String {
        subscript (r: Range<Int>) -> String {
            get {
                let startIndex = advance(self.startIndex, r.startIndex)
                let endIndex = advance(startIndex, r.endIndex - r.startIndex)
                return self[Range(start: startIndex, end: endIndex)]
            }
        }
    }

    var s = "Aha, hello, why"
    println(s[5..<10]) // ==> "Hello"


这个扩展实际上是把 `Range<Int>` 转变成了 `Range<String.Index>` ，只是把 Range 的使用封装到了下标里。



## more

好吧本来搜到很多内容但是删删减减最后也就记录了这么点。其实截取子串本身不是什么大问题，翻来倒去的也就是一些对于 Range 的封装和使用而已。

但是我为什么专门花一章来写这个呢？

因为本来想写的其实不是这个。

但是真的忘了要写的是啥了。

好吧那今天就只能先这样了。



*** 

## References

- [Swift: Using String Ranges The Functional Way](http://natashatherobot.com/swift-string-ranges-the-functional/)
- [How To Find A Substring In Range of a Swift String](http://natashatherobot.com/swift-string-substringinrange/)
- [How do you use String.substringWithRange?](http://stackoverflow.com/questions/24044851/how-do-you-use-string-substringwithrange-or-how-do-ranges-work-in-swift)
- [Swift: Cocoaphobia](http://ericasadun.com/2014/06/17/swift-cocoaphobia/)