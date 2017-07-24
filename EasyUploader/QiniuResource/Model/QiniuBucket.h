//
//  QiniuBucket.h
//  EasyUploader
//
//  Created by zhouyong on 17/7/22.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QiniuBucket : NSObject

@property (nonatomic, copy) NSString *name;
//@property (nonatomic, copy) NSString *

+ (instancetype)bucketWithJSONString:(NSString *)json;
+ (NSArray<QiniuBucket *> *)instancesOfJSONString:(NSString *)json;
+ (NSArray<QiniuBucket *> *)instancesOfJSONStrings:(NSArray<NSString *> *)jsons;

@end
