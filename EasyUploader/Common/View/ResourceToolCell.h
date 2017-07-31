//
//  ResourceToolCell.h
//  EasyUploader
//
//  Created by zhouyong on 17/7/31.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ToolCell.h"

@interface ResourceToolCell : ToolCell

@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UILabel *sizeLabel;


- (void)configWithQiniuResource:(QiniuResource *)resource;

@end
