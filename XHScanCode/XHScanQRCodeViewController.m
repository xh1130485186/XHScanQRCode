//
//  XHScanQrCodeViewController.m
//  扫码
//
//  Created by 向洪 on 2019/3/28.
//  Copyright © 2019 向洪. All rights reserved.
//

#import "XHScanQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "XHScanQRCodeGridView.h"

#define statusBarHeight CGRectGetHeight([UIApplication sharedApplication].statusBarFrame)
#define navigationBarHeight CGRectGetHeight(self.navigationController.navigationBar.frame)

static inline NSString *XHScanQRCodeBundlePathForResource(NSString *bundleName, Class aClass, NSString *resourceName, NSString *ofType, BOOL times) {
    NSBundle *bundle = [NSBundle bundleForClass:aClass];
    NSURL *url = [bundle URLForResource:bundleName withExtension:@"bundle"];
    bundle = [NSBundle bundleWithURL:url];
    NSString *name = resourceName;
    if (times) {
        name = [UIScreen mainScreen].scale==3?[name stringByAppendingString:@"@3x"]:[name stringByAppendingString:@"@2x"];
    }
    NSString *imagePath = [bundle pathForResource:name ofType:ofType];
    return imagePath;
}

//static const CGFloat kBorderW = 100;
static const CGFloat kMargin = 50;

@interface XHScanQRCodeViewController () <AVCaptureMetadataOutputObjectsDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) XHScanQRCodeGridView *scanView;
//@property (nonatomic, strong) UIImageView *scanImageView;

@end

@implementation XHScanQRCodeViewController

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    self.view.backgroundColor = [UIColor blackColor];
    
    // 设置遮罩
    [self setupMaskView];
    // 设置扫码视图
    [self setupScanView];
    // 顶部导航
    [self setupNavView];
    // 顶部菜单
    [self setupBottomBar];
    // 开始采集
    [self beginScanning];
}


- (void)setupNavView {
    
    // 顶部视图
    UIView *navView = [[UIView alloc] init];
    navView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    [self.view addSubview:navView];
    
    // 返回按钮
    NSString *path = XHScanQRCodeBundlePathForResource(@"xh.scan", [XHScanQRCodeViewController class], @"qrcode_scan_titlebar_back_nor", @"png", 1);
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageWithContentsOfFile:path] forState:UIControlStateNormal];
    backBtn.contentMode = UIViewContentModeScaleAspectFit;
    [backBtn addTarget:self action:@selector(disMiss) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:backBtn];
    
    // 标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"扫一扫";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [navView addSubview:titleLabel];
    
    // 相册
    UIButton *photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    photoBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [photoBtn setTitle:@"相册" forState:UIControlStateNormal];
    [photoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [photoBtn addTarget:self action:@selector(photoBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:photoBtn];
    
    // 约束布局
    navView.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    backBtn.translatesAutoresizingMaskIntoConstraints = NO;
    photoBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSMutableArray *constraints = [NSMutableArray array];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[navView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(navView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-0-[navView(%lf)]", navigationBarHeight+statusBarHeight] options:0 metrics:nil views:NSDictionaryOfVariableBindings(navView)]];

    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-14-[backBtn(30)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(backBtn)]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%lf-[backBtn(30)]", (navigationBarHeight-30)*0.5+statusBarHeight] options:0 metrics:nil views:NSDictionaryOfVariableBindings(backBtn)]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:navView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:backBtn attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[photoBtn(40)]-20-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(photoBtn)]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[photoBtn(30)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(photoBtn)]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:photoBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:backBtn attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    
    [navView addConstraints:constraints];
}

- (void)setupMaskView {
    
    // 遮罩视图
    UIView *maskView = [[UIView alloc] init];
    [self.view insertSubview:maskView atIndex:0];
    
    maskView.translatesAutoresizingMaskIntoConstraints = NO;
    NSMutableArray *constraints = [NSMutableArray array];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[maskView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(maskView)]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[maskView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(maskView)]];
    [self.view addConstraints:constraints];
    
    // 设置遮罩区域
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.view.bounds cornerRadius:0];
    
    UIBezierPath *maskPath;
    CGFloat width = CGRectGetWidth(self.view.bounds)-kMargin*2;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(kMargin, (CGRectGetHeight(self.view.bounds)-width)*0.5, width, width)
                                     byRoundingCorners:UIRectCornerAllCorners
                                           cornerRadii:CGSizeMake(2, 2)];
    [path appendPath:maskPath];
    //使用奇偶性原则，设置填充部分为除去部分
    [path setUsesEvenOddFillRule:YES];
    
    
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.path = path.CGPath;
    fillLayer.fillRule = kCAFillRuleEvenOdd;
    fillLayer.fillColor = [UIColor blackColor].CGColor;
    fillLayer.opacity = 0.5;
    
    [maskView.layer addSublayer:fillLayer];
    
}

