//
//  AppDelegate.h
//  EasyUploader
//
//  Created by zhouyong on 17/2/28.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlutterVC;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, assign) BOOL isUnderPathSelectMode;
@property (nonatomic, strong) FlutterVC *flutterVC;


- (void)showPhotoAuthorizationAlertView;
- (UINavigationController *)currentNavVC;
- (void)showTaskListVC;

@end

