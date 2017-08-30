//
//  ConfirmUploadPathToolView.m
//  EasyUploader
//
//  Created by zhouyong on 31/08/2017.
//  Copyright © 2017 zhouyong. All rights reserved.
//

#import "ConfirmUploadPathToolView.h"

@implementation ConfirmUploadPathToolView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor darkGrayColor];

        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        addButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [addButton setBackgroundColor:[UIColor lightGrayColor]];
        [addButton setTitle:@"新建文件夹" forState:UIControlStateNormal];
        [addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

        UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        confirmButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [confirmButton setBackgroundColor:kNavigationBarColor];
        [confirmButton setTitle:@"选定" forState:UIControlStateNormal];
        [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

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

    }
    return self;
}

@end
