//
//  QiniuResouresViewController.m
//  EasyUploader
//
//  Created by zhouyong on 17/7/26.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "QiniuResouresViewController.h"
#import "ResourceToolCell.h"

#define kCellIdentifier @"ResourceCellIdentifier"

@interface QiniuResouresViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<QiniuResource *> *resouces;
@property (nonatomic, strong) QiniuBucket *bucket;

@end

@implementation QiniuResouresViewController

- (instancetype)initWithBucket:(QiniuBucket *)bucket {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.bucket = bucket;
        self.resouces = [NSMutableArray arrayWithCapacity:20];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.bucket.name;
    [self addSubviews];

    [QiniuResourceManager queryResourcesInBucket:_bucket.name withPrefix:@"" limit:20 handler:^(NSArray<QiniuResource *> *resources) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.resouces addObjectsFromArray:resources];
            [self.tableView reloadData];
        });
    }];
}

- (void)addSubviews {
    [self.view addSubview:self.tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.top.equalTo(self.titleView.mas_bottom);
    }];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resouces.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (ResourceToolCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ResourceToolCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];

    QiniuResource *resource = self.resouces[indexPath.row];
    [cell configWithQiniuResource:resource];
    return cell;
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
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.allowsMultipleSelection = YES;    // 支持全选功能必须要开启多选，想想也明白啊
    tableView.backgroundColor = self.view.backgroundColor;
    tableView.tableFooterView = [UIView new];
    [tableView registerClass:ResourceToolCell.class forCellReuseIdentifier:kCellIdentifier];
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
