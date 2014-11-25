# 习题笔记

今天解决一下 [Higher Order Functions: Map, Filter, Reduce and more – Part 1](http://www.weheartswift.com/higher-order-functions-map-filter-reduce-and-more/) 中最后的13个练习题，主要是关于闭包的（咦不对啊我明明是想看集合方面内容的。。。）。


### Write a function applyTwice(f:(Float -> Float),x:Float) -> Float that takes a function f and a float x and aplies f to x twice i.e. f(f(x))

    func applyTwice(f:(Float -> Float),x:Float) -> Float {
        return f(f(x))
    }

### Write a function applyKTimes(f:(Float -> Float),x:Float,k:Int) -> Float that takes a function f and a float x and aplies f to x k times

    // recursive version
    func applyKTimes(f:(Float -> Float), x:Float, k:Int) -> Float
    {
        return k > 0 ? applyKTimes(f, f(x), k - 1) : x
    }

    // unrolled by hand
    func applyKTimes(f:(Float -> Float),x:Float,k:Int) -> Float {
        var y : Float = x
        for _ in 0..<k {
            y = f(y)
        }
        return y
    }

### Using applyKTimes write a function that raises x to the kth power

    func getKthPower(x:Float, k:Int) -> Float{
        return applyKTimes( {x * $0}, 1, k) // {x * $0} => {p in return x * p}
    }
    getKthPower(2.0, 3) // 8.0


### Given an array of Users which have properties name:String and age:Int write a map function that returns an array of strings consisting of the user’s names

    class User {
        var name: String?
        var age : Int?
        
        init (name: String, age:Int) {
            self.name = name
            self.age = age
        }
    }

    var user1 = User(name: "WHY1", age: 22)
    var user2 = User(name: "WHY2", age: 23)
    var user3 = User(name: "WHY3", age: 24)
    var user4 = User(name: "WHY4", age: 25)
    var users = [user1,user2,user3,user4]
    var names = users.map({(user:User) in user.name!})
    println(names) // [WHY1, WHY2, WHY3, WHY4]



### Given an array of of dictionaries containing keys for “name” and “age” write a map function that returns an array of users created from it


    var users = [["name":"WHY1","age":"22"],["name":"WHY2","age":"23"],
                 ["name":"WHY3","age":"24"],["name":"WHY4","age":"25"]]
    var result = users.map({ (userDic:[String:String]) -> User  in
        return User(name: userDic["name"]!, age:userDic["age"]!.toInt()!)

    })



### Given an array of numbers write a filter method that only selects odd integers

    var nums = [1,2,4,8,23,45,89,127]
    var odds = nums.filter({ $0 % 2 == 0 }) // 2 4 8

### Given an array of strings write a filter function that selects only strings that can be converted to Ints

    var strs = ["2333","1223","callmewhy","callherhh"]
    var intables = strs.filter({ $0.toInt() != nil }) // ["2333", "1223"]


### Given an array of UIViews write a filter function that selects only those views that are a subclass of UILabel

    import UIKit

    var view1 = UIView()
    var view2 = UIView()
    var view3 = UILabel()
    var view4 = UIView()
    var views = [view1,view2,view3,view4]
    var labels = views.filter({ $0.isKindOfClass(UILabel) }) // view3


### Write a reduce function that takes an array of strings and returns a single string consisting of the given strings separated by newlines
    
    var strs = ["str1","str2","str3","str4"]
    var str = strs.reduce("", combine: { "\($0)\n\($1)" })
    println(str)


### Write a reduce function that finds the largest element in an array of Ints

    var ints = [1,2,3,4,5,6]
    var maxValue = ints.reduce(Int.min, { max($0, $1) })    // 6


### You could implement a mean function using the reduce operation {$0 + $1 / Float(array.count)}. Why is this a bad idea?

    var array = [1,2,3,4,6]
    var mean = array.reduce(0, combine: {$0 + Float($1) / Float(array.count)}) // make division 5 times


### There’s a problem you encounter when trying to implement a parallel version of reduce. What property should the operation have to make this easier ?

    // TODO

### Implement Church Numerals in Swift (This is a difficult and open ended exercise)

    // TODO

*** 

## References

- [Higher Order Functions: Map, Filter, Reduce and more – Part 1](http://www.weheartswift.com/higher-order-functions-map-filter-reduce-and-more/)
- [How to write a function applies f to x k times?](http://stackoverflow.com/questions/24081697/how-to-write-a-function-that-takes-a-function-f-and-a-float-x-and-applies-f-to-x)
- [Raise x to the Kth power?](http://stackoverflow.com/questions/24086544/using-swift-what-function-to-use-as-another-functions-parameter-to-raise-x-to-t)
- [Correct way to find max in an Array in Swift](http://stackoverflow.com/questions/24036514/correct-way-to-find-max-in-an-array-in-swift)
- [Swift equivalent for MIN and MAX macros](http://stackoverflow.com/questions/24186648/swift-equivalent-for-min-and-max-macros)