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
@property (nonatomic, copy) NSArray *tobeUploadedTask;

- (void)saveTobeUploadTasks:(NSArray<ALAsset *> *)assets;

// 上传资源
- (void)uploadALAssets:(NSArray<ALAsset *> *)assets handler:(UploadHandler)handler;
- (void)uploadALAsset:(ALAsset *)asset handler:(UploadHandler)handler;

@end
