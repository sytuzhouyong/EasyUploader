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

- (NSString *)marshal {
    time_t deadline;
    time(&deadline);    // 返回当前系统时间
    deadline += 3600;   // +3600秒,即默认token保存1小时.

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    // users是我开辟的公共空间名（即bucket），aaa是文件的key，
    // 按七牛“上传策略”的描述：    <bucket>:<key>，表示只允许用户上传指定key的文件。
    // 在这种格式下文件默认允许“修改”，若已存在同名资源则会被覆盖。
    // 如果只希望上传指定key的文件，并且不允许修改，那么可以将下面的 insertOnly 属性值设为 1。
    // 所以如果参数只传users的话，下次上传key还是aaa的文件会提示存在同名文件，不能上传。
    // 传users:aaa的话，可以覆盖更新，但实测延迟较长，我上传同名新文件上去，下载下来的还是老文件。
    params[@"scope"] = @"easy-uploader:bbb";
    params[@"deadline"] = @(deadline);
    NSString *json = [StringUtil jsonStringFromObject:params];
    return json;
}

- (NSString *)makeUploadTokenWithAccessKey:(NSString *)accessKey secretKey:(NSString *)secretKey {
    NSString *policy = [self marshal];
    NSData *policyData = [policy dataUsingEncoding:NSUTF8StringEncoding];

    NSString *encodedPolicy = [GTMBase64 stringByWebSafeEncodingData:policyData padded:TRUE];
    const char *encodedPolicyStr = [encodedPolicy cStringUsingEncoding:NSUTF8StringEncoding];

    char digestStr[CC_SHA1_DIGEST_LENGTH];
    bzero(digestStr, 0);

    const char *secretKeyStr = [secretKey UTF8String];
    CCHmac(kCCHmacAlgSHA1, secretKeyStr, strlen(secretKeyStr), encodedPolicyStr, strlen(encodedPolicyStr), digestStr);

    NSString *encodedDigest = [GTMBase64 stringByWebSafeEncodingBytes:digestStr length:CC_SHA1_DIGEST_LENGTH padded:TRUE];
    NSString *token = [NSString stringWithFormat:@"%@:%@:%@", accessKey, encodedDigest, encodedPolicy];
    return token;
}

- (void)uploadALAsset:(ALAsset *)asset {
    NSString *token = [self makeUploadTokenWithAccessKey:kAccessKey secretKey:kSecretKey];
    NSLog(@"upload token = %@",token);

    QNUploadManager *manager = [[QNUploadManager alloc] init];
    [manager putALAsset: asset
                      key: @"bbb"
                    token: token
                 complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                     NSLog(@"info = %@\n", info);
                     NSLog(@"key = %@\n",key);
                     NSLog(@"resp = %@\n", resp);
                 } option: nil];
}

@end
