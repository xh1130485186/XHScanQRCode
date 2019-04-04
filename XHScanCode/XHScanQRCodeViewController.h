//
//  XHScanQrCodeViewController.h
//  扫码
//
//  Created by 向洪 on 2019/3/28.
//  Copyright © 2019 向洪. All rights reserved.
//

/*

 // 条形码
 AVMetadataObjectTypeUPCECode - 据说用于美国部分地区的条码 长度必须是6位或者11位  必须获得许可才能用
 AVMetadataObjectTypeCode39Code - 一种字母和简单的字符共三十九个字符组成的条形码 缺点是生成的条码较大
 AVMetadataObjectTypeCode39Mod43Code - 是上面的一种扩展
 AVMetadataObjectTypeCode93Code -
 AVMetadataObjectTypeEAN13Code - 我国商品码主要就是这和 EAN8 必须是12数字 必须获得许可
 AVMetadataObjectTypeEAN8Code - 必须是7位或者8位数字 必须获得许可
 AVMetadataObjectTypeCode128Code - 包含字母数字所有字符 包含三个表格更好的对数据进行编码 缺点就是生成条码较大
 AVMetadataObjectTypeInterleaved2of5Code - 类型二进五出码 条形码 查到好像是偶数位的条码  只支持数字 最长10位
 AVMetadataObjectTypeITF14Code - 全球贸易货号。主要用于运输方面的条形码。iOS8以后才支持

 AVMetadataObjectTypePDF417Code - 一个二维码的格式，类似条码

 // 二维码
 AVMetadataObjectTypeQRCode - 常用的二维码
 AVMetadataObjectTypeDataMatrixCode - 一种二维码制式，外观是一个由许多小方格所组成的正方形或长方形符

 */

#import <UIKit/UIKit.h>
#import "XHScanResult.h"

NS_ASSUME_NONNULL_BEGIN

/**
 基于系统自带的二维码扫码(目前只支持二维码QRCode ，aMatrixCode)
 */
@interface XHScanQRCodeViewController : UIViewController

// 重新开始扫码
- (void)reStartScan;
// 停止捕获
- (void)endScanning;

/**
 扫码获取到结果后调用这个方法，重新这个方法来获取结果

 @param results 扫码结果，数组可能没有值
 */
- (void)scanResultWithArray:(NSArray<XHScanResult *> *)results;

@end

NS_ASSUME_NONNULL_END
