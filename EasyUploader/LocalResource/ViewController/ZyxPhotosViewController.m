//
//  ZyxPhotosViewController.m
//  XingHomecloud
//
//  Created by zhouyong on 12/28/15.
//  Copyright © 2015 zhouyong. All rights reserved.
//

#import "ZyxPhotosViewController.h"
#import "ZyxPhotoManager.h"
#import "ZyxPhotoCollectionViewCell.h"
#import "SelectUploadPathToolView.h"

#define kPhotoCellIdentifier            @"ZyxPhotoCell"
#define kPhotoSectionHeaderIdentifier   @"ZyxPhotoSectionHeader"
#define kPhotoSectionFooterIdentifier   @"ZyxPhotoSectionFooter"

@interface ZyxPhotosViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ZyxPickAlbumViewControllerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) ALAssetsGroup *group;
@property (nonatomic, assign) CGSize cellSize;

@property (nonatomic, strong) NSMutableArray<NSString *> *dateDescs;    // 有序
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSDate *> *datesDict;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<ALAsset *> *> *assetsDict;

@property (nonatomic, strong) SelectUploadPathToolView *toolView;

@end

@implementation ZyxPhotosViewController

- (instancetype)initWithAssetsGroup:(ALAssetsGroup *)group {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.group = group;
        self.numberOfCellsPerLine = 4;
        self.cellSpacing = 5;
        self.isSelectAll = NO;
        self.dateDescs = [NSMutableArray array];
        self.datesDict = [NSMutableDictionary dictionary];
        self.assetsDict = [NSMutableDictionary dictionary];
        [self enumPhotosInGroup:group];
    }
    return self;
}

- (void)viewDidLoad {    
    [super viewDidLoad];
    self.title = [kZyxPhotoManager nameOfGroup:self.group];
    // Do any additional setup after loading the view.
    [self addSubviews];
    [self createRightBarButtonWithTitle:Text(@"SelectAll") action:@"selectButtonPressed"];
}

- (void)selectButtonPressed {
    self.isSelectAll = !self.isSelectAll;
    self.rightBarButtonTitle = Text(self.isSelectAll ? @"CancelSelectAll" : @"SelectAll");
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat width = _collectionView.frame.size.width;
    UIEdgeInsets insets = ((UICollectionViewFlowLayout *)_collectionView.collectionViewLayout).sectionInset;
    CGFloat cellWidth = (width - (_numberOfCellsPerLine - 1) * _cellSpacing - insets.left - insets.right) / _numberOfCellsPerLine;
    self.cellSize = CGSizeMake(cellWidth, cellWidth);
}

- (void)addSubviews {
    [self.view addSubview:self.toolView];
    [_toolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.height.mas_equalTo(52);
    }];

    [self.view addSubview:self.collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(self.titleView.mas_bottom);
        make.bottom.equalTo(self.toolView.mas_top);
    }];
}

- (void)enumPhotosInGroup:(ALAssetsGroup *)group {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary<NSString *, NSMutableArray<ALAsset *> *> *unuploadAssetsDict = [NSMutableDictionary dictionary];
        NSMutableDictionary<NSString *, NSMutableArray<ALAsset *> *> *allAssetsDict = [NSMutableDictionary dictionary];
        NSMutableDictionary<NSString *, NSDate *> *dateStringsDict = [NSMutableDictionary dictionary];
        
        [group setAssetsFilter:[ALAssetsFilter allAssets]];
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
            if (asset == nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self addAssetsDict:allAssetsDict dateStringsDict:dateStringsDict];
                });
                return;
            }
            
