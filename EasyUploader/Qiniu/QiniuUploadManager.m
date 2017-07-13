//
//  QiniuUploadManager.m
//  EasyUploader
//
//  Created by zhouyong on 17/4/6.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "QiniuUploadManager.h"

#import <CommonCrypto/CommonCrypto.h>
#import "GTMBase64.h"
#import "QNUploadManager.h"
#import "StringUtil.h"

#define kAccessKey  @"ebgn6Ab9Zk8mtWxycGT9ww2GHB3HI5-FTeXGTJTe"
#define kSecretKey  @"aqF2ARHxYqekMsxyutZOgahXb_PdVmLeDHfNKh-0"


@implementation QiniuUploadManager

SINGLETON_IMPLEMENTATION(QiniuUploadManager);

// https://developer.qiniu.com/kodo/manual/1208/upload-token
- (NSString *)defaultUploadPolicyWithKey:(NSString *)key {
    time_t deadline;
    time(&deadline);    // 返回当前系统时间
    deadline += 3600;   // +3600秒,即默认token保存1小时.

    NSDictionary *params = @{
        @"scope": [NSString stringWithFormat:@"easy-uploader:%@", key],
        @"deadline": @(deadline)
        };
    NSString *json = [StringUtil jsonStringFromObject:params];
    return json;
}

- (NSString *)makeUploadTokenWithKey:(NSString *)key {
    NSString *policy = [self defaultUploadPolicyWithKey:key];
    NSData *policyData = [policy dataUsingEncoding:NSUTF8StringEncoding];

    NSString *encodedPolicy = [GTMBase64 stringByWebSafeEncodingData:policyData padded:TRUE];
    const char *encodedPolicyStr = [encodedPolicy cStringUsingEncoding:NSUTF8StringEncoding];

    char digestStr[CC_SHA1_DIGEST_LENGTH];
    bzero(digestStr, 0);

    const char *secretKeyStr = [kSecretKey UTF8String];
    CCHmac(kCCHmacAlgSHA1, secretKeyStr, strlen(secretKeyStr), encodedPolicyStr, strlen(encodedPolicyStr), digestStr);

    NSString *encodedDigest = [GTMBase64 stringByWebSafeEncodingBytes:digestStr length:CC_SHA1_DIGEST_LENGTH padded:TRUE];
    NSString *token = [NSString stringWithFormat:@"%@:%@:%@", kAccessKey, encodedDigest, encodedPolicy];
    return token;
}

- (void)uploadALAsset:(ALAsset *)asset withKey:(NSString *)key {
    NSString *token = [self makeUploadTokenWithKey:key];
    NSLog(@"upload token [%@]  = %@", key, token);

    QNUploadManager *manager = [[QNUploadManager alloc] init];
    [manager putALAsset: asset
                    key: key
                  token: token
               complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                     NSLog(@"info = %@\n", info);
                     NSLog(@"key = %@\n",key);
                     NSLog(@"resp = %@\n", resp);
                 } option: nil];
}

@end
