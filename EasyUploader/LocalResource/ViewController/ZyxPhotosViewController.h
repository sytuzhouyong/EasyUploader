//
//  ZyxPhotosViewController.h
//  XingHomecloud
//
//  Created by zhouyong on 12/28/15.
//  Copyright © 2015 zhouyong. All rights reserved.
//

#import "ZyxPickAlbumViewController.h"

@class ALAssetsGroup;

@protocol ZyxSelectPhotoDelegate <NSObject>

- (void)didSelectPhoto:(ALAsset *)asset atIndexPath:indexPath;
- (void)didDeselectPhoto:(ALAsset *)asset atIndexPath:indexPath;

@end

@interface ZyxPhotosViewController : UIViewController

@property (nonatomic, assign) NSInteger numberOfCellsPerLine;
@property (nonatomic, assign) CGFloat cellSpacing;
@property (nonatomic, assign) BOOL isSelectAll;
@property (nonatomic, assign) ZyxImagePickerSelectionMode selectionMode;
@property (nonatomic, weak  ) id<ZyxPickAlbumViewControllerDelegate> imagePickerDelegate;
@property (nonatomic, weak  ) id<ZyxSelectPhotoDelegate> selectDelegate;

- (instancetype)initWithAssetsGroup:(ALAssetsGroup *)group;

- (NSArray<ALAsset *> *)selectedPhotos;
- (void)removePhototOfURLString:(NSString *)urlString;

- (void)addAssetsDict:(NSDictionary<NSString *, NSArray<ALAsset *> *> *)assetsDict dateStringsDict:(NSDictionary<NSString *, NSDate *> *)dateStringsDict;

@end
