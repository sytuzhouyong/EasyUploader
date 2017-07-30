//
//  ToolCell.h
//  EasyUploader
//
//  Created by zhouyong on 17/7/30.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ExpandButtonHandler) (UIButton *button);

@interface ToolCell : UITableViewCell

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIView *toolView;
@property (nonatomic, copy) ExpandButtonHandler expandHandler;

- (void)updateExpandState:(BOOL)expand;

@end
