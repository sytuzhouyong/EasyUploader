//
//  LocalMainViewController.m
//  EasyUploader
//
//  Created by zhouyong on 17/7/22.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "LocalMainViewController.h"
#import "ZyxPickAlbumViewController.h"

@implementation LocalMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"本地相册";

    // 不为空说明是选择上传路径界面
    if (self.presentingViewController != nil) {
        self.title = @"选择目录";

        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithImage:UIImageNamed(@"icon_arrow_left") style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)];
        self.navigationItem.leftBarButtonItem = buttonItem;
    }
}

- (void)cancelButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
