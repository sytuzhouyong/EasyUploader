//
//  ALAssetUtil.m
//  EasyUploader
//
//  Created by zhouyong on 17/7/15.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "ALAssetUtil.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "DateUtil.h"

@implementation ALAssetUtil

+ (NSString *)dateStringOfALAsset:(ALAsset *)asset withFormat:(NSString *)format {
    NSDate *date = [asset valueForProperty:ALAssetPropertyDate];
    NSDateFormatter *formatter = [DateUtil sharedDateFormatter];
    formatter.dateFormat = format;
    return [formatter stringFromDate:date];
}

+ (NSString *)defaultDateStringOfALAsset:(ALAsset *)asset {
    NSDate *date = [asset valueForProperty:ALAssetPropertyDate];
    NSString *format = [DateUtil defaultUnderlineStringWithDate:date];
    NSDateFormatter *formatter = [DateUtil sharedDateFormatter];
    formatter.dateFormat = format;
    return [formatter stringFromDate:date];
}

+ (NSString *)millisecondDateStringOfALAsset:(ALAsset *)asset {
    NSDate *date = [asset valueForProperty:ALAssetPropertyDate];
    NSString *format = [DateUtil millisecondPreciseUnderlineStringWithDate:date];
    NSDateFormatter *formatter = [DateUtil sharedDateFormatter];
    formatter.dateFormat = format;
    return [formatter stringFromDate:date];
}

+ (NSString *)extOfAsset:(ALAsset *)asset {
    NSURL *url = (NSURL *)[asset valueForProperty:ALAssetPropertyAssetURL];
    NSString *string = url.absoluteString;
    NSArray<NSString *> *items = [string componentsSeparatedByString:@"&"];
    for (NSString *item in items) {
        if ([item hasPrefix:@"ext="]) {
            return [item substringFromIndex:@"ext=".length];
        }
    }
    return @"";
}

+ (id)valueOfALAsset:(ALAsset *)asset withKey:(NSString *)key {
    return [asset valueForProperty:key];
}

@end
