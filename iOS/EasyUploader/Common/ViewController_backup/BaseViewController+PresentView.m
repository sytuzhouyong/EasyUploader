//
//  BaseViewController+PresentView.m
//  EasyUploader
//
//  Created by zhouyong on 17/8/1.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "BaseViewController+PresentView.h"

@interface BaseViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *presentedView;
@property (nonatomic, strong) UIButton *presentedBackgroundButton;
@property (nonatomic, assign) UIViewLayoutType layout;

@property (nonatomic, weak  ) UIControl *focusedView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;


@end

@implementation BaseViewController (PresentView)

- (void)viewDidLoad {
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
//    tap.delegate = self;
//    [self.view addGestureRecognizer: tap];
//    self.tapGesture = tap;
}

- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
    [self addObserver];
}

- (void)viewDidDisappear:(BOOL)animated {
//    [super viewDidDisappear:animated];
    [self removeObserver];
    [self hideKeyboard];
}


- (void)addObserver {
    [self removeObserver];
    [kNotificationCenter addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [kNotificationCenter addObserver:self selector:@selector(inputableViewFocused:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    [kNotificationCenter addObserver:self selector:@selector(inputableViewFocused:) name:UITextViewTextDidBeginEditingNotification object:nil];
}

- (void)removeObserver {
    [kNotificationCenter removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [kNotificationCenter removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
    [kNotificationCenter removeObserver:self name:UITextViewTextDidBeginEditingNotification object:nil];
}


- (void)presentView:(UIView *)view layout:(UIViewLayoutType)layout {
    if (self.presentedView != nil) {
        [self dismissPresentedViewWithCompletion:^{
            [self showView:view layout:layout];
        }];
    } else {
        [self showView:view layout:layout];
    }
}

- (void)showView:(UIView *)view layout:(UIViewLayoutType)layout {
    CGFloat viewWidth = view.width;
    CGFloat viewHeight = view.height;
    if (viewWidth == 0) {
        viewWidth = kWindowWidth;
    }

    UIButton *backgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backgroundButton.frame = self.view.bounds;
    backgroundButton.backgroundColor = [UIColor blackColor];
    backgroundButton.alpha = 0.6f;
    AddButtonEvent(backgroundButton, @"backgroundButtonPressed");

    // 为了让titleview不被遮挡
    if ((layout & UIViewLayoutTypeTop) && !self.isTitleViewHidden) {
        [self.view bringSubviewToFront:self.titleView];
        [self.view insertSubview:backgroundButton belowSubview:self.titleView];
    } else {
        [self.view addSubview:backgroundButton];
    }

    NSArray<NSValue *> *points = [self pointsWithPresentView:view andLayoutType:layout];
    CGPoint startPoint = [points.firstObject CGPointValue];
    CGPoint endPoint = [points.lastObject CGPointValue];
    view.frame = CGRect(startPoint.x, startPoint.y, viewWidth, viewHeight);
    view.alpha = 0;
    [self.view insertSubview:view aboveSubview:backgroundButton];

    [UIView animateWithDuration:0.3f animations:^{
        view.frame = CGRect(endPoint.x, endPoint.y, viewWidth, viewHeight);
        view.alpha = 1;
    }];

    self.presentedBackgroundButton = backgroundButton;
    self.presentedView = view;
    self.layout = layout;
}

- (void)backgroundButtonPressed {
    if (self.focusedView != nil) {
        [self hideKeyboard];
    } else if (self.presentedView != nil) {
        [self dismissPresentedView];
    }
}

- (void)hideKeyboard {
    if (self.focusedView != nil) {
        [self.focusedView resignFirstResponder];
        self.focusedView = nil;
    }
}

- (void)dismissPresentedViewWithCompletion:(void (^)())completion {
    NSArray<NSValue *> *points = [self pointsWithPresentView:self.presentedView andLayoutType:self.layout];
    CGPoint endPoint = [points.firstObject CGPointValue];

    CGRect frame = self.presentedView.frame;
    frame.origin = endPoint;

    kWeakself;
    [UIView animateWithDuration:.4f animations:^{
        self.presentedView.frame = frame;
        self.presentedView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.presentedView removeFromSuperview];
        [self.presentedBackgroundButton removeFromSuperview];
        weakself.presentedView = nil;
        weakself.presentedBackgroundButton = nil;
        weakself.layout = UIViewLayoutTypeNone;

        ExecuteBlockIfNotNil(completion);
    }];
}

- (void)dismissPresentedView {
    [self dismissPresentedViewWithCompletion:nil];
}

- (UIView *)presentedView {
    return self.presentedView;
}

- (NSArray<NSValue *> *)pointsWithPresentView:(UIView *)view andLayoutType:(UIViewLayoutType)layout {
    CGFloat viewWidth = view.width;
    CGFloat viewHeight = view.height;
    if (viewWidth == 0) {
        viewWidth = kWindowWidth;
    }

    CGFloat centerX = (self.view.width - viewWidth) / 2.f;
    CGFloat centerY = (self.view.height - viewHeight) / 2.f;
    CGPoint startPoint = CGPointZero;
    CGPoint endPoint = CGPointZero;

    switch (layout) {
        case UIViewLayoutTypeTopLeft:
            startPoint = CGPoint(self.view.x - viewWidth, self.view.y - viewHeight);
            endPoint   = CGPoint(self.view.x, self.view.y);
            break;
        case UIViewLayoutTypeTopCenter:
            startPoint = CGPoint(centerX, self.view.y - viewHeight);
            endPoint   = CGPoint(centerX, self.titleView.bottomY);
            break;
        case UIViewLayoutTypeTopRight:
            startPoint = CGPoint(self.view.rightX, self.view.y - viewHeight);
            endPoint   = CGPoint(self.view.rightX - viewWidth, self.titleView.bottomY);
            break;
        case UIViewLayoutTypeCenterLeft:
            startPoint = CGPoint(self.view.x - viewWidth, centerY);
            endPoint = CGPoint(self.view.x, centerY);
            break;
        case UIViewLayoutTypeCenter:
            startPoint = CGPoint(centerX, self.view.y - viewHeight);
            endPoint   = CGPoint(centerX, centerY);
            break;
        case UIViewLayoutTypeCenterRight:
            startPoint = CGPoint(self.view.rightX, centerY);
            endPoint   = CGPoint(self.view.rightX - viewWidth, centerY);
            break;
        case UIViewLayoutTypeBottomLeft:
            startPoint = CGPoint(self.view.x - viewWidth, self.view.bottomY - viewHeight);
            endPoint   = CGPoint(self.view.x - viewWidth, self.view.bottomY);
            break;
        case UIViewLayoutTypeBottomCenter:
            startPoint = CGPoint(centerX, self.view.bottomY);
            endPoint   = CGPoint(centerX, self.view.bottomY - viewHeight);
            break;
        case UIViewLayoutTypeBottomRight:
            startPoint = CGPoint(self.view.rightX, self.view.bottomY);
            endPoint   = CGPoint(self.view.rightX - viewWidth, self.view.bottomY - viewHeight);
            break;
        default:
            break;
    }
    return @[[NSValue valueWithCGPoint:startPoint], [NSValue valueWithCGPoint:endPoint]];
}

#pragma mark - Notification Handler

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect beginFrame, endFrame;
    [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&beginFrame];
    [[info objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&endFrame];

    NSTimeInterval duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    duration = MAX(duration, 0.25f);
    UIViewAnimationCurve curve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIView animateWithDuration:duration delay:0 options:(curve << 16) animations:^{
        BOOL isHidden = endFrame.origin.y == kWindowHeight;
        [self keyboardWillChangeFrameFrom:beginFrame to:endFrame isHidden:isHidden];
    } completion:nil];
}

- (void)keyboardWillChangeFrameFrom:(CGRect)beginFrame to:(CGRect)endFrame isHidden:(BOOL)isHidden {
    CGRect frame = [kKeyWindow convertRect:self.focusedView.frame fromView:self.focusedView.superview];
    CGFloat inputViewY = CGRectGetMaxY(frame);
    CGFloat keyboardY = endFrame.origin.y;
    if (keyboardY >= inputViewY && !isHidden) {
        return;
    }

    frame = self.view.frame;
    if (!isHidden) {
        frame.origin.y += keyboardY - inputViewY - 1;
    } else {
        frame.origin = CGPointZero;
    }
    self.view.frame = frame;
}

- (void)inputableViewFocused:(NSNotification *)notification {
    self.focusedView = (UIControl *)notification.object;
}


@end
