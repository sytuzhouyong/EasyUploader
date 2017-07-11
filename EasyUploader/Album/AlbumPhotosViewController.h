//
//  AlbumPhotosViewController.h
//  XingHomecloud
//
//  Created by zhouyong on 3/7/16.
//  Copyright © 2016 zhouyong. All rights reserved.
//

#import "BaseViewController.h"
#import "ZyxPickAlbumViewController.h"

@interface AlbumPhotosViewController : BaseViewController

@property (nonatomic, strong) ALAssetsGroup *group;
@property (nonatomic, weak  ) id<ZyxPickAlbumViewControllerDelegate> imagePickerDelegate;

@end
