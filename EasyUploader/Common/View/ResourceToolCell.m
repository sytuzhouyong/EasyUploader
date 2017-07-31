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
        UILabel *label1 = [[UILabel alloc] init];
        label1.textColor = [UIColor darkTextColor];
        label1.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:label1];
        [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.label);
            make.trailing.equalTo(self.label);
            make.top.equalTo(self.label.mas_bottom).offset(2);
            make.height.equalTo(self.label);
        }];

        UILabel *label2 = [[UILabel alloc] init];
        label2.textColor = [UIColor darkTextColor];
        label2.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:label2];
        [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.label);
            make.trailing.equalTo(self.label);
            make.top.equalTo(self.label.mas_bottom).offset(2);
            make.height.equalTo(self.label);
        }];

        self.detailLabel = label1;
        self.sizeLabel = label2;
    }
    return self;
}

- (void)configWithQiniuResource:(QiniuResource *)resource {
    self.label.text = resource.name;
    self.detailLabel.text = @(resource.createTime).stringValue;
    self.sizeLabel.text = @(resource.size).stringValue;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
