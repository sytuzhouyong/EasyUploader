//
//  QiniuUploadManager.h
//  EasyUploader
//
//  Created by zhouyong on 17/4/6.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QiniuUploadManager : NSObject

- (NSString *)makeUploadTokenWithAccessKey:(NSString *)accessKey secretKey:(NSString *)secretKey;
- (void)uploadALAsset:(ALAsset *)asset;

@end
