# [Swift90Days](https://github.com/callmewhy/Swift90Days) - GCD 1

最近比较忙啦，就贴一下自己学习时候的关键代码，以后有机会再补上讲述的内容。

## dispatch_async

看代码说话：

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIImage *overlayImage = [self faceOverlayImageFromImage:_image];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self fadeInNewImage:overlayImage];
        });
    });

上面的代码可以发送一个自定义的异步请求，然后通过 `dispatch_get_main_queue` 在主线程里刷新UI。


## dispatch_after

比如我们想在1秒之后弹出提示框，可以这样：

    NSUInteger count = [[PhotoManager sharedManager] photos].count;
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)); // 1 
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){ // 2 
        if (!count) {
            [self.navigationItem setPrompt:@"Add photos with faces to Googlyify them!"];
        } else {
            [self.navigationItem setPrompt:nil];
        }
    });



## dispatch_once

我们可以通过 `dispatch_once` 实现单例模式：

    + (instancetype)sharedManager
    {
        static PhotoManager *sharedPhotoManager = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedPhotoManager = [[PhotoManager alloc] init];
            sharedPhotoManager->_photosArray = [NSMutableArray array];
        });
        return sharedPhotoManager;
    }



*** 

## References

- [Grand Central Dispatch In-Depth: Part 1/2](http://www.raywenderlich.com/60749/grand-central-dispatch-in-depth-part-1)