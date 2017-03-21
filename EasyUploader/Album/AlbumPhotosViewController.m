//
//  AlbumPhotosViewController.m
//  XingHomecloud
//
//  Created by zhouyong on 3/7/16.
//  Copyright © 2016 zhouyong. All rights reserved.
//

#import "AlbumPhotosViewController.h"
#import "ZyxPhotosViewController.h"

@interface AlbumPhotosViewController () <ZyxSelectPhotoDelegate>

@property (nonatomic, strong) ZyxPhotosViewController *unuploadPhotosVC;
@property (nonatomic, strong) ZyxPhotosViewController *allPhotosVC;
@property (nonatomic, weak  ) ZyxPhotosViewController *presentingVC;

@property (nonatomic, strong) NSMutableSet<ALAsset *> *selectedPhotos;


@end

@implementation AlbumPhotosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [kPhotoManager nameOfGroup:self.group];
    // Do any additional setup after loading the view.    
    self.selectedPhotos = [NSMutableSet set];
    [self addSubviews];
    [self createRightBarButtonWithTitle:Text(@"SelectAll") action:@"selectAllButtonPressed"];
    
    self.presentingVC = self.unuploadPhotosVC;
    [kNotificationCenter addObserver:self selector:@selector(taskUploadSuccess:) name:@"TaskUploadSuccess" object:nil];
    
    [self enumAsset];
}

- (void)addSubviews {
    self.unuploadPhotosVC = [[ZyxPhotosViewController alloc] initWithAssetsGroup:self.group];
    self.unuploadPhotosVC.selectionMode = ZyxImagePickerSelectionModeMultiple;
    self.unuploadPhotosVC.selectDelegate = self;
    self.allPhotosVC = [[ZyxPhotosViewController alloc] initWithAssetsGroup:self.group];
    self.allPhotosVC.selectionMode = ZyxImagePickerSelectionModeMultiple;
    self.allPhotosVC.selectDelegate = self;
}

- (void)enumAsset {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary<NSString *, NSMutableArray<ALAsset *> *> *unuploadAssetsDict = [NSMutableDictionary dictionary];
        NSMutableDictionary<NSString *, NSMutableArray<ALAsset *> *> *allAssetsDict = [NSMutableDictionary dictionary];
        NSMutableDictionary<NSString *, NSDate *> *dateStringsDict = [NSMutableDictionary dictionary];
        
        __block NSUInteger unuploadCount = 0;
        __block NSUInteger allCount = 0;
        
        [self.group setAssetsFilter:[ALAssetsFilter allAssets]];
        [self.group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
            if (asset == nil) {
                NSString *title1 = [NSString stringWithFormat:@"%@ (%@)", Text(@"NotUpload"), @(unuploadCount)];
                NSString *title2 = [NSString stringWithFormat:@"%@ (%@)", Text(@"All"), @(allCount)];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.allPhotosVC addAssetsDict:allAssetsDict dateStringsDict:dateStringsDict];
                    [self.unuploadPhotosVC addAssetsDict:unuploadAssetsDict dateStringsDict:dateStringsDict];
                });
                return;
            }
            
            NSURL *url = [asset valueForProperty:ALAssetPropertyAssetURL];
            NSDate *date = [asset valueForProperty:ALAssetPropertyDate];
            NSString *yyyyMMdd = [DateUtil yyyyMMddStringWithDate:date];
            dateStringsDict[yyyyMMdd] = date;
            
            NSMutableArray<ALAsset *> *allAssets = allAssetsDict[yyyyMMdd];
            if (allAssets == nil) {
                allAssets = [NSMutableArray array];
                allAssetsDict[yyyyMMdd] = allAssets;
            }
            [allAssets addObject:asset];
            
            allCount++;
            BOOL haveUploaded = NO;//uploadedPhotoURLStrings[url.absoluteString] != nil;
            if (!haveUploaded) {
                NSMutableArray<ALAsset *> *unuploadAssets = unuploadAssetsDict[yyyyMMdd];
                if (unuploadAssets == nil) {
                    unuploadAssets = [NSMutableArray array];
                    unuploadAssetsDict[yyyyMMdd] = unuploadAssets;
                }
                [unuploadAssets addObject:asset];
                unuploadCount++;
            }
            
            if ((index % 200) == 0) {
                NSString *title1 = [NSString stringWithFormat:@"%@ (%@)", Text(@"NotUpload"), @(unuploadCount)];
                NSString *title2 = [NSString stringWithFormat:@"%@ (%@)", Text(@"All"), @(allCount)];
                
                // 这边必须要用dispatch_sync，不能用dispatch_async
                // 因为这边有清除allAssetsDict和unuploadAssetsDict数据，而这两个数据实在后台线程中修改的
                // 如果使用dispatch_async，那么函数会直接返回继续下个循环，在下个循环中会向这两个字典中添加数据，
                // 而此时在主线程中会更新UI, 并且会将这两个数据源清空，这时后台线程就有可能正在操作字典里面的数据，
                // 导致操作被释放的数据，引起异常。
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.allPhotosVC addAssetsDict:allAssetsDict dateStringsDict:dateStringsDict];
                    [self.unuploadPhotosVC addAssetsDict:unuploadAssetsDict dateStringsDict:dateStringsDict];
                    
                    [allAssetsDict removeAllObjects];
                    [unuploadAssetsDict removeAllObjects];
                });
            }
        }];
    });
}

