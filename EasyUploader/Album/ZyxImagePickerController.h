//
//  ZyxImagePickerController.h
//  TestReadImage
//
//  Created by zhouyong on 12/25/15.
//  Copyright © 2015 zhouyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

typedef NS_ENUM(NSUInteger, ZyxImagePickerSelectionMode) {
    ZyxImagePickerSelectionModeNone,
    ZyxImagePickerSelectionModeSingle,
    ZyxImagePickerSelectionModeMultiple,
};

@class ZyxImagePickerController;


@protocol ZyxImagePickerControllerDelegate <NSObject>

@optional
- (void)zyxImagePickrController:(ZyxImagePickerController *)picker didFinishPickingMedioWithInfo:(NSDictionary *)info;
@optional
- (void)zyxImagePickrController:(ZyxImagePickerController *)picker didFinishPickingMedioWithInfos:(NSArray<NSDictionary *> *)infos;

@end



@interface ZyxImagePickerController : BaseViewController

@property (nonatomic, assign) ZyxImagePickerSelectionMode selectionMode;
@property (nonatomic, weak  ) id<ZyxImagePickerControllerDelegate> imagePickerDelegate;

@end
