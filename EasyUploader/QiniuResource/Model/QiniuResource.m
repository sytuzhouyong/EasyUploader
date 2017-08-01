//
//  QiniuResource.m
//  EasyUploader
//
//  Created by zhouyong on 17/7/22.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "QiniuResource.h"

#define SetPropertyInDict(prop_name, key_name) \
    if (dict[key_name]) { \
        [resource setValue:dict[key_name] forKey:prop_name]; \
    }

@implementation QiniuResource


+ (instancetype)resourceWithDict:(NSDictionary *)dict {
    QiniuResource *resource = [[QiniuResource alloc] init];

    SetPropertyInDict(@"name", @"key");
    SetPropertyInDict(@"hashString", @"hash");
    SetPropertyInDict(@"mimeType", @"mimeType");
    SetPropertyInDict(@"size", @"fsize");

    if (dict[@"putTime"]) {
        unsigned long long timestamp = [dict[@"putTime"] unsignedLongLongValue];
        timestamp = timestamp / 10000000;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
        resource.createTimeDesc = [DateUtil defaultStringWithDate:date];
        resource.createTime = date;
    }

    resource.sizeDesc = [StringUtil descriptionOfSpace:resource.size];
    return resource;
}

+ (NSArray<QiniuResource *> *)resourcesWithDicts:(NSArray<NSDictionary *> *)dicts {
    NSMutableArray *resources = [NSMutableArray array];
    for (NSDictionary *dict in dicts) {
        QiniuResource *resource = [self.class resourceWithDict:dict];
        [resources addObject:resource];
    }
    return resources;
}


@end
