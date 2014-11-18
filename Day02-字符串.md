# 字符串

## 简介

Swift 中的字符串是值类型，传递的时候会对值进行拷贝，而 OC 中的字符串传递则是引用。我们可以用 `for in` 遍历字符串：

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

要获取 SubString 的话需要这样：

    var str = "abcdefg"

    str.substringWithRange(Range<String.Index>(start: advance(str.startIndex,2), end: str.endIndex))

其中， `advance(i, n)` 等价于 `i++n`。