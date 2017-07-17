//
//  QiniuResourceManager.m
//  EasyUploader
//
//  Created by zhouyong on 17/7/17.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "QiniuResourceManager.h"

#define kHttpManager    [AFHTTPSessionManager manager]

@implementation QiniuResourceManager

+ (void)queryResourcesWithPrefix:(NSString *)prefix limit:(int)limit offset:(int)offset {
    NSString *url = [NSString stringWithFormat:@"%@/list", kQiniuResourceHost];
    NSDictionary *parma = @{@"bucket": kBucket,
                            @"marker": @(offset),
                            @"limit": @(limit),
                            @"prefix": prefix,
                            @"delimiter": @""
                            };
    [kHttpManager POST:url parameters:parma constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        ;
    } progress:^(NSProgress * _Nonnull uploadProgress) {

    } success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        NSLog(@"response = %@", responseObject);

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@", error);
    }];
}

@end
