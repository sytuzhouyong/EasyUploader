//
//  QiniuResourceManager.h
//  EasyUploader
//
//  Created by zhouyong on 17/7/17.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QiniuResourceManager : NSObject

//SINGLETON_DECLEAR;

+ (void)queryResourcesWithPrefix:(NSString *)prefix limit:(int)limit;
+ (NSString *)authRequestPath:(NSString *)url andBody:(NSString *)body;

@end
