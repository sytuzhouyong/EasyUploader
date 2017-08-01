//
//  BaseViewController+PresentView.h
//  EasyUploader
//
//  Created by zhouyong on 17/8/1.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController (PresentView)

// view会被BaseViewController持有，如果view在当前ViewController中也被持有，会导致view在dismiss后内存不会释放
// 要等到当前ViewController释放后才能释放
- (void)presentView:(UIView *)view layout:(UIViewLayoutType)layout;
- (void)dismissPresentedView;
- (UIView *)presentedView;

- (void)keyboardWillChangeFrameFrom:(CGRect)beginFrame to:(CGRect)endFrame isHidden:(BOOL)isHidden;

@end
