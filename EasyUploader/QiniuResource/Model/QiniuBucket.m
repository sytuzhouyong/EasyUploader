//
//  QiniuBucket.m
//  EasyUploader
//
//  Created by zhouyong on 17/7/22.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "QiniuBucket.h"

@implementation QiniuBucket

- (id)initWithName:(NSString *)name {
    if (self = [super init]) {
        self.name = name;
    }
    return self;
}

+ (NSArray<QiniuBucket *> *)instancesOfJSONString:(NSString *)json {
    NSMutableArray<QiniuBucket *> *buckets = [NSMutableArray array];

    NSArray<NSString *> *bucketsString = (NSArray<NSString *> *)[StringUtil objectFromJsonString:json];
    for (NSString *name in bucketsString) {
        QiniuBucket *bucket = [[QiniuBucket alloc] initWithName:name];
        [buckets addObject:bucket];
    }

    return buckets;
}

@end
