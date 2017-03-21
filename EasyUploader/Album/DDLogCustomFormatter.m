//
//  DDLogCustomFormatter.m
//  DDLogCustomFormatter
//
//  Created by zhouyong on 15/11/20.
//  Copyright © 2015年 sytuzhouyong. All rights reserved.
//

#import "DDLogCustomFormatter.h"

@implementation DDLogCustomFormatter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    NSString *logLevel;
    switch (logMessage->_flag) {
        case DDLogFlagError    : logLevel = @"E"; break;
        case DDLogFlagWarning  : logLevel = @"W"; break;
        case DDLogFlagInfo     : logLevel = @"I"; break;
        case DDLogFlagDebug    : logLevel = @"D"; break;
        default                : logLevel = @"V"; break;
    }
    
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy/MM/dd HH:mm:ss.SSS zzz";
    });
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    if (logMessage.tag != nil) {
        return [NSString stringWithFormat:@"%@ | %@ | %@ | %@ | %@ | %@ |\n  | %@", logMessage.tag, logLevel, dateString, logMessage.fileName, logMessage.function, @(logMessage.line), logMessage.message];
    } else {
        return [NSString stringWithFormat:@"%@ | %@ | %@ | %@ | %@ |\n  | %@", logLevel, dateString, logMessage.fileName, logMessage.function, @(logMessage.line), logMessage.message];
    }
}

@end


@implementation DDDynamicLogLevel

static DDLogLevel s_ddLogLevel = DDLogLevelVerbose;

+ (DDLogLevel)ddLogLevel {
    return s_ddLogLevel;
}

+ (void)ddSetLogLevel:(DDLogLevel)level {
    s_ddLogLevel = level;
}

@end
