//
//  QiniuResourceManager.h
//  EasyUploader
//
//  Created by zhouyong on 17/7/17.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QiniuBucket.h"
#import "QiniuResource.h"

@interface QiniuResourceManager : NSObject

//SINGLETON_DECLEAR;

typedef void (^BucketsHandler)(NSArray<QiniuBucket *> *buckets);
typedef void (^ResourcesHandler)(NSArray<QiniuResource *> *resources);


+ (void)queryAllBucketsWithHandler:(BucketsHandler)handler;
+ (void)queryResourcesInBucket:(NSString *)bucket withPrefix:(NSString *)prefix limit:(int)limit handler:(ResourcesHandler)handler;

+ (NSString *)authRequestPath:(NSString *)url andBody:(NSString *)body;

@end
