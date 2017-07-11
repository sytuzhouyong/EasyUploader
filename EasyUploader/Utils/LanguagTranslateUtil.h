//
//  LanguagTranslateUtil.h
//  XingHomecloud
//
//  Created by zhouyong on 15/11/30.
//  Copyright © 2015年 zhouyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LanguagTranslateUtil : NSObject

SINGLETON_DECLEAR;

// 获取当前语言
- (NSString *)preferredLanguage;
- (void)readLocalLanguageProfiles;

- (NSString *)stringForKey:(NSString *)key;
- (void)translateStringInView: (UIView *)view;

@end
