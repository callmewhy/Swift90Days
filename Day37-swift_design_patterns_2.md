# [Swift90Days](https://github.com/callmewhy/Swift90Days) - iOS 中的设计模式 (Swift 版本) 02

## 更新声明

翻译自 [Introducing iOS Design Patterns in Swift – Part 2/2](http://www.raywenderlich.com/90773/introducing-ios-design-patterns-in-swift-part-2) ，本教程 [objc](http://www.raywenderlich.com/46988/ios-design-patterns) 版本的作者是 Eli Ganem ，由 Vincent Ngo 更新为 Swift 版本。

## 再续前缘

欢迎来到教程的第二部分！这是本系列教程的最后一部分，在这一章的学习里，我们会更加深入的学习一些 iOS 开发中常见的设计模式：适配器模式 (Adapter)，观察者模式 (Observer)，备忘录模式 (Memento)。

开始吧少年们！

## 准备工作

你可以先下载上一章结束时的[项目源码](http://cdn5.raywenderlich.com/wp-content/uploads/2014/11/BlueLibrarySwift-Part1.zip) 。

在第一部分的教程里，我们完成了这样一个简单的应用：

![](http://cdn3.raywenderlich.com/wp-content/uploads/2014/11/Screen-Shot-2014-11-11-at-12.38.53-AM-179x320.png)

我们的原计划是在上面的空白处放一个可以横滑浏览专辑的视图。其实仔细想想，这个控件是可以应用在其他地方的，我们不妨把它做成一个可复用的视图。

为了让这个视图可以复用，显示内容的工作都只能交给另一个对象来完成：它的委托。这个横滑页面应该声明一些方法让它的委托去实现，就像是 `UITableView` 的 `UITableViewDelegate` 一样。我们将会在下一个设计模式中实现这个功能。

## 适配器模式 - Adapter

适配器把自己封装起来然后暴露统一的接口给其他类，这样即使其他类的接口各不相同，也能相安无事，一起工作。

如果你熟悉适配器模式，那么你会发现苹果在实现适配器模式的方式稍有不同：苹果通过委托实现了适配器模式。委托相信大家都不陌生。举个例子，如果一个类遵循了 `NSCoying` 的协议，那么它一定要实现 `copy` 方法。

### 如何使用适配器模式

横滑的滚动栏理论上应该是这个样子的：

![](http://cdn2.raywenderlich.com/wp-content/uploads/2014/11/swiftDesignPattern7.png)


新建一个 Swift 文件：`HorizontalScroller.swift` ，作为我们的横滑滚动控件， `HorizontalScroller` 继承自 `UIView` 。

打开 `HorizontalScroller.swift` 文件并添加如下代码：

    @objc protocol HorizontalScrollerDelegate {
    }

这行代码定义了一个新的协议： `HorizontalScrollerDelegate` 。我们在前面加上了 `@objc` 的标记，这样我们就可以像在 objc 里一样使用 `@optional` 的委托方法了。

接下来我们在大括号里定义所有的委托方法，包括必须的和可选的：

    // 在横滑视图中有多少页面需要展示
    func numberOfViewsForHorizontalScroller(scroller: HorizontalScroller) -> Int
    // 展示在第 index 位置显示的 UIView
    func horizontalScrollerViewAtIndex(scroller: HorizontalScroller, index:Int) -> UIView
    // 通知委托第 index 个视图被点击了
    func horizontalScrollerClickedViewAtIndex(scroller: HorizontalScroller, index:Int)
    // 可选方法，返回初始化时显示的图片下标，默认是0
    optional func initialViewIndex(scroller: HorizontalScroller) -> Int

其中，没有 `option` 标记的方法是必须实现的，一般来说包括那些用来显示的必须数据，比如如何展示数据，有多少数据需要展示，点击事件如何处理等等，不可或缺；有 `option` 标记的方法为可选实现的，相当于是一些辅助设置和功能，就算没有实现也有默认值进行处理。

在 `HorizontalScroller` 类里添加一个新的委托对象：

    weak var delegate: HorizontalScrollerDelegate?

为了避免循环引用的问题，委托是 `weak` 类型。如果委托是 `strong` 类型的，当前对象持有了委托的强引用，委托又持有了当前对象的强引用，这样谁都无法释放就会导致内存泄露。

委托是可选类型，所以很有可能当前类的使用者并没有指定委托。但是如果指定了委托，那么它一定会遵循 `HorizontalScrollerDelegate` 里约定的内容。

再添加一些新的属性：
    
    // 1
    private let VIEW_PADDING = 10
    private let VIEW_DIMENSIONS = 100
    private let VIEWS_OFFSET = 100
     
    // 2
    private var scroller : UIScrollView!
    // 3
    var viewArray = [UIView]()

上面标注的三点分别做了这些事情：

- 定义一个常量，用来方便的改变布局。现在默认的是显示的内容长宽为100，间隔为10。
- 创建一个 `UIScrollView` 作为容器。
- 创建一个数组用来存放需要展示的数据

接下来实现初始化方法：

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeScrollView()
    }
     
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeScrollView()
    }
     
    func initializeScrollView() {
        //1
        scroller = UIScrollView()
        addSubview(scroller)

        //2
        scroller.setTranslatesAutoresizingMaskIntoConstraints(false)
        //3
        self.addConstraint(NSLayoutConstraint(item: scroller, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: scroller, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: scroller, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: scroller, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0.0))

        //4
        let tapRecognizer = UITapGestureRecognizer(target: self, action:Selector("scrollerTapped:"))
        scroller.addGestureRecognizer(tapRecognizer)
    }


上面的代码做了如下工作：

- 创建一个 `UIScrollView` 对象并且把它加到父视图中。
- 关闭 `autoresizing masks` ，从而可以使用 `AutoLayout` 进行布局。
- 给 `scrollview` 添加约束。我们希望 `scrollview` 能填满 `HorizontalScroller` 。
- 创建一个点击事件，检测是否点击到了专辑封面，如果确实点击到了专辑封面，我们需要通知 `HorizontalScroller` 的委托。

添加委托方法：

    func scrollerTapped(gesture: UITapGestureRecognizer) {
      let location = gesture.locationInView(gesture.view)
      if let delegate = self.delegate {
        for index in 0..<delegate.numberOfViewsForHorizontalScroller(self) {
          let view = scroller.subviews[index] as UIView
          if CGRectContainsPoint(view.frame, location) {
            delegate.horizontalScrollerClickedViewAtIndex(self, index: index)
            scroller.setContentOffset(CGPointMake(view.frame.origin.x - self.frame.size.width/2 + view.frame.size.width/2, 0), animated:true)
            break
          }
        }
      }
    }

我们把 `gesture` 作为一个参数传了进来，这样就可以获取点击的具体坐标了。

接下来我们调用了 `numberOfViewsForHorizontalScroller` 方法，`HorizontalScroller` 不知道自己的 `delegate` 具体是谁，但是知道它一定实现了 `HorizontalScrollerDelegate` 协议，所以可以放心的调用。

对于 `scroll view` 中的 `view` ，通过 `CGRectContainsPoint` 进行点击检测，从而获知是哪一个 `view` 被点击了。当找到了点击的 `view` 的时候，则会调用委托方法里的 `horizontalScrollerClickedViewAtIndex` 方法通知委托。在跳出 `for` 循环之前，先把点击到的 `view` 居中。

接下来我们再加个方法获取数组里的 `view` ：

    func viewAtIndex(index :Int) -> UIView {
      return viewArray[index]
    } 

这个方法很简单，只是用来更方便获取数组里的 `view` 而已。在后面实现高亮选中专辑的时候会用到这个方法。

添加如下代码用来重新加载 `scroller` ：

    func reload() {
      // 1 - Check if there is a delegate, if not there is nothing to load.
      if let delegate = self.delegate {
        //2 - Will keep adding new album views on reload, need to reset.
        viewArray = []
        let views: NSArray = scroller.subviews
     
        // 3 - remove all subviews
        views.enumerateObjectsUsingBlock {
        (object: AnyObject!, idx: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
          object.removeFromSuperview()
        }
        // 4 - xValue is the starting point of the views inside the scroller            
        var xValue = VIEWS_OFFSET
        for index in 0..<delegate.numberOfViewsForHorizontalScroller(self) {
          // 5 - add a view at the right position
          xValue += VIEW_PADDING
          let view = delegate.horizontalScrollerViewAtIndex(self, index: index)
          view.frame = CGRectMake(CGFloat(xValue), CGFloat(VIEW_PADDING), CGFloat(VIEW_DIMENSIONS), CGFloat(VIEW_DIMENSIONS))
          scroller.addSubview(view)
          xValue += VIEW_DIMENSIONS + VIEW_PADDING
          // 6 - Store the view so we can reference it later
         viewArray.append(view)
        }
        // 7
        scroller.contentSize = CGSizeMake(CGFloat(xValue + VIEWS_OFFSET), frame.size.height)
     
        // 8 - If an initial view is defined, center the scroller on it
        if let initialView = delegate.initialViewIndex?(self) {
          scroller.setContentOffset(CGPointMake(CGFloat(initialView)*CGFloat((VIEW_DIMENSIONS + (2 * VIEW_PADDING))), 0), animated: true)
        }
      }
    }

这个 `reload` 方法有点像是 `UITableView` 里面的 `reloadData` 方法，它会重新加载所有数据。

一段一段的看下上面的代码：

- 在调用 `reload` 之前，先检查一下是否有委托。
- 既然要清除专辑封面，那么也需要重新设置 `viewArray` ，要不然以前的数据会累加进来。
- 移除先前加入到 `scrollview` 的子视图。
- 所有的 `view` 都有一个偏移量，目前默认是100，我们可以修改 `VIEW_OFFSET` 这个常量轻松的修改它。
- `HorizontalScroller` 通过委托获取对应位置的 `view` 并且把它们放在对应的位置上。
- 把 `view` 存进 `viewArray` 以便后面的操作。
- 当所有 `view` 都安放好了，再设置一下 `content size` 这样才可以进行滑动。
- `HorizontalScroller` 检查一下委托是否实现了 `initialViewIndex()` 这个可选方法，这种检查十分必要，因为这个委托方法是可选的，如果委托没有实现这个方法则用0作为默认值。最终设置 `scroll view` 将初始的 `view` 放置到居中的位置。


当数据发生改变的时候，我们需要调用 `reload` 方法。当 `HorizontalScroller` 被加到其他页面的时候也需要调用这个方法，我们在 `HorizontalScroller.swift` 里面加入如下代码：

    override func didMoveToSuperview() {
        reload()
    }

在当前 `view` 添加到其他 `view` 里的时候就会自动调用 `didMoveToSuperview` 方法，这样可以在正确的时间重新加载数据。

`HorizontalScroller` 的最后一部分是用来确保当前浏览的内容时刻位于正中心的位置，为了实现这个功能我们需要在用户滑动结束的时候做一些额外的计算和修正。

添加下面这个方法：

    func centerCurrentView() {
        var xFinal = scroller.contentOffset.x + CGFloat((VIEWS_OFFSET/2) + VIEW_PADDING)
        let viewIndex = xFinal / CGFloat((VIEW_DIMENSIONS + (2*VIEW_PADDING)))
        xFinal = viewIndex * CGFloat(VIEW_DIMENSIONS + (2*VIEW_PADDING))
        scroller.setContentOffset(CGPointMake(xFinal, 0), animated: true)
        if let delegate = self.delegate {
            delegate.horizontalScrollerClickedViewAtIndex(self, index: Int(viewIndex))
        }  
    }

上面的代码计算了当前视图里中心位置距离多少，然后算出正确的居中坐标并滑动到那个位置。最后一行是通知委托所选视图已经发生了改变。

为了检测到用户滑动的结束时间，我们还需要实现 `UIScrollViewDelegate` 的方法。在文件结尾加上下面这个扩展：

    extension HorizontalScroller: UIScrollViewDelegate {
        func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            if !decelerate {
                centerCurrentView()
            }
        }

        func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
            centerCurrentView()
        }
    }


当用户停止滑动的时候，`scrollViewDidEndDragging(_:willDecelerate:)` 这个方法会通知委托。如果滑动还没有停止，`decelerate` 的值为 `true` 。当滑动完全结束的时候，则会调用 `scrollViewDidEndDecelerating` 这个方法。在这两种情况下，你都应该把当前的视图居中，因为用户的操作可能会改变当前视图。

你的 `HorizontalScroller` 已经可以使用了！回头看看前面写的代码，你会看到我们并没有涉及什么 `Album` 或者 `AlbumView` 的代码。这是极好的，因为这样意味着这个 `scroller` 是完全独立的，可以复用。

运行一下你的项目，确保编译通过。

这样，我们的 `HorizontalScroller` 就完成了，接下来我们就要把它应用到我们的项目里了。首先，打开 `Main.Sstoryboard` 文件，点击上面的灰色矩形，设置 `Class` 为 `HorizontalScroller` ：

![](http://cdn5.raywenderlich.com/wp-content/uploads/2014/11/swiftDesignPattwern9-700x414.png)

接下来，在 `assistant editor` 模式下向 `ViewController.swift` 拖拽生成 outlet ，命名为 `scroller` ：

![](http://cdn5.raywenderlich.com/wp-content/uploads/2014/11/swiftDesignPattern10-700x411.png)

接下来打开 `ViewController.swift` 文件，是时候实现 `HorizontalScrollerDelegate` 委托里的方法啦！

添加如下扩展：

    extension ViewController: HorizontalScrollerDelegate {
        func horizontalScrollerClickedViewAtIndex(scroller: HorizontalScroller, index: Int) {
            //1
            let previousAlbumView = scroller.viewAtIndex(currentAlbumIndex) as AlbumView
            previousAlbumView.highlightAlbum(didHighlightView: false)
            //2
            currentAlbumIndex = index
            //3
            let albumView = scroller.viewAtIndex(index) as AlbumView
            albumView.highlightAlbum(didHighlightView: true)
            //4
            showDataForAlbum(index)
        }
    }

让我们一行一行的看下这个委托的实现：

- 获取上一个选中的相册，然后取消高亮
- 存储当前点击的相册封面
- 获取当前选中的相册，设置为高亮
- 在 `table view` 里面展示新数据

接下来在扩展里添加如下方法：

    func numberOfViewsForHorizontalScroller(scroller: HorizontalScroller) -> (Int) {
        return allAlbums.count
    }

这个委托方法返回 `scroll vew` 里面的视图数量，因为是用来展示所有的专辑的封面，所以数目也就是专辑数目。

然后添加如下代码：

    func horizontalScrollerViewAtIndex(scroller: HorizontalScroller, index: Int) -> (UIView) {
        let album = allAlbums[index]
        let albumView = AlbumView(frame: CGRectMake(0, 0, 100, 100), albumCover: album.coverUrl)
        if currentAlbumIndex == index {
            albumView.highlightAlbum(didHighlightView: true)
        } else {
            albumView.highlightAlbum(didHighlightView: false)
        }
        return albumView
    }

我们创建了一个新的 `AlbumView` ，然后检查一下是不是当前选中的专辑，如果是则设为高亮，最后返回结果。

是的就是这么简单！三个方法，完成了一个横向滚动的浏览视图。

我们还需要创建这个滚动视图并把它加到主视图里，但是在这之前，先添加如下方法：

    func reloadScroller() {
        allAlbums = LibraryAPI.sharedInstance.getAlbums()
        if currentAlbumIndex < 0 {
            currentAlbumIndex = 0
        } else if currentAlbumIndex >= allAlbums.count {
            currentAlbumIndex = allAlbums.count - 1
        } 
        scroller.reload() 
        showDataForAlbum(currentAlbumIndex)
    }

这个方法通过 `LibraryAPI` 加载专辑数据，然后根据 `currentAlbumIndex` 的值设置当前视图。在设置之前先进行了校正，如果小于0则设置第一个专辑为展示的视图，如果超出了范围则设置最后一个专辑为展示的视图。

接下来只需要指定委托就可以了，在 `viewDidLoad` 最后加入一下代码：

    scroller.delegate = self
    reloadScroller()

因为 `HorizontalScroller` 是在 `StoryBoard` 里初始化的，所以我们需要做的只是指定委托，然后调用 `reloadScroller()` 方法，从而加载所有的子视图并且展示专辑数据。

标注：如果协议里的方法过多，可以考虑把它分解成几个更小的协议。`UITableViewDelegate` 和 `UITableViewDataSource` 就是很好的例子，它们都是 `UITableView` 的协议。尝试去设计你自己的协议，让每个协议都单独负责一部分功能。

运行一下当前项目，看一下我们的新页面：

![](http://cdn1.raywenderlich.com/wp-content/uploads/2014/11/swiftDesignPattern12-288x320.png)

等下，滚动视图显示出来了，但是专辑的封面怎么不见了？

啊哈，是的。我们还没完成下载部分的代码，我们需要添加下载图片的方法。因为我们所有的访问都是通过 `LibraryAPI` 实现的，所以很显然我们下一步应该去完善这个类了。不过在这之前，我们还需要考虑一些问题：

- `AlbumView` 不应该直接和 `LibraryAPI` 交互，我们不应该把视图的逻辑和业务逻辑混在一起。
- 同样， `LibraryAPI` 也不应该知道 `AlbumView` 这个类。
- 如果 `AlbumView` 要展示封面，`LibraryAPI` 需要告诉 `AlbumView` 图片下载完成。

看起来好像很难的样子？别绝望，接下来我们会用观察者模式 (`Observer Pattern`) 解决这个问题！:]


## 观察者模式 - Observer

在观察者模式里，一个对象在状态变化的时候会通知另一个对象。参与者并不需要知道其他对象的具体是干什么的 - 这是一种降低耦合度的设计。这个设计模式常用于在某个属性改变的时候通知关注该属性的对象。

常见的使用方法是观察者注册监听，然后再状态改变的时候，所有观察者们都会收到通知。

在 MVC 里，观察者模式意味着需要允许 `Model` 对象和 `View` 对象进行交流，而不能有直接的关联。

`Cocoa` 使用两种方式实现了观察者模式： `Notification` 和 `Key-Value Observing (KVO)`。

### 通知 - Notification

不要把这里的通知和推送通知或者本地通知搞混了，这里的通知是基于订阅-发布模型的，即一个对象 (发布者) 向其他对象 (订阅者) 发送消息。发布者永远不需要知道订阅者的任何数据。

`Apple` 对于通知的使用很频繁，比如当键盘弹出或者收起的时候，系统会分别发送 `UIKeyboardWillShowNotification/UIKeyboardWillHideNotification` 的通知。当你的应用切到后台的时候，又会发送 `UIApplicationDidEnterBackgroundNotification` 的通知。

注意：打开 `UIApplication.swift` 文件，在文件结尾你会看到二十多种系统发送的通知。

#### 如何使用通知

打开 `AlbumView.swift` 然后在 `init` 的最后插入如下代码：

    NSNotificationCenter.defaultCenter().postNotificationName("BLDownloadImageNotification", object: self, userInfo: ["imageView":coverImage, "coverUrl" : albumCover])

这行代码通过 `NSNotificationCenter` 发送了一个通知，通知信息包含了 `UIImageView` 和图片的下载地址。这是下载图像需要的所有数据。

然后在 `LibraryAPI.swift` 的 `init` 方法的 `super.init()` 后面加上如下代码：

    NSNotificationCenter.defaultCenter().addObserver(self, selector:"downloadImage:", name: "BLDownloadImageNotification", object: nil)

这是等号的另一边：观察者。每当 `AlbumView` 发出一个 `BLDownloadImageNotification` 通知的时候，由于 `LibraryAPI` 已经注册了成为观察者，所以系统会调用 `downloadImage()` 方法。

但是，在实现 `downloadImage()` 之前，我们必须先在 `dealloc` 里取消监听。如果没有取消监听消息，消息会发送给一个已经销毁的对象，导致程序崩溃。

在 `LibaratyAPI.swift` 里加上取消订阅的代码：

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

当对象销毁的时候，把它从所有消息的订阅列表里去除。

这里还要做一件事情：我们最好把图片存储到本地，这样可以避免一次又一次下载相同的封面。

打开 `PersistencyManager.swift` 添加如下代码：

    func saveImage(image: UIImage, filename: String) {
        let path = NSHomeDirectory().stringByAppendingString("/Documents/\(filename)")
        let data = UIImagePNGRepresentation(image)
        data.writeToFile(path, atomically: true)
    }

    func getImage(filename: String) -> UIImage? {
        var error: NSError?
        let path = NSHomeDirectory().stringByAppendingString("/Documents/\(filename)")
        let data = NSData(contentsOfFile: path, options: .UncachedRead, error: &error)
        if let unwrappedError = error {
            return nil
        } else {
            return UIImage(data: data!)
        }
    }

代码很简单直接，下载的图片会存储在 `Documents` 目录下，如果没有检查到缓存文件， `getImage()` 方法则会返回 `nil` 。

然后在 `LibraryAPI.swift` 添加如下代码：

    func downloadImage(notification: NSNotification) {
        //1
        let userInfo = notification.userInfo as [String: AnyObject]
        var imageView = userInfo["imageView"] as UIImageView?
        let coverUrl = userInfo["coverUrl"] as NSString

        //2
        if let imageViewUnWrapped = imageView {
            imageViewUnWrapped.image = persistencyManager.getImage(coverUrl.lastPathComponent)
            if imageViewUnWrapped.image == nil {
                //3
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                    let downloadedImage = self.httpClient.downloadImage(coverUrl)
                    //4
                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                        imageViewUnWrapped.image = downloadedImage
                        self.persistencyManager.saveImage(downloadedImage, filename: coverUrl.lastPathComponent)
                    })
                })
            }
        }
    }


