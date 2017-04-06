//
//  ViewController.m
//  EasyUploader
//
//  Created by zhouyong on 17/2/28.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "ViewController.h"
#import "ZyxImagePickerController.h"

@interface ViewController ()

@end

@implementation ViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    ZyxImagePickerController *vc = [[ZyxImagePickerController alloc] init];
    vc.selectionMode = ZyxImagePickerSelectionModeNone;
//    vc.imagePickerDelegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)zyxImagePickrController:(ZyxImagePickerController *)picker didFinishPickingMedioWithInfos:(NSArray<NSDictionary *> *)infos {
    NSLog(@"111111");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
