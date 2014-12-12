# [Swift90Days](https://github.com/callmewhy/Swift90Days) - 侧滑菜单的制作

今天仔细阅读了 [How to Create Your Own Slide-Out Navigation Panel in Swift](http://www.raywenderlich.com/78568/create-slide-out-navigation-panel-swift) 的源码，感觉收获很大，记录一下。


## 简单描述

大致的结构是这样：

- ContainerViewController：其他视图的容器，存放了中间的主视图、左侧的侧滑视图、右侧的策划视图
- CenterViewController：主视图，导航栏左右分别有左滑按钮和右滑按钮。
- SidePanelViewController：侧视图菜单，当主视图侧滑后显示


## StoryBoard 中复杂 View 的处理方案

一般使用 SB 的时候，我们常常是简单的 push 和 pop 操作，如果是侧滑菜单这种，上一个菜单退了一半，漏了一部分在屏幕右侧的话，直接通过 SB 无法实现。

解决的方案就是：使用 SB 负责 UI 布局，并不是 Scene 的作用。

在 `AppDelegate` 的 `didFinishLaunchingWithOptions` 里我们手动创建 window 并且指定 `rootViewController` 。比如我们需要个容器来存放主页面和侧滑出现的菜单页面，我们可以这样：

window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    let containerViewController = ContainerViewController()
    window!.rootViewController = containerViewController
    window!.makeKeyAndVisible()

这样项目运行的时候就会进入 `ContainerViewController` 。

### 私有扩展便利获取指定视图

我们经常需要在代码里获取指定的 VC，一大串代码写起来很麻烦，可以在需要频繁使用的地方写个私有扩展：

    private extension UIStoryboard {
        class func mainStoryboard() -> UIStoryboard { 
            return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) 
        }

        class func leftViewController() -> SidePanelViewController? {
            return mainStoryboard().instantiateViewControllerWithIdentifier("LeftViewController") as? SidePanelViewController
        }

        class func rightViewController() -> SidePanelViewController? {
            return mainStoryboard().instantiateViewControllerWithIdentifier("RightViewController") as? SidePanelViewController
        }

        class func centerViewController() -> CenterViewController? {
            return mainStoryboard().instantiateViewControllerWithIdentifier("CenterViewController") as? CenterViewController
        }
    }

可以看到扩展中定义了四个类方法，在后面的代码中我们可以通过类似于 `UIStoryboard.centerViewController()` 这样的代码获取对应的 VC。

## ContainerViewController

这个容器类只起到了容器的作用，没有复杂的布局，更多的是集中处理事件和加载页面，所以并没有出现在 SB 里。

### SlideOutState

容器类中通过枚举定义了三种状态：

    enum SlideOutState {
        case BothCollapsed        // 均未出现
        case LeftPanelExpanded    // 左侧显示
        case RightPanelExpanded   // 右侧显示
    }


通过变量 `currentState` 存储当前的状态，默认是 `BothCollapsed`。通过监听这个变量的 `didSet` 事件实现了主页面阴影的设置。不过我觉得可以在 `viewDidLoad` 里面设置 `shadowOpacity` ，因为全屏的时候是看不见阴影区域的。不知道原作者这样做是不是有什么缘由。


### viewDidLoad

注意这段代码：

    view.addSubview(centerNavigationController.view)
    addChildViewController(centerNavigationController)
    centerNavigationController.didMoveToParentViewController(self)

最后两行去掉并不影响最终结果，但是建立了父子关系。这个具体明天的笔记中再分析。

对于横向滑动的手势操作则是这两行代码：

    let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
    centerNavigationController.view.addGestureRecognizer(panGestureRecognizer)

`handlePanGesture` 处理了滑动手势：
    
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        // 判断是否从左向右
        let gestureIsDraggingFromLeftToRight = (recognizer.velocityInView(view).x > 0)
        
        switch(recognizer.state) {

        // 刚刚开始滑动
        case .Began:
            // 如果刚刚开始滑动的时候还处于主页面，则根据左右方向加入侧面菜单
            if (currentState == .BothCollapsed) {
                if (gestureIsDraggingFromLeftToRight) {
                    addLeftPanelViewController()
                } else {
                    addRightPanelViewController()
                }
            }

        // 如果是正在滑动，则偏移主视图的坐标实现跟随手指位置移动
        case .Changed:
            recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translationInView(view).x
            recognizer.setTranslation(CGPointZero, inView: view)

        // 如果滑动结束
        case .Ended:
            // 判断该左还是该右
            if (leftViewController != nil) {
                let hasMovedGreaterThanHalfway = recognizer.view!.center.x > view.bounds.size.width
                animateLeftPanel(shouldExpand: hasMovedGreaterThanHalfway)
            } else if (rightViewController != nil) {
                let hasMovedGreaterThanHalfway = recognizer.view!.center.x < 0
                animateRightPanel(shouldExpand: hasMovedGreaterThanHalfway)
            }
        default:
            break
        }
    }

