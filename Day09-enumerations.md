# 枚举

## 相关值 - Associated Values

Swift 中的相关值有点像是 F# 中的 [Discriminated Unions](http://msdn.microsoft.com/en-us/library/dd233226.aspx)，它允许在枚举中存储额外的数据。

比如这样一个网络请求结构体，`POST` 是枚举类型，不过可以存储额外的 String 用来存放参数：

    struct NetRequest {
        enum Method {
            case GET
            case POST(String)
        }

        var URL: String
        var method: Method
    }

    var getRequest = NetRequest(URL: "http://drewag.me", method: .GET)
    var postRequest = NetRequest(URL: "http://drewag.me", method: .POST("{\"username\": \"drewag\"}"))

比如下面这个 Barcode 的例子。枚举类中定义了两种条形码，一种是普通的条形码 `UPCA` ，存储四个 Int 值；另一种是二维码 `QRCode` ，存储一个字符串的值：

    enum Barcode {
        case UPCA(Int, Int, Int, Int)
        case QRCode(String)
    }

    var productBarcode = Barcode.UPCA(8, 85909, 51226, 3)
    productBarcode = .QRCode("ABCDEFGHIJKLMNOP")

    switch productBarcode {
    case .UPCA(let numberSystem, let manufacturer, let product, let check):
        println("UPC-A: \(numberSystem), \(manufacturer), \(product), \(check).")
    case .QRCode(let productCode):
        println("QR code: \(productCode).")
    }
    // prints "QR code: ABCDEFGHIJKLMNOP."


这个挺有意思，如果我们要比较两个枚举变量，比如 `code1 == code2` ，结果是相等还是不等呢？

答案是：都不对。Xcode会报错告诉你 `==` 符号无法调用。我们可以自定义运算符解决这个问题：


    func ==(a:Barcode, b:Barcode) -> Bool {
        switch(a) {
            
        case let .UPCA(a1,b1,c1,d1):
            switch(b) {
            case let .UPCA(a2,b2,c2,d2):
                return (a1 == a2 && b1 == b2 && c1 == c2 && d1 == d2)
            default:
                return false
            }
            
        case let .QRCode(a1):
            switch(b) {
            case let .QRCode(a2):
                return a1 == a2
            default:
                return false
            }
        }
    }

    enum Barcode {
        case UPCA(Int, Int, Int, Int)
        case QRCode(String)
    }

    var code1 = Barcode.UPCA(8, 85909, 51226, 3)
    var code2 = Barcode.UPCA(8, 85909, 51226, 4)

    code1 == code2  // false

如果没有相关值是可以直接比较的：

    enum Numbers: Int {
        case One = 1, Two, Three, Four, Five
    }
    var possibleNum1 = Numbers.Three
    var possibleNum2 = Numbers.Three
    println(possibleNum1 == possibleNum2) // true


可选类型就是相关值应用的最好的例子：

    enum Optional {
        case None
        case Some(T)
    }

可以试一下：

    var a: String?
    a = "a" // {Some "a"}
    a == .None  // false
    a == .Some("a") // true



## 原始值 - Raw Values


我们可以给枚举类型的成员用默认值填充，比如下面这个例子，成员的类型为 Character ：

    enum ASCIIControlCharacter: Character {
        case Tab = "\t"
        case LineFeed = "\n"
        case CarriageReturn = "\r"
    }


原始值可以是 `String`，`Character`，`Int`，`Float`，但是只有 Int 可以自增。使用 `toRaw` 可以访问该枚举成员的原始值：

    ASCIIControlCharacter.Tab.rawValue  // rawValue = \t

也可以用 `fromRaw` 从原始值转换成枚举成员，注意返回的是 `.Some` ，因为不一定能转换成功：

    var a = ASCIIControlCharacter(rawValue: "\t")
    a?.rawValue // {Some "\t"}

## 遍历

我们可以通过 `allValues` 遍历枚举类型的所有成员：

    enum ProductCategory : String {
         case Washers = "washers", Dryers = "dryers", Toasters = "toasters"

         static let allValues = [Washers, Dryers, Toasters]
    }

    for category in ProductCategory.allValues{
         //Do something
    }

## 用处

用好枚举类型可以有效的提高代码的可读性，比如我们在 `prepareForSegue` 中经常需要对 `segue.segueIdentifier` 进行比较，如果纯粹的进行字符串比较显得很生硬，不妨在外面套上一层枚举类型，像这样：

    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if let identifier = SegueIdentifier.fromRaw(segue.identifier) {
            switch identifier {
            case .OtherScreenSegue1:
                println("Going to other screen 1")
            case .OtherScreenSegue2:
                println("Going to other screen 2")
            case .OtherScreenSegue3:
                println("Going to other screen 3")
            default:
                println("Going somewhere else")
            }
        }
    }

同理，也可以用在 `NSNotificationCenter` 里。



## 其他

发现一个挺好的网站：[SwiftExamples](http://brettbukowski.github.io/SwiftExamples/)，通过例子演示 Swift 的各种语法，如果一时半会的忘了某个语法可以去看一看。

*** 

## References

- [Enumerations](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Enumerations.html)
- [AdvancedOperators](https://developer.apple.com/library/prerelease/ios/documentation/swift/conceptual/swift_programming_language/AdvancedOperators.html)
- [How to test equality of Swift enums with associated values](http://stackoverflow.com/questions/24339807/how-to-test-equality-of-swift-enums-with-associated-values)
- [How to enumerate an enum with String type?](http://stackoverflow.com/questions/24007461/how-to-enumerate-an-enum-with-string-type)
- [Replace Magic Strings with Enumerations in Swift](http://www.andrewcbancroft.com/2014/09/02/replace-magic-strings-with-enumerations-in-swift/)
- [What is an Optional in Swift](http://www.drewag.me/posts/what-is-an-optional-in-swift)