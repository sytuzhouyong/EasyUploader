//
//  QiniuResourceMainViewController.m
//  EasyUploader
//
//  Created by zhouyong on 17/2/28.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "QiniuMainViewController.h"
#import "ZyxPickAlbumViewController.h"

@interface QiniuMainViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<QiniuBucket *> *buckets;

@end

@implementation QiniuMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    [QiniuResourceManager queryResourcesInBucket:@"easy-uploader" withPrefix:@"" limit:10];

    [self addSubviews];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor cyanColor];
//    ZyxPickAlbumViewController *vc = [[ZyxPickAlbumViewController alloc] init];
//    vc.selectionMode = ZyxImagePickerSelectionModeNone;
//    vc.imagePickerDelegate = self;
//    [self.navigationController pushViewController:vc animated:YES];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    [QiniuResourceManager queryAllBucketsWithHandler:^(NSArray<QiniuBucket *> *buckets) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.buckets = [NSMutableArray arrayWithArray:buckets];
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
    return self.buckets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"BucketCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UINormalTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }

    QiniuBucket *bucket = self.buckets[indexPath.row];
    cell.textLabel.text = bucket.name;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    QiniuBucket *bucket = self.buckets[indexPath.row];
    [QiniuResourceManager queryResourcesInBucket:bucket.name withPrefix:@"" limit:10 handler:^(NSArray<QiniuResource *> *resources) {
        if (resources.count == 0) {
            return;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            ;
        });
    }];
}


- (void)zyxImagePickrController:(ZyxPickAlbumViewController *)picker didFinishPickingMedioWithInfos:(NSArray<NSDictionary *> *)infos {
    NSLog(@"111111");
}

- (void)viewDidLayoutSubviews {
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,10,0,0)];
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
    return tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
