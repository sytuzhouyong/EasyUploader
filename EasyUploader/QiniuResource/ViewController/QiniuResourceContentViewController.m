//
//  QiniuResourceContentViewController.m
//  EasyUploader
//
//  Created by zhouyong on 26/08/2017.
//  Copyright © 2017 zhouyong. All rights reserved.
//

#import "QiniuResourceContentViewController.h"
#import "QiniuResouresViewController.h"
#import "ResourceToolCell.h"
#import "QiniuViewModel.h"

@interface QiniuResourceContentViewController ()

@property (nonatomic, strong) QiniuBucket *bucket;
@property (nonatomic, strong) QiniuResourceViewModel *viewModel;
@property (nonatomic, strong) NSIndexPath *lastIndexPath;
@property (nonatomic, copy) ExpandButtonHandler expandHandler;
@property (nonatomic, copy) ExpandButtonHandler downloadHandler;
@property (nonatomic, weak) QiniuResouresViewController *parentVC;
@property (nonatomic, copy) NSString *currentPath;

@end

@implementation QiniuResourceContentViewController

- (instancetype)initWithBucket:(QiniuBucket *)bucket parentVC:(QiniuResouresViewController *)parentVC {
    if ( self = [super initWithStyle:UITableViewStylePlain]) {
        self.bucket = bucket;
        self.parentVC = parentVC;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initHandlers];

    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:ResourceToolCell.class forCellReuseIdentifier:kFileCellIdentifier];
    [self.tableView registerClass:ResourceToolCell.class forCellReuseIdentifier:kDirCellIdentifier];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadMore:)];
    self.tableView.backgroundColor = RGB(random()%255, random()%255, random()%255);

    self.currentPath = [self prefixFromPaths:self.parentVC.paths];
    [QiniuResourceManager queryResourcesInBucket:_bucket withPrefix:self.currentPath limit:100 handler:^(NSArray<QiniuResource *> *resources) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.viewModel = [[QiniuResourceViewModel alloc] initWithResources:resources];
            [self.tableView reloadData];
        });
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

    [cell configWithQiniuResource:resource prefix:self.currentPath];
    [cell updateExpandState:expand];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    QiniuResource *resource = [self.viewModel resourceAtIndexPath:indexPath];
    if (resource.type == QiniuResourceTypeFile) {
        return;
    }

    [self.parentVC enterSubpath:resource.name];

    QiniuResourceContentViewController *vc = [[QiniuResourceContentViewController alloc] initWithBucket:self.bucket parentVC:self.parentVC];
    vc.view.frame = CGRectOffset(self.view.frame, kWindowWidth, 0);
    [self.view.superview insertSubview:vc.view belowSubview:self.view];

    // notice: must have a delay, because vc.view must has benn in view hierarchy
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            self.view.frame = CGRectOffset(self.view.frame, -kWindowWidth, 0);
            vc.view.frame = CGRectOffset(vc.view.frame, -kWindowWidth, 0);
        } completion:nil];
    });

}

- (void)viewDidLayoutSubviews {
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    [self.tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
}

- (NSString *)prefixFromPaths:(NSArray *)paths {
    NSMutableString *path = [NSMutableString string];
    [paths enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        if (idx != 0) {
            [path appendString:obj];
        }
    }];
    return path;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end