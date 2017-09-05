//
//  QiniuUploadManager.h
//  EasyUploader
//
//  Created by zhouyong on 17/4/6.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^UploadHandler)(BOOL finished, NSString *key, float percent);

@interface QiniuUploadManager : NSObject

SINGLETON_DECLEAR;

@property (nonatomic, copy) NSString *uploadPath;

- (void)uploadALAsset:(ALAsset *)asset toBucket:(NSString *)bucket withKey:(NSString *)key handler:(UploadHandler)handler;

@end
