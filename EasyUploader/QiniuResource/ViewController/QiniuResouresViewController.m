//
//  QiniuResouresViewController.m
//  EasyUploader
//
//  Created by zhouyong on 17/7/26.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "QiniuResouresViewController.h"
#import "ResourceToolCell.h"
#import "QiniuViewModel.h"
#import "LocalMainViewController.h"


@interface QiniuResouresViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) QiniuBucket *bucket;
@property (nonatomic, strong) QiniuResourceViewModel *viewModel;
@property (nonatomic, strong) NSIndexPath *lastIndexPath;
@property (nonatomic, copy) ExpandButtonHandler expandHandler;
@property (nonatomic, copy) ExpandButtonHandler downloadHandler;

@end

@implementation QiniuResouresViewController

- (instancetype)initWithBucket:(QiniuBucket *)bucket {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.bucket = bucket;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.bucket.name;
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tabBarController.tabBar.hidden = YES;
//    UINavigationControllerHideShowBarDuration

    [self addSubviews];
    [self initHandlers];

    [QiniuResourceManager queryResourcesInBucket:_bucket withPrefix:@"" limit:100 handler:^(NSArray<QiniuResource *> *resources) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.viewModel = [[QiniuResourceViewModel alloc] initWithResources:resources];
            [self.tableView reloadData];
        });
    }];
}

- (void)addSubviews {
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"上传" style:UIBarButtonItemStylePlain target:self action:@selector(uploadButtonClicked)];
    self.navigationController.navigationItem.rightBarButtonItem = button;

    [self.view addSubview:self.tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.top.equalTo(self.view);
    }];
}

- (void)initHandlers {
    kWeakself;
    self.expandHandler = ^(UIButton *button) {
        CGPoint pt = [weakself.tableView convertPoint:button.center fromView:button.superview];
        NSIndexPath *indexPath = [weakself.tableView indexPathForRowAtPoint:pt];
        NSArray *indexPaths = @[indexPath];
        if (self.lastIndexPath && self.lastIndexPath.row != indexPath.row && [self.viewModel isExpandAtIndexPath:self.lastIndexPath]) {
            indexPaths = @[indexPath, self.lastIndexPath];
            [weakself.viewModel updateExpandStateAtIndexPath:weakself.lastIndexPath];
        }

        [weakself.viewModel updateExpandStateAtIndexPath:indexPath];
        [weakself.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        weakself.lastIndexPath = indexPath;
    };
    self.downloadHandler = ^(UIButton *button) {
        CGPoint pt = [weakself.tableView convertPoint:button.center fromView:button.superview];
        NSIndexPath *indexPath = [weakself.tableView indexPathForRowAtPoint:pt];

        QiniuResource *resource = [weakself.viewModel resourceAtIndexPath:indexPath];
        [kQiniuDownloadManager downloadResourceWithKey:resource.name handler:^(BOOL success, NSURL *destURL) {
            ;
        }];
    };
}

- (void)loadMore:(id)obj {
    [self.tableView.mj_header endRefreshing];
}

#pragma mark - Button Event

- (void)uploadButtonClicked {
    LocalMainViewController *vc = [[LocalMainViewController alloc] init];
//    vc.leftBarButtonWidth = 44;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel numberOfResources];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL expand = [self.viewModel isExpandAtIndexPath:indexPath];
    return expand ? 94 : 50;
}

- (ResourceToolCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QiniuResource *resource = [self.viewModel resourceAtIndexPath:indexPath];
    BOOL expand = [self.viewModel isExpandAtIndexPath:indexPath];

    NSString *identifier = resource.type == QiniuResourceTypeDir ? kDirCellIdentifier : kFileCellIdentifier;
    ResourceToolCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.expandHandler = self.expandHandler;
    cell.downloadHandler = self.downloadHandler;

    [cell configWithQiniuResource:resource];
    [cell updateExpandState:expand];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    QiniuResource *resource = [self.viewModel resourceAtIndexPath:indexPath];
    if (resource.type == QiniuResourceTypeFile) {
        return;
    }

    [QiniuResourceManager queryResourcesInBucket:self.bucket withPrefix:resource.name limit:20 handler:^(NSArray<QiniuResource *> *resources) {
        NSLog(@"%@", resources);
    }];
    NSLog(@"xx");
}

- (void)viewDidLayoutSubviews {
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

# pragma mark - Getter and Setter

- (UITableView *)tableView {
    if (_tableView != nil) {
        return _tableView;
    }

    UITableView *tableView = [[UITableView alloc] init];
    _tableView = tableView;
    tableView.delegate = self;
    tableView.dataSource = self;
//    tableView.allowsMultipleSelection = YES;    // 支持全选功能必须要开启多选，想想也明白啊
    tableView.backgroundColor = self.view.backgroundColor;
    tableView.tableFooterView = [UIView new];
    [tableView registerClass:ResourceToolCell.class forCellReuseIdentifier:kFileCellIdentifier];
    [tableView registerClass:ResourceToolCell.class forCellReuseIdentifier:kDirCellIdentifier];
    tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadMore:)];
    return tableView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
