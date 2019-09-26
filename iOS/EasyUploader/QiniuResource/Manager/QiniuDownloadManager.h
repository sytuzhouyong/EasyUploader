//
//  QiniuDownloadManager.h
//  EasyUploader
//
//  Created by zhouyong on 17/8/2.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DonwloadResourceHandler)(BOOL success, NSURL *destURL);

@interface QiniuDownloadManager : NSObject

SINGLETON_DECLEAR;

- (void)downloadResourceWithKey:(NSString *)key handler:(DonwloadResourceHandler)handler;
- (void)downloadResourceThumbnailWithKey:(NSString *)key handler:(DonwloadResourceHandler)handler;

- (NSURL *)thumbnailURLWithKey:(NSString *)key;
- (NSURL *)thumbnailURLWithKey:(NSString *)key inBucket:(QiniuBucket *)bucket;

- (NSURL *)urlWithKey:(NSString *)key;
- (NSURL *)urlWithKey:(NSString *)key inBucket:(QiniuBucket *)bucket;

@end
