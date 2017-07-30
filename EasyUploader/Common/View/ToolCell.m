//
//  ToolCell.m
//  EasyUploader
//
//  Created by zhouyong on 17/7/30.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "ToolCell.h"

@implementation ToolCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = UIImageNamed(@"icon_round_selected_blue");
        [self.contentView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(10);
            make.leading.equalTo(self.contentView).offset(10);
            make.size.mas_equalTo(CGSize(24, 24));
        }];

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:UIImageNamed(@"icon_arrow_down") forState:UIControlStateNormal];
        [button addTarget:self action:@selector(expandButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(10);
            make.trailing.equalTo(self.contentView).offset(-10);
            make.size.mas_equalTo(CGSizeMake(17, 10));
        }];

        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor darkTextColor];
        label.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(imageView.mas_trailing).offset(10);
            make.top.equalTo(imageView);
            make.bottom.equalTo(imageView);
            make.trailing.equalTo(button.mas_leading).offset(-10);
        }];

        UIView *toolView = [self toolViewWithToolButtonCount:1];

        self.iconImageView = imageView;
        self.label = label;
        self.button = button;
        self.toolView = toolView;

        ShowBorder(toolView, greenColor);
        ShowBorder(imageView, redColor);
        ShowBorder(button, greenColor);
        ShowBorder(label, yellowColor);
    }
    return self;
}

- (void)updateExpandState:(BOOL)expand {
    [self.toolView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(expand ? 40 : 0);
    }];
    [self.contentView updateConstraintsIfNeeded];
}

- (UIView *)toolViewWithToolButtonCount:(NSInteger)count {
    UIView *view = [[UIView alloc] init];
    [self.contentView addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(44);
        make.height.mas_equalTo(40);
    }];

    CGFloat padding = self.contentView.width / count;
    CGSize imageSize = CGSize(24, 24);
    for (NSInteger i=0; i<count; i++) {
        CGFloat x = padding * i + padding;

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:UIImageNamed(@"icon_trash") forState:UIControlStateNormal];
        [view addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(imageSize);
            make.top.equalTo(self.contentView);
            make.leading.equalTo(self.contentView).offset(x);
        }];
    }

    return view;
}

- (void)expandButtonClicked:(UIButton *)button {
    ExecuteBlock1IfNotNil(self.expandHandler, button);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
