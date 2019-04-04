//
//  XHScanQrCodeGridView.m
//  扫码
//
//  Created by 向洪 on 2019/3/28.
//  Copyright © 2019 向洪. All rights reserved.
//


#import "XHScanQRCodeGridView.h"

static const CGFloat kGridLineNum = 20;

@interface XHScanQRCodeGridView ()

@property (nonatomic, strong) CAShapeLayer *edgesShapeLayer;
@property (nonatomic, strong) CALayer *tailorLayer;
@property (nonatomic, strong) CALayer *gridLayer;
@property (nonatomic, strong) CAGradientLayer *glowGradientLayer;
@property (nonatomic, strong) NSMutableArray<CAGradientLayer *> *horizontalGradientLayers;
@property (nonatomic, strong) NSMutableArray<CAGradientLayer *> *verticalGradientLayers;

@property (nonatomic, assign) BOOL canAnimation;

@end

@implementation XHScanQRCodeGridView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initalize];
    }
    return self;
}

- (void)initalize {
    
    self.edgesLineColor = [UIColor greenColor];
    self.gridColor = [UIColor colorWithRed:207/255.f green:234/255.f blue:234/255.f alpha:1];
    self.canAnimation = YES;
    
    // 边角
    CAShapeLayer *edgesShapeLayer = [[CAShapeLayer alloc] init];
    edgesShapeLayer.lineWidth = 3;
    edgesShapeLayer.strokeColor = self.edgesLineColor.CGColor;
    edgesShapeLayer.lineJoin = kCALineJoinRound;
    edgesShapeLayer.lineCap = kCALineCapRound;
    
    [self.layer addSublayer:edgesShapeLayer];
    
    self.edgesShapeLayer = edgesShapeLayer;
    
    // 网格
    CALayer *tailorLayer = [[CALayer alloc] init];
    tailorLayer.masksToBounds = YES;
    [self.layer addSublayer:tailorLayer];
    
    CALayer *gridLayer = [[CALayer alloc] init];
    [tailorLayer addSublayer:gridLayer];
    
    CGFloat r, g, b;
    [self.gridColor getRed:&r green:&g blue:&b alpha:0];
    
    UIColor *glowGradientColor1 = [UIColor colorWithRed:r green:g blue:b alpha:1];
    UIColor *glowGradientColor2 = [UIColor colorWithRed:r green:g blue:b alpha:0.7];
    UIColor *glowGradientColor3 = [UIColor colorWithRed:r green:g blue:b alpha:0];
    CAGradientLayer *glowGradientLayer = [[CAGradientLayer alloc] init];
    glowGradientLayer.locations = @[@0, @0.9, @1];
    glowGradientLayer.colors = @[(__bridge id)glowGradientColor3.CGColor, (__bridge id)glowGradientColor2.CGColor, (__bridge id)glowGradientColor1.CGColor];
    self.glowGradientLayer = glowGradientLayer;
    [gridLayer addSublayer:glowGradientLayer];
    
    _horizontalGradientLayers = [NSMutableArray array];
    _verticalGradientLayers = [NSMutableArray array];
    UIColor *verticalColor = [UIColor colorWithRed:r green:g blue:b alpha:0];
    
    for (int i = 0; i < kGridLineNum; i ++) {
    
        UIColor *horizontalColor = [UIColor colorWithRed:r green:g blue:b alpha:i/(kGridLineNum-1)];
        CAGradientLayer *horizontalGradientLayer = [[CAGradientLayer alloc] init];
        horizontalGradientLayer.locations = @[@0, @1];
        horizontalGradientLayer.colors = @[(__bridge id)horizontalColor.CGColor, (__bridge id)horizontalColor.CGColor];
        [gridLayer addSublayer:horizontalGradientLayer];
        
        [self.horizontalGradientLayers addObject:horizontalGradientLayer];
        
        CAGradientLayer *verticalGradientLayer = [[CAGradientLayer alloc] init];
        verticalGradientLayer.colors = @[(__bridge id)verticalColor.CGColor, (__bridge id)self.gridColor.CGColor];
        verticalGradientLayer.locations = @[@0, @1];
        [gridLayer addSublayer:verticalGradientLayer];
        
        [self.verticalGradientLayers addObject:verticalGradientLayer];
    }
    
    self.tailorLayer = tailorLayer;
    self.gridLayer = gridLayer;
    
    [self startAnimation];
}

