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

+ (NSString *)primaryKey {
    return @"hashString";
}

+ (instancetype)resourceWithDict:(NSDictionary *)dict {
    QiniuResource *resource = [[QiniuResource alloc] init];
    resource.type = QiniuResourceTypeFile;

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

+ (instancetype)resourceWithDirName:(NSString *)dir {
    QiniuResource *resource = [[QiniuResource alloc] init];
    resource.name = [dir substringToIndex:dir.length - 1];
    resource.type = QiniuResourceTypeDir;
    return resource;
}

+ (NSArray<QiniuResource *> *)resourcesWithDict:(NSDictionary *)dict {
    NSMutableArray *resources = [NSMutableArray array];

    // 目录
    NSArray *dirs = dict[@"commonPrefixes"];
    if (dirs) {
        for (NSString *dir in dirs) {
            QiniuResource *resource = [QiniuResource resourceWithDirName:dir];
            [resources addObject:resource];
        }
    }

    // 文件
    NSArray *files = dict[@"items"];
    for (NSDictionary *dict in files) {
        QiniuResource *resource = [self.class resourceWithDict:dict];
        [resources addObject:resource];
    }
    return resources;
}


@end
