//
//  QiniuResourceManager.m
//  EasyUploader
//
//  Created by zhouyong on 17/7/17.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "QiniuResourceManager.h"

#define kHttpManager    [AFHTTPSessionManager manager]

@implementation QiniuResourceManager

//SINGLETON_IMPLEMENTATION(QiniuResourceManager);

// 查询指定 bucket 的资源
+ (void)queryResourcesInBucket:(NSString *)bucket withPrefix:(NSString *)prefix limit:(int)limit handler:(ResourcesHandler)handler {
    NSString *requestPath = [NSString stringWithFormat:@"/list?limit=%d&bucket=%@", limit, bucket];
    [self.class sendRequestWithPath:requestPath body:@"" andHandler:^(BOOL success, id responseObject) {
        NSArray<QiniuResource *> *resources = nil;
        if (success) {
            resources = [QiniuResource resourcesWithDicts:responseObject[@"items"]];
        }
        ExecuteBlock1IfNotNil(handler, resources);
    }];
}

// 查询所有 buckets
+ (void)queryAllBucketsWithHandler:(BucketsHandler)handler {
    [self.class sendRequestWithPath:@"/buckets" body:@"" andHandler:^(BOOL success, id responseObject) {
        NSArray<QiniuBucket *> *buckets = nil;
        if (success) {
            buckets = [QiniuBucket instancesWithJSONStrings:responseObject];
        }
        ExecuteBlock1IfNotNil(handler, buckets);
    }];
}

// 添加 bucket
+ (void)addBucketWithName:(NSString *)name {
//    NSString *requestPath =  @"/buckets";
//    NSString *requestPathAuthed = [self.class authRequestPath:requestPath andBody:@""];
//    NSString *url = [NSString stringWithFormat:@"%@%@", kQiniuResourceHost, requestPath];
    ;
}

+ (void)sendRequestWithPath:(NSString *)path body:(NSString *)body andHandler:(RequestHandler)handler {
    NSString *authedPath = [self.class authRequestPath:path andBody:body];
    NSString *url = [NSString stringWithFormat:@"%@%@", kQiniuResourceHost, path];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setValue:authedPath forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"rs.qbox.me" forHTTPHeaderField:@"Host"];
    
    [[[AFHTTPSessionManager manager] dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        BOOL success = YES;
        if (error != nil) {
            success = NO;
            NSLog(@"resquest [%@] failed, error = %@", path, error);
        }
        ExecuteBlock2IfNotNil(handler, success, responseObject);
    }] resume];
}

// 生成指定请求的 URL 的管理凭证
+ (NSString *)authRequestPath:(NSString *)url andBody:(NSString *)body {
    const char *sign = [[NSString stringWithFormat:@"%@\n%@", url, body] cStringUsingEncoding:NSUTF8StringEncoding];
    const char *secretKey = [kSecretKey UTF8String];

    char digestStr[CC_SHA1_DIGEST_LENGTH];
    bzero(digestStr, 0);
    CCHmac(kCCHmacAlgSHA1, secretKey, strlen(secretKey), sign, strlen(sign), digestStr);

    NSString *encodedDigest = [GTMBase64 stringByWebSafeEncodingBytes:digestStr length:CC_SHA1_DIGEST_LENGTH padded:TRUE];
    NSString *auth = [NSString stringWithFormat:@"%@:%@", kAccessKey, encodedDigest];
    auth = [NSString stringWithFormat:@"QBox %@", auth];
    return auth;
}

@end
