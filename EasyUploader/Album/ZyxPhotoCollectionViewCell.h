//
//  ZyxPhotoCollectionViewCell.h
//  XingHomecloud
//
//  Created by zhouyong on 12/28/15.
//  Copyright © 2015 zhouyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZyxImagePickerController.h"

@class ALAsset;

@interface ZyxPhotoCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) ZyxImagePickerSelectionMode mode;

- (void)configCellWithAsset:(ALAsset *)asset;

@end
