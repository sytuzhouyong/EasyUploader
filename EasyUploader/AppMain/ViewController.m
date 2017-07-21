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

    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"请求" forState: UIControlStateNormal];
    button.frame = CGRectMake(100, 200, 60, 40);
    [self.view addSubview:button];
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];

    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor cyanColor];
//    ZyxPickAlbumViewController *vc = [[ZyxPickAlbumViewController alloc] init];
//    vc.selectionMode = ZyxImagePickerSelectionModeNone;
//    vc.imagePickerDelegate = self;
//    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)buttonClicked:(id)sender {
//    [QiniuResourceManager queryResourcesWithPrefix:@"" limit:10];
    [QiniuResourceManager queryAllBucketsWithHandler:nil];
}


- (void)zyxImagePickrController:(ZyxPickAlbumViewController *)picker didFinishPickingMedioWithInfos:(NSArray<NSDictionary *> *)infos {
    NSLog(@"111111");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
