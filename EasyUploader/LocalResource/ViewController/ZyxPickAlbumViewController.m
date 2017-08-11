//
//  ZyxPickAlbumViewController.m
//  TestReadImage
//
//  Created by zhouyong on 12/25/15.
//  Copyright © 2015 zhouyong. All rights reserved.
//

#import "ZyxPickAlbumViewController.h"
#import "ZyxPhotosViewController.h"
#import "UINormalTableViewCell.h"
#import "QiniuUploadManager.h"
#import "ALAssetUtil.h"

#define kCellIdentifier  @"ZyxPickAlbumViewControllerCell"

@interface ZyxPickAlbumViewController () <UITableViewDataSource, UITableViewDelegate,
    ZyxPickAlbumViewControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<ALAssetsGroup *> *groups;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *selectFlags;

@end

@implementation ZyxPickAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = Text(@"SelectAlbum");
    [self addSubviews];

    if (self.selectionMode == ZyxImagePickerSelectionModeMultiple) {
        [self createRightBarButtonWithTitle:Text(@"SelectAll") action:@"selectAllButtonPressed"];
    }
    
    if (![DeviceUtil isPhotoAuthorized]) {
        [kAppDelegate showPhotoAuthorizationAlertView];
        return;
    }
    
    self.groups = [kZyxPhotoManager allGroups];
    self.selectFlags = [NSMutableArray array];
    for (NSUInteger i=0; i<self.groups.count; i++) {
        [_selectFlags addObject:@(NO)];
    }
}

- (void)addSubviews {
    MASViewAttribute *attribute = nil;
    
    if (self.selectionMode != ZyxImagePickerSelectionModeNone) {
    } else {
        attribute = self.view.mas_bottom;
    }
    
    [self.view addSubview:self.tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.and.trailing.equalTo(self.view);
        make.top.equalTo(self.titleView.mas_bottom);
        make.bottom.equalTo(attribute);
    }];
}

#pragma mark - SelectPathViewDelegate Methods

- (void)changePathButtonPressed {
}

- (void)uploadButtonPressed {
    
}

- (void)didSelectCell:(UITableViewCell *)cell  {
    NSInteger count = [self.class numberInString:self.title] + 1;
    self.title = [NSString stringWithFormat:Text(@"SelectedItemsCount"), @(count)];
}

- (void)didDeselectCell:(UITableViewCell *)cell {
    NSInteger count = [self.class numberInString:self.title];
    self.title = [NSString stringWithFormat:Text(@"SelectedItemsCount"), @(count-1)];
}

#pragma mark - ZyxPickAlbumViewControllerDelegate Methods

- (void)zyxImagePickrController:(ZyxPickAlbumViewController *)picker didFinishPickingMedioWithInfos:(NSArray<NSDictionary *> *)infos {
    if ([_imagePickerDelegate respondsToSelector:@selector(zyxImagePickrController:didFinishPickingMedioWithInfos:)]) {
        [_imagePickerDelegate zyxImagePickrController:self didFinishPickingMedioWithInfos:infos];
    }
}

#pragma mark - Button Action

- (void)selectAllButtonPressed {
    static BOOL isSelectAll = NO;
    isSelectAll = !isSelectAll;
    
    NSString *title = isSelectAll ? Text(@"CancelSelectAll") : Text(@"SelectAll");
    self.rightBarButtonTitle = title;
    self.title = isSelectAll ? [NSString stringWithFormat:Text(@"SelectedItemsCount"), @(self.groups.count)] : Text(@"SelectedUploadItems");
    
    for (NSInteger i=0; i<_selectFlags.count; i++) {
        _selectFlags[i] = @(isSelectAll);
    }
    [_tableView reloadData];
}

- (void)selectButtonPressed:(UIButton *)button {
    CGPoint pt = [_tableView convertPoint:button.center fromView:button.superview];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:pt];
    BOOL flag = [_selectFlags[indexPath.row] boolValue];
    _selectFlags[indexPath.row] = @(!flag);
    
    if (!flag) {
        [self didSelectCell:nil];
    } else {
        [self didDeselectCell:nil];
    }
    
    NSString *imageName = ImageNameOfSelectedState(!flag);
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

#pragma mark - UITableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _groups.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 64.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (cell == nil) {
        cell = [[UINormalTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 1000;
        [button addTarget:self action:@selector(selectButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cell.contentView);
            make.bottom.equalTo(cell.contentView);
            make.trailing.equalTo(cell.contentView);
            make.width.equalTo(@64);
        }];
    }
    
    UIButton *button = (UIButton *)[cell viewWithTag:1000];
    if (_selectionMode == ZyxImagePickerSelectionModeNone) {
        button.hidden = YES;
    } else {
        BOOL isSelected = [self.selectFlags[indexPath.row] boolValue];
        NSString *imageName = ImageNameOfSelectedState(isSelected);
        [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }

    ALAssetsGroup *group = _groups[indexPath.row];
    UIImage *image = [kZyxPhotoManager latestPhotoInGroup:group withType:ZyxImageTypeThumbnail];
    cell.imageView.image = image;
    cell.textLabel.text = [group valueForProperty:ALAssetsGroupPropertyName];
    cell.detailTextLabel.text = [NSString stringWithFormat:Text(@"ImageCount"), @([kZyxPhotoManager numberOfPhotosInGroup:group])];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ALAssetsGroup *group = _groups[indexPath.row];
    ZyxPhotosViewController *vc = [[ZyxPhotosViewController alloc] initWithAssetsGroup:group];
    vc.selectionMode = ZyxImagePickerSelectionModeMultiple;
    vc.selectDelegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0,10,0,0)];
    }

    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

#pragma mark - ZyxSelectPhotoDelegate Methods

- (void)didSelectPhoto:(ALAsset *)asset atIndexPath:indexPath {
//    [self.selectedPhotos addObject:asset];

//    NSString *key = [ALAssetUtil defaultDateStringOfALAsset:asset];
//    [[QiniuUploadManager sharedInstance] uploadALAsset:asset withKey:key];
}

- (void)didDeselectPhoto:(ALAsset *)asset atIndexPath:indexPath {
//    [self.selectedPhotos removeObject:asset];
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
    tableView.dataSource = self;
    tableView.delegate = self;
    return tableView;
}

+ (NSInteger)numberInString:(NSString *)string {
    NSScanner *scan = [NSScanner scannerWithString:string];
    do {
        if (![scan scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:nil]) {
            break;
        }
        NSInteger count = 0;
        if ([scan scanInteger:&count]) {
            return count;
        }
    } while (NO);
    
    return 0;
}

@end