- (void)setupScanView {
    
    // 网格视图
    XHScanQRCodeGridView *scanView = [[XHScanQRCodeGridView alloc] init];
    [self.view addSubview:scanView];
    
    self.scanView = scanView;
    
    // 操作提示
    UILabel * tipLabel = [[UILabel alloc] init];
    tipLabel.text = @"将取景框对准二维码，即可自动扫描";
    tipLabel.textColor = [UIColor whiteColor];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.numberOfLines = 2;
    tipLabel.font=[UIFont systemFontOfSize:12];
    tipLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tipLabel];
    
    scanView.translatesAutoresizingMaskIntoConstraints = NO;
    tipLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSMutableArray *constraints = [NSMutableArray array];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-%lf-[scanView]-%lf-|", kMargin, kMargin] options:0 metrics:nil views:NSDictionaryOfVariableBindings(scanView)]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:scanView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:scanView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:scanView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-(>=%lf)-[tipLabel]", kMargin] options:0 metrics:nil views:NSDictionaryOfVariableBindings(tipLabel)]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[scanView]-12-[tipLabel]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(scanView, tipLabel)]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:tipLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [self.view addConstraints:constraints];
    
}

- (void)setupBottomBar {
    
    //闪光灯
    NSString *pathFlash = XHScanQRCodeBundlePathForResource(@"xh.scan", [XHScanQRCodeViewController class], @"qrcode_scan_btn_flash_nor", @"png", 1);
    
    NSString *pathOff = XHScanQRCodeBundlePathForResource(@"xh.scan", [XHScanQRCodeViewController class], @"qrcode_scan_btn_scan_off", @"png", 1);
    
    UIButton *flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    flashBtn.contentMode = UIViewContentModeScaleAspectFit;
    [flashBtn setImage:[UIImage imageWithContentsOfFile:pathFlash] forState:UIControlStateNormal];
    [flashBtn setImage:[UIImage imageWithContentsOfFile:pathOff] forState:UIControlStateSelected];
    [flashBtn addTarget:self action:@selector(openFlashAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:flashBtn];
    
    flashBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSMutableArray *constraints = [NSMutableArray array];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[flashBtn(32)]-16-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(flashBtn)]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[flashBtn(32)]-16-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(flashBtn)]];
    
    [self.view addConstraints:constraints];
    
}

#pragma mark - 扫码

