# [Swift90Days](https://github.com/callmewhy/Swift90Days) - 基于手势的 TODO 应用 1

推荐下两篇教程：

- [Making a Gesture-Driven To-Do List App Like Clear in Swift: Part 1/2](http://www.raywenderlich.com/77974/making-a-gesture-driven-to-do-list-app-like-clear-in-swift-part-1)
- [Making a Gesture-Driven To-Do List App Like Clear in Swift: Part 2/2](http://www.raywenderlich.com/77975/making-a-gesture-driven-to-do-list-app-like-clear-in-swift-part-2)


Raywenderlich 出品，必属精品。具体教程我就不翻译了，看看源码挑一些内容写写。


## UITextField 添加删除线

项目里的每一个 TodoItem 都有删除线，删除线的效果是通过写了一个自定义的 `StrikeThroughText` 类实现的，继承自 `UITextField` 。

### strikeThrough
通过 `Bool` 类型的属性 `strikeThrough` 判断是否添加删除线。监听 `didSet` 方法，每次设置之后修改删除线的显示状态：

    var strikeThrough : Bool {
        didSet {
            strikeThroughLayer.hidden = !strikeThrough
            // 如果需要删除线，则调整删除线的长度
            if strikeThrough {
                resizeStrikeThrough()
            }
        }
    }


### strikeThroughLayer

删除线是通过添加一个自定义的 CALayer 实现的。在 `init` 里面加了进去：

    override init(frame: CGRect) {
        strikeThroughLayer = CALayer()
        strikeThroughLayer.backgroundColor = UIColor.whiteColor().CGColor
        strikeThrough = false        
        super.init(frame: frame)
        layer.addSublayer(strikeThroughLayer)
    }

调整尺寸的时候是通过 `sizeWithAttributes` 这个方法获取尺寸，从而设置宽度。


    func resizeStrikeThrough() {
        let textSize = text.sizeWithAttributes([NSFontAttributeName:font])
        strikeThroughLayer.frame = CGRect(x: 0, y: bounds.size.height/2,
            width: textSize.width, height: kStrikeOutThickness)
    }



*** 

## References

- [Making a Gesture-Driven To-Do List App Like Clear in Swift: Part 1/2](http://www.raywenderlich.com/77974/making-a-gesture-driven-to-do-list-app-like-clear-in-swift-part-1)
- [Making a Gesture-Driven To-Do List App Like Clear in Swift: Part 2/2](http://www.raywenderlich.com/77975/making-a-gesture-driven-to-do-list-app-like-clear-in-swift-part-2)