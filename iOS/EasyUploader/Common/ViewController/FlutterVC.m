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

@interface FlutterVC () <FlutterStreamHandler, FlutterBinaryMessenger>

@property (nonatomic, strong) FlutterMethodChannel *methodChannel;
@property (nonatomic, strong) FlutterMethodChannel *taskMethodChannel;
@property (nonatomic, strong) FlutterEventChannel *eventChannel;
@property (nonatomic, copy) FlutterEventSink eventCallback;


@end

@implementation FlutterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Resolve this problem.
    // MissingPluginException(No implementation found for method getApplicationDocumentsDirectory on channel plugins.flutter.io/path_provider)
    [GeneratedPluginRegistrant registerWithRegistry:self];
    kAppDelegate.flutterVC = self;
    // Do any additional setup after loading the view.
    [self xxx];
    [self yyy];
    
    kWeakself;
    FlutterEventChannel *evenChannal = [FlutterEventChannel eventChannelWithName:@"channel.event.native" binaryMessenger:self];
    // 代理FlutterStreamHandler
    [evenChannal setStreamHandler:self];
    self.eventChannel = evenChannal;
}

#pragma mark - <FlutterStreamHandler>
// // 这个onListen是Flutter端开始监听这个channel时的回调，第二个参数 EventSink是用来传数据的载体。
- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(FlutterEventSink)events {
    // arguments flutter给native的参数
    // 回调给flutter， 建议使用实例指向，因为该block可以使用多次
    NSLog(@"onListenWithArguments args = %@", arguments);
    if (events) {
        self.eventCallback = events;
//        events(@"push传值给flutter的vc");
    }
    return nil;
}

/// flutter不再接收
- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    // arguments flutter给native的参数
    NSLog(@"%@", arguments);
    return nil;
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
        
        // 获取之前要上传的任务列表信息
        if ([method isEqualToString:@"getTobeUploadedTasks"]) {
            NSLog(@"getTobeUploadedTasks");
            NSString *string = @"";
            if (kQiniuUploadManager.tobeUploadedTask.count > 0) {
                string = [weakself JSONStringOfObject:kQiniuUploadManager.tobeUploadedTask];
            }
            result(string);
            return;
        }
        // 清空待上传的任务列表
        if ([method isEqualToString:@"clearTobeUploadedTasks"]) {
            NSLog(@"clearTobeUploadedTasks");
            kQiniuUploadManager.tobeUploadedTask = nil;
            return;
        }
    }];
}

- (void)yyy {
    NSString *methodChannelName = @"channel.method.task-manager";
    kWeakself;
    self.taskMethodChannel = [FlutterMethodChannel methodChannelWithName:methodChannelName binaryMessenger:weakself];
    [self.taskMethodChannel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
        NSLog(@"flutter call method = %@ arguments = %@", call.method, call.arguments);
        NSString *method = call.method;
        id param = call.arguments;
        
        if ([method isEqualToString:@"startUploadTask"]) {
            [weakself onStartUploadTask:param];
            return;
        }
    }];
}

- (void)onStartUploadTask:(NSDictionary *)dict {
    NSString *url = dict[@"asset_url"];
    if ([url isKindOfClass:NSNull.class]) {
        NSLog(@"onStartUploadTask: asset_url is empty");
        return;
    }
    if (url.length <= 0) return;
    ALAsset *asset = [kZyxPhotoManager assetWithUrlString:url];
    
    kWeakself;
    [kQiniuUploadManager uploadALAsset:asset handler:^(BOOL finished, NSString *key, float percent) {
        NSLog(@"finished: %@, key: %@, percent: %.2f ", @(finished), key, percent);
        [weakself sendFlutterNotificationWithObject:@{@"id": dict[@"id"], @"name":key, @"percent":@(percent), @"finished":@(finished)}];
    }];
}

/// 向Flutter端发送通知
- (void)sendFlutterNotificationWithObject:(NSDictionary *)object {
    if (object == nil || _eventCallback == nil) {
        return;
    }
    if (_eventCallback && object) {
        _eventCallback(object);
    }
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
