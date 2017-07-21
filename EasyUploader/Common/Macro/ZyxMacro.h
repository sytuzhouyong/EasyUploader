//
//  ZyxMacro.h
//  EasyUploader
//
//  Created by zhouyong on 17/3/21.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#ifndef ZyxMacro_h
#define ZyxMacro_h

#pragma mark - 常用对象宏

#define kApplication            [UIApplication sharedApplication]
#define kAppDelegate            ((AppDelegate *)[kApplication delegate])
#define kAddressBook            kAppDelegate.addressBookRef
#define kNotificationCenter     [NSNotificationCenter defaultCenter]
#define kKeyWindow              kApplication.keyWindow
#define kUserDefaults           [NSUserDefaults standardUserDefaults]
#define kWeakself               __weak __typeof(&*self) weakself = self


#pragma mark - 简便函数宏

#define RGBA(r,g,b,a)               [UIColor colorWithRed:r/255. green:g/255. blue:b/255. alpha:a]
#define RGB(r,g,b)                  RGBA(r,g,b,1.0)
#define GrayColor(_c)               RGB(_c,_c,_c)
#define GrayColorA(_c, _a)          RGBA(_c,_c,_c,_a)
#define CGPoint(_x, _y)             CGPointMake(_x, _y)
#define CGSize(_w, _h)              CGSizeMake(_w, _h)
#define CGSizeE(_s)                 CGSizeMake(_s, _s)
#define CGRect(__x,__y,__w,__h)     CGRectMake(__x, __y, __w, __h)
#define UIEdgeInsets(_t,_l,_b,_r)   UIEdgeInsetsMake(_t, _l, _b, _r)
#define NSIndexPath(section, row)   [NSIndexPath indexPathForRow:row inSection:section]

#define IS_IOS7_OR_LATER            ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0 ? YES : NO)
#define IS_IOS9_OR_LATER            ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0 ? YES : NO)
#define SafeString(_s)              (_s != nil ? _s : @"")
#define ReturnObjectIfNotNil(_o)    if (_o != nil) { return _o; }
#define ReturnIfBlockIsNil(_b)      if (_b == nil) { return; }
#define ReturnIfArrayIsEmpty(_a)    if (_a.count == 0) { return; }

#define UIImageNamed(_n)            [UIImage imageNamed:_n]
#define UIFontOfSize(_s)            [UIFont systemFontOfSize:_s]
#define Text(_k)                    [kTranslateUtil stringForKey:_k]
#define InfoPlistValueForKey(_k)    [[NSBundle mainBundle] infoDictionary][_k]
#define kAppVersion                 InfoPlistValueForKey(@"CFBundleVersion")
#define kDeviceId                   [DeviceUtil deviceUniqueId]

#define ExecuteBlockIfNotNil(_b)                    !_b ?: _b()
#define ExecuteBlock1IfNotNil(_b, _v1)              !_b ?: _b(_v1)
#define ExecuteBlock2IfNotNil(_b, _v1, _v2)         !_b ?: _b(_v1, _v2)
#define ExecuteBlock3IfNotNil(_b, _v1, _v2, _v3)    !_b ?: _b(_v1, _v2,_v3)

#define CODETICK   NSDate *startTime = [NSDate date];
#define CODETOCK   NSLog(@"Time Interval: %f", -[startTime timeIntervalSinceNow]);

#define ImageNameOfSelectedState(_s) \
_s ? @"icon_round_selected_blue" : @"icon_round_unselected_gray"
#define AddButtonEvent(_b, _e)  \
    [_b addTarget:self action:NSSelectorFromString(_e) forControlEvents:UIControlEventTouchUpInside]
#define AddButtonEventTarget(_t, _b, _e) \
    [_b addTarget:_t action:NSSelectorFromString(_e) forControlEvents:UIControlEventTouchUpInside]
#define RemoveButtonEvent(_b, _e)\
    [_b removeTarget:self action:NSSelectorFromString(_e) forControlEvents:UIControlEventTouchUpInside]
#define SetButtonImage(_b, _n) \
    [_b setImage:UIImageNamed(_n) forState:UIControlStateNormal]; \
    [_b setImage:UIImageNamed(_n@"_pressed") forState:UIControlStateHighlighted]

#pragma mark - 简便取值宏

#define kWindowFrame                        [[UIScreen mainScreen] bounds]
#define kWindwoSize                         kWindowFrame.size
#define kWindowWidth                        kWindwoSize.width
#define kWindowHeight                       kWindwoSize.height
// UI按照375 x 667 切的图，在除了3.5英寸屏幕的其他分辨率下要等比缩放
#define kUIScale                            kWindowHeight / 667.0f
#define kNavigationBarColor                 RGB(0x18, 0x5C, 0xC1)
#define kStatusBarHeight                    20
#define kTitleContentViewHeight             44
#define kBaseViewControllerTitleViewHeight  64
#define kNavigationBarFontSize              15
#define kFullDateFormat                     @"EEE, d MMM yyyy HH:mm:ss zzz"
#define kFileTitleDateFormat                @"yyyy_MM_dd_HH:mm:ss"
#define kBundleIdentifier                   @"com.zhouyong.XingHomecloud"
#define kFunctionTip                        Text(@"ThisFunctionIsUnderDevelopment,it'sComingSoon")
#define kOperateTimeout                     60   //文件操作的超时时间


#pragma mark - 简便类型宏

typedef void (^ConstraintBlock)(MASConstraintMaker *maker);
#define DeviceArray             NSArray<HC100Device *>
#define DeviceMutableArray      NSMutableArray<HC100Device *>
#define NSStringArray           NSArray<NSString *>
#define NSStringMutableArray    NSMutableArray<NSString *>
#define NSStringDictionary      NSDictionary<NSString *, NSString *>


#pragma mark - CocoaLog

#ifdef LOG_LEVEL_DEF
#   undef LOG_LEVEL_DEF
#endif
#define LOG_LEVEL_DEF [DDDynamicLogLevel ddLogLevel]

//#if DEBUG
//    static const DDLogLevel ddLogLevel = DDLogLevelError;
//#else
//    static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
//#endif

#define DDLogErrorTag(tag, frmt, ...)   LOG_MAYBE(NO,                LOG_LEVEL_DEF, DDLogFlagError,   0, tag, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogWarnTag(tag, frmt, ...)    LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagWarning, 0, tag, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogInfoTag(tag, frmt, ...)    LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagInfo,    0, tag, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogDebugTag(tag, frmt, ...)   LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagDebug,   0, tag, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogVerboseTag(tag, frmt, ...) LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagVerbose, 0, tag, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)


#pragma mark - 项目相关宏

#define kAccessKey              @"ebgn6Ab9Zk8mtWxycGT9ww2GHB3HI5-FTeXGTJTe"
#define kSecretKey              @"aqF2ARHxYqekMsxyutZOgahXb_PdVmLeDHfNKh-0"
#define kPhotoManager           [ZyxPhotoManager sharedInstance]
#define kTranslateUtil          [LanguagTranslateUtil sharedInstance]
#define kKeychainUtil           [KeychainUtil sharedInstance]
#define kQiniuResourceManager   [QiniuResourceManager sharedInstance]
#define kBucket                 @"easy-uploader"
#define kQiniuResourceHost      @"http://rsf.qbox.me"


#endif /* ZyxMacro_h */
