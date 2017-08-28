//
//  QiniuResouresViewController.m
//  EasyUploader
//
//  Created by zhouyong on 17/7/26.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "QiniuResouresViewController.h"
#import "LocalMainViewController.h"
#import "QiniuResourceContentViewController.h"
#import "PathView.h"


@interface QiniuResouresViewController ()

@property (nonatomic, strong) PathView *pathView;
@property (nonatomic, strong) UIView *contentView;  // 容纳多个contentVC的父 view

@property (nonatomic, strong) QiniuBucket *bucket;
@property (nonatomic, strong) NSMutableArray *paths;
@property (nonatomic, strong) NSMutableArray *contentVCs;
@property (nonatomic, assign) NSUInteger currentPathIndex;

@end

@implementation QiniuResouresViewController

- (instancetype)initWithBucket:(QiniuBucket *)bucket paths:(NSArray *)paths {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.bucket = bucket;
        self.paths = [NSMutableArray array];
        self.contentVCs = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithBucket:(QiniuBucket *)bucket {
    return [self initWithBucket:bucket paths:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.bucket.name;
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tabBarController.tabBar.hidden = YES;

    [self addSubviews];
    self.currentPathIndex = self.paths.count - 1;
}

- (void)addSubviews {
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"上传" style:UIBarButtonItemStylePlain target:self action:@selector(uploadButtonClicked)];
    self.navigationItem.rightBarButtonItem = button;

    kWeakself;
    self.pathView = [[PathView alloc] initWithResourePaths:self.paths pathSelectHandler:^(NSUInteger index) {
        if (index == self.currentPathIndex) {
            return;
        }

        UIViewController *dstVC = self.contentVCs[index];
        UIViewController *srcVC = self.contentVCs[self.currentPathIndex];
        // why could not add this code, or error animation with forwar case
//        [weakself.contentView bringSubviewToFront:dstVC.view];

        BOOL forward = index > self.currentPathIndex;
        CGRect dstVCBeginFrame = CGRectOffset(srcVC.view.frame, (forward ? 1 : -1) * kWindowWidth, 0);
        dstVC.view.frame = dstVCBeginFrame;

        [UIView animateWithDuration:0.5 animations:^{
            dstVC.view.frame = CGRectOffset(dstVC.view.frame, (forward ? -1 : 1) * kWindowWidth, 0);
            srcVC.view.frame = CGRectOffset(srcVC.view.frame, (forward ? -1 : 1) * kWindowWidth, 0);
            [weakself.pathView updateUIWhenSelectPathButtonChangedTo:index];
        } completion:nil];

        weakself.currentPathIndex = index;
    }];
    [self.view addSubview:self.pathView];
    [self.pathView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(self.view).offset(64);
        make.height.mas_equalTo(36);
    }];

    self.contentView = [[UIView alloc] init];
    self.contentView.clipsToBounds = YES;
    self.contentView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.top.equalTo(self.pathView.mas_bottom);
    }];

    QiniuResourceContentViewController *vc = [[QiniuResourceContentViewController alloc] initWithBucket:self.bucket resourceName:self.bucket.name parentVC:self];
    [self.contentView addSubview:vc.view];
    [vc.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(5, 5, 5, 5));
    }];
}

#pragma mark - Button Event

- (void)uploadButtonClicked {
    LocalMainViewController *vc = [[LocalMainViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:nav animated:YES completion:nil];
}

# pragma mark - Getter and Setter

- (void)enterSubContentVC:(UIViewController *)vc named:(NSString *)path {
    self.currentPathIndex = _paths.count;
    [_paths addObject:path];
    [self.pathView appendPath:path];
    [self.contentVCs addObject:vc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
