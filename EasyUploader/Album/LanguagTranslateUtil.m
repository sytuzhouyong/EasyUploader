//
//  LanguagTranslateUtil.m
//  XingHomecloud
//
//  Created by zhouyong on 15/11/30.
//  Copyright © 2015年 zhouyong. All rights reserved.
//

#import "LanguagTranslateUtil.h"

#define kFormatStringJoiner         @" ## "
#define kParamStringPlaceholder     @"%s"
#define kPrefixString               @"XHC_"
#define kParamStringJoiner          @", "

@interface LanguagTranslateUtil ()

@property (nonatomic, strong) NSDictionary *dict;

@end

@implementation LanguagTranslateUtil

SINGLETON_IMPLEMENTATION(LanguagTranslateUtil);

- (NSString *)preferredLanguage {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *allLanguages = [defaults objectForKey:@"AppleLanguages"];
    NSString *preferredLanguage = allLanguages.firstObject;
    return preferredLanguage;
}

- (void)readLocalLanguageProfiles {
    NSBundle *bundle = [NSBundle mainBundle];
    
    NSString *plistFilePath = nil;
    NSString *language = [self preferredLanguage];
    if ([language rangeOfString:@"zh-Hans"].location != NSNotFound) {
        plistFilePath = [bundle pathForResource:@"zh-Hans" ofType:@"plist"];
    } else {
        plistFilePath = [bundle pathForResource:@"en" ofType:@"plist"];
    }
    
    DDLogVerbose(@"当前系统语言： %@", language);
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:plistFilePath];
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *string, BOOL *stop) {
        NSString *parsedString = [self parseString:string inDictionary:resultDict];
        resultDict[key] = parsedString;
    }];
    self.dict = resultDict;
}

- (NSString *)parseString:(NSString *)string inDictionary:(NSMutableDictionary *)dict {
    if ([string rangeOfString:kFormatStringJoiner].location == NSNotFound) {
        return string;
    }
    
    NSArray *strings = [string componentsSeparatedByString:kFormatStringJoiner];
    NSString *formatString = strings.firstObject;
    NSString *keyString = strings.lastObject;
    NSScanner *formatScanner = [NSScanner scannerWithString:formatString];
    NSScanner *keyScanner = [NSScanner scannerWithString:keyString];
    formatScanner.charactersToBeSkipped = nil;
    NSMutableString *finalString = [NSMutableString string];
    
    while (![keyScanner isAtEnd]) {
        NSString *keyName = nil;
        if (![keyScanner scanUpToString:kParamStringJoiner intoString:&keyName]) {
            DDLogWarn(@"oh no, scan key[%@] in key string[%@] at postion[%@] failed!", kParamStringJoiner, keyName, @(keyScanner.scanLocation));
            break;
        }
        [keyScanner scanString:kParamStringJoiner intoString:nil];
        
        NSString *normalString = nil;
        if (![formatScanner scanUpToString:kParamStringPlaceholder intoString:&normalString]) {
            // 说明字符串以 %s 开头
            if ([formatScanner scanString:kParamStringPlaceholder intoString:nil]) {
                NSString *value = [self recursiveParseKey:keyName inDictionary:dict];
                [finalString appendString:value];
            } else {
                DDLogWarn(@"oh no, format string[%@] error!", formatString);
                break;
            }
        } else {
            [finalString appendString:normalString];
            if (![formatScanner scanString:kParamStringPlaceholder intoString:nil]) {
                DDLogWarn(@"oh no, format string[%@] error at location[%@], [%@] expected", formatString, @(formatScanner.scanLocation), kParamStringPlaceholder);
                break;
            } else {
                NSString *value = [self recursiveParseKey:keyName inDictionary:dict];
                [finalString appendString:value];
            }
        }
    }
    
    if (![formatScanner isAtEnd]) {
        NSString *leftString = [formatString substringFromIndex:formatScanner.scanLocation];
        [finalString appendString:leftString];
    }
    return finalString;
}

// 递归解析key对应的value，直到参数全部解析完成为止
- (NSString *)recursiveParseKey:(NSString *)key inDictionary:(NSMutableDictionary *)dict {
    NSString *value = dict[key];
    if (value.length == 0) {
        DDLogWarn(@"oh no, key[%@] not existed!", key);
        return @"";
    }
    
    NSString *newValue = [value copy];
    while (YES) {
        if ([newValue rangeOfString:kFormatStringJoiner].location != NSNotFound) {
            newValue = [self parseString:value inDictionary:dict];
        } else {
            if (![value isEqualToString:newValue]) {
                dict[key] = newValue;
            }
            break;
        }
    }
    return newValue;
}

- (NSString *)stringForKey:(NSString *)key {
    NSString *value = self.dict[key];
    if (value == nil) {
        DDLogWarn(@"oh no, key[%@] is not existed!", key);
    }
    return value == nil ? @"" : value;
}

- (void)translateStringInView: (UIView *)view {
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:UILabel.class]) {
            UILabel *label = (UILabel *)subview;
            NSString *key = label.text;
            if (key.length > 0 && [self isNeedTranslateForKey:key]) {
                label.text = [self stringForKey:[self translateForKey:key]];
            }
            continue;
        }
        if ([subview isKindOfClass:UIButton.class]) {
            UIButton *button = (UIButton *)subview;
            NSString *key1 = [button titleForState:UIControlStateNormal];
            NSString *key2 = [button titleForState:UIControlStateHighlighted];
            NSString *key3 = [button titleForState:UIControlStateSelected];
            NSString *key4 = [button titleForState:UIControlStateDisabled];
            if (key1.length > 0 && [self isNeedTranslateForKey:key1]) {
                [button setTitle:[self stringForKey:[self translateForKey:key1]] forState:UIControlStateNormal];
            }
            if (key2.length > 0 && [self isNeedTranslateForKey:key2]) {
                [button setTitle:[self stringForKey:[self translateForKey:key2]] forState:UIControlStateHighlighted];
            }
            if (key3.length > 0 && [self isNeedTranslateForKey:key3]) {
                [button setTitle:[self stringForKey:[self translateForKey:key3]] forState:UIControlStateSelected];
            }
            if (key4.length > 0 && [self isNeedTranslateForKey:key4]) {
                [button setTitle:[self stringForKey:[self translateForKey:key4]] forState:UIControlStateDisabled];
            }
            continue;
        }
        if ([subview isKindOfClass:UITextField.class]) {
            UITextField *textfield = (UITextField *)subview;
            NSString *key1 = textfield.text;
            NSString *key2 = textfield.placeholder;
            if (key1.length > 0 && [self isNeedTranslateForKey:key1]) {
                textfield.text = [self stringForKey:[self translateForKey:key1]];
            }
            if (key2.length > 0 && [self isNeedTranslateForKey:key2]) {
                textfield.placeholder = [self stringForKey:[self translateForKey:key2]];
            }
            continue;
        }
        if ([subview isKindOfClass:UIBarItem.class]) {
            UIBarItem *bar = (UIBarItem *)subview;
            NSString *key = bar.title;
            if (key.length > 0 && [self isNeedTranslateForKey:key]) {
                bar.title = [self stringForKey:[self translateForKey:key]];
            }
            continue;
        }
        
        if (subview.subviews.count > 0) {
            [self translateStringInView:subview];
        }
    }
}

- (BOOL)isNeedTranslateForKey:(NSString *)key {
    return [key hasPrefix:kPrefixString];
}

- (NSString *)translateForKey:(NSString *)key {
    if ([self isNeedTranslateForKey:key]) {
        return [key substringFromIndex:kPrefixString.length];
    } else {
        return key;
    }
}

@end
