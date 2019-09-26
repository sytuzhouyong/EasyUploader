//
//  QiniuResourceContentViewController.h
//  EasyUploader
//
//  Created by zhouyong on 26/08/2017.
//  Copyright © 2017 zhouyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QiniuResourceContentViewController : UITableViewController

@property (nonatomic, copy, readonly) NSString *currentPath;

- (instancetype)initWithBucket:(QiniuBucket *)bucket path:(NSString *)path parentVC:(UIViewController *)parentVC;

@end
