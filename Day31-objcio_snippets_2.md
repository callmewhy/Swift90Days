# [Swift90Days](https://github.com/callmewhy/Swift90Days) - objc.io 的 Swift 片段 2


## 函数式快排

结合前面的 `decompose` 扩展，我们可以分分钟写出一个快排片段。先取出第一个元素作为锚点，然后把后面小于这个数的放到一个数组里，大于这个数的放到另一个数组里： 

    extension Array {
        var decompose : (head: T, tail: [T])? {
            return (count > 0) ? (self[0], Array(self[1..<count])) : nil
        }
    }

    func qsort(input: [Int]) -> [Int] {
        if let (pivot, rest) = input.decompose {
            let lesser = rest.filter { $0 < pivot }
            let greater = rest.filter { $0 >= pivot }
            return qsort(lesser) + [pivot] + qsort(greater)
        } else {
            return []
        }
    }

    qsort([2,4,6,3,5,1])    // 1,2,3,4,5,6


## 压缩映射数组

在函数式编程里，`map` 是个十分常见的操作。如果 `map` 操作的结果是一个数组，我们通常需要对这个数组进行压缩降维操作，在其他函数式语言中压缩后再映射的操作通常命名为 `bind` ，在 Swift 中可以定义这样的运算符：

    infix operator >>= {}
    func >>=<A, B>(xs: [A], f: A -> [B]) -> [B] {
        return xs.map(f).reduce([], combine: +)
    }

用起来也很简单：

    let ranks = ["A", "K", "Q", "J", "10",
                 "9", "8", "7", "6", "5", 
                 "4", "3", "2"]
    let suits = ["♠", "♥", "♦", "♣"]
    
    let allCards =  ranks >>= { rank in
        suits >>= { suit in [(rank, suit)] }
    } 

    // Prints: [(A, ♠), (A, ♥), (A, ♦), 
    //          (A, ♣), (K, ♠), ...

*** 

## References

- [Functional Quicksort](http://www.objc.io/snippets/3.html)
- [Flattening and mapping arrays](http://www.objc.io/snippets/4.html)