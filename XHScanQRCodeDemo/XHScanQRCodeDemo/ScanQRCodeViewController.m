//
//  ScanQRCodeViewController.m
//  XHScanQRCodeDemo
//
//  Created by 向洪 on 2019/4/4.
//  Copyright © 2019 向洪. All rights reserved.
//

#import "ScanQRCodeViewController.h"

@interface ScanQRCodeViewController ()

@end

@implementation ScanQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)scanResultWithArray:(NSArray<XHScanResult *> *)results {
    if (results != nil && results.count > 0) {
        XHScanResult *obj = results[0];
        NSString *result = obj.strScanned;

        NSLog(@"%@", result);
    } else {
        [self reStartScan];
        // @"未能识别到二维码"
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
