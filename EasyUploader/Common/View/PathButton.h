//
//  PathButton.h
//  EasyUploader
//
//  Created by zhouyong on 24/08/2017.
//  Copyright © 2017 zhouyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PathButton : UIButton

- (instancetype)initWithFrame:(CGRect)frame isRootPath:(BOOL)isRootPath;
+ (instancetype)buttonWithType:(UIButtonType)type isRootPath:(BOOL)isRootPath;

@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) CGFloat borderWidth;

@end
