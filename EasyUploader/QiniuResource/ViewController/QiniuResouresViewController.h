//
//  QiniuResouresViewController.h
//  EasyUploader
//
//  Created by zhouyong on 17/7/26.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "ToolCell.h"

@interface QiniuResouresViewController : UIViewController

@property (nonatomic, strong, readonly) NSArray *paths;

- (instancetype)initWithBucket:(QiniuBucket *)bucket;
- (instancetype)initWithBucket:(QiniuBucket *)bucket paths:(NSArray *)paths;

- (void)enterSubpath:(NSString *)path;

@end
