# [Swift90Days](https://github.com/callmewhy/Swift90Days) - CABasicAnimation



`CABasicAnimation` 的结构如下： 

- NSObject
    - CAAnimation
        - CAPropertyAnimation
            - CABasicAnimation


用起来也挺简单：


    import UIKit

    class AnimationViewController: UIViewController {

        var testView: UIView!

        override func viewDidLoad() {
            super.viewDidLoad()
            testView = UIView(frame: CGRectMake(100, 200, 100, 100))
            testView.backgroundColor = UIColor.blackColor()
            view.addSubview(testView)
            
            // 开始动画
            var anim = CABasicAnimation(keyPath: "position.y")
            anim.duration = 2
            anim.fromValue = testView.frame.origin.y
            anim.toValue   = testView.frame.origin.y + 100
            anim.delegate = self
            anim.removedOnCompletion = false
            anim.fillMode = kCAFillModeForwards

            testView.layer.addAnimation(anim, forKey: "translate")
        }

        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }

    }

哈哈哈哈哈就写这么多了，睡觉！




*** 

## References

- [CABasicAnimation Class Reference](https://developer.apple.com/library/mac/documentation/GraphicsImaging/Reference/CABasicAnimation_class/index.html)