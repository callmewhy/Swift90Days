# [Swift90Days](https://github.com/callmewhy/Swift90Days) - 一个简单的小应用 2 / 2


## 第10步：保存修改

给 `DataManager` 加个添加的方法：

    func saveData() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue(species, forKey: "species")
    }
    
    func addRace(species inSpecies: String, race: String) {
        if var races = species[inSpecies] {
            races.append(race)
            species[inSpecies] = races
        }
        
        saveData()
    }

`saveData` 方法用来写入本地，`addRace` 方法供外部调用，添加一条记录。

## 第11步：添加按钮

给导航栏加个 Add 按钮，并且关联 `didTapAdd` 这个 `IBAction` 。

## 第12步：弹出视图

使用 `UIAlerView` 弹出视图输入内容，注意设置 style 为 `PlainTextInput` ，设置 delegate 为 self 。

    @IBAction func didTapAdd() {
        var alert = UIAlertView(title: "New Race", message: "Type in a new race", delegate: self,
            cancelButtonTitle: "Cancel", otherButtonTitles: "Add")
        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
        alert.show()
    }

然后实现 `alertView` 的委托方法：

    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            var textField = alertView.textFieldAtIndex(0)!
            var newRace = textField.text
            DataManager.sharedInstance.addRace(species: species, race: newRace)
            var newIndexPath = NSIndexPath(forRow: races.count - 1, inSection: 0)
            myTableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }

这个时候再运行一下测试一下添加功能是不是OK。

## 第13步：删除数据

和添加数据一样，我们先去 DataManager 加个删除数据的方法：


    func removeRace(species inSpecies: String, race inRace: String) {
        if var races = species[inSpecies] {
            var index = -1
            
            for (idx, race) in enumerate(races) {
                if race == inRace {
                    index = idx
                    break
                }
            }
            
            if index != -1 {
                races.removeAtIndex(index)
                species[inSpecies] = races
                saveData()
            }
            
        }
    }

有几个值得注意的地方：

- 通过 `index` 设置为 -1 作为标识，防止出现搜索到最后也没找到的结局。
- 通过 `enumerate` 来遍历数组，既不用 `++i` 式的遍历，又可以获取索引值。


然后回到 `RacesViewController` ，添加删除相关的委托方法：


    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        var raceToRemove = races[indexPath.row]
        DataManager.sharedInstance.removeRace(species: species, race: raceToRemove)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }

试一下删除操作，OK没问题。


## 完结

后面 WebView 的内容没什么亮点，大同小异，不再记录。

匆匆记录了一些关键点，如果想完整学习请参考引用中的教程。

其实整个项目的功能很简单，不过凑头到尾走一遍可以体验一下其他程序员的开发思路和基本步骤。总之还是有些收获的。不过边看边记录效率太低，以后只会记录关键的收获，不再啰嗦重复的内容。

完整代码地址：[BirdsCatsDogs](https://github.com/callmewhy/Swift90Days/tree/master/projects/day18/BirdsCatsDogs)


*** 

## References

- [Birds, Cats and Dogs](http://www.weheartswift.com/birds-cats-dogs/)