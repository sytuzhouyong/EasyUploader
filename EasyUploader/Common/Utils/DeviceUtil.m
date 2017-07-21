//
//  DeviceUtil.m
//  XingHomecloud
//
//  Created by zhouyong on 15/11/24.
//  Copyright © 2015年 zhouyong. All rights reserved.
//

#import "DeviceUtil.h"
#import "KeychainItemWrapper.h"
#import "IPAddress.h"
#include <sys/param.h>
#include <sys/mount.h>
#include <AVFoundation/AVFoundation.h>

@implementation DeviceUtil

+ (BOOL)isPhotoAuthorized {
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status == ALAuthorizationStatusAuthorized) {
        return YES;
    } else if (status == ALAuthorizationStatusRestricted || status == ALAuthorizationStatusDenied) {
        return NO;
    }
    
    __block BOOL havePermission = YES;
    __block BOOL waitDetermined = YES;
    
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    ALAssetsLibrary *assetsLib = [[ALAssetsLibrary alloc] init];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 因为这是同步方法，如果在主线程中跑，结合NSRunLoop，会阻塞主线程
        [assetsLib enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            *stop = YES;
            waitDetermined = NO;
            dispatch_semaphore_signal(sem);
        } failureBlock:^(NSError *error) {
            havePermission = NO;
            waitDetermined = NO;
            dispatch_semaphore_signal(sem);
        }];
        while (waitDetermined) {
            NSLog(@"run loop...");
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            NSLog(@"run loop end");
        }
    });
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    return havePermission;
}

+ (BOOL)isCameraAuthorized {
    __block BOOL havePermission = YES;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied) {
        havePermission = NO;
    } else if (status == AVAuthorizationStatusNotDetermined) {
        __block BOOL waitDetermined = YES;
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            havePermission = granted;
            waitDetermined = NO;
        }];
        while (waitDetermined) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
    return havePermission;
}

+ (BOOL)isMicrophoneAuthorized {
    __block BOOL accessGranted = YES;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
        __block BOOL waitDetermined = YES;
        [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            waitDetermined = NO;
            accessGranted = granted;
        }];
        while (waitDetermined) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
    return accessGranted;
}

+ (void)jumpToURLString:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    [kApplication openURL:url];
}

+ (void)jumpToAppSettings {
    [self jumpToURLString:UIApplicationOpenSettingsURLString];
}

+ (void)jumpToWiFi {
   [self jumpToURLString:@"prefs:root=WiFi"];
}

+ (NSString *)deviceIpAddress {
    InitAddresses();
    GetIPAddresses();
    GetHWAddresses();
    if (ip_names[1] == NULL || strlen(ip_names[1]) == 0) {
        return @"";
    }
    return [NSString stringWithUTF8String:ip_names[1]];
}

+ (NSString *)uniqueString {
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    return (__bridge_transfer NSString *)(string);
}

+ (NSString *)deviceUniqueId {
    KeychainItemWrapper *keychain = [DeviceUtil keyChainWrapperForKeyID:@"DeviceID"];
    NSString *string = [keychain objectForKey:(__bridge id)(kSecAttrAccount)];
    if (string.length == 0) {
        string = [self.class uniqueString];
        [keychain setObject: string forKey: (__bridge id)(kSecAttrAccount)];
        DDLogInfo(@"yes, device unique id = %@", string);
    }
    return string;
}

+ (KeychainItemWrapper *)keyChainWrapperForKeyID:(NSString *)keyID {
    static dispatch_once_t onceToken = 0;
    static NSMutableDictionary *keyChains = nil;
    dispatch_once(&onceToken, ^{
        keyChains = [NSMutableDictionary new];
    });
    
    KeychainItemWrapper *keychain = nil;
    @synchronized (keyChains) {
        keychain = [keyChains objectForKey: keyID];
        if (keychain == nil) {
            keychain = [[KeychainItemWrapper alloc] initWithIdentifier:keyID accessGroup:nil];
            [keyChains setObject:keychain forKey:keyID];
        }
    }
    return keychain;
}

+ (NSString *)freeDiskSpaceInBytes {
    struct statfs buf;
    long long freespace = -1;
    if(statfs("/var", &buf) >= 0){
        freespace = (long long)(buf.f_bsize * buf.f_bfree);
    }
    return [NSString stringWithFormat:Text(@"PhoneRemainingSpace"), [StringUtil descriptionOfSpace:freespace]];
}

@end
