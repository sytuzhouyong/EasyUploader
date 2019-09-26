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
#import "JGPhotoBrowser.h"
#import "JGPBPhoto.h"

@interface QiniuResourceContentViewController ()

@property (nonatomic, strong) QiniuBucket *bucket;
@property (nonatomic, strong) QiniuResourceViewModel *viewModel;
@property (nonatomic, strong) NSIndexPath *lastIndexPath;
@property (nonatomic, copy) ExpandButtonHandler expandHandler;
@property (nonatomic, copy) ExpandButtonHandler downloadHandler;
@property (nonatomic, copy) ExpandButtonHandler deleteHandler;
@property (nonatomic, weak) QiniuResouresViewController *parentVC;
@property (nonatomic, copy) NSString *currentPath;
@property (nonatomic, copy) NSString *marker;   // 用于分页数据查找下一页的数据

@property (nonatomic, strong) RLMNotificationToken *token;

@end

@implementation QiniuResourceContentViewController

// name: full path, for example: test1/test11
- (instancetype)initWithBucket:(QiniuBucket *)bucket path:(NSString *)name parentVC:(UIViewController *)parentVC {
    if ( self = [super initWithStyle:UITableViewStylePlain]) {
        self.bucket = bucket;
        self.parentVC = (QiniuResouresViewController *)parentVC;
        self.currentPath = name.length == 0 ? @"" : [NSString stringWithFormat:@"%@/", name];
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
//    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadMore:)];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMore:)];

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.parentVC.navigationController.view animated:YES];
    hud.label.text = @"加载中..."; //NSLocalizedString(@"Loading...", @"HUD loading title");
    [kQiniuResourceManager queryResourcesInBucket:_bucket withPrefix:self.currentPath limit:10 marker:self.marker handler:^(NSArray<QiniuResource *> *resources, NSString *marker) {
        dispatch_async(dispatch_get_main_queue(), ^{
            QiniuResourceType type = kAppDelegate.isUnderPathSelectMode ? QiniuResourceTypeDir : QiniuResourceTypeAll;
            self.viewModel = [[QiniuResourceViewModel alloc] initWithResources:resources type:type];
            [self.tableView reloadData];
            self.marker = marker;
            [hud hideAnimated:YES];
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

        BOOL expand = [weakself.viewModel isExpandAtIndexPath:indexPath];
        [weakself.viewModel updateExpandStateAtIndexPath:indexPath];
        weakself.lastIndexPath = indexPath;

        [UIView animateWithDuration:0.3 animations:^{
             [weakself.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            if (!expand) {
                button.transform = CGAffineTransformRotate(button.transform, M_PI);
            } else {
                button.transform = CGAffineTransformRotate(button.transform, -M_PI);
            }
        } completion:nil];
    };
    self.downloadHandler = ^(UIButton *button) {
        CGPoint pt = [weakself.tableView convertPoint:button.center fromView:button.superview];
        NSIndexPath *indexPath = [weakself.tableView indexPathForRowAtPoint:pt];

        QiniuResource *resource = [weakself.viewModel resourceAtIndexPath:indexPath];
        [kQiniuDownloadManager downloadResourceWithKey:resource.name handler:^(BOOL success, NSURL *destURL) {
            ;
        }];
    };
    self.deleteHandler = ^(UIButton *button) {
        CGPoint pt = [weakself.tableView convertPoint:button.center fromView:button.superview];
        NSIndexPath *indexPath = [weakself.tableView indexPathForRowAtPoint:pt];

        QiniuResource *resource = [weakself.viewModel resourceAtIndexPath:indexPath];

        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakself.parentVC.navigationController.view animated:YES];
        hud.label.text = @"删除中...";
        [kQiniuResourceManager deleteResourceNamed:resource.name inBucket:weakself.bucket withHandler:^(BOOL success, id responseObject) {
            hud.label.text = success ? @"删除成功" : @"删除失败";
            [hud hideAnimated:YES];
            if (success) {
                [weakself.viewModel deleteResourceAtIndexPath:indexPath];
                [weakself.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }];
    };
}

- (void)loadMore:(id)obj {
    // 没有mark说明没有下一页的数据
    if (_marker.length == 0) {
        [self.tableView.mj_footer endRefreshing];
        return;
    }
    
    [kQiniuResourceManager queryResourcesInBucket:_bucket withPrefix:self.currentPath limit:3 marker:_marker handler:^(NSArray<QiniuResource *> *resources, NSString *marker) {
        self.marker = marker;
        if (resources.count == 0) {
            [self.tableView.mj_footer endRefreshing];
            return;
        }
        
        QiniuResourceType type = kAppDelegate.isUnderPathSelectMode ? QiniuResourceTypeDir : QiniuResourceTypeAll;
        [self.viewModel addResources:resources type:type];
        [self.tableView reloadData];
        [self.tableView.mj_footer endRefreshing];
    }];
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
    cell.deleteHandler = self.deleteHandler;

    [cell configWithQiniuResource:resource prefix:self.currentPath];
    [cell updateExpandState:expand];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    QiniuResource *resource = [self.viewModel resourceAtIndexPath:indexPath];
    if (resource.type == QiniuResourceTypeDir) {
        [self.parentVC enterContentVCNamed:resource.name];
        return;
    }

    NSUInteger selectedIndex = indexPath.row;
    NSMutableArray *photoArray = [NSMutableArray array];
    
    for (int i=0; i<[self.viewModel numberOfResources]; i++) {
        QiniuResource *resource = [self.viewModel resourceAtIndexPath:NSIndexPath(0, i)];
        if (resource.type != QiniuResourceTypeFile) {
            if (indexPath.row > i) {
                selectedIndex--;
            }
            continue;
        }

        NSURL *url = [kQiniuDownloadManager urlWithKey:resource.name];

        JGPhoto *photo = [[JGPhoto alloc] init];
        photo.url = url;
        photo.srcImageView = ((ResourceToolCell *)[tableView cellForRowAtIndexPath:indexPath]).iconImageView;
        [photoArray addObject:photo];
    }

    JGPBBrowserController *photoBrowser = [[JGPBBrowserController alloc] initWithPhotos:photoArray index:selectedIndex];
    [photoBrowser show];
}

- (void)viewDidLayoutSubviews {
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    [self.tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
