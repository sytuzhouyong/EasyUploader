//
//  ResourceToolCell.m
//  EasyUploader
//
//  Created by zhouyong on 17/7/31.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "ResourceToolCell.h"
#import "UIImageView+WebCache.h"

@implementation ResourceToolCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        if (![reuseIdentifier isEqualToString:kFileCellIdentifier]) {
            return self;
        }

        self.iconImageView.image = UIImageNamed(@"icon_image");

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
            make.top.equalTo(self.label.mas_bottom).offset(0);
            make.height.equalTo(self.label);
        }];

        UILabel *label2 = [[UILabel alloc] init];
        label2.font = [UIFont systemFontOfSize:11];
        label2.textColor = [UIColor lightGrayColor];
        label2.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:label2];
        [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(80);
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

- (NSArray<ToolButtonInfo *> *)toolButtons {
    ToolButtonInfo *info1 = [[ToolButtonInfo alloc] initWithTitle:@"下载" imageName:@"icon_trash" handler:nil];
    ToolButtonInfo *info2 = [[ToolButtonInfo alloc] initWithTitle:@"删除" imageName:@"icon_trash" handler:nil];
    return @[info1, info2];
}

- (void)configWithQiniuResource:(QiniuResource *)resource prefix:(NSString *)prefix {
    NSString *name = [resource.name substringFromIndex:prefix.length];
    self.label.text = name;
    self.detailLabel.text = resource.createTimeDesc;
    self.sizeLabel.text = resource.sizeDesc;

    NSString *iconName = resource.type == QiniuResourceTypeDir ? @"icon_bucket" : @"icon_file";
    NSString *ext = resource.name.lowercaseString.pathExtension;
    if ([@[@".png", @".jpg", @".heic"] indexOfObject:ext] != NSNotFound) {
        iconName = @"icon_file_image";
    }
    NSURL *url = [kQiniuDownloadManager thumbnailURLWithKey:resource.name];
    [self.iconImageView sd_setImageWithURL:url placeholderImage:UIImageNamed(iconName)];
}

- (void)buttonClicked:(UIButton *)button {
    switch (button.tag - kToolCellButtonTag) {
        case 0:
            ExecuteBlock1IfNotNil(self.downloadHandler, button);
            break;
        case 1:
            ExecuteBlock1IfNotNil(self.deleteHandler, button);
            break;
        default:
            break;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
