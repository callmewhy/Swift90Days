# Swift 中的柯里化

新手上路的学习笔记，如有错误还望指出，不胜感激。

## 上集：理论预备

在学习柯里化的过程中接触到了三个有趣的概念，在此和各位分享一下。

### 偏函数 (Partial Function)

偏函数是只对函数定义域的一个子集进行定义的函数，是一个数学概念。

[偏函数](http://zh.wikipedia.org/wiki/%E5%87%BD%E6%95%B0)定义如下：

> 从输入值集合 X 到可能的输出值集合 Y 的函数 f (记作f:X→Y) 是 X 和 Y 的关系，若 f 满足多个输入可以映射到一个输出，但一个输入不能映射到多个输出，则为偏函数。

换句话说，定义域 `X` 中可能存在某些值，在值域 `Y` 中没有对应的值。从定义来看，偏函数是函数的超集。也就是说，函数都是偏函数，但偏函数不都是函数。

### 偏函数应用 (Partial Application || Partial Function Application)

上面说的概念是数学中的概念，和我们将要接触的内容无关。和我们关系比较大的是偏函数应用 (Partial Application)。

[偏函数应用](http://en.wikipedia.org/wiki/Partial_application)的定义如下：

> 在计算机科学领域，偏函数应用是指通过固定原函数的一部分参数生成新函数的过程，新函数的参数数目少于原函数。

通过数学公式演示一下，比如原函数 `f` 有三个参数： `f:(X×Y×Z)→N` ，通过绑定第一个参数 `X` ，我们可以得到一个新的函数： `partial(f):(Y×Z)→N` 。

编程中的偏函数，比如廖雪峰老师在[偏函数](http://www.liaoxuefeng.com/wiki/001374738125095c955c1e6d8bb493182103fac9270762a000/001386819893624a7edc0e3e3df4d5d852a352b037c93ec000)中提及的 `functools` 模块的用法，其实就是偏函数应用，又叫局部函数应用，有道词典翻译为[切一刀](http://dict.youdao.com/search?q=partial%20application)在此表过不提。

为避免混淆，下文中提及的偏函数均为编程中的偏函数应用 (Partial Application)。

偏函数有点像是给函数的参数设置默认值一样，不过偏函数更加灵活。比如下面这段 c 语言的代码中，`foo23` 函数就是 `foo` 函数的偏函数，参数 `b` 的值被绑定为 `23` ：

    int foo(int a, int b, int c) {
      return a + b + c;
    }

    int foo23(int a, int c) {
      return foo(a, 23, c);
    }



### 柯里化

柯里化和偏函数有些关系，但是是两个完全不同的概念。

[柯里化](http://en.wikipedia.org/wiki/Currying)定义如下：

> 柯里化（英语：Currying）是把接受多个参数的函数变换成接受一个单一参数（最初函数的第一个参数）的函数，并且返回接受余下的参数而且返回结果的新函数的技术。

通过数学公式来简单的演示一下，原始的函数是一个普通的函数：`f:(X×Y) → Z` ，柯里化之后函数变成了：`curry(f):X → (Y→Z)` 。

我们用几段 js 代码演示一下柯里化的过程。首先先看一个普通的函数 `foo` ，返回参数的平方：

    var foo = function(a) {
        return a * a;
    }

假设我们的函数都只能有一个参数，那么可以用下面的方式模拟出一个多参数函数：

    var foo = function(a) {
        return function(b) {
            return a * a + b * b;
        }
    }

我们可以这样调用 `foo(3)(4)` 。

柯里化解决的问题是：将多参数函数转变为一系列单参数函数的链式调用。

柯里化背后的基本想法是函数可以局部应用，意思是一些参数值可以在函数调用之前被指定，并且返回一个新的函数。也就是偏函数的基本思想。


### 小结

可以看到，柯里化将函数进行了~~肢解~~拆分，这样我们可以很容易的实现偏函数。比如：

    var foo = function(a) {
        return function(b) {
            return a * a + b * b;
        }
    }
    var foo3 = foo(3);
    foo3(4);

这就出来了。函数 `foo3` 就是 `foo` 函数的偏函数。

简单总结一下偏函数和柯里化以及两者的关系：

- 偏函数应用：固定原函数的几个参数值，从而得到一个新的函数。
- 函数柯里化：一种使用匿名单参数函数来实现多参数函数的方法。
- 关系：柯里化能够轻松的实现某些偏函数应用。



## 中集：柯里化与偏函数

前面扯了很多有的没的，接下来我们来看看在 Swift 中柯里化。

节目预告：下面的例子极为简单，让各位见笑了。希望通过这些最简单的例子演示柯里化最关键的部分。

### 传统手段：老老实实传参数

我们先来写个最简单的东西好了：计数器，每次运算后+1即可：

    func add(a:Int) -> Int{
        return a + 1;
    }

    var a = 0

    a = add(a)   // 1
    a = add(a)   // 2

但是每次都+1，步子有点小了。有时我们可能也需要+2，+3，+4，那么简单，我们把需要加的步长放在参数里就行：

    func add(a:Int, b:Int) -> Int{
        return a + b ;
    }

    var a = 0

    a = add(a, 1)   // 1
    a = add(a, 2)   // 3

似乎没什么问题。那么问题来了：我大部分时间都只要+1啊，我可能只是100次调用有90次要+1，为了剩下的那10次，每行代码都要多个参数，是不是麻烦了点？OK嫌麻烦我们可以通过设置默认值的方式解决。

### 进阶手段：可以设置默认值

在函数定义的时候我们就给它定好默认值是1，那不就得了：

    func add(a:Int, b:Int=1) -> Int{
        return a + b ;
    }

    var a = 0

    a = add(a)   // 1
    a = add(a, b:2)   // 3


如果你要+1，行，你别写参数我给你调好了自动+1；如果你要+2+3，行，爱加几加几，自己写到参数里去。

似乎没什么问题。那么问题来了：我有一半的时间要+1，有一半的时间要+2，还有些时间+3+4，怎么玩？

唉可真是磨人的小妖精。


### 柯学手段：通过柯里化实现

和前面的例子不一样的是，柯里化的函数返回一个新的函数而不是计算后的结果，计算后的结果要通过返回的新函数计算获得。


比如前面的那个例子，我们新定义一个 `add` 函数，它有一个参数，是步长 `b` 。然后它返回一个新的函数 `newAdd` ，新的函数需要一个参数，也就是 `a`，完整的代码如下：

    func add(b:Int) -> (Int->Int){
        func newAdd(a:Int) -> Int {
            return a + b ;
        }
        return newAdd
    }

    let addOne = add(1)
    let addTwo = add(2)

    var a = 0

    a = addOne(a)    // 1
    a = addTwo(a)    // 3
    a = add(2)(3)    // 5

如果你觉得各种 `(Int)->(Int->Int)` 看的晕乎，你也可以参照[官方文档](https://developer.apple.com/library/ios/documentation/swift/conceptual/Swift_Programming_Language/Declarations.html)，用下面这种简化的声明：

    func add(b:Int)(a:Int) -> Int{
        return a + b ;
    }

    let addOne = add(1)
    let addTwo = add(2)

    var a = 0

    a = addOne(a: a)    // 1
    a = addTwo(a: a)    // 3

在这个例子里，我们生成两个新的函数：`addOne` 和 `addTwo` 分别进行+1和+2操作。可以看到，通过柯里化实现偏函数是十分方便的，一切都顺其自然，水到渠成。

通过这个例子可以看出，柯里化是偏函数的方法论，偏函数是柯里化背后的~~男人~~思想。

## 下集：实例方法与柯里化

实际上，Swift 中的实例方法也是柯里化方法，你可以传个实例作为第一个参数。

我们还就和计数器杠上了，再次以计数器为例：

    class Counter {
        var b: Int = 1
        
        func add(a:Int) -> Int{
            return a + b ;
        }
    }


我们可以初始化实例对象然后来调用：

    let counter = Counter()
    var a = counter.add(1)  // 2


我们也可以这样做：

    let add = Counter.add   // Function
    let counter = Counter()
    var a = add(counter)(1) // 2

这两个是完全等价的。

有点神奇啊，不是吗？注意， `let add = Counter.add` 这个定义后面没有小括号。也就是说，我们并没有调用它，只是指向它，像一个指针一样指了过去。

我们可以按住 `option` 键查看一下 `add` 的类型：`let add: Counter -> (Int) -> Int` 。它的参数是一个 `Counter` 类型的实例，返回的是另一个新函数，这个新函数的参数类型是 `Int` ，返回的类型也是 `Int` ，和类里定义的函数类型是一样的。

看起来好像挺有趣的，不过问题来了：有啥用呢？

这个问题我还没办法回答，因为我也是刚刚接触这部分内容。我只能做一名知识的搬运工了。

在 [Instance Methods are Curried Functions in Swift](http://oleb.net/blog/2014/07/swift-instance-methods-curried-functions/) 这篇文章里，作者举了一个例子：用 [Target-Action](https://developer.apple.com/library/ios/documentation/general/conceptual/Devpedia-CocoaApp/TargetAction.html) 模式实现一个 `Control` ：

    protocol TargetAction {
        func performAction()
    }

    struct TargetActionWrapper<T: AnyObject> : TargetAction {
        weak var target: T?
        let action: (T) -> () -> ()
        
        func performAction() -> () {
            if let t = target {
                action(t)()
            }
        }
    }

    enum ControlEvent {
        case TouchUpInside
        case ValueChanged
        // ...
    }

    class Control {
        var actions = [ControlEvent: TargetAction]()
        
        func setTarget<T: AnyObject>(target: T, action: (T) -> () -> (), controlEvent: ControlEvent) {
            actions[controlEvent] = TargetActionWrapper(target: target, action: action)
        }
        
        func removeTargetForControlEvent(controlEvent: ControlEvent) {
            actions[controlEvent] = nil
        }
        
        func performActionForControlEvent(controlEvent: ControlEvent) {
            actions[controlEvent]?.performAction()
        }
    }

用法和平时没什么两样：

    class MyViewController {
        let button = Control()
        
        func viewDidLoad() {
            button.setTarget(self, action: MyViewController.onButtonTap, controlEvent: .TouchUpInside)
        }
        
        func onButtonTap() {
            println("Button was tapped")
        }



## 下集的下集：其他

由于没有在实战中用过，暂时不对柯里化做太多评价。就目前的了解来看，它可以让我们很方便的对函数进行局部调用，让代码更加灵活，语意更加清晰。

如果想感受一下原汁原味的柯里化，不妨接触一下 Haskell 这门语言。 Haskell 中多参数函数都是通过柯里化实现的。它的作者是 Haskell Brooks Curry，是的就是柯里化 (Curring) 的命名者 (不过并不是他发明的)。


使用 Mac 的朋友可以下载 [Haskell Platform for Mac](https://www.haskell.org/platform/mac.html) ，然后通过 `ghci` 命令试一试 Haskell 的代码。


当然也有[反柯里化](http://en.wikipedia.org/wiki/Currying)，感兴趣的同学可以继续了解一下：）


*** 

## References

- [Wikipedia - Currying](http://en.wikipedia.org/wiki/Currying)
- [Wikipedia - Partial Application](http://en.wikipedia.org/wiki/Partial_application)
- [What is the advantage of currying?](http://programmers.stackexchange.com/questions/185585/what-is-the-advantage-of-currying)
- [Currying and Partial Function)](http://real-wolrd-haskell-note.readthedocs.org/en/latest/chp4.html#currying-partial-function)
- [Why Curry Helps](http://hughfdjackson.com/javascript/why-curry-helps/)
- [Function Scala](http://www.ibm.com/developerworks/cn/java/j-lo-funinscala3/)
- [Curried Functions in Swift](http://ijoshsmith.com/2014/06/09/curried-functions-in-swift/)
- [Swift Function Currying](http://blog.xebia.com/2014/11/06/swift-function-currying/)
- [Instance Methods are Curried Functions in Swift](http://oleb.net/blog/2014/07/swift-instance-methods-curried-functions/)
- [Partial Function in Python](http://www.liaoxuefeng.com/wiki/001374738125095c955c1e6d8bb493182103fac9270762a000/001386819893624a7edc0e3e3df4d5d852a352b037c93ec000)
- [Function_(mathematics)](http://en.wikipedia.org/wiki/Function_(mathematics))
- [Programming Challenge: Are You a Swift Ninja? Part 2](http://www.raywenderlich.com/77845/swift-ninja-part-2)
- [Currying and Partial Application](http://www.vaikan.com/currying-partial-application/)