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

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"七牛云";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];

    // 不为空说明是选择上传路径界面
    if (kAppDelegate.isUnderPathSelectMode) {
        self.title = @"选择目录";

        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithImage:UIImageNamed(@"icon_arrow_left") style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)];
        self.navigationItem.leftBarButtonItem = buttonItem;
    }

    [self addSubviews];
    [self initHandlers];

    [QiniuResourceManager queryAllBucketsWithHandler:^(NSArray<QiniuBucket *> *buckets) {
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
        [UIView animateWithDuration:0.3 animations:^{
            if (!expand) {
                button.transform = CGAffineTransformRotate(button.transform, -M_PI*0.0000001);
            } else {
                button.transform = CGAffineTransformRotate(button.transform, -M_PI);
            }
        } completion:^(BOOL finished) {
            ;
        }];

        NSArray *indexPaths = @[indexPath];
        if (self.lastIndexPath && self.lastIndexPath.row != indexPath.row && [self.viewModel isExpandAtIndexPath:self.lastIndexPath]) {
            indexPaths = @[indexPath, self.lastIndexPath];
            [weakself.viewModel updateExpandStateAtIndexPath:weakself.lastIndexPath];
        }

        [weakself.viewModel updateExpandStateAtIndexPath:indexPath];
        [weakself.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        weakself.lastIndexPath = indexPath;
    };
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.cellModels.count;
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

