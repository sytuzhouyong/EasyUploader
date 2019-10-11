//
//  QiniuUploadManager.m
//  EasyUploader
//
//  Created by zhouyong on 17/4/6.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "QiniuUploadManager.h"
#import "QNUploadManager.h"
#import "QNUploadOption+Private.h"
#import "QNConfiguration.h"


@implementation QiniuUploadManager

SINGLETON_IMPLEMENTATION(QiniuUploadManager);

// https://developer.qiniu.com/kodo/manual/1208/upload-token
// key: 上传的文件名
- (NSString *)defaultUploadPolicyOfBucket:(NSString *)bucket withKey:(NSString *)key {
    time_t deadline;
    time(&deadline);    // 返回当前系统时间
    deadline += 3600;   // +3600秒,即默认token保存1小时.

    NSDictionary *params = @{
        @"scope": [NSString stringWithFormat:@"%@:%@", bucket, key],
        @"deadline": @(deadline)
        };
    NSString *json = [StringUtil jsonStringFromObject:params];
    return json;
}

/// 生成上传token
- (NSString *)generateUploadTokenOfBucketNamed:(NSString *)bucket withKey:(NSString *)key {
    NSString *policy = [self defaultUploadPolicyOfBucket:bucket withKey:key];
    NSData *policyData = [policy dataUsingEncoding:NSUTF8StringEncoding];

    NSString *encodedPolicy = [GTMBase64 stringByWebSafeEncodingData:policyData padded:TRUE];
    const char *encodedPolicyStr = [encodedPolicy cStringUsingEncoding:NSUTF8StringEncoding];
    const char *secretKeyStr = [kSecretKey UTF8String];

    char digestStr[CC_SHA1_DIGEST_LENGTH];
    bzero(digestStr, 0);
    CCHmac(kCCHmacAlgSHA1, secretKeyStr, strlen(secretKeyStr), encodedPolicyStr, strlen(encodedPolicyStr), digestStr);

    NSString *encodedDigest = [GTMBase64 stringByWebSafeEncodingBytes:digestStr length:CC_SHA1_DIGEST_LENGTH padded:TRUE];
    NSString *token = [NSString stringWithFormat:@"%@:%@:%@", kAccessKey, encodedDigest, encodedPolicy];
    return token;
}

- (void)uploadALAsset:(ALAsset *)asset handler:(UploadHandler)handler {
    QiniuBucket *bucket = kQiniuResourceManager.selectedBucket;
    NSString *key = [self uploadKeyOfALAsset:asset];
    NSString *token = [self generateUploadTokenOfBucketNamed:bucket.name withKey:key];
    NSLog(@"upload key = %@, token = %@", key, token);

    QNUploadOption *uploadOption = [[QNUploadOption alloc] initWithMime:nil
                                                        progressHandler:^(NSString *key, float percent) {
                                                            ExecuteBlock3IfNotNil(handler, NO, key, percent);
                                                        }
                                                                 params:nil
                                                               checkCrc:NO
                                                     cancellationSignal:^BOOL{
                                                         return NO;
                                                                 }
                                    ];
    QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
        builder.zone = [QNFixedZone zone2];
        builder.retryMax = 3;
    }];
    QNUploadManager *manager = [[QNUploadManager alloc] initWithConfiguration:config];
    [manager putALAsset: asset
                    key: key
                  token: token
               complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                   NSLog(@"key: %@, resp = %@, info = %@", key, resp, info);
                   BOOL success = resp[@"hash"];
                   ExecuteBlock3IfNotNil(handler, success, key, 1.0f);
                 }
                 option: uploadOption];
}

- (void)saveTobeUploadTasks:(NSArray<ALAsset *> *)assets {
    [self createThumbnailDirIfNecessory];

    NSMutableArray *params = [NSMutableArray arrayWithCapacity:assets.count];
    for (ALAsset *asset in assets) {
        NSDictionary *param = [self taskPropertyDictOfALAsset:asset];
        
        UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
        // 将取得的图片写入本地的沙盒中，其中0.5表示压缩比例，1表示不压缩，数值越小压缩比例越大
        
        NSString *path = [self thumbnailPathOfAsset:asset];
        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path];
        if (!exists) {
            NSData *data = UIImageJPEGRepresentation(image, 1);
            BOOL success = [data writeToFile:path atomically:YES];
            if (!success) {
                NSLog(@"writeToFile failed");
            }
        }
        [params addObject:param];
        
    }
    self.tobeUploadedTask = params;
}

- (NSString *)thumbnailDir {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    path = [path stringByAppendingPathComponent:@"thumbnail"];
    return path;
}

- (NSString *)thumbnailPathOfAsset:(ALAsset *)asset {
    NSString *dir = [self thumbnailDir];
    NSString *fileName = asset.defaultRepresentation.filename;
    NSString *path = [dir stringByAppendingPathComponent:fileName];
    return path;
}

- (BOOL)createThumbnailDirIfNecessory {
    NSString *dir = [self thumbnailDir];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL exists = [manager fileExistsAtPath:dir isDirectory:&isDir];
    
    if (isDir && !exists) {
        NSError *error = nil;
        BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error];
        if (!result && error) {
            NSLog(@"create dir thumbnail failed, error: %@", error);
            return NO;
        }
    }
    return YES;
}


- (void)uploadALAssets:(NSArray<ALAsset *> *)assets handler:(UploadHandler)handler {
   
//    [[FlutterUtil sharedInstance] invokeFlutterMethod:@"addUploadTasks" param:params result:^(id  _Nonnull result) {
//        NSLog(@"invokeFlutterMethod addTasks result: %@", result);
//    }];
    
//    for (ALAsset *asset in assets) {
//        NSString *key = [self uploadKeyOfALAsset:asset];
//        [kQiniuUploadManager uploadALAsset:asset handler:^(BOOL finished, NSString *key, float percent) {
//            NSLog(@"finished: %d, percent: %.3f", finished, percent);
//        }];
//    }
}

- (NSString *)uploadKeyOfALAsset:(ALAsset *)asset {
//    NSString *title = [ALAssetUtil millisecondDateStringOfALAsset:asset];
//    NSString *ext = [ALAssetUtil extOfAsset:asset];
//    NSString *key = [NSString stringWithFormat:@"%@.%@", title, ext];
    
    NSString *key = asset.defaultRepresentation.filename;
    return key;
}

- (NSDictionary *)taskPropertyDictOfALAsset:(ALAsset *)asset {
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"name"] = [self uploadKeyOfALAsset:asset];
    param[@"total_size"] = @(asset.defaultRepresentation.size);
    param[@"transferred_size"] = @0;
    param[@"state"] = @0;
    param[@"thumbnail_url"] = [self thumbnailPathOfAsset:asset];
    param[@"asset_url"] = [[ZyxPhotoManager sharedInstance] urlStringOfAsset:asset];
    return param;
}

@end
