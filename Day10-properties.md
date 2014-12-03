# [Swift90Days](https://github.com/callmewhy/Swift90Days) - 属性

## 延时存储属性

### Objective-C 的做法

有时候我们需要延时加载属性，在 Objective-C 中可以通过重写 `getter` 方法实现：

    @property (nonatomic, strong) NSMutableArray *players;

    - (NSMutableArray *)players {
        if (!_players) {
            _players = [[NSMutableArray alloc] init];
        }
        return _players;
    }

### Swift 的新关键字

在 Swift 中用 `lazy` 标记即可，注意，一定要是 `var` 定义的变量才行，而且要是 class 或者 struct 的属性。注意，全局属性是不需要 `lazy` 标记的延时加载属性。如果需要延时加载，可以把延时加载的内容放在一个闭包里：

    class PlayerManager {
        lazy var players: [String] = {
            var temporaryPlayers = [String]()
            temporaryPlayers.append("WHY")
            return temporaryPlayers
            }()

    }

    var p = PlayerManager()
    p   // {nil}
    p.players
    p   // {...}

### 何时使用延时加载

何时该用延时加载这个功能呢？一个最典型的例子就是：当属性的初始化必须在对象初始化完成之后。

举个例子，我有个 Person 类，它有个 `greeting` 属性，返回打招呼时候的招呼用语。比如你叫汪海，那么它就是 `"Hello, Wanghai"` 。它的初始化依赖于当前对象的 `name` 值。这时可以使用延时加载的特性：

    class Person {
        var name: String
        lazy var greeting: String = {
            [unowned self] in
            return "Hello, \(self.name)!"
            }()
        
        init(name: String) {
            self.name = name
        }
    }

    var p = Person(name: "WHY")
    p   // {"WHY",nil}
    p.greeting
    p   // {"WHY,{Some "Hello, WHY"}"}

还有种情况，就是运算量比较大的时候，可以用 `lazy` 避免不必要的加载。


## 计算属性

计算属性和存储属性对应，不过它是通过 `get` 来获取值，通过一个可选的 `set` 方法来截取设值的情况。如果没有 `setter` 则该属性只读。通过一个 Time 类来演示计算属性的用法：

    class Time
    {
        var seconds:Double = 0
        
        init(seconds: Double)
        {
            self.seconds = seconds
        }
        
        var minutes: Double
            {
            get
            {
                return (seconds / 60)
            }
            set
            {
                self.seconds = (newValue * 60)
            }
        }
    }

    var time = Time(seconds: 120)
    time.minutes    // 2
    time.seconds    // 120
    time.minutes=20 // 20
    time.seconds    // 1200

可以看到，minutes 的值是基于 seconds 计算获得的。


## 属性观察

有时候在属性发生改动的时候
还是上面那个 `Person` 类的例子，上次我们用了延时加载，这次不妨用 `didSet` 实现，在设置 `name` 之后更新 `greeting` 的值：

    class Person {
        var name: String? {
            didSet {
                self.greeting = "Hello, \(self.name!)"
            }
        }
        var greeting: String?
    }

    var p = Person()
    p.greeting          // nil
    p.name = "WHY"
    p.greeting          // "Hello, WHY"


*** 

## References

- [Properties](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Properties.html)
- [Lazy Initialization with Swift](http://mikebuss.com/2014/06/22/lazy-initialization-swift/)
- [Computed Properties in Swift](http://www.codingexplorer.com/computed-properties-in-swift/)