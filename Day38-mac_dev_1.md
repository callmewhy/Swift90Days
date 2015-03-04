# [Swift90Days](https://github.com/callmewhy/Swift90Days) - 用 Swift 开发 Mac App 1 / 3


今天抽点时间找了篇 Raywenderlich 上的教程入门了一下 Mac App 的开发。

教程的例子是实现一个简单的 `TableView` ，不过在 Mac 里它叫做 `NSTableView` 。

用法也和 `UITableView` 相似，通过 `delegate` 和 `datasource` 来加载列表：


    import Cocoa

    class MasterViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

        var bugs: [ScaryBugDoc]!
        
        override func viewDidLoad() {
            super.viewDidLoad()

            // init bugs
            var doc1 = ScaryBugDoc(title: "Potato Bug", rating: 4, thumbImage:NSImage(named:"potatoBugThumb")!, fullImage: NSImage(named:"potatoBug")!)
            var doc2 = ScaryBugDoc(title: "House Centipede", rating: 4, thumbImage:NSImage(named:"centipedeThumb")!, fullImage: NSImage(named:"centipede")!)
            var doc3 = ScaryBugDoc(title: "Wolf Spider", rating: 4, thumbImage:NSImage(named:"wolfSpiderThumb")!, fullImage: NSImage(named:"wolfSpider")!)
            var doc4 = ScaryBugDoc(title: "Lady Bug", rating: 4, thumbImage:NSImage(named:"ladybugThumb")!, fullImage: NSImage(named:"ladybug")!)
            bugs = [doc1,doc2,doc3,doc4]
        }
        
        

        // MARK: NSTableViewDataSource
        func tableView(tableView: NSTableView!, viewForTableColumn tableColumn: NSTableColumn!, row: Int) -> NSView! {
            var cellView = tableView.makeViewWithIdentifier(tableColumn.identifier, owner: self) as NSTableCellView
            if cellView.identifier == "BugColumn" {
                var doc = bugs[row]
                cellView.imageView?.image = doc.thumbImage
                cellView.textField?.stringValue = doc.data.title
            }
            return cellView;
        }
        
        func numberOfRowsInTableView(tableView: NSTableView) -> Int {
            return bugs.count
        }
        
    }

好吧就这么点了，感兴趣的同学可以看下文末的教程链接。



***

原文链接：

- [How to Make a Simple Mac App on OS X 10.7 Tutorial: Part 1/3](http://www.raywenderlich.com/17811/how-to-make-a-simple-mac-app-on-os-x-10-7-tutorial-part-13)