拆解一下上面的代码：

- `downloadImage` 通过通知调用，所以这个方法的参数就是 `NSNotification` 本身。 `UIImageView` 和 `URL` 都可以从其中获取到。
- 如果以前下载过，从 `PersistencyManager` 里获取缓存。
- 如果图片没有缓存，则通过 `HTTPClient` 获取。
- 如果下载完成，展示图片并用 `PersistencyManager` 存储到本地。

再回顾一下，我们使用外观模式隐藏了下载图片的复杂程度。通知的发送者并不在乎图片是如何从网上下载到本地的。

运行一下项目，可以看到专辑封面已经显示出来了：

![](http://cdn1.raywenderlich.com/wp-content/uploads/2014/11/swiftDesignPattern13-288x320.png)

关了应用再重新运行，注意这次没有任何延时就显示了所有的图片，因为我们已经有了本地缓存。我们甚至可以在没有网络的情况下正常使用我们的应用。不过出了问题：这个用来提示加载网络请求的小菊花怎么一直在显示！

我们在下载图片的时候开启了这个白色小菊花，但是在图片下载完毕的时候我们并没有停掉它。我们可以在每次下载成功的时候发送一个通知，但是我们不这样做，这次我们来用用另一个观察者模式： KVO 。


### 键值观察 - KVO

在 KVO 里，对象可以注册监听任何属性的变化，不管它是否持有。如果感兴趣的话，可以读一读[苹果 KVO 编程指南](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/KeyValueObserving/KeyValueObserving.html)。

#### 如何使用 KVO

正如前面所提及的， 对象可以关注任何属性的变化。在我们的例子里，我们可以用 KVO 关注 `UIImageView` 的 `image` 属性变化。

打开 `AlbumView.swift` 文件，找到 `init(frame:albumCover:)` 方法，在把 `coverImage` 添加到 `subView` 的代码后面添加如下代码：

    coverImage.addObserver(self, forKeyPath: "image", options: nil, context: nil)

这行代码把 `self` (也就是当前类) 添加到了 `coverImage` 的 `image` 属性的观察者里。

在销毁的时候，我们也需要取消观察。还是在 `AlbumView.swift` 文件里，添加如下代码：

    deinit {
        coverImage.removeObserver(self, forKeyPath: "image")
    }

最终添加如下方法：

    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if keyPath == "image" {
            indicator.stopAnimating()
        }
    }

