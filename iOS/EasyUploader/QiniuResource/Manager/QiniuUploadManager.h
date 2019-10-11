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
// 保存了新添加的上传任务，Flutter会在任务列表页面显示的时候来取这个数据, 并在取完之后清空这个数据
@property (nonatomic, copy) NSArray *tobeUploadedTask;

- (void)saveTobeUploadTasks:(NSArray<ALAsset *> *)assets;

// 上传资源
- (void)uploadALAssets:(NSArray<ALAsset *> *)assets handler:(UploadHandler)handler;
- (void)uploadALAsset:(ALAsset *)asset handler:(UploadHandler)handler;

@end
