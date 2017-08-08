//
//  ToolCell.h
//  EasyUploader
//
//  Created by zhouyong on 17/7/30.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ToolButtonInfo;

typedef void (^ButtonHandler) (UIButton *button);
typedef ButtonHandler ExpandButtonHandler;

@interface ToolCell : UITableViewCell

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIView *toolView;
@property (nonatomic, copy) ExpandButtonHandler expandHandler;
@property (nonatomic, strong) NSArray *toolButtons;

- (void)updateExpandState:(BOOL)expand;
- (NSArray<ToolButtonInfo *> *)toolButtons;

@end


@interface ToolButtonInfo : NSObject

@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) ButtonHandler handler;

- (instancetype)initWithTitle:(NSString *)title imageName:(NSString *)imageName handler:(ButtonHandler)handler;

@end
