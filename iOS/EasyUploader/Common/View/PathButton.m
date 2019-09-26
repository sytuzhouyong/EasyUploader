//
//  PathButton.m
//  EasyUploader
//
//  Created by zhouyong on 24/08/2017.
//  Copyright © 2017 zhouyong. All rights reserved.
//

#import "PathButton.h"

#define kPathButtonFontSize     13

@interface PathButton ()

@property (nonatomic, assign) BOOL isRootPath;
@property (nonatomic, assign) CGSize lastSize;
@property (nonatomic, strong) CAShapeLayer *borderLayer;

@end

@implementation PathButton

- (void)initConfig {
    self.borderColor = [UIColor orangeColor];
    self.borderWidth = 4;
    self.lastSize = CGSizeZero;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame isRootPath:YES];
}

- (instancetype)initWithFrame:(CGRect)frame isRootPath:(BOOL)isRootPath {
    if (self = [super initWithFrame:frame]) {
        [self initConfig];
        self.isRootPath = isRootPath;
    }
    return self;
}

+ (instancetype)buttonWithPath:(NSString *)path isRootPath:(BOOL)isRootPath {
    PathButton *button = [super buttonWithType:UIButtonTypeSystem];
    button.isRootPath = isRootPath;
    button.titleLabel.font = [UIFont systemFontOfSize:kPathButtonFontSize];
    button.titleEdgeInsets = UIEdgeInsetsMake(0, isRootPath ? 2 : 12, 0, 0);
    button.backgroundColor = kNavigationBarColor;
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [button setTitle:path forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button initConfig];
    return button;
}

// determine the condition of touch event happening
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if ([[self maskPath] containsPoint:point]) {
        return YES;
    }
    return NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (CGSizeEqualToSize(self.bounds.size, self.lastSize)) {
        return;
    }
    [self setMaskLayerWithUIBezierPath:[self maskPath]];
}

- (void)setMaskLayerWithUIBezierPath:(UIBezierPath *)bezierPath {
    self.layer.mask = nil;
    [self.borderLayer removeFromSuperlayer];
    self.lastSize = self.bounds.size;

    //蒙版
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = [bezierPath CGPath];
    maskLayer.fillColor = [[UIColor brownColor] CGColor];
    maskLayer.frame = self.bounds;
    self.layer.mask = maskLayer;
    //边框蒙版
    CAShapeLayer *maskBorderLayer = [CAShapeLayer layer];
    maskBorderLayer.path = [bezierPath CGPath];
    maskBorderLayer.fillColor = [[UIColor clearColor] CGColor];
    maskBorderLayer.strokeColor = [[UIColor clearColor] CGColor];//边框颜色
    maskBorderLayer.lineWidth = 2; //边框宽度
    [self.layer addSublayer:maskBorderLayer];

    self.borderLayer = maskBorderLayer;
}

- (UIBezierPath *)maskPath {
    CGFloat mid_x = self.bounds.size.width - 10.0f;
    CGFloat mid_y = self.bounds.size.height * 0.5f;
    CGFloat max_x = self.bounds.size.width;
    CGFloat max_y = self.bounds.size.height;

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointZero];
    [path addLineToPoint:CGPointMake(mid_x, 0)];
    [path addLineToPoint:CGPointMake(max_x, mid_y)];
    [path addLineToPoint:CGPointMake(mid_x, max_y)];
    [path addLineToPoint:CGPointMake(0, max_y)];

    if (!self.isRootPath) {
        [path addLineToPoint:CGPointMake(10.0f, mid_y)];
    }

    [path closePath];
    return path;
}

@end
