//
//  QiniuResourceManager.m
//  EasyUploader
//
//  Created by zhouyong on 17/7/17.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "QiniuResourceManager.h"

#define kHttpManager    [AFHTTPSessionManager manager]

@interface QiniuResourceManager ()

@property (nonatomic, strong) NSMutableDictionary *domainDict;

@end

@implementation QiniuResourceManager

SINGLETON_IMPLEMENTATION_ADD(QiniuResourceManager, init_additional);

- (void)init_additional {
    self.domainDict = [NSMutableDictionary dictionary];
}

// 查询指定 bucket 的资源
+ (void)queryResourcesInBucket:(QiniuBucket *)bucket withPrefix:(NSString *)prefix limit:(int)limit handler:(ResourcesHandler)handler {
    NSString *requestPath = [NSString stringWithFormat:@"/list?bucket=%@&prefix=%@&limit=%d&delimiter=/", bucket.name, prefix, limit];
    NSLog(@"request url = %@", requestPath);
    [self.class sendRequestWithPath:requestPath body:@"" host:kQiniuResourceHost andHandler:^(BOOL success, id responseObject) {
        NSLog(@"response = %@", responseObject);
        NSArray<QiniuResource *> *resources = nil;
        if (success) {
            resources = [QiniuResource resourcesWithDict:responseObject];
        }
        ExecuteBlock1IfNotNil(handler, resources);
    }];
}

// 查询所有 buckets
+ (void)queryAllBucketsWithHandler:(BucketsHandler)handler {
    [self.class sendRequestWithPath:@"/buckets" body:@"" host:kQiniuBucketHost andHandler:^(BOOL success, id responseObject) {
        NSArray<QiniuBucket *> *buckets = nil;
        if (success) {
            buckets = [QiniuBucket instancesWithJSONStrings:responseObject];
        }
        ExecuteBlock1IfNotNil(handler, buckets);
    }];
}

- (void)queryDomainOfBucket:(QiniuBucket *)bucket withHandler:(StringArrayHandler)handler {
    NSString *url = [NSString stringWithFormat:@"/v6/domain/list?tbl=%@", bucket.name];
    [self.class sendRequestWithPath:url baseURL:kQiniuBaseRequestURL body:@"" host:kQiniuAPIHost andHandler:^(BOOL success, id responseObject) {
        NSLog(@"response = %@", responseObject);
        if (success) {
            self.domainDict[bucket.name] = responseObject;
        }
    }];
}

// 添加 bucket
+ (void)addBucketWithName:(NSString *)name {
//    NSString *requestPath =  @"/buckets";
//    NSString *requestPathAuthed = [self.class authRequestPath:requestPath andBody:@""];
//    NSString *url = [NSString stringWithFormat:@"%@%@", kQiniuResourceHost, requestPath];
    ;
}

+ (void)sendRequestWithPath:(NSString *)path baseURL:(NSString *)baseURL body:(NSString *)body host:(NSString *)host andHandler:(RequestHandler)handler {
    NSString *authedPath = [self.class authRequestPath:path andBody:body];
    NSString *url = [NSString stringWithFormat:@"%@%@", baseURL, path];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setValue:authedPath forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:host forHTTPHeaderField:@"Host"];

    [[[AFHTTPSessionManager manager] dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        BOOL success = YES;
        if (error != nil) {
            success = NO;
            NSLog(@"resquest [%@] failed, error = %@", path, error);
        }
        ExecuteBlock2IfNotNil(handler, success, responseObject);
    }] resume];
}

+ (void)sendRequestWithPath:(NSString *)path body:(NSString *)body host:(NSString *)host andHandler:(RequestHandler)handler {
    [self.class sendRequestWithPath:path baseURL:kQiniuBaseRequestURL body:body host:host andHandler:handler];
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
