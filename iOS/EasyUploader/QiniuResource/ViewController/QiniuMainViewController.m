//
//  QiniuResourceMainViewController.m
//  EasyUploader
//
//  Created by zhouyong on 17/2/28.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "QiniuMainViewController.h"
#import "ZyxPickAlbumViewController.h"
#import "QiniuResouresViewController.h"
#import "QiniuViewModel.h"
#import "ToolCell.h"
#import <Flutter/Flutter.h>
#import "FlutterVC.h"

#define kExpandButtonTag        1000
#define kLabelTag               2000
#define kCellToolViewTag        3000

#define kCellIdentifier         @"ToolCell"

@interface QiniuMainViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) QiniuBucketViewModel *viewModel;
@property (nonatomic, strong) NSIndexPath *lastIndexPath;
@property (nonatomic, copy) ExpandButtonHandler expandHandler;

@end

@implementation QiniuMainViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"七牛云";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];

    // 不为空说明是选择上传路径界面
    if (kAppDelegate.isUnderPathSelectMode) {
        self.title = @"选择相册";
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:UIImageNamed(@"icon_arrow_left") style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:UIImageNamed(@"icon_upload_download") style:UIBarButtonItemStylePlain target:self action:@selector(showTaskButtonPressed)];
        self.navigationItem.rightBarButtonItem.tintColor = GrayColor(0x33);
    }

    [self addSubviews];
    [self initHandlers];

    [kQiniuResourceManager queryAllBucketsWithHandler:^(NSArray<QiniuBucket *> *buckets) {
        dispatch_async(dispatch_get_main_queue(), ^{
            kQiniuResourceManager.selectedBucket = buckets.lastObject;
            self.viewModel = [[QiniuBucketViewModel alloc] initWithBuckets:buckets];
            [self.tableView reloadData];
        });
    }];
}

- (void)addSubviews {
    [self.view addSubview:self.tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)showTaskButtonPressed {
    self.navigationController.navigationBarHidden = YES;
    
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
    
    kWeakself;
    NSString *channelName = @"easy-upload-ios";
    FlutterMethodChannel *messageChannel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:vc];
   
    [messageChannel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
        // call.method 获取 flutter 给回到的方法名，要匹配到 channelName 对应的多个 发送方法名，一般需要判断区分
        // call.arguments 获取到 flutter 给到的参数，（比如跳转到另一个页面所需要参数）
        // result 是给flutter的回调， 该回调只能使用一次
        NSLog(@"method=%@ \narguments = %@", call.method, call.arguments);
        NSString *method = call.method;
//        id args = call.arguments;
        
        // method和WKWebView里面JS交互很像
        if ([method isEqualToString:@"popVC"] ) {
            [weakself.navigationController popViewControllerAnimated:YES];
            weakself.navigationController.navigationBarHidden = NO;
        }
    }];
    
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)cancelButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
    kAppDelegate.isUnderPathSelectMode = NO;
}

- (void)initHandlers {
    kWeakself;
    self.expandHandler = ^(UIButton *button) {
        CGPoint pt = [weakself.tableView convertPoint:button.center fromView:button.superview];
        NSIndexPath *indexPath = [weakself.tableView indexPathForRowAtPoint:pt];
        BOOL expand = [weakself.viewModel isExpandAtIndexPath:indexPath];

        NSArray *indexPaths = @[indexPath];
        if (self.lastIndexPath && self.lastIndexPath.row != indexPath.row && [self.viewModel isExpandAtIndexPath:self.lastIndexPath]) {
            indexPaths = @[indexPath, self.lastIndexPath];
            [weakself.viewModel updateExpandStateAtIndexPath:weakself.lastIndexPath];
        }

        [weakself.viewModel updateExpandStateAtIndexPath:indexPath];
        weakself.lastIndexPath = indexPath;

        [UIView animateWithDuration:0.3 animations:^{
            // 如果放在动画之前跑，效果会和 reload 冲突，导致动画很突兀
            [weakself.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            if (!expand) {
                button.transform = CGAffineTransformRotate(button.transform, M_PI);
            } else {
                button.transform = CGAffineTransformRotate(button.transform, -M_PI);
            }
        } completion:nil];
    };
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel numberOfBuckets];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    QiniuBucketCellModel *cellModel = self.viewModel.cellModels[indexPath.row];
    return cellModel.expand ? 88 : 44;
}

- (ToolCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ToolCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    cell.expandHandler = self.expandHandler;

    QiniuBucketCellModel *cellModel = self.viewModel.cellModels[indexPath.row];
    cell.label.text = cellModel.bucket.name;
    [cell updateExpandState:cellModel.expand];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    QiniuBucket *bucket = self.viewModel.cellModels[indexPath.row].bucket;
    kQiniuResourceManager.selectedBucket = bucket;
    
    QiniuResouresViewController *vc = [[QiniuResouresViewController alloc] initWithBucket:bucket];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)viewDidLayoutSubviews {
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

- (UITableView *)tableView {
    if (_tableView != nil) {
        return _tableView;
    }

    UITableView *tableView = [[UITableView alloc] init];
    _tableView = tableView;
    tableView.dataSource = self;
    tableView.delegate = self;
//    tableView.allowsMultipleSelection = YES;    // 支持全选功能必须要开启多选，想想也明白啊
    tableView.backgroundColor = self.view.backgroundColor;
    tableView.tableFooterView = [UIView new];
    [tableView registerClass:ToolCell.class forCellReuseIdentifier:kCellIdentifier];
    return tableView;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end

#undef kCellIdentifier

