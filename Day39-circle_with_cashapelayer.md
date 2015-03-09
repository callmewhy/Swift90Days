# [Swift90Days](https://github.com/callmewhy/Swift90Days) - 如何实现圆形加载进度条

今天照着 raywenderlich 的教程学习了一下使用 CAShapeLayer 实现一个原型的加载指示器。完成效果如图：

![](http://cdn3.raywenderlich.com/wp-content/uploads/2015/02/Circle.gif)

后面显示图片的动画暂且不谈，先说这个红色的圆环动画。

通过自定义一个 `UIView` 实现了这个红色的加载指示器，上面有一个 `CAShapeLayer` ，用来显示红色的圆环，圆环部分的关键代码是：


    let circlePathLayer = CAShapeLayer()
    let circleRadius: CGFloat = 20.0
    func configure() {
        circlePathLayer.frame = bounds
        circlePathLayer.lineWidth = 2
        circlePathLayer.fillColor = UIColor.clearColor().CGColor
        circlePathLayer.strokeColor = UIColor.redColor().CGColor
        layer.addSublayer(circlePathLayer)
        backgroundColor = UIColor.whiteColor()
        progress = 0
    }
    

其实也没什么，就是设置 `frame` 和 `lineWidth` 以及一些颜色之类的。然后在 `layoutSubviews` 里面设置 `layer` 的 `path` 就可以了：

    override func layoutSubviews() {
        super.layoutSubviews()
        circlePathLayer.frame = bounds
        circlePathLayer.path = UIBezierPath(ovalInRect: circleFrame()).CGPath
    }

至于动画，则是通过 `setter` 来实现的，在 `set` 里设置 `Layer` 的终点：

    var progress: CGFloat {
        get {
            return circlePathLayer.strokeEnd
        }
        set {
            if (newValue > 1) {
                circlePathLayer.strokeEnd = 1
            } else if (newValue < 0) {
                circlePathLayer.strokeEnd = 0
            } else {
                circlePathLayer.strokeEnd = newValue
            }
        }
    }

嗯挺简单也挺实用的，刚好公司里面有用到。完整的教程和项目源码见原文。



***

原文链接：

- [How To Implement A Circular Image Loader Animation with CAShapeLayer](http://www.raywenderlich.com/94302/implement-circular-image-loader-animation-cashapelayer)