//            NSURL *url = [asset valueForProperty:ALAssetPropertyAssetURL];
            NSDate *date = [asset valueForProperty:ALAssetPropertyDate];
            NSString *yyyyMMdd = [DateUtil yyyyMMddStringWithDate:date];
            dateStringsDict[yyyyMMdd] = date;
            
            NSMutableArray<ALAsset *> *allAssets = allAssetsDict[yyyyMMdd];
            if (allAssets == nil) {
                allAssets = [NSMutableArray array];
                allAssetsDict[yyyyMMdd] = allAssets;
            }
            [allAssets addObject:asset];
            
            if ((index % 200) == 0) {
                // 这边必须要用dispatch_sync，不能用dispatch_async
                // 因为这边有清除allAssetsDict和unuploadAssetsDict数据，而这两个数据实在后台线程中修改的
                // 如果使用dispatch_async，那么函数会直接返回继续下个循环，在下个循环中会向这两个字典中添加数据，
                // 而此时在主线程中会更新UI, 并且会将这两个数据源清空，这时后台线程就有可能正在操作字典里面的数据，
                // 导致操作被释放的数据，引起异常。
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self addAssetsDict:allAssetsDict dateStringsDict:dateStringsDict];
                    
                    [allAssetsDict removeAllObjects];
                    [unuploadAssetsDict removeAllObjects];
                });
            }
        }];
    });
}


- (NSMutableSet<ALAsset *> *)selectedPhotos {
    NSMutableSet<ALAsset *> *assets = [NSMutableSet set];
    NSArray<NSIndexPath *> *indexPaths = [_collectionView indexPathsForSelectedItems];
    for (NSIndexPath *indexPath in indexPaths) {
        ALAsset *asset = [self assetAtIndexPath:indexPath];
        [assets addObject:asset];
    }
    return assets;
}

- (void)removePhototOfURLString:(NSString *)urlString {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [_dateDescs enumerateObjectsUsingBlock:^(NSString *key1, NSUInteger i1, BOOL *stop1) {
            NSMutableArray *assetsInDateSection = _assetsDict[key1];
            [assetsInDateSection enumerateObjectsUsingBlock:^(ALAsset *key2, NSUInteger i2, BOOL *stop2) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i2 inSection:i1];
                ALAsset *asset = [self assetAtIndexPath:indexPath];
                NSURL *url = [asset valueForProperty:ALAssetPropertyAssetURL];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([urlString isEqualToString:url.absoluteString]) {
                        [assetsInDateSection removeObjectAtIndex:i2];
                        
                        if (assetsInDateSection.count == 0) {
                            [_assetsDict removeObjectForKey:key1];
                            [_dateDescs removeObjectAtIndex:i1];
                            [_collectionView deleteSections:[NSIndexSet indexSetWithIndex:i1]];
                        } else {
                            [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
                        }
                        return;
                    }
                });
            }];
        }];
    });
}

- (void)addAssetsDict:(NSDictionary<NSString *, NSArray<ALAsset *> *> *)assetsDict dateStringsDict:(NSDictionary<NSString *, NSDate *> *)dateStringsDict {
    [assetsDict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray<ALAsset *> *obj, BOOL *stop) {
        NSMutableArray<ALAsset *> *assets = _assetsDict[key];
        if (assets == nil) {
            assets = [NSMutableArray array];
            _assetsDict[key] = assets;
            [_dateDescs addObject:key];
        }
        [assets addObjectsFromArray:obj];
        
        NSDate *date = dateStringsDict[key];
        _datesDict[key] = date;
    }];
    
    [_dateDescs sortUsingComparator:^NSComparisonResult(NSDate *obj1, NSDate *obj2) {
        return [obj2 compare:obj1];
    }];
    
    [self.collectionView reloadData];
}

#pragma mark - Button Action

- (void)setIsSelectAll:(BOOL)isSelectAll {
    _isSelectAll = isSelectAll;
    
    [_dateDescs enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString *key1, NSUInteger i1, BOOL *stop1) {
        [_assetsDict[key1] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *key2, NSUInteger i2, BOOL *stop2) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i2 inSection:i1];
            if (_isSelectAll) {
                [_collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            } else {
                [_collectionView deselectItemAtIndexPath:indexPath animated:NO];
            }
        }];
    }];
}

