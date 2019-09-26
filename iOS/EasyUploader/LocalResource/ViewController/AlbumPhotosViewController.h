//
//  AlbumPhotosViewController.h
//  XingHomecloud
//
//  Created by zhouyong on 3/7/16.
//  Copyright © 2016 zhouyong. All rights reserved.
//

#import "ZyxPickAlbumViewController.h"

@interface AlbumPhotosViewController : UIViewController

@property (nonatomic, strong) ALAssetsGroup *group;
@property (nonatomic, weak  ) id<ZyxPickAlbumViewControllerDelegate> imagePickerDelegate;

@end
