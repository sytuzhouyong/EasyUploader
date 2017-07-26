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

@end

@implementation QiniuResouresViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - UICollectionView Delegate Methods

//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//    return _dateDescs.count;
//}
//
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    NSString *key = _dateDescs[section];
//    NSInteger count =_assetsDict[key].count;
//    return count;
//}
//
//- (ZyxPhotoCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    ZyxPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellIdentifier forIndexPath:indexPath];
//    cell.mode = ZyxImagePickerSelectionModeMultiple;
//
//    ALAsset *asset = [self assetAtIndexPath:indexPath];
//    [cell configCellWithAsset:asset];
//    return cell;
//}
//
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    if ([_selectDelegate respondsToSelector:@selector(didSelectPhoto:atIndexPath:)]) {
//        ALAsset *asset = [self assetAtIndexPath:indexPath];
//        [_selectDelegate didSelectPhoto:asset atIndexPath:indexPath];
//    }
//}

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
