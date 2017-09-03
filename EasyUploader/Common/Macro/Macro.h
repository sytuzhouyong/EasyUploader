//
//  Macro.h
//  EasyUploader
//
//  Created by zhouyong on 17/7/26.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#ifndef Macro_h
#define Macro_h

#pragma mark - 项目相关宏

#define kAccessKey                  @"ebgn6Ab9Zk8mtWxycGT9ww2GHB3HI5-FTeXGTJTe"
#define kSecretKey                  @"aqF2ARHxYqekMsxyutZOgahXb_PdVmLeDHfNKh-0"

#define kQiniuResourceHost          @"rsf.qbox.me"
#define kQiniuAPIHost               @"api.qiniu.com"

#define kQiniuResourceDownloadURL   @"http://onzw106di.bkt.clouddn.com"

#define kQiniuResourceManager       [QiniuResourceManager sharedInstance]
#define kQiniuDownloadManager       [QiniuDownloadManager sharedInstance]
#define kQiniuUploadManager         [QiniuUploadManager sharedInstance]

#define kQiniuPathDelimiter          @"/"

typedef void (^ButtonHandler) (UIButton *button);

typedef NS_ENUM(NSUInteger, ZyxImagePickerSelectionMode) {
    ZyxImagePickerSelectionModeNone,
    ZyxImagePickerSelectionModeSingle,
    ZyxImagePickerSelectionModeMultiple,
};

#endif /* Macro_h */