根据方法名称可以了解基本的处理。具体的方法内容后面再看。

可以看到视图加载完毕之后只加载了主视图，左右菜单视图并没有初始化。接下来我们到主视图中，看看左上角的按钮点击之后到底发生了什么。(等同于侧滑手势，在此不再赘述。)


## CenterViewController

主视图中没有太多内容，通过委托把左右面板的切换工作分配了出去，所以更多起到了一个分发的作用。委托的定义如下：

    protocol CenterViewControllerDelegate {
        optional func toggleLeftPanel()
        optional func toggleRightPanel()
        optional func collapseSidePanels()
    }

这个方法显然只能由容器类来实现。在这里使用委托好处多多，有利于主页面集中解决自己的业务逻辑，不用关心视图切换的问题。

## SidePanelViewController

由于侧视图中的内容点击之后需要切换主视图中的内容，所以也用委托来实现：

    protocol SidePanelViewControllerDelegate {
      func animalSelected(animal: Animal)
    }

点击事件之后调用委托的 `animalSelected` 方法切换数据源。这里有个小技巧，通过 struct 存储 cell 的 identifier ：

    struct TableView {
        struct CellIdentifiers {
            static let AnimalCell = "AnimalCell"
            static let CatCell    = "CatCell"
            static let DogCell    = "DogCell"
        }
    }


## Slide Out

下面看下左侧按钮点击之后的整个流程。

### toggleLeftPanel

主视图通过委托调用容器视图的 `toggleLeftPanel` 方法：

    func toggleLeftPanel() {

        // 是否还没有展开左侧视图
        let notAlreadyExpanded = (currentState != .LeftPanelExpanded)
        
        // 如果没有展开，则重新添加
        if notAlreadyExpanded {
            addLeftPanelViewController()
        }
        
        // 动态显示左侧视图
        animateLeftPanel(shouldExpand: notAlreadyExpanded)
    }


这里面有两个方法需要看下。

### addLeftPanelViewController()

这个方法添加左侧菜单视图，初始化完成之后调用了 `addChildSidePanelController` 把侧菜单加入到当前视图中。这个方法完成了一些基本的配置工作：

    func addChildSidePanelController(sidePanelController: SidePanelViewController) {

        // 设置委托
        sidePanelController.delegate = centerViewController
        
        // 插入当前视图并置顶
        view.insertSubview(sidePanelController.view, atIndex: 0)
        
        // 建立父子关系
        addChildViewController(sidePanelController)
        sidePanelController.didMoveToParentViewController(self)
    }

这个方法结束之后，并没有显示左侧菜单，显示的部分是下一个方法。


### animateLeftPanel()

这个方法的作用是动态展示和隐藏左侧菜单。完整的代码如下：
    
    func animateLeftPanel(#shouldExpand: Bool) {

        // 如果是用来展示
        if (shouldExpand) {
            // 更新当前状态
            currentState = .LeftPanelExpanded
            // 动画
            animateCenterPanelXPosition(targetPosition: CGRectGetWidth(centerNavigationController.view.frame) - centerPanelExpandedOffset)
        }
        // 如果是用于隐藏
        else {
            // 动画
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                // 动画结束之后更新状态
                self.currentState = .BothCollapsed
                // 移除左侧视图
                self.leftViewController!.view.removeFromSuperview()
                // 释放内存
                self.leftViewController = nil;
            }
        }
    }


突然发现最后设置为 nil 并没有调用 deinit 。。。明天看看吧。

最后就是这个动画啦：

    func animateCenterPanelXPosition(#targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.centerNavigationController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }

通过 `UIView.animateWithDuration` 实现动画效果，没啥好说滴。

今天就到这里啦。




*** 

## References

- [How to Create Your Own Slide-Out Navigation Panel in Swift](http://www.raywenderlich.com/78568/create-slide-out-navigation-panel-swift)
- [New iOS Design Pattern: Slide-out Navigation](http://kenyarmosh.com/ios-pattern-slide-out-navigation/)
- [WWDC 2013 Session笔记 - iOS7中的ViewController切换](http://onevcat.com/2013/10/vc-transition-in-ios7/)