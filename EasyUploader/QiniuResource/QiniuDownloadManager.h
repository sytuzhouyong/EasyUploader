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

@end
