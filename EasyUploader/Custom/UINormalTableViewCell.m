//
//  UINormalTableViewCell.m
//  XingHomecloud
//
//  Created by zhouyong on 15/11/27.
//  Copyright © 2015年 zte. All rights reserved.
//

#import "UINormalTableViewCell.h"

@implementation UINormalTableViewCell {
    UITableViewCellStyle _style;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _style = style;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel.textColor = GrayColor(0x3A);
        self.textLabel.font = [UIFont systemFontOfSize:15];
        self.detailTextLabel.textColor = GrayColor(0x9E);
        self.detailTextLabel.font = [UIFont systemFontOfSize:12];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    // 不知道什么原因，在设置页面，点击cell后返回，cell的分割线hidden变成YES了
    for (UIView *view in self.subviews) {
        if ([NSStringFromClass(view.class) isEqualToString:@"_UITableViewCellSeparatorView"] && view.hidden) {
            view.hidden = NO;
        }
    }
    
    BOOL isImageShowing = self.imageView.image != nil;
    if (isImageShowing) {
        CGRect frame = self.contentView.frame;
        frame.origin = CGPoint(10, 10);
        frame.size.height -= 20;
        frame.size.width = frame.size.height;
        self.imageView.frame = frame;
    }
    
    if (_style == UITableViewCellStyleSubtitle) {
        if (isImageShowing) {
            CGRect labelFrame = self.textLabel.frame;
            labelFrame.origin.x = CGRectGetMaxX(self.imageView.frame) + 10;
            labelFrame.origin.y -= 2;
            self.textLabel.frame = labelFrame;
            
            CGRect detailLabelFrame = self.detailTextLabel.frame;
            detailLabelFrame.origin.y += 4;
            detailLabelFrame.origin.x = labelFrame.origin.x;
            self.detailTextLabel.frame = detailLabelFrame;
        } else {
            self.textLabel.frame = CGRectOffset(self.textLabel.frame, 0, -2);
            self.detailTextLabel.frame = CGRectOffset(self.detailTextLabel.frame, 0, 4);
        }
    }
}

@end
