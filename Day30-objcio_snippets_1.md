# [Swift90Days](https://github.com/callmewhy/Swift90Days) - objc.io 的 Swift 片段 1


[objcio](http://www.objc.io/) 上的文章质量都很高，最近攒了十期，一起看下 Swift 相关的一些小贴士。

### 分解数组

我们可以通过下面这个扩展给 Array 加上一个分解方法，返回首个元素和剩下的元素组成的元组：

    extension Array {
        var decompose : (head: T, tail: [T])? {
            return (count > 0) ? (self[0], Array(self[1..<count])) : nil 
        }
    }

比如[1,2,3]，就会拆解成 (1,[2,3]) 返回。我们可以用这个扩展写一个求和程序：

    func sum(xs: [Int]) -> Int {
        if let (head, tail) = xs.decompose {
            return head + sum(tail)
        } else {
            return 0
        }
    }


### 函数拼接

比如我们需要一个函数来获取网页的内容，再通过一个函数来计算有多少换行符。这样可以获取指定网址里换行符：


    import Foundation

    func getContents(url: String) -> String {
        return NSString(contentsOfURL: NSURL(string: url)!,
            encoding: NSUTF8StringEncoding, error: nil)!
    }

    func lines(input: String) -> [String] {
        return input.componentsSeparatedByCharactersInSet(
            NSCharacterSet.newlineCharacterSet())
    }

    let linesInURL = { url in countElements(lines(getContents(url))) }

    println(linesInURL("http://www.objc.io"))

因为在函数式编程里，函数的包含调用十分常见，我们可以定义一个自己的运算符：

    infix operator >>> { associativity left }
    func >>> <A, B, C>(f: B -> C, g: A -> B) -> A -> C {
        return { x in f(g(x)) }
    }

这样就可以这样调用了：


    let linesInURL = countElements >>> lines >>> getContents
    println(linesInURL("http://www.objc.io"))


*** 

## References

- [Decomposing Arrays](http://www.objc.io/snippets/1.html)
- [Function Composition](http://www.objc.io/snippets/2.html)