必须在所有的观察者里实现上面的代码。在检测到属性变化的时候，系统会自动调用这个方法。在上面的代码里，我们在图片加载完成的时候把那个提示加载的小菊花去掉了。

再次运行项目，你会发现一切正常了：

![](http://cdn3.raywenderlich.com/wp-content/uploads/2014/11/swiftDesignPattern14-292x320.png)

注意：一定要记得移除观察者，否则如果对象已经销毁了还给它发送消息会导致应用崩溃。

此时你可以把玩一下当前的应用然后再关掉它，你会发现你的应用的状态并没有存储下来。最后看见的专辑并不会再下次打开应用的时候出现。

为了解决这个问题，我们可以使用下一种模式：备忘录模式。

## 备忘录模式 - Memento

备忘录模式捕捉并且具象化一个对象的内在状态。换句话说，它把你的对象存在了某个地方，然后在以后的某个时间再把它恢复出来，而不会打破它本身的封装性，私有数据依旧是私有数据。 

### 如何使用备忘录模式

在 `ViewController.swift` 里加上下面两个方法：

    //MARK: Memento Pattern
    func saveCurrentState() {
        // When the user leaves the app and then comes back again, he wants it to be in the exact same state
        // he left it. In order to do this we need to save the currently displayed album.
        // Since it's only one piece of information we can use NSUserDefaults.
        NSUserDefaults.standardUserDefaults().setInteger(currentAlbumIndex, forKey: "currentAlbumIndex")
    }

    func loadPreviousState() {
        currentAlbumIndex = NSUserDefaults.standardUserDefaults().integerForKey("currentAlbumIndex")
        showDataForAlbum(currentAlbumIndex)
    }

`saveCurrentState` 把当前相册的索引值存到 `NSUserDefaults` 里。`NSUserDefaults` 是 iOS 提供的一个标准存储方案，用于保存应用的配置信息和数据。

`loadPreviousState` 方法加载上次存储的索引值。这并不是备忘录模式的完整实现，但是已经离目标不远了。

接下来在 `viewDidLoad` 的 `scroller.delegate = self` 前面调用：

    loadPreviousState()

这样在刚初始化的时候就加载了上次存储的状态。但是什么时候存储当前状态呢？这个时候我们可以用通知来做。在应用进入到后台的时候， iOS 会发送一个 `UIApplicationDidEnterBackgroundNotification` 的通知，我们可以在这个通知里调用 `saveCurrentState` 这个方法。是不是很方便？

在 `viewDidLoad` 的最后加上如下代码：

    NSNotificationCenter.defaultCenter().addObserver(self, selector:"saveCurrentState", name: UIApplicationDidEnterBackgroundNotification, object: nil)

现在，当应用即将进入后台的时候，`ViewController` 会调用 `saveCurrentState` 方法自动存储当前状态。

当然也别忘了取消监听通知，添加如下代码：

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

这样就确保在 `ViewController` 销毁的时候取消监听通知。

这时再运行程序，随意移到某个专辑上，然后按下 Home 键把应用切换到后台，再在 Xcode 上把 App 关闭。重新启动，会看见上次记录的专辑已经存了下来并成功还原了：

![](http://cdn2.raywenderlich.com/wp-content/uploads/2014/11/swiftDesignPattern15-202x320.png)

看起来专辑数据好像是对了，但是上面的滚动条似乎出了问题，没有居中啊！

这时 `initialViewIndex` 方法就派上用场了。由于在委托里 (也就是 `ViewController` ) 还没实现这个方法，所以初始化的结果总是第一张专辑。

为了修复这个问题，我们可以在 `ViewController.swift` 里添加如下代码：

    func initialViewIndex(scroller: HorizontalScroller) -> Int {
        return currentAlbumIndex
    }

现在 `HorizontalScroller` 可以根据 `currentAlbumIndex` 自动滑到相应的索引位置了。

再次重复上次的步骤，切到后台，关闭应用，重启，一切顺利：

![](http://cdn2.raywenderlich.com/wp-content/uploads/2014/11/swiftDesignPattern16-230x320.png)

回头看看 `PersistencyManager` 的 `init` 方法，你会发现专辑数据是我们硬编码写进去的，而且每次创建 `PersistencyManager` 的时候都会再创建一次专辑数据。而实际上一个比较好的方案是只创建一次，然后把专辑数据存到本地文件里。我们如何把专辑数据存到文件里呢？

一种方案是遍历 `Album` 的属性然后把它们写到一个 `plist` 文件里，然后如果需要的时候再重新创建 `Album` 对象。这并不是最好的选择，因为数据和属性不同，你的代码也就要相应的产生变化。举个例子，如果我们以后想添加 `Movie` 对象，它有着完全不同的属性，那么存储和读取数据又需要重写新的代码。

况且你也无法存储这些对象的私有属性，因为其他类是没有访问权限的。这也就是为什么 Apple 提供了 归档 的机制。

### 归档 - Archiving

苹果通过归档的方法来实现备忘录模式。它把对象转化成了流然后在不暴露内部属性的情况下存储数据。你可以读一读 《iOS 6 by Tutorials》 这本书的第 16 章，或者看下[苹果的归档和序列化文档](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/Archiving/Archiving.html)。

#### 如何使用归档

首先，我们需要让 `Album` 实现 `NSCoding` 协议，声明这个类是可被归档的。打开 `Album.swift` 在 `class` 那行后面加上 `NSCoding` ：

    class Album: NSObject, NSCoding {

然后添加如下的两个方法：

    required init(coder decoder: NSCoder) {
        super.init()
        self.title = decoder.decodeObjectForKey("title") as String?
        self.artist = decoder.decodeObjectForKey("artist") as String?
        self.genre = decoder.decodeObjectForKey("genre") as String?
        self.coverUrl = decoder.decodeObjectForKey("cover_url") as String?
        self.year = decoder.decodeObjectForKey("year") as String?
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(title, forKey: "title")
        aCoder.encodeObject(artist, forKey: "artist")
        aCoder.encodeObject(genre, forKey: "genre")
        aCoder.encodeObject(coverUrl, forKey: "cover_url")
        aCoder.encodeObject(year, forKey: "year")
    }


`encodeWithCoder` 方法是 `NSCoding` 的一部分，在被归档的时候调用。相对的， `init(coder:)` 方法则是用来解档的。很简单，很强大。

现在 `Album` 对象可以被归档了，添加一些代码来存储和加载 `Album` 数据。

在 `PersistencyManager.swift` 里添加如下代码：

    func saveAlbums() {
        var filename = NSHomeDirectory().stringByAppendingString("/Documents/albums.bin")
        let data = NSKeyedArchiver.archivedDataWithRootObject(albums)
        data.writeToFile(filename, atomically: true)
    } 

这个方法可以用来存储专辑。 `NSKeyedArchiver` 把专辑数组归档到了 `albums.bin` 这个文件里。

当我们归档一个包含子对象的对象时，系统会自动递归的归档子对象，然后是子对象的子对象，这样一层层递归下去。在我们的例子里，我们归档的是 `albums` 因为 `Array` 和 `Album` 都是实现 `NSCopying` 接口的，所以数组里的对象都可以自动归档。

用下面的代码取代 `PersistencyManager` 中的 `init` 方法：

    override init() {
        super.init()
        if let data = NSData(contentsOfFile: NSHomeDirectory().stringByAppendingString("/Documents/albums.bin")) {
            let unarchiveAlbums = NSKeyedUnarchiver.unarchiveObjectWithData(data) as [Album]?
            if let unwrappedAlbum = unarchiveAlbums {
                albums = unwrappedAlbum
            }
        } else {
            createPlaceholderAlbum()
        }
    }

    func createPlaceholderAlbum() {
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
        saveAlbums()
    }

我们把创建专辑数据的方法放到了 `createPlaceholderAlbum` 里，这样代码可读性更高。在新的代码里，如果存在归档文件， `NSKeyedUnarchiver` 从归档文件加载数据；否则就创建归档文件，这样下次程序启动的时候可以读取本地文件加载数据。

我们还想在每次程序进入后台的时候存储专辑数据。看起来现在这个功能并不是必须的，但是如果以后我们加了编辑功能，这样做还是很有必要的，那时我们肯定希望确保新的数据会同步到本地的归档文件。

因为我们的程序通过 `LibraryAPI` 来访问所有服务，所以我们需要通过 `LibraryAPI` 来通知 `PersistencyManager` 存储专辑数据。

在 `LibraryAPI` 里添加存储专辑数据的方法：

    func saveAlbums() {
        persistencyManager.saveAlbums()
    }

这个方法很简单，就是把 `LibraryAPI` 的 `saveAlbums` 方法传递给了 `persistencyManager` 的 `saveAlbums` 方法。

然后在 `ViewController.swift` 的 `saveCurrentState` 方法的最后加上：

    LibraryAPI.sharedInstance.saveAlbums()

在 `ViewController` 需要存储状态的时候，上面的代码通过 `LibraryAPI` 归档当前的专辑数据。

运行一下程序，检查一下没有编译错误。

不幸的是似乎没什么简单的方法来检查归档是否正确完成。你可以检查一下 `Documents` 目录，看下是否存在归档文件。如果要查看其他数据变化的话，还需要添加编辑专辑数据的功能。

不过和编辑数据相比，似乎加个删除专辑的功能更好一点，如果不想要这张专辑直接删除即可。再进一步，万一误删了话，是不是还可以再加个撤销按钮？

## 最后的润色

现在我们将添加最后一个功能：允许用户删除专辑，以及撤销上次的删除操作。

在 `ViewController` 里添加如下属性：

    // 为了实现撤销功能，我们用数组作为一个栈来 push 和 pop 用户的操作
    var undoStack: [(Album, Int)] = []

然后在 `viewDidLoad` 的 `reloadScroller()` 后面添加如下代码：

    let undoButton = UIBarButtonItem(barButtonSystemItem: .Undo, target: self, action:"undoAction")
    undoButton.enabled = false;
    let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target:nil, action:nil)
    let trashButton = UIBarButtonItem(barButtonSystemItem: .Trash, target:self, action:"deleteAlbum")
    let toolbarButtonItems = [undoButton, space, trashButton]
    toolbar.setItems(toolbarButtonItems, animated: true)

上面的代码创建了一个 `toolbar` ，上面有两个按钮，在 `undoStack` 为空的情况下， `undo` 的按钮是不可用的。注意 `toolbar` 已经在 `storyboard` 里了，我们需要做的只是配置上面的按钮。

我们需要在 `ViewController.swift` 里添加三个方法，用来处理专辑的编辑事件：增加，删除，撤销。

先写添加的方法：

    func addAlbumAtIndex(album: Album,index: Int) {
        LibraryAPI.sharedInstance.addAlbum(album, index: index)
        currentAlbumIndex = index
        reloadScroller()
    }

做了三件事：添加专辑，设为当前的索引，重新加载滚动条。

接下来是删除方法：

    func deleteAlbum() {
        //1
        var deletedAlbum : Album = allAlbums[currentAlbumIndex]
        //2
        var undoAction = (deletedAlbum, currentAlbumIndex)
        undoStack.insert(undoAction, atIndex: 0)
        //3
        LibraryAPI.sharedInstance.deleteAlbum(currentAlbumIndex)
        reloadScroller()
        //4
        let barButtonItems = toolbar.items as [UIBarButtonItem]
        var undoButton : UIBarButtonItem = barButtonItems[0]
        undoButton.enabled = true
        //5
        if (allAlbums.count == 0) {
            var trashButton : UIBarButtonItem = barButtonItems[2]
            trashButton.enabled = false
        }
    }

挨个看一下各个部分：

- 获取要删除的专辑。
- 创建一个 `undoAction` 对象，用元组存储 `Album` 对象和它的索引值。然后把这个元组加到了栈里。
- 使用 `LibraryAPI` 删除专辑数据，然后重新加载滚动条。
- 既然撤销栈里已经有了数据，那么我们需要设置撤销按钮为可用。
- 检查一下是不是还剩专辑，如果没有专辑了那就设置删除按钮为不可用。

最后添加撤销按钮：

    func undoAction() {
        let barButtonItems = toolbar.items as [UIBarButtonItem]
        //1       
        if undoStack.count > 0 {
            let (deletedAlbum, index) = undoStack.removeAtIndex(0)
            addAlbumAtIndex(deletedAlbum, index: index)
        }
        //2       
        if undoStack.count == 0 {
            var undoButton : UIBarButtonItem = barButtonItems[0]
            undoButton.enabled = false
        }
        //3       
        let trashButton : UIBarButtonItem = barButtonItems[2]
        trashButton.enabled = true
    }

照着备注的三个步骤再看一下撤销方法里的代码：

- 首先从栈里 `pop` 出一个对象，这个对象就是我们当初塞进去的元祖，存有删除的 `Album` 对象和它的索引位置。然后我们把取出来的对象放回了数据源里。
- 因为我们从栈里删除了一个对象，所以需要检查一下看看栈是不是空了。如果空了那就设置撤销按钮不可用。
- 既然我们已经撤消了一个专辑，那删除按钮肯定是可用的。所以把它设置为 `enabled` 。

这时再运行应用，试试删除和插销功能，似乎一切正常了：

![](http://cdn2.raywenderlich.com/wp-content/uploads/2014/11/swiftDesignPattern1-179x320.png)

我们也可以趁机测试一下，看看是否及时存储了专辑数据的变化。比如删除一个专辑，然后切到后台，强关应用，再重新开启，看看是不是删除操作成功保存了。

如果想要恢复所有数据，删除应用然后重新安装即可。

## 小结

最终项目的源代码可以在 [BlueLibrarySwift-Final](http://cdn2.raywenderlich.com/wp-content/uploads/2014/12/BlueLibrarySwift-Final.zip) 下载。

通过这两篇设计模式的学习，我们接触到了一些基础的设计模式和概念：Singleton、MVC、Delegation、Protocols、Facade、Observer、Memento 。

这篇文章的目的，并不是推崇每行代码都要用设计模式，而是希望大家在考虑一些问题的时候，可以参考设计模式提出一些合理的解决方案，尤其是应用开发的起始阶段，思考和设计尤为重要。

如果想继续深入学习设计模式，推荐设计模式的经典书籍：[Design Patterns: Elements of Reusable Object-Oriented Software](http://www.amazon.com/Design-Patterns-Elements-Reusable-Object-Oriented/dp/0201633612/)。

如果想看更多的设计模式相关的代码，推荐这个神奇的项目： [Swift 实现的种种设计模式](https://github.com/ochococo/Design-Patterns-In-Swift)。

接下来你可以看看这篇：[Swift 设计模式中级指南](http://www.raywenderlich.com/86053/intermediate-design-patterns-in-swift)，学习更多的设计模式。

玩的开心。 :]



***

原文链接：

- [Introducing iOS Design Patterns in Swift – Part 2/2](http://www.raywenderlich.com/90773/introducing-ios-design-patterns-in-swift-part-2)