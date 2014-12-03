# [Swift90Days](https://github.com/callmewhy/Swift90Days) - 自动引用计数

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


## 综合案例

或许前面两个例子看了还有些晕乎：到底什么时候用弱引用什么时候用无主引用啊！

请看这个例子：


    import UIKit

    class FilePickerController : UIViewController {
        var onDidPickFileWithPath : ((path : String) -> ())?
    }

    class DocumentViewController : UIViewController {
        var filePicker: FilePickerController?
        var content: String?
        
        init(fileAtURL URL: NSURL) {
            super.init(nibName: nil, bundle: nil)
            
            var request = NSURLRequest(URL: URL)
            
            // weak：这里使用弱引用，因为异步请求结束了可能 self 已经销毁了
            NSURLConnection.sendAsynchronousRequest(request, queue: nil) { [weak self]
                (response, data, error) in
                if let actualSelf = self {
                    // Captures an owning reference "actualSelf" so interacting with it in this
                    // block is safe
                    actualSelf.content = NSString(data: data, encoding: NSUTF8StringEncoding)
                }
            }
        }

        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func presentFilePicker() {
            if (filePicker == nil) {
                filePicker = FilePickerController();
                
                // unowned: 这里用无主引用，因为进行这个操作的时候 self 不可能为 nil
                filePicker!.onDidPickFileWithPath = { [unowned self]
                    (path: String) in
                    self.content = NSString(contentsOfFile:path, encoding: NSUTF8StringEncoding, error: nil)
                    
                }
            }
            
            self.presentViewController(filePicker!, animated: true, completion: nil)
        }
    }

上面代码中的两个例子是两个比较常见的场景：异步状态下，回调的闭包调用的时候 `self` 可能已经被设置成 `nil` 了，比如 pop 了之类的，这个时候可以用 `weak` ，然后通过可选绑定进行解包。而另一种情况下，由于是 `presentViewController` 弹出视图，所以回调的时候 `self` 一定是不为 `nil` 的，这种时候可以用 `unowned` (真难拼，老写错了。。)。



## 闭包中的循环强引用

解决闭包和类实例之间的循环强引用可以通过定义捕获列表来实现。

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





*** 

## References

- [Automatic Reference Counting](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/AutomaticReferenceCounting.html)
- [7 Cool Features in Swift](http://www.drewag.me/posts/7-cool-features-in-swift#enumeration-cases-can-hold-values)