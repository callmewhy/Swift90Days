# 蛋疼的初始化过程

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

> 构造器在第一阶段构造完成之前，不能调用任何实例方法、不能读取任何实例属性的值，也不能引用 self 的值。

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


## 蛋疼的初始化过程

Swift 的初始化过程十分严格，刚从 OC 转过来的同仁可能习惯性的就写了这样的代码：

    class ViewController: UIViewController {
        private let animator: UIDynamicAnimator
        
        required init(coder aDecoder: NSCoder) {
            // ERROR: Property 'self.animator' not initialized at super.init call
            super.init(coder: aDecoder)
            animator = UIDynamicAnimator(referenceView: self.view)
        }
    }

是的它报错了！哦想起来了，要在 super 前面初始化自己的属性：

    class ViewController: UIViewController {
        private let animator: UIDynamicAnimator
        
        required init(coder aDecoder: NSCoder) {
            // use of property 'view' in base object before super.init initializes it
            animator = UIDynamicAnimator(referenceView: self.view)
            super.init(coder: aDecoder)
        }
    }

是的它又报错了！哦想起来了你不能在 view 的父类初始化之前调用这个属性。那就先不赋值吧：

 
    class ViewController: UIViewController {
        private let animator: UIDynamicAnimator
        
        required init(coder aDecoder: NSCoder) {
            animator = UIDynamicAnimator()
            super.init(coder: aDecoder)
            // ERROR: Cannot assign to the result of this expression
            animator.referenceView = self.view
        }
    }

坑爹啊不是，这个属性居然是只读的！

我们只好把属性设置成 `let` 的可选类型，并且把初始化放到了 `viewDidLoad` 里面：

    class ViewController: UIViewController {
        private var animator: UIDynamicAnimator?
        
        required init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            animator = UIDynamicAnimator(referenceView: self.view)
        }
    }

这时 `animator` 终于可以安全的访问 `self.view` 这个属性了。

你以为这就完了？想太多。

由于是可选类型，所以在使用的时候需要解包：

    if let actualAnimator = animator {
      actualAnimator.addBehavior(UIGravityBehavior())
    } 

这太丑了，或者用强制解包：

    animator!.addBehavior(UIGravityBehavior())

或者用可选链：

    animator?.addBehavior(UIGravityBehavior())

都！太！low！了！

这时候不妨试试隐式解析可选类型：


    class ViewController: UIViewController {
        private var animator: UIDynamicAnimator!
        
        required init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            animator = UIDynamicAnimator(referenceView: self.view)
        }
    }

似乎好看多了。不过这并不是正确的打开方式，我觉得设计可选类型的工程师们应该不希望我们用这个方法，毕竟这更像是为了解决历史遗留包袱所做的妥协。

或许用 `lazy` 延时加载更合适：

    class ViewController: UIViewController {
        lazy private var animator: UIDynamicAnimator = {
            return UIDynamicAnimator(referenceView: self.view)
            }()
        
        required init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            animator.addBehavior(UIGravityBehavior())
        }
    }




*** 

## References

- [Initialization](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Initialization.html)
- [Deinitialization](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Deinitialization.html)
- [SWIFT INITIALIZATION AND THE PAIN OF OPTIONALS](http://www.scottlogic.com/blog/2014/11/20/swift-initialisation.html)