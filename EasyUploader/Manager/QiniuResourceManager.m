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

+ (void)queryResourcesWithPrefix:(NSString *)prefix limit:(int)limit offset:(int)offset {
    NSString *queryURL = [NSString stringWithFormat:@"/list?limit=10&bucket=%@", kBucket];
    NSString *url = [NSString stringWithFormat:@"%@%@", kQiniuResourceHost, queryURL];

    NSString *auth = [self.class signURL:queryURL andBody:@""];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setValue:auth forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"rsf.qbox.me" forHTTPHeaderField:@"Host"];
    NSLog(@"headers = %@", kHttpManager.requestSerializer.HTTPRequestHeaders);

    [[[AFHTTPSessionManager manager] dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSLog(@"response = %@", responseObject);
        NSLog(@"error = %@", error);
    }] resume];
}

+ (NSString *)signURL:(NSString *)url andBody:(NSString *)body {
    const char *sign = [[NSString stringWithFormat:@"%@\n%@", url, body] cStringUsingEncoding:NSUTF8StringEncoding];
    const char *secretKey = [kSecretKey UTF8String];

    char digestStr[CC_SHA1_DIGEST_LENGTH];
    bzero(digestStr, 0);
    CCHmac(kCCHmacAlgSHA1, secretKey, strlen(secretKey), sign, strlen(sign), digestStr);

    NSString *encodedDigest = [GTMBase64 stringByWebSafeEncodingBytes:digestStr length:CC_SHA1_DIGEST_LENGTH padded:TRUE];
    NSString *auth = [NSString stringWithFormat:@"%@:%@", kAccessKey, encodedDigest];
    auth = [NSString stringWithFormat:@"QBox %@", auth];
    NSLog(@"auth = %@", auth);
    return auth;
}

@end
