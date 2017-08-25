//
//  PathButton.m
//  EasyUploader
//
//  Created by zhouyong on 24/08/2017.
//  Copyright © 2017 zhouyong. All rights reserved.
//

#import "PathButton.h"

@interface PathButton ()

@property (nonatomic, assign) BOOL isRootPath;
@property (nonatomic, assign) CGSize lastSize;
@property (nonatomic, strong) CAShapeLayer *maskLayer;

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
    PathButton *button = [super buttonWithType:UIButtonTypeCustom];
    [button setTitle:path forState:UIControlStateNormal];
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
    [self setMaskLayerWithUIBezierPath:[self maskPath]];
    NSLog(@"frame2 = %@", NSStringFromCGRect(self.frame));
}

- (void)setMaskLayerWithUIBezierPath:(UIBezierPath *)bezierPath {
    if (self.maskLayer != nil) {
        if (CGSizeEqualToSize(self.maskLayer.frame.size, self.lastSize)) {
            NSLog(@"size are equal, so reuse last mask layer!");
            return;
        }
        [self.maskLayer removeFromSuperlayer];
    }

    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = [bezierPath CGPath];
    maskLayer.fillColor = [[UIColor redColor] CGColor]; // content color
    maskLayer.strokeColor = [self.borderColor CGColor]; // border color
    maskLayer.lineWidth = self.borderWidth;             // border width
    maskLayer.frame = self.bounds;
    [self.layer addSublayer: maskLayer];
    self.maskLayer = maskLayer;
    self.lastSize = self.bounds.size;
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
