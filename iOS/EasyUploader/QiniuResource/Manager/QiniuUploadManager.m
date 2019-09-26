//
//  QiniuUploadManager.m
//  EasyUploader
//
//  Created by zhouyong on 17/4/6.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "QiniuUploadManager.h"
#import "QNUploadManager.h"
#import "QNUploadOption+Private.h"
#import "QNConfiguration.h"


@implementation QiniuUploadManager

SINGLETON_IMPLEMENTATION(QiniuUploadManager);

// https://developer.qiniu.com/kodo/manual/1208/upload-token
// key: 上传的文件名
- (NSString *)defaultUploadPolicyOfBucket:(NSString *)bucket withKey:(NSString *)key {
    time_t deadline;
    time(&deadline);    // 返回当前系统时间
    deadline += 3600;   // +3600秒,即默认token保存1小时.

    NSDictionary *params = @{
        @"scope": [NSString stringWithFormat:@"%@:%@", bucket, key],
        @"deadline": @(deadline)
        };
    NSString *json = [StringUtil jsonStringFromObject:params];
    return json;
}

- (NSString *)makeUploadTokenOfBucket:(NSString *)bucket withKey:(NSString *)key {
    NSString *policy = [self defaultUploadPolicyOfBucket:bucket withKey:key];
    NSData *policyData = [policy dataUsingEncoding:NSUTF8StringEncoding];

    NSString *encodedPolicy = [GTMBase64 stringByWebSafeEncodingData:policyData padded:TRUE];
    const char *encodedPolicyStr = [encodedPolicy cStringUsingEncoding:NSUTF8StringEncoding];
    const char *secretKeyStr = [kSecretKey UTF8String];

    char digestStr[CC_SHA1_DIGEST_LENGTH];
    bzero(digestStr, 0);
    CCHmac(kCCHmacAlgSHA1, secretKeyStr, strlen(secretKeyStr), encodedPolicyStr, strlen(encodedPolicyStr), digestStr);

    NSString *encodedDigest = [GTMBase64 stringByWebSafeEncodingBytes:digestStr length:CC_SHA1_DIGEST_LENGTH padded:TRUE];
    NSString *token = [NSString stringWithFormat:@"%@:%@:%@", kAccessKey, encodedDigest, encodedPolicy];
    return token;
}

- (void)uploadALAsset:(ALAsset *)asset toBucket:(NSString *)bucket withKey:(NSString *)key handler:(UploadHandler)handler {
    NSString *token = [self makeUploadTokenOfBucket:bucket withKey:key];
    NSLog(@"upload token [%@]  = %@", key, token);

    QNUploadOption *uploadOption = [[QNUploadOption alloc] initWithMime:nil
                                                        progressHandler:^(NSString *key, float percent) {
                                                            ExecuteBlock3IfNotNil(handler, NO, key, percent);
                                                        }
                                                                 params:nil
                                                               checkCrc:NO
                                                     cancellationSignal:^BOOL{
                                                         return NO;
                                                                 }
                                    ];
    QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
        builder.zone = [QNFixedZone zone2];
        builder.retryMax = 3;
    }];
    QNUploadManager *manager = [[QNUploadManager alloc] initWithConfiguration:config];
    [manager putALAsset: asset
                    key: key
                  token: token
               complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                   NSLog(@"key: %@, resp = %@, info = %@", key, resp, info);
                   BOOL success = resp[@"hash"];
                   ExecuteBlock3IfNotNil(handler, success, key, 1.0f);
                 }
                 option: uploadOption];
}

@end