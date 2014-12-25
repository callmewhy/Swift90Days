# [Swift90Days](https://github.com/callmewhy/Swift90Days) - objc.io 的 Swift 片段 3


## Reduce

`reduce` 是函数式编程里很常用的操作之一。我们可以用 `reduce` 封装一个简单的求和函数：

    let sum: [Int] -> Int = { $0.reduce(0, combine: +) }

    println(sum([1,2,3,5]))

一开始看可能有点难以理解，把它补全就是这样的：

    let sum: [Int] -> Int = { (nums:[Int]) -> Int in
        nums.reduce(0, combine: +)
    }

    println(sum([1,2,3,5]))

不仅是整数，Bool 值也是可以的：

    let all: [Bool] -> Bool = { $0.reduce(true, combine: { $0 && $1 }) }

## Applicative Functors


假设我们有这样一个登录的函数：

    func login(email: String, pw: String, success: Bool -> ())

由于获取参数的函数可能返回的是可选类型，所以在调用的时候需要挨个解包：

    if let email = getEmail() {
        if let pw = getPw() {
            login(email, pw) { println("success: \($0)") }
        } else {
            // error...
        }
    } else {
        // error...
    }

这个操作十分的繁琐且无意义的多次重复，我们可以通过自定义运算符解决这个问题：

    infix operator <*> { associativity left precedence 150 }
    func <*><A, B>(lhs: (A -> B)?, rhs: A?) -> B? {
        if let lhs1 = lhs {
            if let rhs1 = rhs {
                return lhs1(rhs1)
            }
        }
        return nil
    }

可以看到，我们把解包的操作放到这个操作符里，这样就能避免解包的苦恼：

    func curry<A, B, C, R>(f: (A, B, C) -> R) -> A -> B -> C -> R {
        return { a in { b in { c in f(a, b, c) } } }
    }

    if let f = curry(login) <*> getEmail() <*> getPw() {
        f { println("success \($0)") }
    } else {
        // error...
    }





*** 

## References

- [Reduce](http://www.objc.io/snippets/5.html)
- [Currying](http://www.objc.io/snippets/6.html)
- [Applicative Functors](http://www.objc.io/snippets/7.html)