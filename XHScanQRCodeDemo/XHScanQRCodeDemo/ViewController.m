//
//  ViewController.m
//  XHScanQRCodeDemo
//
//  Created by 向洪 on 2019/4/4.
//  Copyright © 2019 向洪. All rights reserved.
//

#import "ViewController.h"
#import "ScanQRCodeViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)scanAction:(id)sender {
    
    ScanQRCodeViewController *vc = [[ScanQRCodeViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
