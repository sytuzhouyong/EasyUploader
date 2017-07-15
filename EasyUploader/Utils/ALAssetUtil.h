//
//  ALAssetUtil.h
//  EasyUploader
//
//  Created by zhouyong on 17/7/15.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALAssetUtil : NSObject

+ (NSString *)dateStringOfALAsset:(ALAsset *)asset withFormat:(NSString *)format;
+ (NSString *)defaultDateStringOfALAsset:(ALAsset *)asset;

@end