- (void)selectAllButtonPressed {
    [self createRightBarButtonWithTitle:Text(@"CancelSelectAll") action:@"cancelSelectAllButtonPressed"];

    self.presentingVC.isSelectAll = YES;
    self.selectedPhotos = [self.presentingVC selectedPhotos];
}

- (void)cancelSelectAllButtonPressed {
    [self createRightBarButtonWithTitle:Text(@"SelectAll") action:@"selectAllButtonPressed"];
    
    self.presentingVC.isSelectAll = NO;
    self.selectedPhotos = [NSMutableSet set];
}

#pragma mark - SelectPathViewDelegate methods

- (void)changePathButtonPressed {
    
}

- (void)uploadButtonPressed {
    NSMutableArray *infos = [NSMutableArray array];
    
    for (ALAsset *asset in self.selectedPhotos) {
//        NSDictionary *info = [Common uploadFileInfoFromAsset:asset];
//        [infos addObject:info];
    }
    
    if ([_imagePickerDelegate respondsToSelector:@selector(zyxImagePickrController:didFinishPickingMedioWithInfos:)]) {
        ZyxImagePickerController *picker = (ZyxImagePickerController *)self.parentViewController;
        [_imagePickerDelegate zyxImagePickrController:picker didFinishPickingMedioWithInfos:infos];
    }
}

#pragma mark - ZyxPhotoSelectDelegate Methods

- (void)didSelectPhoto:(ALAsset *)asset atIndexPath:indexPath {
    [self.selectedPhotos addObject:asset];
}

- (void)didDeselectPhoto:(ALAsset *)asset atIndexPath:indexPath {
    [self.selectedPhotos removeObject:asset];
}

# pragma mark - SlideViewPageChangedDelegate Methods

- (void)slideViewChangeFromIndex:(NSInteger)fromIndex ToIndex:(NSInteger)toIndex {
    self.presentingVC = toIndex == 0 ? self.unuploadPhotosVC : self.allPhotosVC;
    
    ZyxPhotosViewController *fromVC = fromIndex == 0 ? self.unuploadPhotosVC : self.allPhotosVC;
    fromVC.isSelectAll = NO;
    
    [self.selectedPhotos removeAllObjects];
    [self createRightBarButtonWithTitle:Text(@"SelectAll") action:@"selectAllButtonPressed"];
}

- (void)taskUploadSuccess:(NSNotification *)notification {
    NSString *urlString = notification.object;
    [self.unuploadPhotosVC removePhototOfURLString:urlString];

    for (ALAsset *asset in self.selectedPhotos) {
        NSURL *url = [asset valueForProperty:ALAssetPropertyAssetURL];
        if ([url.absoluteString isEqualToString:urlString]) {
            [self.selectedPhotos removeObject:asset];
            break;
        }
    }
}

- (void)decreaseCountInButton:(UIButton *)button {
    NSString *title = [button titleForState:UIControlStateNormal];
    NSScanner *scanner = [NSScanner scannerWithString:title];
    
    NSString *leftString;
    [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&leftString];
    if ([leftString hasSuffix:@"("]) {
        leftString = [leftString substringToIndex:leftString.length - 1];
    }
    NSInteger count = 0;
    [scanner scanInteger:&count];
    
    if (count > 0) {
        title = [NSString stringWithFormat:@"%@(%@)", leftString, @(count-1).stringValue];
        [button setTitle:title forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
