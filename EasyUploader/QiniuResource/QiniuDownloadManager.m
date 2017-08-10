//
//  QiniuDownloadManager.m
//  EasyUploader
//
//  Created by zhouyong on 17/8/2.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "QiniuDownloadManager.h"

@interface QiniuDownloadManager ()

@property (nonatomic, strong) AFHTTPSessionManager *manager;

@end

@implementation QiniuDownloadManager

SINGLETON_IMPLEMENTATION(QiniuDownloadManager);

- (instancetype)init {
    if (self = [super init]) {
        self.manager = [AFHTTPSessionManager manager];
    }
    return self;
}

- (void)downloadResourceWithKey:(NSString *)key handler:(DonwloadResourceHandler)handler {
    NSString *url = [NSString stringWithFormat:@"%@/%@", kQiniuResourceDownloadURL, key];
    NSString *downloadURL = [self makeDownloadTokenWithURL:url];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:downloadURL]];
    [[self.manager downloadTaskWithRequest:request progress:^(NSProgress *downloadProgress) {
        NSLog(@"progress = %lld / %lld", [downloadProgress completedUnitCount], [downloadProgress totalUnitCount]);
    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSString *basePath = [StringUtil documentsPath];
        NSString *destPath = [NSString stringWithFormat:@"%@/%@", basePath, key];
        NSLog(@"path = %@", basePath);
        return [NSURL fileURLWithPath:destPath];
    } completionHandler:^(NSURLResponse *response, NSURL * filePath, NSError *error) {
        NSLog(@"path = %@", filePath);
        BOOL success = error == nil;
        ExecuteBlock2IfNotNil(handler, success, filePath);
    }] resume];
}

- (void)downloadResourceThumbnailWithKey:(NSString *)key handler:(DonwloadResourceHandler)handler {
    NSString *url = [NSString stringWithFormat:@"%@/%@?imageView2/1/w/80/h/80/format/jpg/q/75|imageslim", kQiniuResourceDownloadURL, key];
    NSString *downloadURL = [self makeDownloadTokenWithURL:url];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:downloadURL]];
    [[self.manager downloadTaskWithRequest:request progress:^(NSProgress *downloadProgress) {
        NSLog(@"progress = %lld / %lld", [downloadProgress completedUnitCount], [downloadProgress totalUnitCount]);
    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSString *basePath = [StringUtil documentsPath];
        NSString *destPath = [NSString stringWithFormat:@"%@/%@", basePath, key];
        NSLog(@"path = %@", basePath);
        return [NSURL fileURLWithPath:destPath];
    } completionHandler:^(NSURLResponse *response, NSURL * filePath, NSError *error) {
        NSLog(@"path = %@", filePath);
        BOOL success = error == nil;
        ExecuteBlock2IfNotNil(handler, success, filePath);
    }] resume];
}

- (NSString *)makeDownloadTokenWithURL:(NSString *)url {
    time_t deadline;
    time(&deadline);    // 返回当前系统时间
    deadline += 3600;   // +3600秒,即默认token保存1小时.

    NSString *tokenURL = [NSString stringWithFormat:@"%@&e=%ld", url, deadline];

    char digestStr[CC_SHA1_DIGEST_LENGTH];
    bzero(digestStr, 0);
    const char *encodedURL = [tokenURL cStringUsingEncoding:NSUTF8StringEncoding];
    const char *secretKeyStr = [kSecretKey UTF8String];
    CCHmac(kCCHmacAlgSHA1, secretKeyStr, strlen(secretKeyStr), encodedURL, strlen(encodedURL), digestStr);

    NSString *encodedDigest = [GTMBase64 stringByWebSafeEncodingBytes:digestStr length:CC_SHA1_DIGEST_LENGTH padded:TRUE];
    NSString *token = [NSString stringWithFormat:@"%@&token=%@:%@", tokenURL, kAccessKey, encodedDigest];
    return token;
}

@end