#pragma mark - UICollectionView Delegate Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _dateDescs.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSString *key = _dateDescs[section];
    NSInteger count =_assetsDict[key].count;
    return count;
}

- (ZyxPhotoCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZyxPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellIdentifier forIndexPath:indexPath];
    cell.mode = ZyxImagePickerSelectionModeMultiple;
    
    ALAsset *asset = [self assetAtIndexPath:indexPath];
    [cell configCellWithAsset:asset];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([_selectDelegate respondsToSelector:@selector(didSelectPhoto:atIndexPath:)]) {
        ALAsset *asset = [self assetAtIndexPath:indexPath];
        [_selectDelegate didSelectPhoto:asset atIndexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([_selectDelegate respondsToSelector:@selector(didDeselectPhoto:atIndexPath:)]) {
        ALAsset *asset = [self assetAtIndexPath:indexPath];
        [_selectDelegate didDeselectPhoto:asset atIndexPath:indexPath];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *selectedItems = [collectionView indexPathsForSelectedItems];
    return ![selectedItems containsObject:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _cellSize;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return _cellSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return _cellSpacing;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(0, 32);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *view = nil;
    
    if ([kind isEqualToString: UICollectionElementKindSectionFooter]) {
        view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kPhotoSectionFooterIdentifier forIndexPath:indexPath];
    } else {
        view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kPhotoSectionHeaderIdentifier forIndexPath:indexPath];
        
        if (view.subviews.count == 0) {
            UILabel *label = [[UILabel alloc] init];
            label.textColor = GrayColor(0x3A);
            label.font = UIFontOfSize(16);
            [view addSubview:label];
        }
        UILabel *label = (UILabel *)view.subviews.firstObject;
        NSString *yyyyMMdd = _dateDescs[indexPath.section];
        NSString *dateString = [DateUtil intelligentDateStringWithDate:_datesDict[yyyyMMdd]];
        label.text = dateString;
        
        CGFloat x = ((UICollectionViewFlowLayout *)collectionView.collectionViewLayout).sectionInset.left;
        
        NSDictionary *attributes = @{NSFontAttributeName: label.font};
        CGFloat height = roundf([label.text sizeWithAttributes:attributes].height + 0.5f);
        CGRect frame = CGRectMake(x, view.frame.size.height - height, view.frame.size.width, height);
        label.frame = frame;
    }
    
    return view;
}


#pragma mark - Getter and Setter

- (UICollectionView *)collectionView {
    ReturnObjectIfNotNil(_collectionView);
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    // 设置section距离collection view 边框的间距
    layout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 15);
    
    UICollectionView *view = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView = view;
    [view registerClass:ZyxPhotoCollectionViewCell.class forCellWithReuseIdentifier:kPhotoCellIdentifier];
    [view registerClass:UICollectionReusableView.class forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kPhotoSectionHeaderIdentifier];
    [view registerClass:UICollectionReusableView.class forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kPhotoSectionFooterIdentifier];
    view.delegate = self;
    view.dataSource = self;
    view.backgroundColor = [UIColor whiteColor];
    view.allowsMultipleSelection = (self.selectionMode == ZyxImagePickerSelectionModeMultiple);
    return view;
}

- (SelectUploadPathToolView *)toolView {
    ReturnObjectIfNotNil(_toolView);

    SelectUploadPathToolView *view = [[SelectUploadPathToolView alloc] init];
    _toolView = view;
    return view;
}

- (ALAsset *)assetAtIndexPath:(NSIndexPath *)indexPath {
    ALAsset *asset = _assetsDict[_dateDescs[indexPath.section]][indexPath.row];
//    NSDate *date = [asset valueForProperty:ALAssetPropertyDate];
//    NSString *type = [asset valueForProperty:ALAssetPropertyType];
//    NSURL *url = [asset valueForProperty:ALAssetPropertyAssetURL];
//    DDLogVerbose(@"asset date in indexPath(%@, %@) is %@, %@, %@,", @(indexPath.section), @(indexPath.row), date, type, url);
    return asset;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
