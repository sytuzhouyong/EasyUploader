//
//  QiniuResouresViewController.m
//  EasyUploader
//
//  Created by zhouyong on 17/7/26.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "QiniuResouresViewController.h"

@interface QiniuResouresViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray<QiniuResource *> *resouces;
@property (nonatomic, strong) NSString *bucket;

@end

@implementation QiniuResouresViewController

- (instancetype)initWithBucket:(NSString *)bucket {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.bucket = bucket;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addSubviews];

    [QiniuResourceManager queryResourcesInBucket:_bucket withPrefix:@"" limit:20 handler:^(NSArray<QiniuResource *> *resources) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.resouces = resources;
            [self.tableView reloadData];
        });
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resouces.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (ToolCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void)viewDidLayoutSubviews {
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

- (void)addSubviews {
    [self.view addSubview:self.collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.top.equalTo(self.titleView.mas_bottom);
    }];
}

#pragma mark - UICollectionView Delegate Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _resouces.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    NSString *key = _dateDescs[section];
//    NSInteger count =_assetsDict[key].count;
//    return count;
    return 0;
}

- (ZyxPhotoCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZyxPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ResourceCell" forIndexPath:indexPath];
    cell.mode = ZyxImagePickerSelectionModeMultiple;

//    ALAsset *asset = [self assetAtIndexPath:indexPath];
//    [cell configCellWithAsset:asset];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    if ([_selectDelegate respondsToSelector:@selector(didSelectPhoto:atIndexPath:)]) {
//        ALAsset *asset = [self assetAtIndexPath:indexPath];
//        [_selectDelegate didSelectPhoto:asset atIndexPath:indexPath];
//    }
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
