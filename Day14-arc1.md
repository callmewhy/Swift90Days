# 自动引用计数

在这一章主要是学习官方文档中产生循环强引用的两种情况：

- 弱引用

`Person & Apartment` 的例子展示了两个属性的值都允许为nil。

- 无主引用

`Customer & CreditCard` 的例子展示了一个属性的值允许为nil，而另一个属性的值不允许为nil。



## 弱引用

可以在前面加上 `weak` 表明这是一个弱引用。弱引用不会保持住引用的实例，并且不会阻止 ARC 销毁被引用的实例。

可以看下下面这个例子中如何通过弱引用避免循环引用的问题：


    class Person {
        let name: String
        var apartment: Apartment?

        init(name: String) {
            self.name = name
        }
        deinit {
            println("\(name) is being deinitialized")
        }
    }

    class Apartment {
        let number: Int
        weak var tenant: Person?

        init(number: Int) {
            self.number = number
        }
        deinit {
            println("Apartment #\(number) is being deinitialized")
        }
    }


    var why: Person?
    var number604: Apartment?

    why = Person(name: "WHY")
    number604 = Apartment(number: 604)

    why!.apartment = number604
    number604!.tenant = why


    println("nil 1")
    why = nil
    println("nil 2")
    number604 = nil




## 无主引用

可以在前面加上 `unowned` 表明这是一个无主引用。和弱引用类似，无主引用不会牢牢保持住引用的实例。

和弱引用不同的是，无主引用是永远有值的。因此，无主引用总是被定义为非可选类型。

下面这个例子：

    class Customer {
        let name: String
        var card: CreditCard?
        
        init(name: String) {
            self.name = name
        }
        deinit {
            println("\(name) is being deinitialized")
        }
    }

    class CreditCard {
        let number: Int
        unowned let customer: Customer
        
        init(number: Int, customer: Customer) {
            self.number = number
            self.customer = customer
        }
        deinit {
            println("Card #\(number) is being deinitialized")
        }
    }


    var john: Customer?
    john = Customer(name: "WHY")
    john!.card = CreditCard(number: 1234_5678_9012_3456, customer: john!)
    john = nil








*** 

## References

- [Automatic Reference Counting](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/AutomaticReferenceCounting.html)