- (void)beginScanning {
    
    //获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
//    if ([device lockForConfiguration:nil])
//    {
//        //自动白平衡
//        if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance])
//        {
//            [device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
//        }
//        //自动对焦
//        if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
//        {
//            [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
//        }
//        //自动曝光
//        if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
//        {
//            [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
//        }
//        [device unlockForConfiguration];
//    }
    
    //创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    if (!input) return;
    //创建输出流
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //设置有效扫描区域
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    CGRect scanCrop = CGRectMake(kMargin, (height-width)*0.5+kMargin, width-kMargin*2, width-kMargin*2);
    output.rectOfInterest = [self getScanCrop:scanCrop readerViewBounds:self.view.bounds];
    //初始化链接对象
    _session = [[AVCaptureSession alloc] init];
    //高质量采集率
    if ([device supportsAVCaptureSessionPreset:AVCaptureSessionPreset1920x1080]) {
        [self.session setSessionPreset:AVCaptureSessionPreset1920x1080];
    } else{
        [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    }
    
    [_session addInput:input];
    [_session addOutput:output];
    //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeDataMatrixCode];
    
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:layer atIndex:0];
    //开始捕获
    [_session startRunning];
    
}

// 重新开始扫码
- (void)reStartScan {
    [_session startRunning];
}

// 停止捕获
- (void)endScanning {
    [_session stopRunning];
}

// 获取扫描区域的比例关系
- (CGRect)getScanCrop:(CGRect)rect readerViewBounds:(CGRect)readerViewBounds {
    
    CGFloat x, y, width, height;
    
    x = (CGRectGetHeight(readerViewBounds)-CGRectGetHeight(rect))/2/CGRectGetHeight(readerViewBounds);
    y = (CGRectGetWidth(readerViewBounds)-CGRectGetWidth(rect))/2/CGRectGetWidth(readerViewBounds);
    width = CGRectGetHeight(rect)/CGRectGetHeight(readerViewBounds);
    height = CGRectGetWidth(rect)/CGRectGetWidth(readerViewBounds);
    
    return CGRectMake(x, y, width, height);
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count > 0) {
        [self endScanning];
        //识别扫码类型
        NSMutableArray *results = [NSMutableArray array];
        for(AVMetadataObject *current in metadataObjects) {
            
            if ([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]] ) {
            
                XHScanResult *result = [[XHScanResult alloc] init];
                NSString *scannedResult = [(AVMetadataMachineReadableCodeObject *)current stringValue];
                result.strScanned = scannedResult;
                result.strBarCodeType = current.type;
                [results addObject:result];
            }
        }
        [self scanResultWithArray:results];
    }
}

- (void)scanResultWithArray:(NSArray<XHScanResult *> *)results {
    
}

#pragma mark - 返回

- (void)disMiss {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 相册

- (void)photoBtnAction {
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.delegate = self;
        /**
         UIImagePickerControllerSourceTypePhotoLibrary,相册
         UIImagePickerControllerSourceTypeCamera,相机
         UIImagePickerControllerSourceTypeSavedPhotosAlbum,照片库
         */
        controller.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentViewController:controller animated:YES completion:NULL];
        
    } else {
        
        // 不支持的相册
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // 获取选择的图片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    // 初始化一个监测器
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
    [picker dismissViewControllerAnimated:YES completion:^{
        // 监测到的结果数组
        NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
        
        NSMutableArray *results = [NSMutableArray array];
        for(CIQRCodeFeature *feature in features) {
            
            XHScanResult *result = [[XHScanResult alloc] init];
            result.strScanned = feature.messageString;
            result.strBarCodeType = AVMetadataObjectTypeQRCode;
            [results addObject:result];
        }
        [self scanResultWithArray:results];
    
    }];
}

#pragma mark - 闪光灯

- (void)openFlashAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self turnTorchOn:YES];
    } else {
        [self turnTorchOn:NO];
    }
}

- (void)turnTorchOn:(BOOL)on {
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch] && [device hasFlash]){
        [device lockForConfiguration:nil];
        if (on) {
            [device setTorchMode:AVCaptureTorchModeOn];
            //[device setFlashMode:AVCaptureFlashModeOn];
            
        } else {
            [device setTorchMode:AVCaptureTorchModeOff];
            //[device setFlashMode:AVCaptureFlashModeOff];
        }
        [device unlockForConfiguration];
    }
}

#pragma mark - UIStatusBarStyle && UIViewControllerRotation

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


@end
