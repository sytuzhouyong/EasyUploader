//
//  QiniuDownloadManager.m
//  EasyUploader
//
//  Created by zhouyong on 17/8/2.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "QiniuDownloadManager.h"

@implementation QiniuDownloadManager


- (void)downloadResourceWithKey:(NSString *)key {
    NSString *url = [NSString stringWithFormat:@"%@/%@", kQiniuResourceDownloadURL, key];
    NSString *token = [self makeDownloadTokenWithURL:url];
    NSString *downloadURL = [NSString stringWithFormat:@"%@?e=1451491200&token=%@", url, token];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:downloadURL]];
    [[AFHTTPSessionManager manager] downloadTaskWithRequest:request progress:^(NSProgress *downloadProgress) {
        NSLog(@"progress = %lld / %lld", [downloadProgress completedUnitCount], [downloadProgress totalUnitCount]);
    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSString *basePath = [StringUtil documentsPath];
        return [NSURL fileURLWithPath:basePath];
    } completionHandler:^(NSURLResponse *response, NSURL * filePath, NSError *error) {
        ;
    }];
}

- (NSString *)makeDownloadTokenWithURL:(NSString *)url {
    NSString *tokenURL = [NSString stringWithFormat:@"%@?e=1451491200", url];

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
