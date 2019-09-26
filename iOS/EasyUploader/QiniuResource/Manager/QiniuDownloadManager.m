//
//  QiniuDownloadManager.m
//  EasyUploader
//
//  Created by zhouyong on 17/8/2.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "QiniuDownloadManager.h"
#import "QiniuResourceManager.h"

@interface QiniuDownloadManager ()

@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) NSMutableDictionary *downloadURLDict;

@end

@implementation QiniuDownloadManager

SINGLETON_IMPLEMENTATION(QiniuDownloadManager);

- (instancetype)init {
    if (self = [super init]) {
        self.manager = [AFHTTPSessionManager manager];
        self.downloadURLDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)downloadResourceWithKey:(NSString *)key handler:(DonwloadResourceHandler)handler {
    NSString *url = [NSString stringWithFormat:@"%@/%@", kQiniuResourceDownloadURL, key];
    NSString *downloadURL = [self makeDownloadTokenOfKey:key url:url isThumbnail:NO];

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
    NSURL *downloadURL = [self thumbnailURLWithKey:key];
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];

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

- (NSURL *)thumbnailURLWithKey:(NSString *)key {
    return [self thumbnailURLWithKey:key inBucket:kQiniuResourceManager.selectedBucket];
}

- (NSString *)domainOfBucketNamed:(NSString *)name {
    QiniuBucket *bucket = [kQiniuResourceManager bucketWithName:name];
    return bucket.domainURL;
//    RLMResults<QiniuBucket *> *results = [QiniuBucket objectsWhere:@"name = %@", name];
//    NSAssert(results.count == 1, @"number of bucket with name %@ must be only 1!", name);
//    NSString *domain = results.firstObject.domainURL;
//    return domain;
}

// 图片资源的缩略图 url
- (NSURL *)thumbnailURLWithKey:(NSString *)key inBucket:(QiniuBucket *)bucket {
    NSString *domain = [self domainOfBucketNamed:bucket.name];
    if (domain.length == 0) {
        return nil;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@/%@?imageView2/1/w/80/h/80/format/jpg/q/100", domain, key];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    urlString = [self makeDownloadTokenOfKey:key url:urlString isThumbnail:YES];
    return [NSURL URLWithString:urlString];
}

- (NSURL *)urlWithKey:(NSString *)key inBucket:(QiniuBucket *)bucket {
    NSString *domain = [self domainOfBucketNamed:bucket.name];
    if (domain.length == 0) {
        return nil;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", domain, key];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    urlString = [self makeDownloadTokenOfKey:key url:urlString isThumbnail:NO];
    return [NSURL URLWithString:urlString];
}

- (NSURL *)urlWithKey:(NSString *)key {
    return [self urlWithKey:key inBucket:kQiniuResourceManager.selectedBucket];
}


- (NSString *)makeDownloadTokenOfKey:(NSString *)key url:(NSString *)url isThumbnail:(BOOL)isThumbnail {
    // reuse token with key
    NSString *format = isThumbnail ? @"%@-thumbnail" : @"%@";
    NSString *fixedKey = [NSString stringWithFormat:format, key];
    if (self.downloadURLDict[fixedKey]) {
        return self.downloadURLDict[fixedKey];
    }

    time_t deadline;
    time(&deadline);    // 返回当前系统时间
    deadline += 3600;   // +3600秒,即默认token保存1小时.

    NSString *paramConnector = isThumbnail ? @"&" : @"?";
    NSString *tokenURL = [NSString stringWithFormat:@"%@%@e=%ld", url, paramConnector, deadline];

    char digestStr[CC_SHA1_DIGEST_LENGTH];
    bzero(digestStr, 0);
    const char *encodedURL = [tokenURL cStringUsingEncoding:NSUTF8StringEncoding];
    const char *secretKeyStr = [kSecretKey UTF8String];
    CCHmac(kCCHmacAlgSHA1, secretKeyStr, strlen(secretKeyStr), encodedURL, strlen(encodedURL), digestStr);

    NSString *encodedDigest = [GTMBase64 stringByWebSafeEncodingBytes:digestStr length:CC_SHA1_DIGEST_LENGTH padded:TRUE];
    NSString *token = [NSString stringWithFormat:@"%@&token=%@:%@", tokenURL, kAccessKey, encodedDigest];
    self.downloadURLDict[fixedKey] = token;

    return token;
}

@end
