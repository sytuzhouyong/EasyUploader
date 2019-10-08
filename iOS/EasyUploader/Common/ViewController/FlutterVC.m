//
//  FlutterVC.m
//  EasyUploader
//
//  Created by 周勇 on 2019/9/26.
//  Copyright © 2019 zhouyong. All rights reserved.
//

#import "FlutterVC.h"
#include "GeneratedPluginRegistrant.h"
#include <AssetsLibrary/AssetsLibrary.h>

@interface FlutterVC () <FlutterBinaryMessenger>

@property (nonatomic, strong) FlutterMethodChannel *methodChannel;
@property (nonatomic, strong) FlutterMethodChannel *navtiveImageMethodChannel;


@end

@implementation FlutterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Resolve this problem.
    // MissingPluginException(No implementation found for method getApplicationDocumentsDirectory on channel plugins.flutter.io/path_provider)
    [GeneratedPluginRegistrant registerWithRegistry:self];
    // Do any additional setup after loading the view.
    [self xxx];
    [self yyy];
}

- (void)xxx {
    NSString *methodChannelName = @"channel.method.ios";
    
    kWeakself;
    self.methodChannel = [FlutterMethodChannel methodChannelWithName:methodChannelName binaryMessenger:weakself];
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
            UINavigationController *nav = [kAppDelegate currentNavVC];
            [nav popViewControllerAnimated:YES];
            nav.navigationBarHidden = NO;
            return;
        }
        
        if ([method isEqualToString:@"getTobeUploadedTasks"]) {
            NSLog(@"getTobeUploadedTasks");
            NSString *string = @"";
            if (kQiniuUploadManager.tobeUploadedTask.count > 0) {
                string = [weakself JSONStringOfObject:kQiniuUploadManager.tobeUploadedTask];
            }
            result(string);
            return;
        }
        if ([method isEqualToString:@"clearTobeUploadedTasks"]) {
            NSLog(@"clearTobeUploadedTasks");
            kQiniuUploadManager.tobeUploadedTask = nil;
            return;
        }
    }];
}

- (void)yyy {
    NSString *methodChannelName = @"channel.method.native_image";
    kWeakself;
    self.navtiveImageMethodChannel = [FlutterMethodChannel methodChannelWithName:methodChannelName binaryMessenger:weakself];
    // Flutter调用原生的回调
    [self.navtiveImageMethodChannel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
        NSLog(@"flutter call method = %@ arguments = %@", call.method, call.arguments);
        NSString *method = call.method;
        //        id args = call.arguments;
        
//        if ([method isEqualToString:@"getNativeImage"] ) {
//            
//        }
    }];
}

- (NSString *)JSONStringOfObject:(id )obj {
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:obj options:0 error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
    jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    return jsonStr;
}

//- (void)sendOnChannel:(NSString*)channel message:(NSData* _Nullable)message {
//    NSLog(@"sendOnChannel:message: %@", channel);
//}
//
//- (void)sendOnChannel:(NSString*)channel
//              message:(NSData* _Nullable)message
//          binaryReply:(FlutterBinaryReply _Nullable)callback {
//    NSLog(@"sendOnChannel:message:binaryReply: %@", channel);
//}
//
//- (void)setMessageHandlerOnChannel:(NSString*)channel
//              binaryMessageHandler:(FlutterBinaryMessageHandler _Nullable)handler {
//    NSLog(@"setMessageHandlerOnChannel: %@", channel);
//}

- (void)dealloc {
    NSLog(@"FlutterVC dealloc");
}

@end
