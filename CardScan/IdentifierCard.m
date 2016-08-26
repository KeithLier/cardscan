//
//  ViewController.m
//  CardScan
//
//  Created by Keith on 16/8/26.
//  Copyright © 2016年 Keith. All rights reserved.
//

#import "IdentifierCard.h"
#import "CaptureManager.h"
#import "IDOverLayerView.h"

@interface IdentifierCard ()<CaptureDelegate>

@property (nonatomic, strong) IDOverLayerView *overlayView;
@property (nonatomic, strong) CaptureManager *captureManager;

@end

@implementation IdentifierCard

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"身份证";
    
    [self initIDCart];
    
    [self.view insertSubview:self.overlayView atIndex:0];
    
    self.captureManager.delegate = self;
    
    self.captureManager.verify = YES;
    
    self.captureManager.sessionPreset = AVCaptureSessionPresetHigh;
    
    self.captureManager.outPutSetting = [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange];
    
    if ([self.captureManager setupSession]) {
        UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
        [self.view insertSubview:view atIndex:0];
        self.captureManager.previewLayer.frame = [UIScreen mainScreen].bounds;
        [view.layer addSublayer:self.captureManager.previewLayer];
        [self.captureManager startSession];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if([self.captureManager.captureSession isRunning]) {
        [self.captureManager.captureSession stopRunning];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([self.captureManager.captureSession isRunning] == NO) {
        [self.captureManager.captureSession startRunning];
    }
}

static bool initFlag = NO;

- (void)initIDCart {
    if (!initFlag) {
        const char *thePath = [[[NSBundle mainBundle] resourcePath] UTF8String];
        int ret = EXCARDS_Init(thePath);
        if (ret != 0) {
            NSLog(@"初始化失败：ret=%d", ret);
        }
        initFlag = YES;
    }
}

- (CaptureManager *)captureManager {
    if (!_captureManager) {
        _captureManager = [[CaptureManager alloc] init];
    }
    return _captureManager;
}

-(IDOverLayerView *)overlayView {
    if(!_overlayView) {
        CGRect rect = [IDOverLayerView getOverlayFrame:[UIScreen mainScreen].bounds];
        _overlayView = [[IDOverLayerView alloc] initWithFrame:rect];
    }
    return _overlayView;
}

#pragma mark - CaptureDelegate
- (void)idCardRecognited:(IDInfo *)idInfo image:(UIImage *)image {
    [self.captureManager stopSession];
}

@end
