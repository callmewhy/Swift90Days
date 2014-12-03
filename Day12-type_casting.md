# [Swift90Days](https://github.com/callmewhy/Swift90Days) - 类型转换

## 类型判断

我们可以通过 `is` 来判断一个实例是否属于指定类或者其子类，功能类似以 `OC` 中的 `isKindOfClass` 。

我们通过一个简单的例子演示一下：

    class A {
    }

    class B: A {
    }

    class C: A {
    }

    var array = [B(),A(),C(),A()]   // [A]

    for item in array {
        if item is B {
            println("B")    // 1 time
        }
        if item is C {
            println("C")    // 1 time
        }
        if item is A {      // ERROR! ALWAYS TRUE
            println("C")    // 1 time
        }
    }


## 向下转型

可以用类型转换操作符 `as` 尝试将某个实例转换到它的子类型。转换没有真的改变实例或它的值。潜在的根本的实例保持不变；只是简单地把它作为它被转换成的类来使用。

比如下面这段代码：

    class A {
    }

    class B: A {
    }

    class C: A {
    }

    var array = [B(),A(),C(),A()]   // [A]

    for item in array {
        if let aB = item as? B {
            println("aB")    // 1 time
        }
        
        if let aC = item as? C {
            println("aC")    // 1 time
        }
    }



## Any 和 AnyObject

Swift为不确定类型提供了两种特殊类型别名：

- Any 可以表示任何类型，除了方法类型（function types）。
- AnyObject 可以代表任何class类型的实例。


*** 

## References

- [TypeCasting](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/TypeCasting.html)