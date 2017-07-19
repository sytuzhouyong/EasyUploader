//
//  ViewController.m
//  EasyUploader
//
//  Created by zhouyong on 17/2/28.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "ViewController.h"
#import "ZyxPickAlbumViewController.h"

@interface ViewController ()

@end

@implementation ViewController 

- (void)viewDidLoad {
    [super viewDidLoad];

//    NSString *signingStr = @"/move/bmV3ZG9jczpmaW5kX21hbi50eHQ=/bmV3ZG9jczpmaW5kLm1hbi50eHQ=";
//    NSString *result = [QiniuResourceManager signURL:signingStr andBody:@""];
//    NSLog(@"%@", result);

    [QiniuResourceManager queryResourcesWithPrefix:@"" limit:10 offset:0];

    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
//    ZyxPickAlbumViewController *vc = [[ZyxPickAlbumViewController alloc] init];
//    vc.selectionMode = ZyxImagePickerSelectionModeNone;
////    vc.imagePickerDelegate = self;
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)zyxImagePickrController:(ZyxPickAlbumViewController *)picker didFinishPickingMedioWithInfos:(NSArray<NSDictionary *> *)infos {
    NSLog(@"111111");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
