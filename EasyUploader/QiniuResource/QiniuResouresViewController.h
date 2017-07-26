//
//  QiniuResouresViewController.h
//  EasyUploader
//
//  Created by zhouyong on 17/7/26.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "BaseViewController.h"

@interface QiniuResouresViewController : BaseViewController

@property (nonatomic, assign) NSInteger numberOfCellsPerLine;
@property (nonatomic, assign) CGFloat cellSpacing;
@property (nonatomic, assign) BOOL isSelectAll;
@property (nonatomic, assign) ZyxImagePickerSelectionMode selectionMode;

@end
