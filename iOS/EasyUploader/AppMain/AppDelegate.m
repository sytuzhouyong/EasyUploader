//
//  AppDelegate.m
//  EasyUploader
//
//  Created by zhouyong on 17/2/28.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

// Flutter集成手册 https://github.com/flutter/flutter/wiki/Add-Flutter-to-existing-apps#ios

#import "AppDelegate.h"
#import "QiniuMainViewController.h"
#import "LocalMainViewController.h"
#import "FlutterVC.h"

@interface AppDelegate () <UITabBarControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.isUnderPathSelectMode = NO;
    [kTranslateUtil readLocalLanguageProfiles];

    UITabBarController *tabBarController = [[UITabBarController alloc] initWithNibName:nil bundle:nil];

    QiniuMainViewController *qiniuVC = [QiniuMainViewController new];
    LocalMainViewController *localVC = [LocalMainViewController new];
    UINavigationController *qiniuNav = [[UINavigationController alloc] initWithRootViewController:qiniuVC];
    UINavigationController *localNav = [[UINavigationController alloc] initWithRootViewController:localVC];
    tabBarController.viewControllers = @[qiniuNav, localNav];
    tabBarController.delegate = self;
    qiniuNav.tabBarItem.title = @"七牛云";
    qiniuNav.tabBarItem.image = [UIImage imageNamed:@"tabbar_qiniu"];
    localNav.tabBarItem.title = @"本地相册";
    localNav.tabBarItem.image = [UIImage imageNamed:@"tabbar_album"];
    //    qiniuNav.navigationController.navigationBar.barTintColor = kNavigationBarColor;
    qiniuNav.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    localNav.navigationController.navigationBar.barStyle = UIBarStyleBlack;

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];

//    [self createDatabaseNamed:@"uploader.realm"];

    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
}

- (UINavigationController *)currentNavVC {
    UITabBarController *tabBarVC = (UITabBarController *)kAppDelegate.window.rootViewController;
    UINavigationController *nav = tabBarVC.selectedViewController;
    return nav;
}

- (void)showTaskListVC {
    UINavigationController *nav = [self currentNavVC];
    nav.navigationBarHidden = YES;
    
    // 自定义闪屏，否则首次启动FlutterVC会显示iOS的启动页面
    UIView *splashView = [[UIView alloc] init];
    splashView.backgroundColor = [UIColor whiteColor ];
    UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loading.frame = CGRectMake(100, 100, 60, 60);
    [splashView addSubview:loading];
    
    FlutterVC* vc = [[FlutterVC alloc] init];
    [vc setInitialRoute:@"task-list"];
    vc.splashScreenView = splashView;
    vc.hidesBottomBarWhenPushed = YES; // 在哪个页面隐藏tabbar就在哪个控制器上设置这个属性
    
    [nav pushViewController:vc animated:YES];
}

#pragma mark - Realm

- (void)createDatabaseNamed:(NSString *)fileName {
    NSString *filePath = [[StringUtil documentsPath] stringByAppendingPathComponent:fileName];
    NSLog(@"数据库目录 = %@", filePath);

    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    config.fileURL = [NSURL URLWithString:filePath];
//    config.objectClasses = @[MyClass.class, MyOtherClass.class];
    config.readOnly = NO;
    int currentVersion = 1.0;
    config.schemaVersion = currentVersion;

//    config.migrationBlock = ^(RLMMigration *migration , uint64_t oldSchemaVersion) {       // 这里是设置数据迁移的block
//        if (oldSchemaVersion < currentVersion) {
//        }
//    };

    [RLMRealmConfiguration setDefaultConfiguration:config];
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
