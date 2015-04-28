# [Swift90Days](https://github.com/callmewhy/Swift90Days) - 打印自定义对象

前几天在做一个外包项目的时候遇到 enum 对象 `printf()` 一直只有内存地址。当时还感觉奇怪为什么我明明写了 `description()` 方法但是打印出来还是不行：

    enum Router {
        var description: String {
            return "Something to print"
        }
    }

后来在看 nixzhu 的这篇 [《使用状态机的好处》](https://github.com/nixzhu/dev-blog/blob/master/2015-04-23-state-machine.md) ，发现其实应该加个 `Printable` 协议：

    enum Router: Printable {
        var description: String {
            return "Something to print"
        }
    }

