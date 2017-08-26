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
@property (nonatomic, strong) QiniuBucket *bucket;
@property (nonatomic, strong) NSMutableArray *paths;
@property (nonatomic, strong) UIView *contentView;  // 容纳多个contentVC的父 view
@property (nonatomic, strong) NSMutableArray *contentVCs;

@end

@implementation QiniuResouresViewController

- (instancetype)initWithBucket:(QiniuBucket *)bucket paths:(NSArray *)paths {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.bucket = bucket;

        if (paths.count == 0) {
            self.paths = [NSMutableArray arrayWithObject:bucket.name];
        } else {
            self.paths = [NSMutableArray arrayWithArray:paths];
        }
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
}

- (void)addSubviews {
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"上传" style:UIBarButtonItemStylePlain target:self action:@selector(uploadButtonClicked)];
    self.navigationItem.rightBarButtonItem = button;

    self.pathView = [[PathView alloc] initWithResourePaths:self.paths];
    [self.view addSubview:self.pathView];
    [self.pathView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(self.view).offset(64);
        make.height.mas_equalTo(36);
    }];

    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.top.equalTo(self.pathView.mas_bottom);
    }];

    QiniuResourceContentViewController *vc = [[QiniuResourceContentViewController alloc] initWithBucket:self.bucket];
    [self.contentView addSubview:vc.view];
    [vc.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(5, 5, 5, 5));
    }];
    self.contentVCs = [NSMutableArray arrayWithObject:vc];
}

#pragma mark - Button Event

- (void)uploadButtonClicked {
    LocalMainViewController *vc = [[LocalMainViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:nav animated:YES completion:nil];
}

# pragma mark - Getter and Setter

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
