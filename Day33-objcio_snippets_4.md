# [Swift90Days](https://github.com/callmewhy/Swift90Days) - objc.io 的 Swift 片段 4


## 类型封装

比如我们有个这样的函数，计算账户的信誉值：

    func credits(account: Account) -> Int

不过在代码里你可能看到 `int` 类型的结果不知道它是用来描述什么的。所以使用 `typealias` 就十分有用了：

    typealias Credits = Int

    func credits(account: Account) -> Credits 

你也可以做的更深入一些：

    struct Credits { let amount: Int }

这样有一个好处就是当尝试把这个值和整数直接相加的时候会有个警告。比如这种操作：

    Credits(amount: 0) + 1

## 可选类型

`map` 大家都不陌生，其实它除了用来处理数组，也可以用于可选类型的解包操作。虽然标准库中已经有了，但是我们可以简单的重写一下：

    func map<A, B>(x: A?, f: A -> B) -> B? {
        if let x1 = x {
            return f(x1)
        }
        return nil
    }

对于这样一段代码：

    let url: NSURL? = NSURL(string: "image.jpg")
    var image: NSImage?
    if let url1 = url {
        image = NSImage(contentsOfURL:url1)
    }

我们现在可以这样做：

    let url: NSURL? = NSURL(string: "image.jpg")
    let image = map(url) { NSImage(contentsOfURL: $0) }


*** 

## References

- [Wrapper Types](http://www.objc.io/snippets/8.html)
- [Currying](http://www.objc.io/snippets/9.html)