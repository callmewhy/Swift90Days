# [Swift90Days](https://github.com/callmewhy/Swift90Days) - 类型的设计

## 介绍

今天读的这篇博文，作者是一名 Haskell 程序员，从 Swift 枚举类可以通过 `rawValue` 来初始化这个特性谈起，提出了一些自己的观点，摘录一部分如下：

> I always thought of the `rawValue` mechanism as an escape hatch to drop back down to the world of Objective-C, rather than something you should use in Swift if you can help it. I don't want to say that using `rawValue` is wrong in any way, but rather that it doesn't fit with my intuition. Years of Haskell programming have warped my brain in interesting ways. One important lesson I've learned is that designing the right types for your problem is a great way to help the compiler debug your program.

感兴趣的同学建议直接阅读原文：[The Design of Types](http://www.swiftcast.tv/articles/the-design-of-types)。由于是一边看着老罗的直播一边写的，所以写的可能有点凌乱哈哈哈哈。

## 输入校验

输入校验大家应该都不陌生，为了防止 SQL 注入之类的问题，通常会对输入的内容进行校验。简单来说我们可以定义一个函数进行校验：

    func sanitize(userInput : String) -> String

每次需要校验输入的时候用这个函数过滤一下就行。

但问题也随之而来：当出现一个字符串的时候，需要我们手动判断是否需要进行校验，一不小心可能会校验多次 (比如获取的时候校验了，写入数据库又校验了，这有点糟糕)，也有可能就没校验 (比如获取的时候以为写入的时候会校验，写入数据库的时候以为已经校验过了，这更糟糕)。

为了避免这种繁琐的问题，我们可以让编译器去做这个工作：

    typealias UserInput = String

    struct SanitizedString {
        let value : String
        
        init(input : UserInput)
        {
            value = sanitize(input)
        }
    }

可以看到我们定义了两个新的类型 `SanitizedString` 和 `UserInput`：

- `UserInput` 就是 String 类型，用来标记用户的输入。
- `SanitizedString` 是结构体，通过一个 `value` 存储校验后的字符串。

是的，这样就不用亲自监控输入的校验了，使用起来看看。比如我们通过 `sanitize` 把空格去掉然后返回：


    import Foundation

    func sanitize(userInput : String) -> String {
        return userInput.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    }

    typealias UserInput = String

    struct SanitizedString {
        let value : String
        
        init(input : UserInput)
        {
            value = sanitize(input)
        }
    }

    var a: SanitizedString = SanitizedString(input: "  Hello WHY  ")
    println(a.value)    // HelloWHY


## 用户注册

我们可以用个元组来封装用户信息，比如存储了邮件地址和脸书账号：

    typealias UserInfo = (EmailAddress?, FacebookAccount?)

但是很不幸，这样定义的类型会出现这种无效值：

    let bogus : UserInfo = (nil, nil)

文中提出了这样一个观点：应该让非法状态不可表述。换句话说，如果我们想避免这种既没有邮箱地址也没有脸书账号的情况出现，应该让这种情况无法表现出来。

比如我们可以用这样一个枚举类型来表示用户的状态：

    enum UserInfo {
      case Email (EmailAddress)
      case Facebook (FacebookAccount)
      case EmailAndFacebook (EmailAddress, FacebookAccount)
    }

用户的信息分为三种情况：

- 邮件地址
- 脸书账户
- 邮件地址和脸书账户

看起来增加了很多额外的工作量，却也收获了很多。我们可以把一部分业务逻辑分离出来。

比如移除脸书账号，如果用元组的方式进行删除是这样的：

    func removeFacebookInfo(userInfo : (EmailAddress?, FacebookAccount?)) -> (EmailAddress?, FacebookAccount?) 
    {
      return (userInfo.0, nil)
    }

用枚举类型来解决则可以返回可选类型表示移除失败的情况：

    func removeFacebookInfo(userInfo : UserInfo) -> UserInfo? 
    {
      switch userInfo 
      {
        case let .EmailAndFacebook(email,_):
            return UserInfo.Email(email)
        default:
            return nil
      }
    }

## 其他

对于类型的设计，作者分享一段不错的代码 [routes.swift](https://gist.github.com/chriseidhof/1fc977ffb856dbcdc113) ：

     import Foundation
     
     enum Github {
        case Zen
        case UserProfile(String)
     }
     
     protocol Path {
        var path : String { get }
     }
     
     extension Github : Path {
        var path: String {
            switch self {
            case .Zen: return "/zen"
            case .UserProfile(let name): return "/users/\(name)"
            }
        }
     }
     
     let sample = Github.UserProfile("ashfurrow")
     
     println(sample.path) // Prints "/users/ashfurrow"
     
     // So far, so good
     
     protocol Moya : Path {
        var baseURL: NSURL { get }
        var sampleData: String { get } // Probably JSON would be better than AnyObject
     }
     
     extension Github : Moya {
        var baseURL: NSURL { return NSURL(string: "https://api.github.com")! }
        var sampleData: String {
            switch self {
            case .Zen: return "Half measures are as bad as nothing at all."
            case .UserProfile(let name): return "{login: \"\(name)\", id: 100}"
            }
        }
     }
     
     func url(route: Moya) -> NSURL {
        return route.baseURL.URLByAppendingPathComponent(route.path)
     }
     
     println(url(sample)) // prints https://api.github.com/users/ashfurrow


相关文章在这里：[Type-safe URL routes in Swift](http://chris.eidhof.nl/posts/typesafe-url-routes-in-swift.html)。就不展开讨论了。

## 总结

作者对于如何合理有效的利用 Swift 的特性进行了思考和讨论，值得一看。

感觉写总结很费时间，因为自己写的没有原文好，又没时间展开讨论只能匆匆记录下来。下次尝试写成英文的锻炼一下英语能力吧。。。


*** 

## References

- [The Design of Types](http://www.swiftcast.tv/articles/the-design-of-types)
- [Type-safe URL routes in Swift](http://chris.eidhof.nl/posts/typesafe-url-routes-in-swift.html)
- [routes.swift](https://gist.github.com/chriseidhof/1fc977ffb856dbcdc113)
- [Moya](https://github.com/AshFurrow/Moya)