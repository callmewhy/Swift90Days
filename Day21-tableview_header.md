# [Swift90Days](https://github.com/callmewhy/Swift90Days) - 动态变化的 UITableView 头部


今天公司的有一个需求是实现动态的 UITableView 头部，基本需求是：

- 默认状态显示一个 headerView 展示头像。
- 上推时 headerView 缩小高度，图像逐渐模糊。
- 下拉时 headerView 的图像相应下移，方便展示全景。

下面先看看开源项目 [ParallaxTableViewHeader](https://github.com/Vinodh-G/ParallaxTableViewHeader) 的实现方式，和自己的做个对比。

## Blur

它的虚化效果是通过 [UIImage+ImageEffects](https://github.com/Vinodh-G/ParallaxTableViewHeader/blob/master/ParallaxTableViewHeader/UIImage%2BImageEffects.m) 这个 category 实现的。

具体内容就不深究了，对于图像处理这块的类库不太熟悉。

在 headerView 中可以这样使用获取一张虚化的图片：

    - (void)refreshBlurViewForNewImage
    {
        UIImage *screenShot = [self screenShotOfView:self];
        screenShot = [screenShot applyBlurWithRadius:5 tintColor:[UIColor colorWithWhite:0.6 alpha:0.2] saturationDeltaFactor:1.0 maskImage:nil];
        self.bluredImageView.image = screenShot;
    }

## Header

源码中提供了两种工厂方法进行初始化：

    + (id)parallaxHeaderViewWithImage:(UIImage *)image forSize:(CGSize)headerSize;
    + (id)parallaxHeaderViewWithSubView:(UIView *)subView;

第一种方法是通过 image 进行初始化，会调用默认的 init 方法，第二种是自定义 subView 的方法。

我们只用看下默认的 init 方法：

    - (void)initialSetupForDefaultHeader
    {
        // 初始化一个 scrollView 作为容器
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.imageScrollView = scrollView;
        
        // 初始化默认大小的图片，用于显示
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:scrollView.bounds];
        // 设置其拉伸模式为：上下左右间距不变，拉伸高度和宽度。
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        // 设置图片填充模式：尽量填充，适当裁剪
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.image = self.headerImage;
        self.imageView = imageView;
        [self.imageScrollView addSubview:imageView];
        
        // 设置显示的标签文字
        CGRect labelRect = self.imageScrollView.bounds;
        labelRect.origin.x = labelRect.origin.y = kLabelPaddingDist;
        labelRect.size.width = labelRect.size.width - 2 * kLabelPaddingDist;
        labelRect.size.height = labelRect.size.height - 2 * kLabelPaddingDist;
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:labelRect];
        headerLabel.textAlignment = NSTextAlignmentCenter;
        headerLabel.numberOfLines = 0;
        headerLabel.lineBreakMode = NSLineBreakByWordWrapping;
        headerLabel.autoresizingMask = imageView.autoresizingMask;
        headerLabel.textColor = [UIColor whiteColor];
        headerLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:23];
        self.headerTitleLabel = headerLabel;
        [self.imageScrollView addSubview:self.headerTitleLabel];
        
        // 设置虚化的图片，默认 alpha 为0，即完全透明
        self.bluredImageView = [[UIImageView alloc] initWithFrame:self.imageView.frame];
        self.bluredImageView.autoresizingMask = self.imageView.autoresizingMask;
        self.bluredImageView.alpha = 0.0f;
        [self.imageScrollView addSubview:self.bluredImageView];
        [self addSubview:self.imageScrollView];
    }

大概了解了整个 view 的结构，不太清楚为什么要通过截屏的方式获取图片。

通过实现 `UISCrollViewDelegate` 中的 `scrollViewDidScroll` 方法来监听 UITableView 的滑动事件。

如果当前 UITableView 滑动了，则会调用 headerView 的 `layoutHeaderViewForScrollViewOffset` 方法：


    - (void)layoutHeaderViewForScrollViewOffset:(CGPoint)offset
    {
        CGRect frame = self.imageScrollView.frame;
        
        // 如果是上推
        if (offset.y > 0)
        {
            frame.origin.y = offset.y *kParallaxDeltaFactor;
            self.imageScrollView.frame = frame;
            
            // 设置虚化图层的 alpha 值。乘2是为了增大虚化梯度
            self.bluredImageView.alpha = 2 * (offset.y / kDefaultHeaderFrame.size.height) ;
            
            // 裁切 subview
            self.clipsToBounds = YES;
        }
        // 如果是下拉
        else
        {
            CGFloat delta = 0.0f;
            CGRect rect = kDefaultHeaderFrame;
            delta = fabs(offset.y);
            // 为了保持 header 的 top 对齐需要设置 y 坐标
            rect.origin.y -= delta;
            rect.size.height += delta;
            self.imageScrollView.frame = rect;
            self.clipsToBounds = NO;
            
            // 设置 label 的 alpha 值
            self.headerTitleLabel.alpha = 1 - delta / kMaxTitleAlphaOffset;
        }
    }

上推的时候主要工作是虚化图片，下拉的时候主要工作是设置图片高度和坐标。这个和我自己写的基本思路相同。

大概就是这样，引用中放了另一个类似的项目供大家参考。这个项目与 Swift 无关，不过实现的思路可以借鉴。


*** 

## References

- [ParallaxTableViewHeader](https://github.com/Vinodh-G/ParallaxTableViewHeader)
- [VGParallaxHeader](https://github.com/stoprocent/VGParallaxHeader)