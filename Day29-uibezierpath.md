# [Swift90Days](https://github.com/callmewhy/Swift90Days) - UIBezierPath



今天在公司的代码里看到通过 `UIBezierPath` 绘制 CALayer 然后实现中空的正方形，感觉还挺有意思的，简单记录一下 `UIBezierPath` 这个东西。


## 一条线

我们自定义一个 BezierView 继承自 UIView ，并重写它的 `drawRect` 方法实现绘图操作。

    import UIKit

    class BezierView: UIView {
        override func drawRect(rect: CGRect) {
            super.drawRect(rect);
            var myBezier = UIBezierPath()
            myBezier.moveToPoint(CGPoint(x: 100, y: 100))
            myBezier.addLineToPoint(CGPoint(x: 200, y: 100))
            UIColor.orangeColor().setStroke()
            myBezier.stroke()
        }
    }

## 两条线

也就是先 `moveToPoint` 然后再 `addLineToPoint` 一次：

    import UIKit

    class BezierView: UIView {
        override func drawRect(rect: CGRect) {
            super.drawRect(rect);
            var myBezier = UIBezierPath()
            myBezier.moveToPoint(CGPoint(x: 100, y: 100))
            myBezier.addLineToPoint(CGPoint(x: 200, y: 100))
            myBezier.moveToPoint(CGPoint(x: 100, y: 200))
            myBezier.addLineToPoint(CGPoint(x: 200, y: 200))
            UIColor.orangeColor().setStroke()
            myBezier.stroke()
        }
    }

## 一个圆

我们可以通过下面的方法绘制一个圆弧：
    
    var bezier1 = UIBezierPath()
    bezier1.addArcWithCenter(CGPointMake(100, 300), radius: 50, startAngle: 0, endAngle: 1.0, clockwise: true)
    bezier1.stroke()

其中，`startAngle` 是以 x 轴正方向为起点，`clockwise` 则是用来标记是否为顺时针方向。

## 加个框

`stroke` 是画线，`fill` 是填充。所以实心圆可以这么画：

    UIColor.redColor().setFill()
    UIColor.greenColor().setStroke()
    var bezier2 = UIBezierPath()
    bezier2.addArcWithCenter(CGPointMake(100, 300), radius: 50, startAngle: 0, endAngle: 20, clockwise: true)
    bezier2.lineWidth = 10
    bezier2.stroke()
    bezier2.fill()
    
    
## 空心圆

其实当初看到 UIBezierPath 是因为公司的项目里用这个实现了一个中间是透明正方形的黑色蒙版，用在了二维码扫描上。接下来就试着做一个黑色的蒙版，然后中间有一个透明的正方形。

先来看看 `mask` 的用法：

    import UIKit

    class ViewController: UIViewController {

        override func viewDidLoad() {
            super.viewDidLoad()
            var path = UIBezierPath()
            path.addArcWithCenter(view.center, radius: 100, startAngle: 0, endAngle: CGFloat(M_PI), clockwise: true)
            path.closePath()
            var mask = CAShapeLayer()
            mask.path = path.CGPath
            view.layer.mask = mask
        }
    }


接下来我们可以简单的实现以下这个中空的效果：


    import UIKit

    class ViewController: UIViewController {

        override func viewDidLoad() {
            super.viewDidLoad()
            
            let imageView = UIImageView(image: UIImage(named: "avatar"))
            imageView.center = view.center
            view.addSubview(imageView)
            
            let maskLayer = CALayer()
            maskLayer.frame = view.frame
            maskLayer.backgroundColor = UIColor.blackColor().CGColor
            maskLayer.opacity = 0.6
            view.layer.addSublayer(maskLayer)
            
            let rectSize = CGFloat(100)
            let shapeLayer = CAShapeLayer()
            shapeLayer.frame = view.layer.frame
            var path = UIBezierPath(rect: CGRectMake((view.frame.width-rectSize)/2, (view.frame.height-rectSize)/2, rectSize, rectSize))
            path.appendPath(UIBezierPath(rect: view.layer.frame))
            shapeLayer.path = path.CGPath
            shapeLayer.fillRule = kCAFillRuleEvenOdd
            
            maskLayer.mask = shapeLayer
        }
    }


简单记录一下 `fillRule` ，它有两种值：

- kCAFillRuleNonZero，非零。按该规则，要判断一个点是否在图形内，从该点作任意方向的一条射线，然后检测射线与图形路径的交点情况。从0开始计数，路径从左向右穿过射线则计数加1，从右向左穿过射线则计数减1。得出计数结果后，如果结果是0，则认为点在图形外部，否则认为在内部。


- kCAFillRuleEvenOdd，奇偶。按该规则，要判断一个点是否在图形内，从该点作任意方向的一条射线，然后检测射线与图形路径的交点的数量。如果结果是奇数则认为点在内部，是偶数则认为点在外部。






*** 

## References

- [UIBezierPath Class](https://developer.apple.com/library/prerelease/ios/documentation/UIKit/Reference/UIBezierPath_class/index.html)