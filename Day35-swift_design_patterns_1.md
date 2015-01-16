# [Swift90Days](https://github.com/callmewhy/Swift90Days) - iOS 中的设计模式 (Swift 版本) 01

## 更新声明

翻译自 [Introducing iOS Design Patterns in Swift – Part 1/2](http://www.raywenderlich.com/86477/introducing-ios-design-patterns-in-swift-part-1) ，本教程 [objc](http://www.raywenderlich.com/46988/ios-design-patterns) 版本的作者是 Eli Ganem ，由 Vincent Ngo 更新为 Swift 版本。

## iOS 设计模式

说到设计模式，相信大家都不陌生，但是又有多少人知道它背后的真正含义？绝大多数程序员都知道设计模式十分重要，不过关于这个话题的文章却不是很多，开发者们在开发的时候有时也不太在意设计模式方面的内容。

设计模式针对软件设计中的常见问题，提供了一些可复用的解决方案，开发者可以通过这些模板写出易于理解且能够复用的代码。正确的使用设计模式可以降低代码之间的耦合度，从而很轻松的修改或者替换以前的代码。

如果你对设计模式还很陌生，那么告诉你一个好消息！在 iOS 的开发过程中，其实你不知不觉已经用了很多设计模式。这得益于 Cocoa 提供的框架和一些良好的编程习惯。接下来的这篇教程将会带你一起飞，去领略设计模式的魅力。

整个教程分为两篇文章，通过整个系列的学习，我们将会完成一个完整的应用，展示音乐专辑和专辑的相关信息。

通过这个应用，我们会接触一些 Cocoa 中常见的设计模式：

- 创建型 (Creational)：单例模式 (Singleton)
- 结构型 (Structural)：MVC、装饰者模式 （Decorator）、适配器模式 (Adapter)、外观模式 (Facade)
- 行为型 (Behavioral)：观察者模式 (Observer)、备忘录模式 (Memento)

嘿嘿嘿别愁眉苦脸的嘛，这篇文章不是什么长篇大论的理论知识，你会在开发应用的过程中慢慢学会这些设计模式。

先来预览一下最终的结果：

![](http://cdn2.raywenderlich.com/wp-content/uploads/2014/11/swiftDesignPattern1.png)

看起来还是不错的，开始学习接下来的内容吧。勇敢的少年们，快来创造奇迹！


## 开始

下载[初始项目](http://cdn1.raywenderlich.com/wp-content/uploads/2014/11/BlueLibrarySwift-Starter.zip)并解压，在 Xcode 中打开 `BlueLibrarySwift.xcodeproj` 项目文件。

项目中有三个地方需要注意一下：

1. `ViewController` 有两个 `IBOutlet` ，分别连接到了 `UITableView` 和 `UIToolBar` 上。

2. 在 StoryBoard 上有三个组件设置了约束。最上面的是专辑的封面，封面下面是列举了相关专辑的列表，最下面是有两个按钮的工具栏，一个用来撤销操作，另一个用来删除你选中的专辑。 StoryBoard 看起来是这个样子的：

![](http://cdn5.raywenderlich.com/wp-content/uploads/2014/11/Screen-Shot-2014-11-11-at-12.20.32-AM-480x228.png)

3. 一个简单的 `HTTP` 客户端类 （`HTTPClient`) ，里面还没有什么内容，需要你去完善。

注意：其实当你创建一个新的 Xcode 的项目的时候，你的代码里就已经有很多设计模式的影子了： MVC、委托、代理、单例 - 真是众里寻他千百度，得来全不费功夫。


在学习第一个设计模式之前，你需要创建两个类，用来存储和展示专辑数据。

创建一个新的类，继承 `NSObject` 名为 `Album` ，记得选择 Swift 作为编程语言然后点击下一步。

打开 `Album.swift` 然后添加如下定义：

    var title : String!
    var artist : String!
    var genre : String!
    var coverUrl : String!
    var year : String!

这里创建了五个属性，分别对应专辑的标题、作者、流派、封面地址和出版年份。

接下来我们添加一个初始化方法：

    init(title: String, artist: String, genre: String, coverUrl: String, year: String) {
      super.init()
     
      self.title = title
      self.artist = artist
      self.genre = genre
      self.coverUrl = coverUrl
      self.year = year
    }

这样我们就可以愉快的初始化了。

然后再加上下面这个方法：

    func description() -> String {
      return "title: \(title)" +
       "artist: \(artist)" +
       "genre: \(genre)" +
       "coverUrl: \(coverUrl)" +
       "year: \(year)"
    }

这是专辑对象的描述方法，详细的打印了 `Album` 的所有属性值，方便我们查看变量各个属性的值。

接下来，再创建一个继承自 `UIView` 的视图类 `AlbumView.swift`。

在新建的类中添加两个属性：

    private let coverImage: UIImageView! 
    private let indicator: UIActivityIndicatorView!

`coverImage` 代表了封面的图片，`indicator` 则是在加载过程中显示的等待指示器。

这两个属性都是私有属性，因为除了 `AlbumView` 之外，其他类没有必要知道他俩的存在。在写一些框架或者类库的时候，这种规范十分重要，可以避免一些误操作。

接下来给这个类添加初始化化方法：

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
     
    init(frame: CGRect, albumCover: String) {
        super.init(frame: frame)
        backgroundColor = UIColor.blackColor()
        coverImage = UIImageView(frame: CGRectMake(5, 5, frame.size.width - 10, frame.size.height - 10))
        addSubview(coverImage)
        indicator = UIActivityIndicatorView()
        indicator.center = center
        indicator.activityIndicatorViewStyle = .WhiteLarge
        indicator.startAnimating()
        addSubview(indicator)
    }


因为 `UIView` 遵从 `NSCoding` 协议，所以我们需要 `NSCoder` 的初始化方法。不过目前我们没有 `encode` 和 `decode` 的必要，所以就把它放在那里就行，调用父类方法初始化即可。

在真正的初始化方法里，我们设置了一些初始化的默认值。比如设置背景颜色默认为黑色，创建 `ImageView` 并设置了 `margin` 值，添加了一个加载指示器。

最终我们再加上如下方法：

    func highlightAlbum(#didHighlightView: Bool) {
        if didHighlightView == true {
            backgroundColor = UIColor.whiteColor()
        } else {
            backgroundColor = UIColor.blackColor()
        }
    }

这会切换专辑的背景颜色，如果高亮就是白色，否则就是黑色。

在继续下面的内容之前， `Command + B` 试一下确保没有什么问题，一切正常？那就开始第一个设计模式的学习啦！:]


## MVC - 设计模式之王

![](http://cdn5.raywenderlich.com/wp-content/uploads/2013/07/mvcking.png)

`Model-View-Controller` (缩写 MVC ) 是 Cocoa 框架的一部分，并且毋庸置疑是最常用的设计模式之一。它可以帮你把对象根据职责进行划分和归类。

作为划分依据的三个基本职责是：

- 模型层 (Model) ：存储数据并且定义如何操作这些数据。在我们的例子中，就是 `Album` 类。
- 视图层 (View) ：负责模型层的可视化展示，并且负责用户的交互，一般来说都是继承自 `UIView` 这个基类。在我们的项目中就是 `AlbumView` 这个类。
- 控制器 (Controller) ：控制器是整个系统的掌控者，它连接了模型层和数据层，并且把数据在视图层展示出来，监听各种事件，负责数据的各种操作。不妨猜猜在我们的项目中哪个是控制器？啊哈猜对了：` ViewController` 这个类就是。

如果你的项目遵循 MVC 的设计模式，那么各种对象要不是 Model ，要不是 View ，要不就是 Controller。当然在实际的开发中也可以灵活变化，比如结合具体业务使用 MVVM 结构给 `ViewController` 瘦瘦身，也是可以的。

三者之间的关系如下：

![](http://cdn2.raywenderlich.com/wp-content/uploads/2013/07/mvc0.png)

模型层通知控制器层任何数据的变化，然后控制器层会刷新视图层中的数据。视图层可以通知控制器层用户的交互事件，然后控制器会处理各种事件以及刷新数据。

你可能会感觉奇怪：为什么要把这三个东西分开来，而不能揉在一个类里呢？那样似乎更简单一点嘛。

Naive.

之所以这样做，是为了将代码更好的分离和重用。理想状态下，视图层应当和模型层完全分离。如果视图层不依赖任何模型层的具体实现，那么就可以很容易的被其他模型复用，用来展示不同的数据。

举个例子，比如在未来我们需要添加电影或者什么书籍，我们依旧可以使用 `AlbumView` 这个类作为展示。更久远点来说，在以后如果你创建了一个新的项目并且需要用到和专辑相关的内容，你可以直接复用 `Album` 类因为它并不依赖于任何视图模块。这就是 MVC 的强大之处，三大元素，各司其职，减少依赖。

### 如何使用 MVC 模式

首先，你需要确定你的项目中的每个类都是三大基本类型中的一种：控制器、模型、视图。不要在一个类里糅合多个角色。目前我们创建了 `Album` 类和 `AlbumView` 类是符合要求的，做得很好。

然后，为了确保你遵循这种模式，你最好创建三个项目分组来存放代码，分别是 Model、View、Controller，保持每个类型的文件分别独立。

接下来把 `Album.swift` 拖到 `Model` 分组，把 `AlbumView.swift` 拖到 `View` 分组，然后把 `ViewController.swift` 拖到 `Controller` 分组中。

现在你的项目应该是这个样子：

![](http://cdn4.raywenderlich.com/wp-content/uploads/2014/11/swiftDesignPattern2-259x320.png)

现在你的项目已经有点样子了，不再是各个文件颠沛流离居无定所了。显然你还会有其他分组和类，但是应用的核心就在这三个类里。

现在你的内容已经组织好了，接下来要做的就是获取专辑的数据。你将会创建一个 API 类来管理数据 - 这里我们会用到下一个设计模式：单例模式。


## 单例模式


单例模式确保每个指定的类只存在一个实例对象，并且可以全局访问那个实例。一般情况下会使用延时加载的策略，只在第一次需要使用的时候初始化。

注意：在 iOS 中单例模式很常见，`NSUserDefaults.standardUserDefaults()` 、 `UIApplication.sharedApplication()` 、 `UIScreen.mainScreen()` 、 `NSFileManager.defaultManager()` 这些都是单例模式。

你可能会疑惑了：如果多于一个实例又会怎么样呢？代码和内存还没精贵到这个地步吧？

某些场景下，保持实例对象仅有一份是很有意义的。举个例子，你的应用实例 (`UIApplication`)，应该只有一个吧，显然是指你的当前应用。还有一个例子：设备的屏幕 (`UIScreen`) 实例也是这样，所以对于这些类的情况，你只想要一个实例对象。

单例模式的应用还有另一种情况：你需要一个全局类来处理配置文件。我们很容易通过单例模式实现线程安全的实例访问，而如果有多个类可以同时访问配置文件，那可就复杂多了。


### 如何使用单例模式

可以看下这个图：

![](http://cdn3.raywenderlich.com/wp-content/uploads/2013/08/singleton.png)

这是一个日志类，有一个属性 (是一个单例对象) 和两个方法 (`sharedInstance()` 和 `init()`)。

第一次调用 `sharedInstance()` 的时候，`instance` 属性还没有初始化。所以我们要创建一个新实例并且返回。

下一次你再调用 `sharedInstance()` 的时候，`instance` 已经初始化完成，直接返回即可。这个逻辑确保了这个类只存在一个实例对象。

接下来我们继续完善单例模式，通过这个类来管理专辑数据。

注意到在我们前面的截图里，分组中有个 `API` 分组，这里可以放那些提供后台服务的类。在这个分组中创建一个新的文件 `LibraryAPI.swift` ，继承自 `NSObject` 类。

在 `LibraryAPI` 里添加下面这段代码：

    //1
    class var sharedInstance: LibraryAPI {
        //2
        struct Singleton {
            //3
            static let instance = LibraryAPI()
        }
        //4
        return Singleton.instance
    }


在这几行代码里，做了如下工作：

- 创建一个计算类型的类变量，这个类变量，就像是 objc 中的静态方法一样，可以直接通过类访问而不用实例对象。具体可参见苹果官方文档的 [属性](https://developer.apple.com/library/ios/documentation/swift/conceptual/swift_programming_language/Properties.html) 这一章。

- 在类变量里嵌套一个 `Singleton` 结构体。

- `Singleton` 封装了一个静态的常量，通过 `static` 定义意味着这个属性只存在一个，注意 Swift 中 `static` 的变量是延时加载的，意味着 `Instance` 直到需要的时候才会被创建。同时再注意一下，因为它是一个常量，所以一旦创建之后不会再创建第二次。这些就是单例模式的核心所在：一旦初始化完成，当前类存在一个实例对象，初始化方法就不会再被调用。

- 返回计算后的属性值。


注意：更多的单例模式实例可以看看 `Github` 上的这个[示例](https://github.com/hpique/SwiftSingleton)，列举了单例模式的若干种实现方式。


你现在可以将这个单例作为专辑管理类的入口，接下来我们继续创建一个处理专辑数据持久化的类。

新建 `PersistencyManager.swift` 并添加如下代码：

    private var albums = [Album]()

在这里我们定义了一个私有属性，用来存储专辑数据。这是一个可变数组，所以你可以很容易的增加或者删除数据。

然后加上一些初始化的数据：

    override init() {
      //Dummy list of albums
      let album1 = Album(title: "Best of Bowie",
             artist: "David Bowie",
             genre: "Pop",
             coverUrl: "http://www.coversproject.com/static/thumbs/album/album_david%20bowie_best%20of%20bowie.png",
             year: "1992")
     
      let album2 = Album(title: "It's My Life",
             artist: "No Doubt",
             genre: "Pop",
             coverUrl: "http://www.coversproject.com/static/thumbs/album/album_no%20doubt_its%20my%20life%20%20bathwater.png",
             year: "2003")
     
      let album3 = Album(title: "Nothing Like The Sun",
             artist: "Sting",
             genre: "Pop",
             coverUrl: "http://www.coversproject.com/static/thumbs/album/album_sting_nothing%20like%20the%20sun.png",
             year: "1999")
     
      let album4 = Album(title: "Staring at the Sun",
             artist: "U2",
             genre: "Pop",
             coverUrl: "http://www.coversproject.com/static/thumbs/album/album_u2_staring%20at%20the%20sun.png",
             year: "2000")
     
      let album5 = Album(title: "American Pie",
             artist: "Madonna",
             genre: "Pop",
             coverUrl: "http://www.coversproject.com/static/thumbs/album/album_madonna_american%20pie.png",
             year: "2000")
     
      albums = [album1, album2, album3, album4, album5]
    }

在这个初始化方法里，我们初始化了五张专辑。如果上面的专辑没有你喜欢的，你可以随意替换成你的菜:]

然后添加如下方法：

    func getAlbums() -> [Album] {
      return albums
    }
     
    func addAlbum(album: Album, index: Int) {
      if (albums.count >= index) { 
        albums.insert(album, atIndex: index)
      } else {
        albums.append(album)
      }
    }
     
    func deleteAlbumAtIndex(index: Int) {
      albums.removeAtIndex(index)
    }

这些方法可以让你自由的访问、添加、删除专辑数据。

这时你可以运行一下你的项目，确保编译通过以便进行下一步操作。

此时你或许会感到好奇： `PersistencyManager` 好像不是单例啊？是的，它确实不是单例。不过没关系，在接下来的外观模式章节，你会看到 `LibraryAPI` 和 `PersistencyManager` 之间的联系。


## 外观模式

![](http://cdn1.raywenderlich.com/wp-content/uploads/2013/07/facade.jpg)

外观模式在复杂的业务系统上提供了简单的接口。如果直接把业务的所有接口直接暴露给使用者，使用者需要单独面对这一大堆复杂的接口，学习成本很高，而且存在误用的隐患。如果使用外观模式，我们只要暴露必要的 API 就可以了。

下图演示了外观模式的基本概念：

![](http://cdn1.raywenderlich.com/wp-content/uploads/2013/07/facade2-480x241.png)

API 的使用者完全不知道这内部的业务逻辑有多么复杂。当我们有大量的类并且它们使用起来很复杂而且也很难理解的时候，外观模式是一个十分理想的选择。

外观模式把使用和背后的实现逻辑成功解耦，同时也降低了外部代码对内部工作的依赖程度。如果底层的类发生了改变，外观的接口并不需要做修改。

举个例子，如果有一天你想换掉所有的后台服务，你只需要修改 API 内部的代码，外部调用 API 的代码并不会有改动。


### 如何使用外观模式

现在我们用 `PersistencyManager` 来管理专辑数据，用 `HTTPClient` 来处理网络请求，项目中的其他类不应该知道这个逻辑。他们只需要知道 `LibraryAPI` 这个“外观”就可以了。

为了实现外观模式，应该只让 `LibraryAPI` 持有 `PersistencyManager` 和 `HTTPClient` 的实例，然后 `LibraryAPI` 暴露一个简单的接口给其他类来访问，这样外部的访问类不需要知道内部的业务具体是怎样的，也不用知道你是通过 `PersistencyManager` 还是 `HTTPClient` 获取到数据的。

大致的设计是这样的：

![](http://cdn2.raywenderlich.com/wp-content/uploads/2013/08/design-patterns-facade-uml-480x71.png)

`LibraryAPI` 会暴露给其他代码访问，但是 `PersistencyManager` 和 `HTTPClient` 则是不对外开放的。

打开 `LibraryAPI.swift` 然后添加如下代码：

    private let persistencyManager: PersistencyManager
    private let httpClient: HTTPClient
    private let isOnline: Bool

除了两个实例变量之外，还有个 `Bool` 值： `isOnline` ，这个是用来标识当前是否为联网状态的，如果是联网状态就会去网络获取数据。

我们需要在 `init` 里面初始化这些变量：

    override init() {
      persistencyManager = PersistencyManager()
      httpClient = HTTPClient()
      isOnline = false
     
      super.init()
    }

`HTTPClient` 并不会直接和真实的服务器交互，只是用来演示外观模式的使用。所以 `inOnline` 这个值我们一直设置为 `false`。

接下来在 `LibraryAPI.swift` 里添加如下代码：

    func getAlbums() -> [Album] {
      return persistencyManager.getAlbums()
    }
     
    func addAlbum(album: Album, index: Int) {
      persistencyManager.addAlbum(album, index: index)
      if isOnline {
        httpClient.postRequest("/api/addAlbum", body: album.description())
      }
    }
     
    func deleteAlbum(index: Int) {
      persistencyManager.deleteAlbumAtIndex(index)
      if isOnline {
        httpClient.postRequest("/api/deleteAlbum", body: "\(index)")
      }
    }

看一下 `addAlbum(_:index:)` 这个方法，先更新本地缓存，然后如果是联网状态还需要向服务器发送网络请求。这便是外观模式的强大之处：如果外部文件想要添加一个新的专辑，它不会也不用去了解内部的实现逻辑是怎么样的。

注意：当你设计外观的时候，请务必牢记：使用者随时可能直接访问你的隐藏类。永远不要假设使用者会遵循你当初的设计做事。

运行一下你的应用，你可以看到两个空的页面和一个工具栏：最上面的视图用来展示专辑封面，下面的视图展示数据列表。

![](http://cdn3.raywenderlich.com/wp-content/uploads/2014/11/Screen-Shot-2014-11-11-at-12.33.50-AM-179x320.png)

你需要在屏幕上展示专辑数据，这是就该用下一种设计模式了：装饰者模式。


## 装饰者模式

装饰者模式可以动态的给指定的类添加一些行为和职责，而不用对原代码进行任何修改。当你需要使用子类的时候，不妨考虑一下装饰者模式，可以在原始类上面封装一层。

在 Swift 里，有两种方式实现装饰者模式：扩展 (Extension) 和委托 (Delegation)。

### 扩展

扩展是一种十分强大的机制，可以让你在不用继承的情况下，给已存在的类、结构体或者枚举类添加一些新的功能。最重要的一点是，你可以在你没有访问权限的情况下扩展已有类。这意味着你甚至可以扩展 Cocoa 的类，比如 `UIView` 或者 `UIImage` 。

举个例子，在编译时新加的方法可以像扩展类的正常方法一样执行。这和装饰器模式有点不同，因为扩展不会持有扩展类的对象。

### 如何使用扩展

想象一下这个场景，我们需要在下面这个列表里展示数据：

![](http://cdn2.raywenderlich.com/wp-content/uploads/2014/11/swiftDesignPattern3-480x262.png)

专辑标题从哪里来？ `Album` 本身是个 `Model` 对象，所以它不应该负责如何展示数据。你需要一些额外的代码添加展示数据的逻辑，但是为了保持 `Model` 的干净，我们不应该直接修改代码，因为这样不符合单一职责原则。 `Model` 层最好就是负责纯粹的数据结构，如果有数据的操作可以放到扩展中完成。

接下来我们会创建一个扩展，扩展现有的 `Album` 类，在扩展里定义了新的方法，返回更适合 `UITableView` 展示用的数据结构。

数据的结构大概是这样：

![](http://cdn5.raywenderlich.com/wp-content/uploads/2013/08/delegate2-480x67.png)

新建一个 Swift 文件：`AlbumExtensions` ，在里面添加如下扩展：

    extension Album {
      func ae_tableRepresentation() -> (titles:[String], values:[String]) {
        return (["Artist", "Album", "Genre", "Year"], [artist, title, genre, year])
      }
    }

在方法的前面有个 `ae_` 前缀，是 `AlbumExtension` 的缩写，这样有利于和类的原有方法进行区分，避免使用的时候产生冲突。现在很多还在维护中的第三方库都已经改成了这个风格。

注意：类是可以重写父类方法的，但是在扩展里不可以。扩展里的方法和属性不能和原始类里的方法和属性冲突。

思考一下这个设计模式的强大之处：

- 我们可以直接在扩展里使用 `Album` 里的属性。
- 我们给 `Album` 类添加了内容但是并没有继承它，事实上，使用继承来扩展业务也可以实现一样的功能。
- 这个简单的扩展让我们可以更好地把 `Album` 的数据展示在 `UITableView` 里，而且不用修改源码。

### 委托

装饰者模式的另一种实现方案是委托。在这种机制下，一个对象可以和另一个对象相关联。比如你在用 `UITableView` ，你必须实现 `tableView(_:numberOfRowsInSection:)` 这个委托方法。

你不应该指望 `UITableView` 知道你有多少数据，这是个应用层该解决的问题。所以，数据相关的计算应该通过 `UITableView` 的委托来解决。这样可以让 `UITableView` 和数据层分别独立。视图层就负责显示数据，你递过来什么我就显示什么。

下面这张图很好的解释了 `UITableView` 的工作过程：

![](http://cdn5.raywenderlich.com/wp-content/uploads/2013/08/delegate-480x252.png)

`UITableView` 的工作仅仅是展示数据，但是最终它需要知道自己要展示那些数据，这时就可以向它的委托询问。在 objc 的委托模式里，一个类可以通过协议来声明可选或者必须的方法。

看起来似乎继承然后重写必须的方法来的更简单一点。但是考虑一下这个问题：继承的结果必定是一个独立的类，如果你想让某个对象成为多个对象的委托，那么子类这招就行不通了。

注意：委托模式十分重要，苹果在 UIKit 中大量使用了该模式，基本上随处可见。

### 如何使用委托模式

打开 `ViewController.swift` 文件，添加如下私有变量：

    private var allAlbums = [Album]()
    private var currentAlbumData : (titles:[String], values:[String])?
    private var currentAlbumIndex = 0

在 `viewDidLoad` 里面加入如下内容：

    override func viewDidLoad() {
        super.viewDidLoad()
        //1
        self.navigationController?.navigationBar.translucent = false
        currentAlbumIndex = 0

        //2
        allAlbums = LibraryAPI.sharedInstance.getAlbums()

        // 3
        // the uitableview that presents the album data
        dataTable.delegate = self
        dataTable.dataSource = self
        dataTable.backgroundView = nil
        view.addSubview(dataTable!)       
    }

对上面三个部分进行拆解：

1. 关闭导航栏的透明效果

2. 通过 API 获取所有的专辑数据，记住，我们使用外观模式之后，应该从 `LibraryAPI` 获取数据，而不是 `PersistencyManager` 。

3. 你可以在这里设置你的 `UITablweView` ，在这里声明了 `UITableView` 的 `delegate` 是当前的 `ViewController` 。事实上你用了 XIB 或者 StoryBoard ，可以直接在可视化的页面里拖拽完成。



接下来添加一个新的方法用来更方便的获取数据：

    func showDataForAlbum(albumIndex: Int) {
        // defensive code: make sure the requested index is lower than the amount of albums
        if (albumIndex < allAlbums.count && albumIndex > -1) {
            //fetch the album
            let album = allAlbums[albumIndex]
            // save the albums data to present it later in the tableview
            currentAlbumData = album.ae_tableRepresentation()
        } else {
            currentAlbumData = nil
        }
        // we have the data we need, let's refresh our tableview
        dataTable!.reloadData()
    } 

`showDataForAlbum()` 这个方法获取最新的专辑数据，当你想要展示新数据的时候，你需要调用 `reloadData()` 这个方法，这样 `UITableView` 就会向委托请求数据，比如有多少个 `section` 有多少个 `row` 之类的。

在 `viewDidLoad` 里面调用上面的方法：

    self.showDataForAlbum(currentAlbumIndex)

这样应用一启动就会去加载当前的专辑数据。因为 `currentAlbumIndex` 的默认值是 0 ，所以一开始会默认显示第一章专辑的信息。

接下来我们该去完善 `DataSource` 的协议方法了。你可以直接把委托方法写在类里面，当然如果你想让你的代码看起来更整洁一点，则可以放在扩展里。

在文件底部添加如下方法，注意一定要放在类定义的大括号外面，因为这两个家伙不是类定义的一部分，它们是扩展：

    extension ViewController: UITableViewDataSource {
    }
     
    extension ViewController: UITableViewDelegate {
    }


上面就是实现委托的方法 - 你可以把协议想象成是与委托之间的约定，只要你实现了约定的方法，就算是实现了委托。在我们的代码中， `ViewController` 需要遵守 `UITableViewDataSource` 和 `UITableViewDelegate` 的协议。这样 `UITableView` 才能确保必要的委托方法都已经实现了。

在 `UITableViewDataSource` 对应的那个扩展里加上如下方法：

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      if let albumData = currentAlbumData {
        return albumData.titles.count
      } else {
        return 0
      }
    }
     
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
      if let albumData = currentAlbumData {
        cell.textLabel?.text = albumData.titles[indexPath.row]
          if let detailTextLabel = cell.detailTextLabel {
            detailTextLabel.text = albumData.values[indexPath.row]
          }
      }
      return cell
    }

`tableView(_:numberOfRowsInSection:)` 返回需要展示的行数，和存储的数据中的 title 的数目相同。

`tableView(_:cellForRowAtIndexPath:)` 创建并且返回了一个单元格，上面有标题和对应的值。


注意：你可以把这些方法直接加在类声明里面，也可以放在扩展里，编译器不会去管数据源到底在哪里，只要能找到对应的方法就可以了。而我们之所以这样做，是为了方便其他人阅读。

此时再构建项目，你可以看到如下内容：

![](http://cdn3.raywenderlich.com/wp-content/uploads/2014/11/Screen-Shot-2014-11-11-at-12.38.53-AM-179x320.png)

是的，显示成功啦！目前的项目源码在这里：[BlueLibrarySwift-Part1](http://cdn5.raywenderlich.com/wp-content/uploads/2014/11/BlueLibrarySwift-Part1.zip)，如果遇到什么问题你可以下载下来对比一下。

下一章我们会继续设计模式的内容，敬请期待！



***

原文链接：

- [Introducing iOS Design Patterns in Swift – Part 1/2](http://www.raywenderlich.com/86477/introducing-ios-design-patterns-in-swift-part-1)