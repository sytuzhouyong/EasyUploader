//
//  ConfirmUploadPathToolView.m
//  EasyUploader
//
//  Created by zhouyong on 31/08/2017.
//  Copyright © 2017 zhouyong. All rights reserved.
//

#import "ConfirmUploadPathToolView.h"

@interface ConfirmUploadPathToolView ()

@end

@implementation ConfirmUploadPathToolView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor darkGrayColor];

        UIButton *addButton = [self.class buttonWithTitle:@"新建文件夹" backgroundColor:[UIColor lightGrayColor]];
        UIButton *confirmButton = [self.class buttonWithTitle:@"选定" backgroundColor:kNavigationBarColor];
        [self addSubview:addButton];
        [self addSubview:confirmButton];
        [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(5);
            make.bottom.equalTo(self).offset(-5);
            make.leading.equalTo(self).offset(10);
        }];
        [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(5);
            make.bottom.equalTo(self).offset(-5);
            make.leading.equalTo(addButton.mas_trailing).offset(10);
            make.trailing.equalTo(self).offset(-10);
            make.width.equalTo(addButton);
        }];

        [[addButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            ExecuteBlock1IfNotNil(self.addDirHandler, x);
        }];
        [[confirmButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            ExecuteBlock1IfNotNil(self.confirmPathHandler, x);
        }];
    }
    return self;
}

+ (UIButton *)buttonWithTitle:(NSString *)title backgroundColor:(UIColor *)color {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.cornerRadius = 4;
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setBackgroundColor:color];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    return button;
}

@end
