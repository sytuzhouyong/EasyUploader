//
//  ZyxPhotoManager.h
//  TestReadImage
//
//  Created by zhouyong on 12/25/15.
//  Copyright © 2015 zhouyong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ZyxImageType) {
    ZyxImageTypeThumbnail,
    ZyxImageTypeFullScreen,
    ZyxImageTypeFullResolutionImage,
};

typedef BOOL(^ZyxPhotoFilter)(ALAsset *asset);
typedef void(^ZyxPhotoAddGroupSuccessHandler)(ALAssetsGroup *group);
typedef void(^ZyxPhotoAddGroupFailHandler)(NSString *groupName, NSError *error);

#define kExportProgress     @"ExportProgress"
#define kZyxPhotoManager    [ZyxPhotoManager sharedInstance]


@interface ZyxPhotoManager : NSObject

SINGLETON_DECLEAR;

@property (nonatomic, strong) ALAssetsGroup *appGroup;

// 按时间降序排列
- (NSArray<ALAssetsGroup *> *)allGroups;
- (NSArray<ALAsset *> *)photosInGroup:(ALAssetsGroup *)group;
- (NSArray<ALAsset *> *)photosInGroup:(ALAssetsGroup *)group filter:(ZyxPhotoFilter)filter;
- (NSArray<ALAsset *> *)allPhotos;
// 返回相机胶卷内的所以图片和视频
- (NSArray<ALAsset *> *)allPhotosInCameraRoll;

- (NSInteger)numberOfAllGroups;
- (NSInteger)numberOfPhotosInGroup:(ALAssetsGroup *)group;
- (NSInteger)numberOfPhotosInGroup:(ALAssetsGroup *)group filter:(ZyxPhotoFilter)filter;
- (NSInteger)numberOfAllPhotos;

- (NSString *)nameOfGroup:(ALAssetsGroup *)group;
- (UIImage *)imageInAsset:(ALAsset *)asset withType:(ZyxImageType)imageType;
- (UIImage *)latestPhotoInGroup:(ALAssetsGroup *)group withType:(ZyxImageType)imageType;

///  根据url获取asset
- (ALAsset *)assetWithUrl:(NSURL *)url;
- (ALAsset *)assetWithUrlString:(NSString *)urlString;
- (NSString *)urlStringOfAsset:(ALAsset *)asset;

// 返回资源的文件名
- (NSString *)mediaNameOfURL:(NSURL *)url;
- (NSString *)mediaNameOfAsset:(ALAsset *)asset;
- (void)mediaNameOfURL:(NSURL *)url completion:(void (^)(NSString *name))block;

// 返回照片的拍摄时间列表，最小单位为天
- (NSArray<NSDate *> *)dateSectionsInGroup:(ALAssetsGroup *)group filter:(ZyxPhotoFilter)filter;
- (NSMutableDictionary<NSString *, NSMutableArray<ALAsset *> *> *)assetsDictInGroup:(ALAssetsGroup *)group filter:(ZyxPhotoFilter)filter;
- (NSMutableArray<NSString *> *)yyyyMMddStringsInDates:(NSArray<NSDate *> *)dates;

// 添加新资源
- (void)addGroupNamed:(NSString *)name withSuccessBlock:(ZyxPhotoAddGroupSuccessHandler)successBlock failureBlock:(ZyxPhotoAddGroupFailHandler)failureBlock;
- (void)saveImageAtPath:(NSString *)path toGroupNamed:(NSString *)group successBlock:(void (^)(void))successBlock failureBlock:(void (^)(NSError *error))failureBlock;
- (void)saveImageAtPath:(NSString *)path toGroup:(ALAssetsGroup *)group successBlock:(void (^)(void))successBlock failureBlock:(void (^)(NSError *error))failureBlock;
- (void)addAssetWithURL:(NSURL *)url toGroupNamed:(NSString *)groupName successBlock:(void (^)(void))successBlock failureBlock:(void (^)(NSError *error))failureBlock;
- (void)saveVideoAtURL:(NSURL *)url toGroup:(ALAssetsGroup *)group successBlock:(void (^)(void))successBlock failureBlock:(void (^)(NSError *error))failureBlock;

- (NSURL *)exportURLOfVideoAtURL:(NSURL *)url;
- (void)exportVideoAtURL:(NSURL *)url withCompletion:(void (^)(BOOL finished))completion;

@end


@interface ZyxGroupResourcesInfo : NSObject

@property (nonatomic, strong) ALAssetsGroup *group;
@property (nonatomic, strong) NSMutableArray<NSDate *> *dateSections;
@property (nonatomic, strong) NSMutableArray<NSString *> *dateSectionDescriptions;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<ALAsset *> *> *assetsDict;
@property (nonatomic, copy  ) ZyxPhotoFilter filter;

- (instancetype)initWithGroup:(ALAssetsGroup *)group filter:(ZyxPhotoFilter)filter;
- (void)enumAssets;
    
@end
