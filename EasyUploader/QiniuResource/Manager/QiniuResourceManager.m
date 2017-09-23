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

@property (nonatomic, strong) NSMutableDictionary *domainsDict;

@end

@implementation QiniuResourceManager

SINGLETON_IMPLEMENTATION_ADD(QiniuResourceManager, init_additional);

- (void)init_additional {
    self.domainsDict = [NSMutableDictionary dictionary];
}

- (NSString *)domainOfBucket:(QiniuBucket *)bucket {
    NSArray *domains = self.domainsDict[bucket.name];
    if (domains.count == 0) {
        return @"";
    }

    NSString *domain = domains.firstObject;
    return [NSString stringWithFormat:@"http://%@", domain];
}

// 查询所有 buckets
+ (void)queryAllBucketsWithHandler:(BucketsHandler)handler {
    NSURLRequest *request = [self.class requestWithHostName:kQiniuResourceHost path:@"/buckets" hostNameInHeader:@"rs.qbox.me"];

    [self.class sendRequest:request withHandler:^(BOOL success, id responseObject) {
        NSArray<QiniuBucket *> *buckets = nil;
        if (success) {
            buckets = [QiniuBucket instancesWithJSONStrings:responseObject];
            for (QiniuBucket *bucket in buckets) {
                [kQiniuResourceManager queryDomainOfBucket:bucket];
            }
        }
        ExecuteBlock1IfNotNil(handler, buckets);
    }];
}

// 查询 bucket 的外链域名, 用于资源下载
- (void)queryDomainOfBucket:(QiniuBucket *)bucket {
    NSString *path = [NSString stringWithFormat:@"/v6/domain/list?tbl=%@", bucket.name];
    NSURLRequest *request = [self.class requestWithHostName:kQiniuAPIHost path:path];
    [self.class sendRequest:request withHandler:^(BOOL success, id responseObject) {
        NSLog(@"response = %@", responseObject);
        if (success) {
            self.domainsDict[bucket.name] = responseObject;
        }
    }];
}

// 查询指定 bucket 的资源
+ (void)queryResourcesInBucket:(QiniuBucket *)bucket withPrefix:(NSString *)prefix limit:(int)limit marker:(NSString *)marker handler:(ResourcesHandler)handler {
    NSString *fixedMarker = SafeString(marker);
    NSString *path = [NSString stringWithFormat:@"/list?bucket=%@&prefix=%@&limit=%d&marker=%@&delimiter=%@", bucket.name, prefix, limit, fixedMarker, kQiniuPathDelimiter];
    NSLog(@"request url = %@", path);
    // if have chinese character, need url encode
    path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSURLRequest *request = [self.class requestWithHostName:kQiniuResourceHost path:path];
    [self.class sendRequest:request withHandler:^(BOOL success, NSDictionary *responseObject) {
        NSLog(@"response = %@", responseObject);
        NSArray<QiniuResource *> *resources = nil;
        NSString *marker = @"";
        if (success) {
            resources = [QiniuResource resourcesWithDict:responseObject];
            if (responseObject[@"marker"]) {
                marker = responseObject[@"marker"];
            }
        }
        ExecuteBlock2IfNotNil(handler, resources, marker);
    }];
}


+ (void)deleteResourceNamed:(NSString *)key inBucket:(QiniuBucket *)bucket withHandler:(RequestHandler)handler {
    NSString *path = [NSString stringWithFormat:@"%@:%@", bucket.name, key];
    NSString *encodedPath = [GTMBase64 encodeBase64String:path];
    NSString *requestPath = [NSString stringWithFormat:@"/delete/%@", encodedPath];

    NSURLRequest *request = [self.class requestWithHostName:@"rs.qiniu.com" path:requestPath];
    [self.class sendRequest:request withHandler:^(BOOL success, id responseObject) {
        NSLog(@"response = %@", responseObject);
        ExecuteBlock2IfNotNil(handler, success, responseObject);
    }];
}


// 添加 bucket
+ (void)addBucketWithName:(NSString *)name {
//    NSString *requestPath =  @"/buckets";
//    NSString *requestPathAuthed = [self.class authRequestPath:requestPath andBody:@""];
//    NSString *url = [NSString stringWithFormat:@"%@%@", kQiniuResourceHost, requestPath];
    ;
}

+ (void)sendRequest:(NSURLRequest *)request withHandler:(RequestHandler)handler {
    [[[AFHTTPSessionManager manager] dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        BOOL success = YES;
        if (error != nil) {
            success = NO;
            NSLog(@"resquest failed, error = %@", error);
        }
        ExecuteBlock2IfNotNil(handler, success, responseObject);
    }] resume];
}


+ (NSURLRequest *)requestWithHostName:(NSString *)host path:(NSString *)path {
    return [self.class requestWithProtocol:@"http" hostName:host path:path hostNameInHeader:host body:@""];
}

+ (NSURLRequest *)requestWithHostName:(NSString *)host path:(NSString *)path hostNameInHeader:(NSString *)headerHostName {
    return [self.class requestWithProtocol:@"http" hostName:host path:path hostNameInHeader:headerHostName body:@""];
}

+ (NSURLRequest *)requestWithProtocol:(NSString *)protocol hostName:(NSString *)host path:(NSString *)path hostNameInHeader:(NSString *)headerHostName body:(NSString *)body {
    NSString *authedPath = [self.class authRequestPath:path andBody:body];
    NSString *urlString = [NSString stringWithFormat:@"%@://%@%@", protocol, host, path];
    NSURL *url = [NSURL URLWithString:urlString];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:authedPath forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:headerHostName forHTTPHeaderField:@"Host"];
    return request;
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
