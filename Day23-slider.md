# [Swift90Days](https://github.com/callmewhy/Swift90Days) - 滑块的制作

今天读到以前人写的滑块源码，十分糟糕，直接导致iPhone6下自动挂断的crush让人崩溃。晚上找些开源库看看别人是怎么实现滑块的。

## 需求

简单的列一下需求：

- 背景视图是容器，显示可滑动区域
- 按钮默认在左侧，可以滑动到最右侧，松手之后自动返回最左
- 最好提示字有动态色彩变化


## 头文件

项目源码参考自：[MBSliderView](https://github.com/mattlawer/MBSliderView)。

先看下头文件声明，主要是一个委托，委托方法是滑动到底之后进行的操作：

    @protocol MBSliderViewDelegate <NSObject>
    - (void) sliderDidSlide:(MBSliderView *)slideView;
    @end

然后再看一下具体的 MBSliderView 的定义：

    @interface MBSliderView : UIView {
        UISlider *_slider;
        UILabel *_label;
        id<MBSliderViewDelegate> _delegate;
    }

    @property (nonatomic, assign) NSString *text;
    @property (nonatomic, assign) UIColor *labelColor;
    @property (nonatomic, assign) IBOutlet id<MBSliderViewDelegate> delegate;
    @property (nonatomic) BOOL enabled;

    - (void) setThumbColor:(UIColor *)color;

    @end

OK基本没有什么问题，其实所谓的滑动按钮也就是个 UISlider ，本来我还准备用 UIScrollView 来做的。

有个比较可取的地方是：

    // Implement the "text" property
    - (NSString *) text {
        return [_label text];
    }

    - (void) setText:(NSString *)text {
        [_label setText:text];
    }

这样你对 `text` 属性的所有操作其实就是对 `label` 的操作，不过这样封装之后使用起来更加简单，不用知道底层的视图结构也可以使用。

### 初始化

提供了两种初始化方式，一种是代码加载，一种是 xib 加载。所以分别实现了两个父类的方法，并在 init 完成之后调用 `loadContent` 方法初始化页面：

    - (id)initWithFrame:(CGRect)frame
    {
        if (frame.size.width < 136.0) {
            frame.size.width = 136.0;
        }
        if (frame.size.height < 44.0) {
            frame.size.height = 44.0;
        }
        self = [super initWithFrame:frame];
        if (self) {
            [self loadContent];        
        }
        return self;
    }

    -(id) initWithCoder:(NSCoder *)aDecoder
    {
        self = [super initWithCoder:aDecoder];
        if (self) {
            [self loadContent];
        }
        return self;
    }

`loadContent` 方法中多是初始化的种种，最后有这么一段：

    // Set the slider action methods
    [_slider addTarget:self 
               action:@selector(sliderUp:) 
     forControlEvents:UIControlEventTouchUpInside];
    [_slider addTarget:self 
               action:@selector(sliderUp:) 
     forControlEvents:UIControlEventTouchUpOutside];
    [_slider addTarget:self 
               action:@selector(sliderDown:) 
     forControlEvents:UIControlEventTouchDown];
    [_slider addTarget:self 
               action:@selector(sliderChanged:) 
     forControlEvents:UIControlEventValueChanged];

这三个 `ControlEvents` 的事件监听主要是用来处理按下、滑动、松手的事件。很多是视觉上的修改，关键的功能点在这里：

    - (void) sliderUp:(UISlider *)sender {
        // 调用委托方法，通知委托对象目前已经滑到底        
        if (_slider.value == 1.0) {
            [_delegate sliderDidSlide:self];
        }
        
        // 松手后弹回起点
        [_slider setValue:0.0 animated: YES];
        }
    }


基本就是这样啦。




*** 

## References

- [MBSliderView](https://github.com/mattlawer/MBSliderView)