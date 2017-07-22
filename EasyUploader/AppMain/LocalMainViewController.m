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

    ZyxPickAlbumViewController *vc = [[ZyxPickAlbumViewController alloc] init];
    [self.navigationController setViewControllers:@[vc] animated:NO];
//    [self.view addSubview:vc.view];
//
//    [vc.view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.view).insets(UIEdgeInsetsZero);
//    }];
}

@end