- (void)startAnimation {

    self.canAnimation = YES;
    
    [self.gridLayer removeAllAnimations];
    
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    pathAnimation.duration = 1.5;
    pathAnimation.fromValue = @(-height*0.5);
    pathAnimation.toValue = @(height*0.5);
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.repeatCount = CGFLOAT_MAX;
    pathAnimation.fillMode = kCAFillModeForwards;
    [self.gridLayer addAnimation:pathAnimation forKey:nil];

}

- (void)stopAnimation {
    self.canAnimation = NO;
    [self.gridLayer removeAllAnimations];
}

- (void)setGridColor:(UIColor *)gridColor {
    
    _gridColor = gridColor;
    CGFloat r, g, b;
    [gridColor getRed:&r green:&g blue:&b alpha:0];
    
    UIColor *glowGradientColor1 = [UIColor colorWithRed:r green:g blue:b alpha:1];
    UIColor *glowGradientColor2 = [UIColor colorWithRed:r green:g blue:b alpha:0.7];
    UIColor *glowGradientColor3 = [UIColor colorWithRed:r green:g blue:b alpha:0];
    self.glowGradientLayer.colors = @[(__bridge id)glowGradientColor3.CGColor, (__bridge id)glowGradientColor2.CGColor, (__bridge id)glowGradientColor1.CGColor];
    
    UIColor *verticalColor = [UIColor colorWithRed:r green:g blue:b alpha:0];
    
    for (int i = 0; i < kGridLineNum; i ++) {
        
        CGFloat r, g, b;
        [self.gridColor getRed:&r green:&g blue:&b alpha:0];
        UIColor *horizontalColor = [UIColor colorWithRed:r green:g blue:b alpha:i/(kGridLineNum-1)];
        CAGradientLayer *horizontalGradientLayer = self.horizontalGradientLayers[i];
        horizontalGradientLayer.colors = @[(__bridge id)horizontalColor.CGColor, (__bridge id)horizontalColor.CGColor];
        
        [self.horizontalGradientLayers addObject:horizontalGradientLayer];
        
        CAGradientLayer *verticalGradientLayer = self.verticalGradientLayers[i];
        verticalGradientLayer.colors = @[(__bridge id)verticalColor.CGColor, (__bridge id)self.gridColor.CGColor];
        
        [self.verticalGradientLayers addObject:verticalGradientLayer];
    }
    
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    //
    CGFloat length = 16;
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:CGPointMake(width, 0)];
    [path addLineToPoint:CGPointMake(width-length, 0)];
    [path moveToPoint:CGPointMake(width, 0)];
    [path addLineToPoint:CGPointMake(width, length)];
    
    [path moveToPoint:CGPointMake(width, height)];
    [path addLineToPoint:CGPointMake(width-length, height)];
    [path moveToPoint:CGPointMake(width, height)];
    [path addLineToPoint:CGPointMake(width, height-length)];
    
    [path moveToPoint:CGPointMake(0, height)];
    [path addLineToPoint:CGPointMake(length, height)];
    [path moveToPoint:CGPointMake(0, height)];
    [path addLineToPoint:CGPointMake(0, height-length)];
    
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(length, 0)];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(0, length)];
    
    self.edgesShapeLayer.path = path.CGPath;
    
    self.tailorLayer.frame = self.bounds;
    self.gridLayer.frame = self.bounds;
    self.glowGradientLayer.frame = CGRectMake(0, height-50, width, 50);
    for (int i = 0; i < kGridLineNum; i ++) {
        
        CGFloat scale = i/(kGridLineNum-1);
        CAGradientLayer *horizontalGradientLayer = self.horizontalGradientLayers[i];
        horizontalGradientLayer.frame = CGRectMake(0, scale*(height-0.5), width, 0.5);
        
        CAGradientLayer *verticalGradientLayer = self.verticalGradientLayers[i];
        verticalGradientLayer.frame = CGRectMake(scale*(width-0.5), 0, 0.5, height);
    }

    if (self.canAnimation) {
        [self startAnimation];
    }
}

@end
