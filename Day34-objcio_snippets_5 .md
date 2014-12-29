# [Swift90Days](https://github.com/callmewhy/Swift90Days) - objc.io 的 Swift 片段 4


## 全排列

我们想通过 Swift 简单的实现全排列。

首先先写个例子，列出所有把元素插入到数组中的情况：

    func between<T>(x: T, ys: [T]) -> [[T]] {
        if let (head, tail) = ys.decompose {
            return [[x] + ys] + between(x, tail).map { [head] + $0 }
        } else {
            return [[x]]
        }
    }


    between(0, [1, 2, 3])   // [[0, 1, 2, 3], [1, 0, 2, 3], [1, 2, 0, 3], [1, 2, 3, 0]]

接下来再通过 `between` 函数实现全排列：

    func permutations<T>(xs: [T]) -> [[T]] {
        if let (head, tail) = xs.decompose {
            return permutations(tail) >>= { permTail in
                between(head, permTail)
            }
        } else {
            return [[]]
        }
    }

其中 `>>=` 这个符号前面有提到过，返回所有的组合结果。完整的实现代码如下：

    extension Array {
        var decompose : (head: T, tail: [T])? {
            return (count > 0) ? (self[0], Array(self[1..<count])) : nil
        }
    }

    infix operator >>= {}
    func >>=<A, B>(xs: [A], f: A -> [B]) -> [B] {
        return xs.map(f).reduce([], combine: +)
    }

    func between<T>(x: T, ys: [T]) -> [[T]] {
        if let (head, tail) = ys.decompose {
            return [[x] + ys] + between(x, tail).map { [head] + $0 }
        } else {
            return [[x]]
        }
    }


    func permutations<T>(xs: [T]) -> [[T]] {
        if let (head, tail) = xs.decompose {
            return permutations(tail) >>= { permTail in
                between(head, permTail)
            }
        } else {
            return [[]]
        }
    }


## 轻量级解包

我们可以在原来的API上面封装一层减少频繁解包的麻烦：

    typealias JSONDictionary = [String:AnyObject]

    func decodeJSON(data: NSData) -> JSONDictionary? {
        return NSJSONSerialization.JSONObjectWithData(data, 
            options: .allZeros, error: nil) as? JSONDictionary
    }

当然 `encode` 也一样：

    func encodeJSON(input: JSONDictionary) -> NSData? {
        return NSJSONSerialization.dataWithJSONObject(input, 
            options: .allZeros, error: nil)
    }





*** 

## References

- [Permutations](http://www.objc.io/snippets/10.html)
- [Lightweight API Wrappers](http://www.objc.io/snippets/11.html)