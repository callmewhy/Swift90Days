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


## 扩展

由于数组和字典十分常用，而官方的方法功能有限，所以我们可以学习[ExSwift 中 Array.swift](https://github.com/pNre/ExSwift/blob/master/ExSwift/Array.swift) 的内容，给 Array 添加一些 Extension。





*** 

## References

