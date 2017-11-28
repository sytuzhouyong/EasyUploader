//
//  QiniuBucket.h
//  EasyUploader
//
//  Created by zhouyong on 17/7/22.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QiniuBucket : RLMObject

//@property NSInteger ID;
@property NSString *name;
@property NSString *domainURL;

+ (instancetype)bucketWithJSONString:(NSString *)json;
+ (NSArray<QiniuBucket *> *)instancesWithJSONString:(NSString *)json;
+ (NSArray<QiniuBucket *> *)instancesWithJSONStrings:(NSArray<NSString *> *)jsons;

@end
