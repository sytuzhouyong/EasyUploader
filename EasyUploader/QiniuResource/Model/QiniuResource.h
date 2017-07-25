//
//  QiniuResource.h
//  EasyUploader
//
//  Created by zhouyong on 17/7/22.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QiniuResource : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *hashString;
@property (nonatomic, copy) NSString *mimeType;
@property (nonatomic, assign) NSTimeInterval createTime;
@property (nonatomic, assign) NSInteger size;

+ (instancetype)resourceWithDict:(NSDictionary *)dict;
+ (NSArray<QiniuResource *> *)resourcesWithDicts:(NSArray<NSDictionary *> *)dicts;

@end
