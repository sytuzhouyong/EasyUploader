//
//  DateUtil.h
//  XingHomecloud
//
//  Created by zhouyong on 12/28/15.
//  Copyright © 2015 zhouyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateUtil : NSObject

+ (NSDateFormatter *)sharedDateFormatter;

+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)format;
+ (NSString *)defaultStringWithDate:(NSDate *)date;
+ (NSString *)defaultUnderlineStringWithDate:(NSDate *)date;
+ (NSString *)yyyyMMddStringWithDate:(NSDate *)date;
+ (NSString *)MMddStringWithDate:(NSDate *)date;
+ (NSString *)intelligentDateStringWithDate:(NSDate *)date;
+ (NSString *)intelligentTimeStringWithDate:(NSDate *)date;

+ (NSDate *)dateFromString:(NSString *)string format:(NSString *)format;

@end
