//
//  StringUtil.h
//  XingHomecloud
//
//  Created by zhouyong on 15/12/3.
//  Copyright © 2015年 zhouyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StringUtil : NSObject

+ (NSString *)jsonStringFromObject:(id)object options:(NSJSONWritingOptions)options;
+ (NSString *)jsonStringFromObject:(id)object;
+ (NSDictionary *)dictFromJsonString:(NSString *)jsonString;

+ (NSString *)documentsPath;
// 缓存目录
+ (NSString *)cachePath;
+ (NSString *)videoCachePath;
+ (NSString *)photoCachePath;
+ (NSString *)tempPath;

+ (NSString *)deviceName;

+ (NSString *)descriptionOfSpace:(UInt64)space;
+ (NSString *)descriptionOfSpeed:(UInt64)speed;

// 128 AES CBC NoPadding
//+ (NSString *)AES128Encrypt:(NSString *)plainText;
+ (NSString *)md5:(NSString *)string;

+ (NSString *)toUnicode:(NSString *)plainText;

@end
