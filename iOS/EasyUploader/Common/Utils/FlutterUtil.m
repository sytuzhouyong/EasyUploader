//
//  FlutterUtil.m
//  EasyUploader
//
//  Created by 周勇 on 2019/9/30.
//  Copyright © 2019 zhouyong. All rights reserved.
//

#import "FlutterUtil.h"
#import <Flutter/Flutter.h>

@interface FlutterUtil ()

@property (nonatomic, strong) FlutterMethodChannel *methodChannel;

@end

@implementation FlutterUtil

SINGLETON_IMPLEMENTATION_ADD(FlutterUtil, init_additional);

- (void)init_additional {
    NSString *methodChannelName = @"method.ios";
    
    self.methodChannel = [FlutterMethodChannel methodChannelWithName:methodChannelName binaryMessenger:self];
    // Flutter调用原生的回调
    [self.methodChannel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
        // call.method 获取 flutter 调用的方法名
        // call.arguments 获取到 flutter 传过来的参数
        // result 是给flutter的回调， 该回调只能使用一次
        NSLog(@"flutter call method = %@ arguments = %@", call.method, call.arguments);
        NSString *method = call.method;
        //        id args = call.arguments;
        
        // method和WKWebView里面JS交互很像
        if ([method isEqualToString:@"popVC"] ) {
            UITabBarController *tabBarVC = (UITabBarController *)kAppDelegate.window.rootViewController;
            UINavigationController *nav = tabBarVC.selectedViewController;
            [nav popViewControllerAnimated:YES];
            nav.navigationBarHidden = NO;
        }
    }];
}

- (void)invokeFlutterMethod:(NSString *)methodName param:(id)param result:(FlutterMethodResult)result {
    [self.methodChannel invokeMethod:methodName arguments:param result:result];
}

@end
