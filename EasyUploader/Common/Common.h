//
//  Common.h
//  EasyUploader
//
//  Created by zhouyong on 17/7/27.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DD_LEGACY_MACROS    0

# pragma mark - System Library Include
#import <AssetsLibrary/AssetsLibrary.h>
#import <CommonCrypto/CommonCrypto.h>
#import <UIKit/UIKit.h>

# pragma mark - Pods Library Include
#import "AFNetworking.h"
#import "CocoaLumberjack.h"
#import "DDLogCustomFormatter.h"
#import "GTMBase64.h"
#import "Masonry.h"
#import <MJRefresh/MJRefresh.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

# pragma mark - Project
#import "AppDelegate.h"
#import "ZyxSingleton.h"
#import "ZyxCommonMacro.h"
#import "Macro.h"

#import "QiniuResourceManager.h"
#import "QiniuUploadManager.h"
#import "ZyxPhotoManager.h"


typedef NS_ENUM(NSUInteger, ZyxImagePickerSelectionMode) {
    ZyxImagePickerSelectionModeNone,
    ZyxImagePickerSelectionModeSingle,
    ZyxImagePickerSelectionModeMultiple,
};

//#import "BaseViewController.h"
#import "UIView+Frame.h"
#import "UINormalTableViewCell.h"
#import "ZyxPhotoCollectionViewCell.h"

# pragma mark - Utils Header File Include
#import "ALAssetUtil.h"
#import "LanguagTranslateUtil.h"
#import "DateUtil.h"
#import "DeviceUtil.h"
#import "StringUtil.h"

#import "QiniuUploadManager.h"
#import "QiniuDownloadManager.h"
#import "QiniuResourceManager.h"


