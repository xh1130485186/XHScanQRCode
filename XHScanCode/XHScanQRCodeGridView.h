//
//  XHScanQrCodeGridView.h
//  扫码
//
//  Created by 向洪 on 2019/3/28.
//  Copyright © 2019 向洪. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XHScanQRCodeGridView : UIView

@property (nonatomic, strong) UIColor *edgesLineColor;
@property (nonatomic, strong) UIColor *gridColor;


/**
 视图创建显示之后默认进行动画，不需要进行startAnimation
 */
- (void)startAnimation;
- (void)stopAnimation;

@end

NS_ASSUME_NONNULL_END
