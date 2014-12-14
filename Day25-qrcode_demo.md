# [Swift90Days](https://github.com/callmewhy/Swift90Days) - 用 Swift 做一个二维码扫描器

这篇[文章](http://www.appcoda.com/qr-code-reader-swift/)中介绍了如何使用 Swift 制作一个二维码扫描器。在此不再赘述具体流程，仅记录一些关键点作为笔记。


## 获取视屏数据

在初始化方法里我们需要获取到摄像头。`AVCaptureDevice` 代表一个真实的物理捕捉设备。`AVCaptureSession` 则是用来处理实时视屏数据。

完整的加载视屏和预览图层的代码如下：

    // 初始化视屏加载和预览
    func setupVideoPreview() {
        
        // 创建一个 AVCaptureDevice 对象
        var captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        // 创建一个 AVCaptureDeviceInput 对象
        var error:NSError?
        let input: AnyObject! = AVCaptureDeviceInput.deviceInputWithDevice(captureDevice, error: &error)
        
        // 如果打开摄像头遇到异常
        if let tError = error {
            println("\(tError.localizedDescription)")
            return
        }
        
        // 初始化 captureSession 对象，并添加输入
        captureSession = AVCaptureSession()
        captureSession?.addInput(input as AVCaptureInput)
        
        // 初始化 AVCaptureMetadataOutput 作为 session 的输出
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        // 初始化预览图层
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer)
        
        // 开始视屏捕捉
        captureSession?.startRunning()
    }


## 处理屏幕数据

我们只需要实现 `AVCaptureMetadataOutputObjectsDelegate` 这个委托里的方法就可以对捕获到的数据进行分析。委托中有这样一个方法：

    optional func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!)

我们可以这样对二维码数据进行分析：


    // MARK - AVCaptureMetadataOutputObjectsDelegate
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        // 检查时候捕获到数据
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRectZero
            println("No QR code is detected")
            return
        }
        
        // 获取数据
        let metadataObj = metadataObjects[0] as AVMetadataMachineReadableCodeObject
        
        // 如果获取到的数据类型是QRCode
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj as AVMetadataMachineReadableCodeObject) as AVMetadataMachineReadableCodeObject
            qrCodeFrameView?.frame = barCodeObject.bounds;
            
            if metadataObj.stringValue != nil {
                println(metadataObj.stringValue)
            }
        }
    }


好吧原来这么简单就可以做一个二维码识别软件。

很多细节没有展开，自行探索吧：）




*** 

## References

- [Building a QR Code Reader in Swift](http://www.appcoda.com/qr-code-reader-swift/)