# [Swift90Days](https://github.com/callmewhy/Swift90Days) - 一个简单的小应用 1 / 2


## 第0步：明确任务

经过前面基础语法的学习，我们终于可以真枪实弹的来一发了。以这篇[小鸡鸡小猫猫小狗狗](http://www.weheartswift.com/birds-cats-dogs/)为例，我们将会创建一个简单的应用：

- 通过 `UITableView` 展示三种小动物
- 通过 `NSUserDefaults` 进行数据持久化
- 通过 `UIWebView` 从维基百科加载更多数据

由于时间有限，这篇博客并不是教程或者翻译，只是一个关键思路的整理和记录，完整的源代码在文末有链接，如果有任何疑问欢迎与我[联系](mailto:whywanghai@gmail.com)，谢谢。

## 第1步：创建项目

创建一个新的项目，模板选择 `Single View Application` ，项目名称叫做：BirdsCatsDogs。

## 第2步：简单重构

系统为我们自动生成了 `ViewController.swift` ，将其改为`SpeciesViewController.swift` ，记得也改下类的名字。然后在 StoryBoard (以后简称为 SB 希望不要误解) 中设置 `custum class`，如果设置正确在输入的时候是有自动补全的，回车即可。

## 第3步：添加导航

拖拽一个 UINavigationController 到 SB 中，设置成 `Initial View Controller`，然后把 `SpeciesViewController` 设置成它的 `root view controller` 。把 `SpeciesViewController` 的 title 设置成 `Species` 。

运行一下，确保没有问题。（不可能有问题，这时候运行一般是满足自己内心的成就感。）

## 第4步：加载数据

在这里我们用 `NSUserDefaults` 加载数据，通常它用来存储一些系统配置，比如字体大小啊之类的。

我们新建一个 `DataManager.swift` ，通过单例模式实现一个数据管理器：

    import Foundation

    class DataManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : DataManager? = nil
        }
        
        class var sharedInstance : DataManager {
            dispatch_once(&Static.onceToken) {
                Static.instance = DataManager()
            }
            return Static.instance!
        }
    }

这段代码是原文的代码，有些地方可以参考：

- 静态变量通过内嵌 `Static` 结构体存储。
- 单例模式通过 `dispatch_once` 实现，通过 `sharedInstance` 获取。 (GCD的内容后面再补充)

接下来我们在 `DataManager` 里面添加一个变量：`species`，类型为 `[String:[String]]`。在 `init()` 里加上一些初始化的工作：

    var species: [String:[String]]
    
    init() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let speciesInfo = userDefaults.valueForKey("species") as? [String:[String]] {
            species = speciesInfo
        } else {
            species = [
                "Birds": ["Swift"],
                "Cats" : ["Persian Cat"],
                "Dogs" : ["Labrador Retriever"]
            ]
        }
    }


我们可以通过 `DataManager.sharedInstance.species` 获取各个种类的数据。

Tips：类似于单例模式这种可能会多次用到的代码片段，建议加到 Xcode 的 Snippets 里。


## 第5步：加载列表

我们用字典存储了数据，通过 key 值获取数据十分方便。但是字典本身是无序的，而像 UITableView 这种列表的数据本身是有序的。所以添加一个计算属性 `speciesList` ，可以获取排序之后的列表并返回：

    
    var speciesList: [String] {
        var list: [String] = []
        for speciesName in species.keys {
            list.append(speciesName)
        }
        list.sort(<)
        return list
    }

回到 `SpeciesViewController`  里，我们可以这样获取数据：

    var species: [String] = DataManager.sharedInstance.speciesList

## 第6步：列表视图

拖拖拽拽设置好 `UITableView` ，具体过程就不赘述了，可以直接打开项目看看。`tableview` 相关的部分代码如下：

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        cell.textLabel?.text = species[indexPath.row]
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return species.count
    }

运行一下，确保没有问题。（这时候就不是成就感的问题了，测试 SB 和代码的连接情况。）

## 第7步：详情页面

我们再创建一个 `RacesViewController` ，用来展示当前种类下的数据列表：

    class RacesViewController: UIViewController {
        var species: String!

        override func viewDidLoad() {
            super.viewDidLoad()

            title = species
        }
    }

注意在 StoryBoard 里设置这个 `RacesViewController` 的 StoryBoard ID ，这样我们在做点击事件的时候可以获取到这个 `RacesViewController` 然后进行 `pushViewController` 操作。

## 第8步：选中事件

回到 `SpeciesViewController` 里，添加单元格的选中事件：

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        var racesViewController = storyboard?.instantiateViewControllerWithIdentifier("RacesViewController") as RacesViewController
        racesViewController.species = species[indexPath.row]
        navigationController?.pushViewController(racesViewController, animated: true)
    }

`instantiateViewControllerWithIdentifier` 可以通过 StoryBoard ID 初始化 ViewController 。

## 第9步：展示种类

这个步骤和第6步基本相同， `tableview` 相关的代码：

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return races.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("RaceCell") as UITableViewCell
        cell.textLabel?.text = races[indexPath.row]
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }

这时再测试一下，点击 cell 之后会跳转到另一个表格列表里。




*** 

## References

- [Birds, Cats and Dogs](http://www.weheartswift.com/birds-cats-dogs/)