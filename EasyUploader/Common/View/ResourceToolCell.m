//
//  ResourceToolCell.m
//  EasyUploader
//
//  Created by zhouyong on 17/7/31.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "ResourceToolCell.h"

@implementation ResourceToolCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.label mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.iconImageView.mas_trailing).offset(10);
            make.top.equalTo(self.iconImageView);
            make.bottom.equalTo(self.iconImageView.mas_centerY).offset(2);
            make.trailing.equalTo(self.button.mas_leading).offset(-10);
        }];

        UILabel *label1 = [[UILabel alloc] init];
        label1.font = [UIFont systemFontOfSize:11];
        label1.textColor = [UIColor lightGrayColor];
        label1.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:label1];
        [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.label);
            make.trailing.equalTo(self.label);
            make.top.equalTo(self.label.mas_bottom).offset(4);
            make.height.equalTo(self.label);
        }];

        UILabel *label2 = [[UILabel alloc] init];
        label2.font = [UIFont systemFontOfSize:11];
        label2.textColor = [UIColor lightGrayColor];
        label2.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:label2];
        [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(40);
            make.trailing.equalTo(self.button.mas_leading).offset(-5);
            make.top.equalTo(label1);
            make.height.equalTo(label1);
        }];

        self.detailLabel = label1;
        self.sizeLabel = label2;
        self.label.font = [UIFont systemFontOfSize:13];
    }
    return self;
}

- (void)configWithQiniuResource:(QiniuResource *)resource {
    self.label.text = resource.name;
    self.detailLabel.text = resource.createTimeDesc;
    self.sizeLabel.text = resource.sizeDesc;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
