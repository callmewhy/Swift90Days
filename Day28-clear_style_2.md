# [Swift90Days](https://github.com/callmewhy/Swift90Days) - 基于手势的 TODO 应用 2


接着上面的文章看看这个 TODO 应用的代码，接下来看下 `TableViewCell` 类。

## TableViewCell

### TableViewCellDelegate

在 Cell 里首先是定义了一个委托，用来对 Cell 进行操作：

    protocol TableViewCellDelegate {
        func toDoItemDeleted(todoItem: ToDoItem)
        func cellDidBeginEditing(editingCell: TableViewCell)
        func cellDidEndEditing(editingCell: TableViewCell)
    }


## todoItem

Cell 的数据来源是这个 todoItem 对象。定义如下：

    var toDoItem: ToDoItem? {
        didSet {
            label.text = toDoItem!.text
            label.strikeThrough = toDoItem!.completed
            itemCompleteLayer.hidden = !label.strikeThrough
        }
    }

可以看到这个属性在 didSet 之后会刷新 UI。

## init

注意在 init 中有这么几个点：

### 内部方法

因为右侧的打钩按钮和左侧的打叉按钮除了内容不同，基本的形式 (背景颜色、字体、文字颜色) 是一样的，而除了当前方法又不会有其他方法调用这个生产 UILabel 的方法，所以定义了一个内部方法生产 UILabel ：

    func createCueLabel() -> UILabel {
        let label = UILabel(frame: CGRect.nullRect)
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.boldSystemFontOfSize(32.0)
        label.backgroundColor = UIColor.clearColor()
        return label
    }

### 按钮高亮

高亮效果并不是用切图实现的，而是通过代码设置色值和色值所在的位置实现的。每个 Cell 的高亮效果是这样写的：

    gradientLayer.frame = bounds
    let color1 = UIColor(white: 1.0, alpha: 0.2).CGColor as CGColorRef
    let color2 = UIColor(white: 1.0, alpha: 0.1).CGColor as CGColorRef
    let color3 = UIColor.clearColor().CGColor as CGColorRef
    let color4 = UIColor(white: 0.0, alpha: 0.1).CGColor as CGColorRef
    gradientLayer.colors = [color1, color2, color3, color4]
    gradientLayer.locations = [0.0, 0.01, 0.95, 1.0]
    layer.insertSublayer(gradientLayer, atIndex: 0)


如果搞不懂这些代码的作用，改成这样再运行就可以理解了：


    // gradient layer for cell
    gradientLayer.frame = bounds
    let color1 = UIColor(white: 1.0, alpha: 1.0).CGColor as CGColorRef
    let color2 = UIColor(white: 1.0, alpha: 0.0).CGColor as CGColorRef
    gradientLayer.colors = [color1, color2]
    gradientLayer.locations = [0.0, 1.0]
    layer.insertSublayer(gradientLayer, atIndex: 0)

### 完成效果

当一个 item 完成的时候，会把它的颜色设置为绿色标记为已经完成。这个绿色也是通过 CALayer 实现的，一开始初始化的时候设置为隐藏：

    // add a layer that renders a green background when an item is complete
    itemCompleteLayer = CALayer(layer: layer)
    itemCompleteLayer.backgroundColor = UIColor(red: 0.0, green: 0.6, blue: 0.0, alpha: 1.0).CGColor
    itemCompleteLayer.hidden = true
    layer.insertSublayer(itemCompleteLayer, atIndex: 0)


### 手势

手势应该算是这个应用的一个亮点，在 init 里面定义了手势的识别：

    var recognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
    recognizer.delegate = self
    addGestureRecognizer(recognizer)

首先先通过委托判断是否应该识别这个手势：

    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translationInView(superview!)
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
            return false
        }
        return false
    }

可以看到是 X 偏移量大于 Y 的偏移量即可继续识别。

然后看下具体的识别过程：


    //MARK: - 横向手势识别
    func handlePan(recognizer: UIPanGestureRecognizer) {
        // 1
        if recognizer.state == .Began {
            // 刚开始的时候，记录手势的位置
            originalCenter = center
        }
        // 2
        if recognizer.state == .Changed {
            let translation = recognizer.translationInView(self)
            center = CGPointMake(originalCenter.x + translation.x, originalCenter.y)
            // 判断是否达到屏幕的一半，从而选择是否触发
            deleteOnDragRelease = frame.origin.x < -frame.size.width / 2.0
            completeOnDragRelease = frame.origin.x > frame.size.width / 2.0
            // 隐藏左右标记
            let cueAlpha = fabs(frame.origin.x) / (frame.size.width / 2.0)
            tickLabel.alpha = cueAlpha
            crossLabel.alpha = cueAlpha
            // 根据判断结果刷新界面
            tickLabel.textColor = completeOnDragRelease ? UIColor.greenColor() : UIColor.whiteColor()
            crossLabel.textColor = deleteOnDragRelease ? UIColor.redColor() : UIColor.whiteColor()
        }
        // 3
        if recognizer.state == .Ended {
            let originalFrame = CGRect(x: 0, y: frame.origin.y,
                width: bounds.size.width, height: bounds.size.height)
            if deleteOnDragRelease {
                if delegate != nil && toDoItem != nil {
                    // 通知委托删除
                    delegate!.toDoItemDeleted(toDoItem!)
                }
            } else if completeOnDragRelease {
                if toDoItem != nil {
                    toDoItem!.completed = true
                }
                label.strikeThrough = true
                itemCompleteLayer.hidden = false
                UIView.animateWithDuration(0.2, animations: {self.frame = originalFrame})
            } else {
                UIView.animateWithDuration(0.2, animations: {self.frame = originalFrame})
            }
        }
    }





*** 

## References

- [Making a Gesture-Driven To-Do List App Like Clear in Swift: Part 1/2](http://www.raywenderlich.com/77974/making-a-gesture-driven-to-do-list-app-like-clear-in-swift-part-1)
- [Making a Gesture-Driven To-Do List App Like Clear in Swift: Part 2/2](http://www.raywenderlich.com/77975/making-a-gesture-driven-to-do-list-app-like-clear-in-swift-part-2)