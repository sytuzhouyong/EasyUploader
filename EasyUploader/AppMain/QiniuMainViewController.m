//
//  QiniuResourceMainViewController.m
//  EasyUploader
//
//  Created by zhouyong on 17/2/28.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "QiniuMainViewController.h"
#import "ZyxPickAlbumViewController.h"
#import "QiniuBucketViewModel.h"
#import "ToolCell.h"

#define kExpandButtonTag        1000
#define kLabelTag               2000
#define kCellToolViewTag        3000

#define kCellIdentifier         @"ToolCell"

@interface QiniuMainViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) QiniuBucketViewModel *viewModel;
@property (nonatomic, strong) NSIndexPath *lastIndexPath;

@end

@implementation QiniuMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"我的七牛云";
    [self addSubviews];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor cyanColor];
    self.leftBarButtonWidth = 0;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    [QiniuResourceManager queryAllBucketsWithHandler:^(NSArray<QiniuBucket *> *buckets) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.viewModel = [[QiniuBucketViewModel alloc] initWithBuckets:buckets];
            [self.tableView reloadData];
        });
    }];
}

- (void)addSubviews {
    [self.view addSubview:self.tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsets(kBaseViewControllerTitleViewHeight, 0, 0, 0));
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.cellModels.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    QiniubucketCellModel *cellModel = self.viewModel.cellModels[indexPath.row];
    return cellModel.expand ? 84 : 44;
}

- (ToolCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ToolCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];

    cell.expandHandler = ^(UIButton *button) {
        NSArray *indexPaths = @[indexPath];
        if (self.lastIndexPath && self.lastIndexPath.row != indexPath.row && [self.viewModel isExpandAtRow:self.lastIndexPath.row]) {
            indexPaths = @[indexPath, self.lastIndexPath];
            [self.viewModel updateExpandStateAtRow:self.lastIndexPath.row];
        }

        [self.viewModel updateExpandStateAtRow:indexPath.row];
        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        self.lastIndexPath = indexPath;
    };

    QiniubucketCellModel *cellModel = self.viewModel.cellModels[indexPath.row];
    cell.label.text = cellModel.bucket.name;
    [cell updateExpandState:cellModel.expand];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    QiniuBucket *bucket = self.viewModel.cellModels[indexPath.row].bucket;
    [QiniuResourceManager queryResourcesInBucket:bucket.name withPrefix:@"" limit:20 handler:^(NSArray<QiniuResource *> *resources) {
        if (resources.count == 0) {
            return;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            ;
        });
    }];
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
    tableView.allowsMultipleSelection = YES;    // 支持全选功能必须要开启多选，想想也明白啊
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

