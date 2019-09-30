//
//  FlutterVC.m
//  EasyUploader
//
//  Created by 周勇 on 2019/9/26.
//  Copyright © 2019 zhouyong. All rights reserved.
//

#import "FlutterVC.h"
#include "GeneratedPluginRegistrant.h"

@interface FlutterVC ()

@end

@implementation FlutterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Resolve this problem.
    // MissingPluginException(No implementation found for method getApplicationDocumentsDirectory on channel plugins.flutter.io/path_provider)
    [GeneratedPluginRegistrant registerWithRegistry:self];
    // Do any additional setup after loading the view.
}

- (void)dealloc {
    NSLog(@"FlutterVC dealloc");
}

@end
