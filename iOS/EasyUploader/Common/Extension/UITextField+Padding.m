//
//  UITextField+Padding.m
//  XingHomecloud
//
//  Created by zte's iMac on 26/11/15.
//  Copyright © 2015年 zte. All rights reserved.
//

#import "UITextField+Padding.h"

@implementation UITextField (Padding)

+(void)setTextFieldLeftPadding:(UITextField *)textField forWidth:(CGFloat)leftWidth{
    
    CGRect frame = textField.frame;
    frame.size.width = leftWidth;
    UIView *leftview = [[UIView alloc] initWithFrame:frame];
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.leftView = leftview;
}

@end
