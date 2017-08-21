//
//  QiniuResource.h
//  EasyUploader
//
//  Created by zhouyong on 17/7/22.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, QiniuResourceType) {
    QiniuResourceTypeDir,
    QiniuResourceTypeFile,
};


@interface QiniuResource : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *hashString;
@property (nonatomic, copy) NSString *mimeType;
@property (nonatomic, strong) NSDate *createTime;
@property (nonatomic, copy) NSString *createTimeDesc;
@property (nonatomic, assign) NSInteger size;
@property (nonatomic, copy) NSString *sizeDesc;
@property (nonatomic, assign) QiniuResourceType type;

+ (instancetype)resourceWithDict:(NSDictionary *)dict;
+ (NSArray<QiniuResource *> *)resourcesWithDict:(NSDictionary *)dict;

@end
