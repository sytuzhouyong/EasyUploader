//
//  AuthorizationUtil.h
//  XingHomecloud
//
//  Created by zhouyong on 15/11/24.
//  Copyright © 2015年 zhouyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceUtil : NSObject

+ (BOOL)isPhotoAuthorized;
+ (BOOL)isCameraAuthorized;
+ (BOOL)isMicrophoneAuthorized;
+ (void)jumpToAppSettings;
+ (void)jumpToWiFi;

+ (NSString *)deviceIpAddress;
+ (NSString *)uniqueString;
+ (NSString *)deviceUniqueId;
+ (NSString *)freeDiskSpaceInBytes;

@end
