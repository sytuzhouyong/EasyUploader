//
//  ZyxPhotoCollectionViewCell.h
//  XingHomecloud
//
//  Created by zhouyong on 12/28/15.
//  Copyright © 2015 zhouyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZyxPickAlbumViewController.h"

@class ALAsset;

//@protocol ZyxSelectALAssetDelegate <NSObject>
//
//- (void)didSelectALAsset:(ALAsset *)asset atIndexPath:indexPath;
//- (void)didDeselectALAsset:(ALAsset *)asset atIndexPath:indexPath;
//
//@end


@interface ZyxPhotoCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) ZyxImagePickerSelectionMode mode;
//@property (nonatomic, weak) id<ZyxSelectALAssetDelegate> alassetDelegate;

- (void)configCellWithAsset:(ALAsset *)asset;

@end
