//
//  ZyxPhotosViewController.h
//  XingHomecloud
//
//  Created by zhouyong on 12/28/15.
//  Copyright © 2015 zhouyong. All rights reserved.
//

#import "BaseViewController.h"
#import "ZyxImagePickerController.h"

@class ALAssetsGroup;

@protocol ZyxSelectPhotoDelegate <NSObject>

- (void)didSelectPhoto:(ALAsset *)asset atIndexPath:indexPath;
- (void)didDeselectPhoto:(ALAsset *)asset atIndexPath:indexPath;

@end

@interface ZyxPhotosViewController : BaseViewController

@property (nonatomic, assign) NSInteger numberOfCellsPerLine;
@property (nonatomic, assign) CGFloat cellSpacing;
@property (nonatomic, assign) BOOL isSelectAll;
@property (nonatomic, assign) ZyxImagePickerSelectionMode selectionMode;
@property (nonatomic, weak  ) id<ZyxImagePickerControllerDelegate> imagePickerDelegate;
@property (nonatomic, weak  ) id<ZyxSelectPhotoDelegate> selectDelegate;

- (instancetype)initWithAssetsGroup:(ALAssetsGroup *)group;

- (NSMutableSet<ALAsset *> *)selectedPhotos;
- (void)removePhototOfURLString:(NSString *)urlString;

- (void)addAssetsDict:(NSDictionary<NSString *, NSArray<ALAsset *> *> *)assetsDict dateStringsDict:(NSDictionary<NSString *, NSDate *> *)dateStringsDict;

@end
