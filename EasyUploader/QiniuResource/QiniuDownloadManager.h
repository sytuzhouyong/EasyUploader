//
//  QiniuDownloadManager.h
//  EasyUploader
//
//  Created by zhouyong on 17/8/2.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QiniuDownloadManager : NSObject

SINGLETON_DECLEAR;

- (void)downloadResourceWithKey:(NSString *)key;

@end
