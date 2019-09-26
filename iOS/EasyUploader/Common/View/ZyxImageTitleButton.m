//
//  ZyxImageTitleButton.m
//  XingHomecloud
//
//  Created by zhouyong on 12/21/15.
//  Copyright © 2015 zte. All rights reserved.
//

#import "ZyxImageTitleButton.h"

@implementation ZyxImageTitleButton

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = self.bounds.size;
    CGRect imageViewFrame = self.imageView.frame;
    CGRect labelFrame = self.titleLabel.frame;
    
    switch (self.layout) {
        case ZyxImageTitleButtonLayoutTypeHorizontal:
            break;
        case ZyxImageTitleButtonLayoutTypeVertical:
            imageViewFrame.origin.x = 0;
            imageViewFrame.origin.y = 0;
            imageViewFrame.size.width = size.width;
            imageViewFrame.size.height = size.height * 0.6f;
            labelFrame.origin.x = 0;
            labelFrame.origin.y = CGRectGetMaxY(imageViewFrame) + self.spacing;
            labelFrame.size.width = size.width;
            labelFrame.size.height = size.height * 0.4f - self.spacing;
            break;
        default:
            break;
    }
    self.imageView.frame = imageViewFrame;
    self.titleLabel.frame = labelFrame;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.imageView.contentMode = UIViewContentModeBottom;
}

//- (void)setLayout:(ZyxImageTitleButtonLayoutType)layout {
//    _layout = layout;
//    [self layoutIfNeeded];
//}

@end
