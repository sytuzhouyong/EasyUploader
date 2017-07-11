//
//  DateUtil.m
//  XingHomecloud
//
//  Created by zhouyong on 12/28/15.
//  Copyright © 2015 zhouyong. All rights reserved.
//

#import "DateUtil.h"

@implementation DateUtil

+ (NSDateFormatter *)sharedDateFormatter {
    static NSDateFormatter *formatter = nil;
    if (formatter != nil) {
        return formatter;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [NSLocale currentLocale];
    });
    return formatter;
}

+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)format {
    NSDateFormatter *formatter = [DateUtil sharedDateFormatter];
    formatter.dateFormat = format;
    return [formatter stringFromDate:date];
}

+ (NSDate *)dateFromString:(NSString *)string format:(NSString *)format {
    NSDateFormatter *formatter = [DateUtil sharedDateFormatter];
    formatter.dateFormat = format;
    return [formatter dateFromString:string];
}

+ (NSDictionary<NSString *, NSDate *> *)dateDictionary {
    NSDate *now = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:now];
    
    [components setHour:-components.hour];
    [components setMinute:-components.minute];
    [components setSecond:-components.second];
    // today 00:00:00
    NSDate *today = [cal dateByAddingComponents:components toDate:now options:0];
    
    [components setHour:-24];
    [components setMinute:0];
    [components setSecond:0];
    // yesterday 00:00:00
    NSDate *yesterday = [cal dateByAddingComponents:components toDate:today options:0];
    
    // day before yesterday
    [components setHour:-24];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *dayBeforeYesterday = [cal dateByAddingComponents:components toDate:yesterday options:0];
    
    // date in this year
    components = [cal components:NSWeekdayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:now];
    // this week
    [components setDay:([components day] - ([components weekday] - 1))];
    NSDate *thisWeek  = [cal dateFromComponents:components];
    // last week
    [components setDay:([components day] - 7)];
    NSDate *lastWeek  = [cal dateFromComponents:components];
    // this month
    [components setDay:([components day] - ([components day] -1))];
    NSDate *thisMonth = [cal dateFromComponents:components];
    // last month
    [components setMonth:([components month] - 1)];
    NSDate *lastMonth = [cal dateFromComponents:components];
    
    // start of this year
    components = [cal components:NSYearCalendarUnit fromDate:now];
    [components setYear:components.year];
    NSDate *thisYear = [cal dateFromComponents:components];
    
    // start of last year
    [components setYear:components.year-1];
    NSDate *lastYear = [cal dateFromComponents:components];
    
    return @{@"today": today,
             @"yesterday": yesterday,
             @"day_before_yesterday": dayBeforeYesterday,
             @"this_week": thisWeek,
             @"last_week": lastWeek,
             @"this_month": thisMonth,
             @"last_month": lastMonth,
             @"this_year": thisYear,
             @"last_year": lastYear,
             };
}

+ (NSString *)defaultStringWithDate:(NSDate *)date {
    return [self stringFromDate:date format:@"yyyy-MM-dd HH:mm:ss"];
}

+ (NSString *)yyyyMMddStringWithDate:(NSDate *)date {
    // 效率低
//    static NSString *format = nil;
//    if (format.length == 0) {
//        NSString *language = [[kTranslateUtil preferredLanguage] lowercaseString];
//        if ([language rangeOfString:@"zh-han"].location != NSNotFound) {
//            format = @"yyyy年MM月dd日";
//        } else {
//            format = @"yyyy-MM-dd";
//        }
//    }
//    return [self stringFromDate:date format:format];

    time_t timep = [date timeIntervalSince1970];
//    time_t timep;
//    time(&timep);
    struct tm *ptm = localtime(&timep);
    return [NSString stringWithFormat:@"%04d-%02d-%02d", ptm->tm_year+1900, ptm->tm_mon+1, ptm->tm_mday];
}

+ (NSString *)MMddStringWithDate:(NSDate *)date {
    NSString *format = @"MM-dd";
    NSString *language = [[kTranslateUtil preferredLanguage] lowercaseString];
    if ([language rangeOfString:@"zh-han"].location != NSNotFound) {
        format = @"MM月dd日";
    }
    return [self stringFromDate:date format:format];
}

+ (NSString *)intelligentDateStringWithDate:(NSDate *)date {
    if (date == nil) {
        return @"无";
    }
    
    NSDictionary<NSString *, NSDate *> *dateDict = [self dateDictionary];
    NSDate *today = dateDict[@"today"];
    
    // 说明是今天
    if ([date compare:today] != NSOrderedAscending) {
        return Text(@"Today");
    }
    NSDate *yesterday = dateDict[@"yesterday"];
    if ([date compare:yesterday] != NSOrderedAscending) {
        return Text(@"Yesterday");
    }
    NSDate *dayBeforeYesterday = dateDict[@"day_before_yesterday"];
    if ([date compare:dayBeforeYesterday] != NSOrderedAscending) {
        return Text(@"DayBeforeYesterday");
    }
    NSDate *thisYear = dateDict[@"this_year"];
    if ([date compare:thisYear] != NSOrderedAscending) {
        return [self MMddStringWithDate:date];
    }
    return [self yyyyMMddStringWithDate:date];
}

+ (NSString *)intelligentTimeStringWithDate:(NSDate *)date {
    if (date == nil) {
        return @"无";
    }
    
    NSDictionary<NSString *, NSDate *> *dateDict = [self dateDictionary];
    NSDate *today = dateDict[@"today"];
    
    NSString *timeString = [self stringFromDate:date format:@"HH:mm:ss"];
    
    // 说明是今天
    if ([date compare:today] != NSOrderedAscending) {
        return [NSString stringWithFormat:@"%@ %@", Text(@"Today"), timeString];
    }
    
    NSDate *yesterday = dateDict[@"yesterday"];
    if ([date compare:yesterday] != NSOrderedAscending) {
        NSString *timeString = [self stringFromDate:date format:@"HH:mm:ss"];
        return [NSString stringWithFormat:@"%@ %@", Text(@"Yesterday"), timeString];
    }
    
    NSDate *dayBeforeYesterday = dateDict[@"day_before_yesterday"];
    if ([date compare:dayBeforeYesterday] != NSOrderedAscending) {
        return [NSString stringWithFormat:@"%@ %@", Text(@"DayBeforeYesterday"), timeString];
    }
    
    NSDate *thisYear = dateDict[@"this_year"];
    if ([date compare:thisYear] != NSOrderedAscending) {
        return [self MMddStringWithDate:date];
    }
    
    return [self yyyyMMddStringWithDate:date];
}

@end
