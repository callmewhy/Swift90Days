# 闭包中的循环强引用

解决闭包和类实例之间的循环强引用可以通过定义捕获列表来实现。

## 捕获列表

捕获列表中的每个元素都是由weak或者unowned关键字和实例的引用（如self）成对组成。每一对都在方括号中，通过逗号分开：

    lazy var someClosure: (Int, String) -> String = {
        [unowned self] (index: Int, stringToProcess: String) -> String in
    }

我们需要判断捕获列表中的属性是弱引用还是无主引用，有以下几条判断依据：

- 当闭包和捕获的实例总是互相引用时并且总是同时销毁时，将闭包内的捕获定义为无主引用。
- 当捕获引用有时可能会是 `nil` 时，则定义为弱引用。弱引用总是可选类型，并且当引用的实例被销毁后，弱引用的值会自动置为 `nil` 。这使我们可以在闭包内检查它们是否存在。


比如下面这段代码：

    class HTMLElement {
        
        let name: String
        let text: String?
        
        lazy var asHTML: () -> String = {
            [unowned self] in
            if let text = self.text {
                return "<\(self.name)>\(text)</\(self.name)>"
            } else {
                return "<\(self.name) />"
            }
        }
        
        init(name: String, text: String? = nil) {
            self.name = name
            self.text = text
        }
        
        deinit {
            println("\(name) is being deinitialized")
        }
        
    }

    var paragraph: HTMLElement? = HTMLElement(name: "p", text: "hello, world")
    println(paragraph!.asHTML())

其实定义成 `weak` 也是可以的(吧)，只是每次都需要进行解包，而实际上 `self` 不可能为 `nil` 的，所以这样的定义没有意义。用无主引用才能更好的表达 `self` 的状态。
 


## 小结


官方文档的基础部分总算看完一遍了，时间有限，很多细节没有展开学习，只能在后面的学习中补上了。

接下来计划看一些开源项目，通过阅读别人的源码深入学习 Swift 的使用。

加油~





*** 

## References

- [Automatic Reference Counting](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/AutomaticReferenceCounting.html)