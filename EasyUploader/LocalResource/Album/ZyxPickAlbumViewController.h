//
//  ZyxPickAlbumViewController.h
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

@class ZyxPickAlbumViewController;


@protocol ZyxPickAlbumViewControllerDelegate <NSObject>

@optional
- (void)zyxImagePickrController:(ZyxPickAlbumViewController *)picker didFinishPickingMedioWithInfo:(NSDictionary *)info;
@optional
- (void)zyxImagePickrController:(ZyxPickAlbumViewController *)picker didFinishPickingMedioWithInfos:(NSArray<NSDictionary *> *)infos;

@end



@interface ZyxPickAlbumViewController : BaseViewController

@property (nonatomic, assign) ZyxImagePickerSelectionMode selectionMode;
@property (nonatomic, weak  ) id<ZyxPickAlbumViewControllerDelegate> imagePickerDelegate;

@end
