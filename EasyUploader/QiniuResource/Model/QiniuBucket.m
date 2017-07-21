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



@end
