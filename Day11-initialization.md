# 构造过程和析构过程

## 阶段构造

Swift 的构造过程分为两个阶段：

- 第一个阶段，每个存储型属性通过引入自己的构造器来设置初始值。
- 第二个阶段，在新实例准备使用之前进一步定制存储型属性。

## 安全检查

在构造的过程中， Swift 会进行四种安全检查。

### 安全检查 1

> 指定构造器必须保证它所在类引入的所有属性都必须先初始化完成，之后才能将其它构造任务向上代理给父类中的构造器。

比如下面这段代码就是错误的：

    class Food {
        var name: String
        init(name: String) {
            self.name = name
        }
    }


    class RecipeIngredient: Food {
        var quantity: Int
        init(name: String, quantity: Int) {
            super.init(name: name)  // ERROR!
            self.quantity = quantity
        }
    }


### 安全检查 2

> 指定构造器必须先向上代理调用父类构造器，然后再为继承的属性设置新值。如果没这么做，指定构造器赋予的新值将被父类中的构造器所覆盖。

比如下面这段代码就是错误的：

    class Food {
        var name: String
        init(name: String) {
            self.name = name
        }
    }


    class RecipeIngredient: Food {
        override init(name: String) {
            self.name = "WHY"   // ERROR!
            super.init(name: name)
        }
    }

### 安全检查 3

> 便利构造器必须先代理调用同一类中的其它构造器，然后再为任意属性赋新值。如果没这么做，便利构造器赋予的新值将被同一类中其它指定构造器所覆盖。

比如下面这段代码就是错误的：

    class Food {
        var name: String
        init(name: String) {
            self.name = name
        }
    }

    class RecipeIngredient: Food {
        var quantity: Int
        init(name: String, quantity: Int) {
            self.quantity = quantity
            super.init(name: name)
        }
        override convenience init(name: String) {
            quantity = 2    // ERROR!
            self.init(name: name, quantity: 1)
        }
    }


### 安全检查 4

> 构造器在第一阶段构造完成之前，不能调用任何实例方法、不能读取任何实例属性的值，也不能引用self的值。

比如下面这段代码就是错误的：

    class Food {
        var name: String
        init(name: String) {
            self.name = name
        }
    }

    class RecipeIngredient: Food {
        var quantity: Int
        init(name: String, quantity: Int) {
            self.quantity = quantity
            println(self.name)  // ERROR!
            super.init(name: name)
        }
        override convenience init(name: String) {
            self.init(name: name, quantity: 1)
        }
    }


## 析构过程

每个类最多只能有一个析构函数。析构函数不带任何参数，也没有括号：

    deinit {
        // 执行析构过程
    }

子类继承了父类的反初始化函数，先释放子类再释放父类。


最近公司项目有点忙，先这么多了。

*** 

## References

- [Initialization](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Initialization.html)
- [Deinitialization](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Deinitialization.html)