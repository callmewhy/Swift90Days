# 字符串

## 简介

`String` 中的字符串是值类型，传递的时候会对值进行拷贝，而 `NSString` 的字符串传递则是引用。我们可以用 `for in` 遍历字符串：

    var a : String = "a"

    for c in "Hello" {
        println(c)
    }


可以通过 `countElements` 计算字符串的字符数量：

    countElements("1234567") // 7

不过要注意的是，`countElements` 和 NSString 的 `length` 并不总是完全一样的值，因为 `length` 利用的是 UTF-16 类型的值，而不是 Unicode 字符。比如 emoji 表情加进去之后，UTF-16 算的结果是2，而 Unicode 的计算结果是1。可以看下面这个例子：

    var a = "Hello🐶"
    countElements(a) // 6 - Unicode
    a.utf16Count     // 7 - UTF16


可以用 utf8 获取 utf-8 的表示，同样，可以用 utf16 获取 utf-16 的表示：

    var b = "Hello🐶"

    // 72 101 108 108 111 240 159 144 182
    for c in b.utf8 {
        println(c)
    }

    // 72 101 108 108 111 55357 56374
    for c in b.utf16 {
        println(c)
    }

如果要获取 Unicode 标量可以用 `unicodeScalars` 来获取：
    
    // 68 111 103 33 128054”
    for scalar in b.unicodeScalars {
        print("\(scalar.value) ")
    }


## 子串

我们没有办法直接用 `str[0...4]` 来截取子串，因为 String 的 `Subscript` 的参数必须是 `String.Index` 的：

    subscript(i: String.Index) -> Character { get }
    subscript(subRange: Range<String.Index>) -> String { get }

要获取 SubString 的话需要这样：

    let digits = "0123456789"
    let position = 3
    let index = advance(digits.startIndex, position)
    let character = digits[index] // -> "3"

或者用 `substringWithRange` 方法：

    var str = "abcdefg"

    str.substringWithRange(Range<String.Index>(start: advance(str.startIndex,2), end: str.endIndex))

其中， `advance(i, n)` 等价于 `i++n`，只需要传一个 `ForwardIndexType` 的值，就可以返回 `i` 往后的第 `n` 个值。比如 `advance(1, 2)` 返回的是 `1+2` 也就是3。

我们可以通过 `Extension` 的方式给 String 加上整数类型的下标：
   
    var digits = "12345678901234567890"

    extension String
    {
        subscript(integerIndex: Int) -> Character
            {
                let index = advance(startIndex, integerIndex)
                return self[index]
        }
        
        subscript(integerRange: Range<Int>) -> String
            {
                let start = advance(startIndex, integerRange.startIndex)
                let end = advance(startIndex, integerRange.endIndex)
                let range = start..<end
                return self[range]
        }
    }

    digits[5]     // works now
    digits[4...6] // works now



可以用 `rangeOfString()` 来判断是否包含子串：

    var myString = "Swift is really easy!"

    if myString.rangeOfString("easy") != nil {
        
        println("Exists!")
        
    }


## 拼接

把数组里的值拼接成字符串是经常遇到的情况。我们可以用遍历拼接所有元素：

    let animals = ["cat", "dog", "turtle", "swift", "elephant"]

    var result: String = ""
    for animal in animals {
        if countElements(result) > 0 {
            result += ","
        }
        result += animal
    }

    result  // "cat,dog,turtle,swift,elephant"

当然也有更简单的方式，`join` 函数：

    println("a list of animals: " + ",".join(animals)) 

可以用 `map` 给每个元素都加个列表标记：

    println("\n".join(animals.map({ "- " + $0})))

可以用 capitalizedString 将字符串首字母大写：

    let capitalizedAnimals = animals.map({ $0.capitalizedString })

    println("\n".join(capitalizedAnimals.map({ "- " + $0})))


可以通过 `sorted()` 方法对数组内的元素进行排序：

    let sortedAnimals = animals.sorted({ (first, second) -> Bool in
        return first < second
    })

    println("\n".join(sortedAnimals.map({ "- " + $0})))


你可以通过自定义运算符的方式来实现字符串 `*n` 的效果，就像是 `3*5=15` 这样：

    func *(string: String, scalar: Int) -> String {
        let array = Array(count: scalar, repeatedValue: string) 
        return "".join(array)
    }

    println("cat " * 3 + "dog " * 2)
    // cat cat cat dog dog 


## 分解

基于 `Foundation` ，我们可以用 `componentsSeparatedByString` 把字符串分解成数组：

    import Foundation

    var myString = "Berlin, Paris, New York, San Francisco"
    var myArray = myString.componentsSeparatedByString(",")
    //Returns an array with the following values:  ["Berlin", " Paris", " New York", " San Francisco"]

如果你希望基于多个字符进行分解，那需要使用另一个方法：

    import Foundation

    var myString = "One-Two-Three-1 2 3"
    var array : [String] = myString.componentsSeparatedByCharactersInSet(NSCharacterSet (charactersInString: "- "))
    //Returns ["One", "Two", "Three", "1", "2", "3"]

如果不希望基于 `Foundation` 进行分解，可以使用全局函数 `split()`：

    var str = "Today is so hot"
    let arr = split(str, { $0 == " "}, maxSplit: Int.max, allowEmptySlices: false)
    println(arr) // [Today, is, so, hot]



## 总结

在 Swift 中，`String` 和 `NSString` 会自动转换。虽然 String 已经很强大，但是用起来总归不太顺手。可以参考一下网上的 [ExSwift](https://github.com/pNre/ExSwift/tree/master/ExSwift) 项目，其中的 [String.swift](https://github.com/pNre/ExSwift/blob/master/ExSwift/String.swift) 很好的补充了一些 String 中常用而 Apple 又没有提供的内容。

*** 

## References

- [Playing with Strings](http://www.weheartswift.com/playing-strings/)
- [String reference guide for Swift](http://www.learnswiftonline.com/reference-guides/string-reference-guide-for-swift/)
- [Swift version of componentsSeparatedByString](http://stackoverflow.com/questions/25226940/swift-version-of-componentsseparatedbystring)
- [Strings in Swift](http://oleb.net/blog/2014/07/swift-strings/)
- [Swift: Using String Ranges The Functional Way](http://natashatherobot.com/swift-string-ranges-the-functional/)
- [How To Find A Substring In Range of a Swift String](http://natashatherobot.com/swift-string-substringinrange/)
- [How do you use String.substringWithRange?](http://stackoverflow.com/questions/24044851/how-do-you-use-string-substringwithrange-or-how-do-ranges-work-in-swift)
- [Swift: Cocoaphobia](http://ericasadun.com/2014/06/17/swift-cocoaphobia/)