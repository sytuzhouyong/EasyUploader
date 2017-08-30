//
//  QiniuUploadManager.h
//  EasyUploader
//
//  Created by zhouyong on 17/4/6.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QiniuUploadManager : NSObject

SINGLETON_DECLEAR;

- (void)uploadALAsset:(ALAsset *)asset toBucket:(NSString *)bucket withKey:(NSString *)key;

@end
