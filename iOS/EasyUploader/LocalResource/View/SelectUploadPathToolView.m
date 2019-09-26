//
//  SelectUploadPathToolView.m
//  EasyUploader
//
//  Created by zhouyong on 17/8/12.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "SelectUploadPathToolView.h"
#import "ZyxImageTitleButton.h"

@interface SelectUploadPathToolView ()

@property (nonatomic, strong) UIButton *selectPathButon;
@property (nonatomic, strong) UIButton *uploadButton;

@end

@implementation SelectUploadPathToolView

- (instancetype)initWithFrame:(CGRect)frame uploadPath:(NSString *)path {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor darkGrayColor];

        UILabel *tipLabel = [[UILabel alloc] init];
        tipLabel.backgroundColor = [UIColor clearColor];
        tipLabel.text = @"选择上传路径";
        tipLabel.textColor = [UIColor whiteColor];
        tipLabel.textAlignment = NSTextAlignmentLeft;
        tipLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:tipLabel];
        [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(5);
            make.top.equalTo(self).offset(2);
            make.trailing.equalTo(self);
            make.height.mas_equalTo(32);
        }];

        UIButton *uploadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        uploadButton.layer.cornerRadius = 3;
        uploadButton.titleLabel.font = UIFontOfSize(12);
        [uploadButton setBackgroundColor: [UIColor grayColor]];
        [uploadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [uploadButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        [uploadButton setTitle:@"上传" forState:UIControlStateNormal];
        [self addSubview:uploadButton];
        [uploadButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self).offset(-5);
            make.width.mas_equalTo(50);
            make.top.equalTo(tipLabel.mas_bottom);
            make.bottom.equalTo(self).offset(-5);
        }];

        UIButton *pathButton = [UIButton buttonWithType:UIButtonTypeCustom];
        pathButton.layer.cornerRadius = 3;
        pathButton.titleLabel.font = UIFontOfSize(16);
        [pathButton setBackgroundColor: [UIColor grayColor]];
        [pathButton setImage:UIImageNamed(@"icon_bucket") forState:UIControlStateNormal];
        [self addSubview:pathButton];
        [pathButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(5);
            make.top.equalTo(tipLabel.mas_bottom);
            make.trailing.equalTo(uploadButton.mas_leading).offset(-5);
            make.bottom.equalTo(self).offset(-5);
        }];

        self.uploadButton = uploadButton;
        self.selectPathButon = pathButton;

        [[uploadButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            ExecuteBlock1IfNotNil(self.uploadHandler, x);
        }];
        [[pathButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            ExecuteBlock1IfNotNil(self.selectPathHandler, path);
        }];
    }
    return self;
}

- (void)enableUploadButton:(BOOL)enable {
    self.uploadButton.enabled = enable;
}

- (void)updatePath:(NSString *)path {
    [self.selectPathButon setTitle:path forState:UIControlStateNormal];
}

@end
