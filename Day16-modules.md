# 公用库和模块系统

## 静态库和动态库

先补充一下静态库和动态库的知识。这部分内容我也不太熟，没有开发经验，如有错误欢迎打脸。

### 静态库

静态库的代码追加到可执行文件内，被多次使⽤用就有多份冗余拷⻉。

好处就是应用程序包自身可以独立运行，而不好的地方就是包会略显臃肿，库不能共享。

iOS 中静态库的形式是 .a 和 .framework (自己创建的 .framework 是静态库)。

#### .a

.a 文件在真正使用的时候需要提供头文件和资源文件。以前 Xcode 中默认提供的就是这种方式。不过编译出来静态库只支持特定的一种硬件架构体系，如果你想生成一个 Universal 的静态库的话，需要通过工具来将多个静态库进行合并。而且使用的时候需要另外配合 .h 文件，相比之下 framework 会是更好的选择。

#### framework 

framework 不但可以包含二进制文件，还可以包含头文件，资源文件等，甚至可以支持多个版本。不过各个应用所使用的自己的公用库，最终都需要 link 进可执行文件，所以本质上还是一个静态库。


### 动态库

动态库的代码和可执行文件是分开独立的，程序运行时由系统动态加载到内存，系统只加载一次，多个程序共用节省内存。

动态库的优劣与静态库相反，动态链接库需要库环境，但由于本身不集成库内容，会比较小，同时也为和其他应用共享库的使用提供了可能。

iOS 中动态库的形式是 .dylib 和 .framework (系统的 .framework 是动态库)。


### 现状

出于安全层面的考虑， AppStore 不允许使用第三方的动态链接库。我们可以通过 framework 编写自己的公用库。随着 Xcode6 开始支持新建 framework ，再也不用手动配置了。[iOS-Universal-Framework](https://github.com/kstenerud/iOS-Universal-Framework) 也宣布停止更新。


## 模块

模块化 (modules) 是在 2012年的 LLVM Developers Meeting 中提出的。简单说就是用树形的结构化描述来取代以往的平坦式 `#include` ，对框架进行封装，从而解决以往方法的脆弱性和扩展性不足的问题。 (这段我也不太懂，只是翻译了一下。。。)

以 UIKit 为例， `module.map` 大概是这个样子：

    framework module UIKit {  
        umbrella header "UIKit.h"
        module * {export *}
        link framework "UIKit"
    }

使用的时候用 `@import` 即可。如果所有代码都需要这样重写必定是一项浩大的工程，所以 Apple 已经提前把这部分工作做好了。只要使用的是 iOS7 的 SDK，将 Enable Modules 打开后，然后保持原来的 `#import` 写法就行了，编译器会在编译的时候自动地把可能的地方换成 modules 的写法去编译。


写到这里，我突然忘了我本来想些什么的了。。。走了太远，忘了当初为什么出发了擦。

那就这样吧。



*** 

## References

- [Module System of Swift](http://andelf.github.io/blog/2014/06/19/modules-for-swift/)
- [iOS如何创建和使用静态库](http://blog.ibireme.com/2013/09/18/create-ios-static-framework/)
- [ios开发中的动态链接库和静态链接库](http://lostplesed.tumblr.com/post/76846987590/ios)
- [WWDC2014之iOS使用动态库](http://foggry.com/blog/2014/06/12/wwdc2014zhi-iosshi-yong-dong-tai-ku/)
- [Can you build dynamic libraries for iOS and load them at runtime?](http://stackoverflow.com/questions/4733847/can-you-build-dynamic-libraries-for-ios-and-load-them-at-runtime)
- [Xcode6制作动态及静态Framework](http://years.im/Home/Article/detail/id/52.html)
- [What’s new in Xcode 6](https://developer.apple.com/xcode/)
- [谈谈objc公用库](http://geeklu.com/2014/02/objc-lib/)
- [说说iOS中库的开发](http://www.molotang.com/articles/1497.html)
- [Frameworks](https://developer.apple.com/library/ios/documentation/MacOSX/Conceptual/BPFrameworks/Frameworks.html)
- [How To Create Frameworks / Modules in Xcode 6 and iOS 8](https://www.youtube.com/watch?v=9us3uijFFpo)
- [iOS程序main函数之前发生了什么](http://blog.sunnyxx.com/2014/08/30/objc-pre-main/)
- [Write Swift Module Cont. Static Library](http://andelf.github.io/blog/2014/06/25/write-swift-module-with-swift-cont/)
- [Introduction to Objective-C Modules](http://stoneofarc.wordpress.com/2013/06/25/introduction-to-objective-c-modules/)
- [Waht's New in Objective-C and Foundation in iOS 7](http://gliyao.logdown.com/posts/2013/09/29/note-wahts-new-in-objective-c-and-foundation-in-ios-7)
- [Ray: What’s New in Objective-C and Foundation in iOS 7](http://www.raywenderlich.com/49850/whats-new-in-objective-c-and-foundation-in-ios-7)
- [WWDC 2013 Session笔记 - Xcode5和ObjC新特性](http://onevcat.com/2013/06/new-in-xcode5-and-objc/)