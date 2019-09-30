//
//  FlutterUtil.h
//  EasyUploader
//
//  Created by 周勇 on 2019/9/30.
//  Copyright © 2019 zhouyong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^FlutterMethodResult)(id result);

@interface FlutterUtil : NSObject

SINGLETON_DECLEAR;

- (void)invokeFlutterMethod:(NSString *)methodName param:(id)param result:(FlutterMethodResult)result;

@end

NS_ASSUME_NONNULL_END
