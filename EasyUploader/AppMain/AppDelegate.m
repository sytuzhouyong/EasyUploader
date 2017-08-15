//
//  AppDelegate.m
//  EasyUploader
//
//  Created by zhouyong on 17/2/28.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "AppDelegate.h"
#import "QiniuMainViewController.h"
#import "LocalMainViewController.h"

@interface AppDelegate () <UITabBarControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [kTranslateUtil readLocalLanguageProfiles];

    UITabBarController *tabBarController = [[UITabBarController alloc] initWithNibName:nil bundle:nil];

    QiniuMainViewController *qiniuVC = [QiniuMainViewController new];
    LocalMainViewController *localVC = [LocalMainViewController new];
    UINavigationController *qiniuNav = [[UINavigationController alloc] initWithRootViewController:qiniuVC];
    UINavigationController *localNav = [[UINavigationController alloc] initWithRootViewController:localVC];
    tabBarController.viewControllers = @[qiniuNav, localNav];
    tabBarController.delegate = self;
    qiniuNav.tabBarItem.title = @"七牛云";
    localNav.tabBarItem.title = @"本地相册";

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {

}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - 显示照片权限alert

- (void)showPhotoAuthorizationAlertView {
    [[[UIAlertView alloc] initWithTitle:nil message:@"您未开启相册权限，是否现在就去开启？" delegate:self cancelButtonTitle:Text(@"Cancel") otherButtonTitles:Text(@"Confirm"), nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != 0) {
        [DeviceUtil jumpToAppSettings];
    }
}

@end
