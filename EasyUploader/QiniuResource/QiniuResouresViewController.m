//
//  QiniuResouresViewController.m
//  EasyUploader
//
//  Created by zhouyong on 17/7/26.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "QiniuResouresViewController.h"

@interface QiniuResouresViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) CGSize cellSize;

@property (nonatomic, strong) NSArray<QiniuResource *> *resouces;

@end

@implementation QiniuResouresViewController

- (instancetype)init {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.numberOfCellsPerLine = 4;
        self.cellSpacing = 5;
        self.isSelectAll = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat width = _collectionView.frame.size.width;
    UIEdgeInsets insets = ((UICollectionViewFlowLayout *)_collectionView.collectionViewLayout).sectionInset;
    CGFloat cellWidth = (width - (_numberOfCellsPerLine - 1) * _cellSpacing - insets.left - insets.right) / _numberOfCellsPerLine;
    self.cellSize = CGSizeMake(cellWidth, cellWidth);
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
