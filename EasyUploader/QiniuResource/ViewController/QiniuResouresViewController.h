//
//  QiniuResouresViewController.h
//  EasyUploader
//
//  Created by zhouyong on 17/7/26.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "ToolCell.h"

@class QiniuResourceContentViewController;

@interface QiniuResouresViewController : UIViewController

@property (nonatomic, strong, readonly) NSArray *paths;

- (instancetype)initWithBucket:(QiniuBucket *)bucket;
- (instancetype)initWithBucket:(QiniuBucket *)bucket paths:(NSArray *)paths pathSelectMode:(BOOL)pathSelectMode;


- (void)addNewContentVC:(QiniuResourceContentViewController *)vc named:(NSString *)path;
- (NSInteger)indexOfConentVCNamed:(NSString *)path;
- (void)enterContentVCNamed:(NSString *)name;

- (void)updateUIWhenEnterNewContentVC;
- (void)updateUIWhenEnterContentVCAtIndex:(NSUInteger)index;

@end
