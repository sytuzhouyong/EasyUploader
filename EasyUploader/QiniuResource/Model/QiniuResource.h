//
//  QiniuResource.h
//  EasyUploader
//
//  Created by zhouyong on 17/7/22.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, QiniuResourceType) {
    QiniuResourceTypeDir    = 0x01,
    QiniuResourceTypeFile   = 0x02,
    QiniuResourceTypeAll    = 0x03,
};


@interface QiniuResource : RLMObject

@property NSString *name;
@property NSString *hashString;
@property NSString *mimeType;
@property NSDate *createTime;
@property NSString *createTimeDesc;
@property NSInteger size;
@property NSString *sizeDesc;
@property QiniuResourceType type;
@property QiniuBucket *bucket;

+ (instancetype)resourceWithDict:(NSDictionary *)dict;
+ (NSArray<QiniuResource *> *)resourcesWithDict:(NSDictionary *)dict;

@end
