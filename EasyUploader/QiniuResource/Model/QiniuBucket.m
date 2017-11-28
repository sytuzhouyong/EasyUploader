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
//        self.ID = [self autoIncreaseID];
        self.domainURL = @"";
    }
    return self;
}

- (NSInteger)autoIncreaseID {
    NSInteger index = [self.class allObjects].count + 1;
    NSLog(@"index = %lu", index);
    return index;
}

//+ (NSString *)primaryKey {
//    return @"ID";
//}

+ (instancetype)bucketWithJSONString:(NSString *)json {
    QiniuBucket *bucket = [[QiniuBucket alloc] initWithName:json];
    return bucket;
}

+ (NSArray<QiniuBucket *> *)instancesWithJSONString:(NSString *)json {
    NSMutableArray<QiniuBucket *> *buckets = [NSMutableArray array];

    NSArray<NSString *> *bucketsString = (NSArray<NSString *> *)[StringUtil objectFromJsonString:json];
    for (NSString *json in bucketsString) {
        QiniuBucket *bucket = [QiniuBucket bucketWithJSONString:json];
        [buckets addObject:bucket];
    }

    return buckets;
}

+ (NSArray<QiniuBucket *> *)instancesWithJSONStrings:(NSArray<NSString *> *)jsons {
    NSMutableArray<QiniuBucket *> *buckets = [NSMutableArray array];

    for (NSString *json in jsons) {
        QiniuBucket *bucket = [QiniuBucket bucketWithJSONString:json];
        [buckets addObject:bucket];
    }

    return buckets;
}

@end
