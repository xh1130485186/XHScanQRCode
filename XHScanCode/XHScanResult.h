//
//  XHScanResult.h
//  扫码
//
//  Created by 向洪 on 2019/3/29.
//  Copyright © 2019 向洪. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 扫码结果
 */
@interface XHScanResult : NSObject

/**
 扫码码的类型
 */
@property (nonatomic, copy) NSString *strBarCodeType;

/**
 结果字符串
 */
@property (nonatomic, copy) NSString *strScanned;

@end

NS_ASSUME_NONNULL_END
