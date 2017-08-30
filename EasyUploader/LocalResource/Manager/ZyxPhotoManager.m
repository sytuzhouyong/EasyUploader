//
//  ZyxPhotoManager.m
//  TestReadImage
//
//  Created by zhouyong on 12/25/15.
//  Copyright © 2015 zhouyong. All rights reserved.
//

#import "ZyxPhotoManager.h"
#import <AVFoundation/AVFoundation.h>
//#ifdef __IPHONE_8_0
//#import <Photos/Photos.h>
//#endif

@interface ZyxPhotoManager ()

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSTimer *exportTimer;

@end

@implementation ZyxPhotoManager

SINGLETON_IMPLEMENTATION(ZyxPhotoManager);

- (id)init {
    if (self= [super init]) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
//        kWeakself;
//        [self addGroupNamed:@"XHC" withSuccessBlock:^(ALAssetsGroup *group) {
//            DDLogInfo(@"yes, group[XHC] ready!");
//            weakself.appGroup = group;
//        } failureBlock:^(NSString *groupName, NSError *error) {
//            DDLogInfo(@"oh no, create group[XHC] failed!");
//        }];
    }
    return self;
}

- (NSArray<ALAssetsGroup *> *)allGroups {
    __block NSMutableArray<ALAssetsGroup *> *groups = [NSMutableArray array];
    
    kWeakself;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group == nil) {
                *stop = YES;
                dispatch_semaphore_signal(semaphore);
            } else {
                [groups addObject:group];
                NSLog(@"add group: %@", [group valueForProperty:ALAssetsGroupPropertyName]);
            }
        } failureBlock:^(NSError *error) {
            [weakself enumerateErrorHandler:error];
            dispatch_semaphore_signal(semaphore);
        }];
    });
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return [[groups reverseObjectEnumerator] allObjects];
}

- (NSArray<ALAsset *> *)photosInGroup:(ALAssetsGroup *)group {
    return [self photosInGroup:group filter:nil];
}

- (NSArray<ALAsset *> *)photosInGroup:(ALAssetsGroup *)group filter:(ZyxPhotoFilter)filter {
    NSMutableArray<ALAsset *> *photos = [NSMutableArray array];
    
    [group setAssetsFilter:[ALAssetsFilter allAssets]];
    [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        if (asset == nil) {
            return;
        }
        if (filter && filter(asset)) {
            return;
        }
        [photos addObject:asset];
    }];
    
    return photos;
}

- (NSArray<ALAsset *> *)allPhotos {
    NSMutableArray<ALAsset *> *photos = [NSMutableArray array];
    
    NSArray<ALAssetsGroup *> *groups = [self allGroups];
    for (ALAssetsGroup *group in groups) {
        NSArray<ALAsset *> *photosInGroup = [self photosInGroup:group];
        [photos addObjectsFromArray:photosInGroup];
    }
    
    return photos;
}

- (NSArray<ALAsset *> *)allPhotosInCameraRoll {
    __block ALAssetsGroup *cameraRollGroup = nil;
    
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    kWeakself;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (!group.editable && group != nil) {
                cameraRollGroup = group;
                *stop = YES;
                dispatch_semaphore_signal(semaphore);
            }
        } failureBlock:^(NSError *error) {
            [weakself enumerateErrorHandler:error];
            dispatch_semaphore_signal(semaphore);
        }];
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    if (cameraRollGroup == nil) {
        return nil;
    }
    
    NSMutableArray<ALAsset *> *photos = [NSMutableArray array];
    [cameraRollGroup setAssetsFilter:[ALAssetsFilter allAssets]];
    [cameraRollGroup enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        if (asset != nil) {
            [photos addObject:asset];
        }
    }];
    
    return photos;
}

- (NSInteger)numberOfAllGroups {
    __block NSInteger count = 0;
    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        count++;
    } failureBlock:^(NSError *error) {
        NSLog(@"oh no, enumrate photo groups failed!");
    }];
    return count;
}

- (NSInteger)numberOfPhotosInGroup:(ALAssetsGroup *)group {
    return [self numberOfPhotosInGroup:group filter:nil];
}

- (NSInteger)numberOfPhotosInGroup:(ALAssetsGroup *)group filter:(ZyxPhotoFilter)filter {
    if (filter == nil) {
        return [group numberOfAssets];
    }
    
    __block NSUInteger count = 0;
    [group setAssetsFilter:[ALAssetsFilter allAssets]];
    [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        if (asset == nil) {
            return;
        }
        if (filter && filter(asset)) {
            return;
        }
        count++;
    }];
    
    return count;
}

- (NSInteger)numberOfAllPhotos {
    __block NSInteger count = 0;
    kWeakself;
    
    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group != nil) {
            count += [weakself numberOfPhotosInGroup:group];
        } else {
            DDLogWarn(@"oh no, group is nil, so can not increase count");
        }
    } failureBlock:^(NSError *error) {
        [weakself enumerateErrorHandler:error];
    }];
    
    return count;
}

- (NSString *)nameOfGroup:(ALAssetsGroup *)group {
    return [group valueForProperty:ALAssetsGroupPropertyName];
}

#pragma mark - 错误处理

- (void)enumerateErrorHandler:(NSError *)error {
    DDLogError(@"oh no, enumerate failed, reason: %@", error.localizedFailureReason);
}

#pragma mark - 获取数据

- (UIImage *)imageInAsset:(ALAsset *)asset withType:(ZyxImageType)imageType {
    CGImageRef imageRef = nil;
    
    switch (imageType) {
        case ZyxImageTypeThumbnail:
            imageRef = [asset thumbnail];
            break;
        case ZyxImageTypeFullScreen:
            imageRef = [asset.defaultRepresentation fullScreenImage];
            break;
        case ZyxImageTypeFullResolutionImage: {
            NSString *xmp = asset.defaultRepresentation.metadata[@"AdjustmentXMP"];
            NSData *data = [xmp dataUsingEncoding:NSUTF8StringEncoding];
            
            CIImage *ciimage = [CIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage];
            
            NSError *error = nil;
            NSArray *filterArray = [CIFilter filterArrayFromSerializedXMP:data inputImageExtent:ciimage.extent error:&error];
            if (error) {
                NSLog(@"Error during CIFilter creation: %@", [error localizedDescription]);
                return nil;
            }
            
            for (CIFilter *filter in filterArray) {
                [filter setValue:ciimage forKey:kCIInputImageKey];
                ciimage = [filter outputImage];
            }
            
            UIImage *image = [UIImage imageWithCIImage:ciimage scale:1.0 orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
            return image;
        }
        default:
            return nil;
    }
    
    return [UIImage imageWithCGImage:imageRef];
}

- (UIImage *)latestPhotoInGroup:(ALAssetsGroup *)group withType:(ZyxImageType)imageType {
    __block UIImage *image;
    [group setAssetsFilter:[ALAssetsFilter allAssets]];
    [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        if (asset == nil) {
            *stop = YES;
        } else {
            image = [kZyxPhotoManager imageInAsset:asset withType:ZyxImageTypeThumbnail];
            *stop = YES;
        }
    }];
    
    if (image == nil) {
        image = [UIImage imageWithCGImage:group.posterImage];
    }
    
    return image;
}

// 这个代码会在某些iPhone6 9.2.1 上获取不到media name
//- (NSString *)mediaNameOfURL:(NSURL *)url {
//    PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil];
//    PHAsset *asset = result.firstObject;
//    NSString *fileName = [asset valueForKey:@"filename"];
//    return fileName;
//}

// assets-library://asset/asset.JPG?id=3ABCB6AE-9122-429E-B8E0-84779CC88188&ext=JPG
- (NSString *)mediaNameOfURL:(NSURL *)url {
    __block NSString *name = nil;
    
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.assetsLibrary assetForURL:url resultBlock:^(ALAsset *myasset) {
            ALAssetRepresentation *representation = [myasset defaultRepresentation];
            name = [representation filename];
            dispatch_semaphore_signal(sem);
        } failureBlock:^(NSError *error) {
            DDLogError(@"oh no, get media name[%@] failed", url);
            dispatch_semaphore_signal(sem);
        }];
    });
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    return name;
}

- (void)mediaNameOfURL:(NSURL *)url completion:(void (^)(NSString *name))block {
    __block NSString *name = nil;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [_assetsLibrary assetForURL:url resultBlock:^(ALAsset *myasset) {
            name = [[myasset defaultRepresentation] filename];
            dispatch_async(dispatch_get_main_queue(), ^{
                block(name);
            });
        } failureBlock:^(NSError *error) {
            DDLogError(@"oh no, get media name[%@] failed", url);
        }];
    });
}

- (NSString *)mediaNameOfAsset:(ALAsset *)asset {
    NSURL *url = [asset valueForProperty:ALAssetPropertyAssetURL];
    return [self mediaNameOfURL:url];
}

- (NSData *)dataOfURL:(NSURL *)url {
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    
    __block ALAsset *asset = nil;
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [assetslibrary assetForURL:url resultBlock:^(ALAsset *a) {
            asset = a;
            dispatch_semaphore_signal(sem);
        } failureBlock:^(NSError *error) {
            dispatch_semaphore_signal(sem);
        }];
    });
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    Byte *buffer = (Byte *)malloc((NSUInteger)rep.size);
    NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:(NSUInteger)rep.size error:nil];
    NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
    return data;
}

- (NSString *)exportNameOfVideoAtURL:(NSURL *)url {
    NSString *fileTitle = [[kPhotoManager mediaNameOfURL:url] componentsSeparatedByString:@"."].firstObject;
    return [NSString stringWithFormat:@"%@.MP4", fileTitle];
}

- (NSURL *)exportURLOfVideoAtURL:(NSURL *)url {
    NSString *fileName = [self exportNameOfVideoAtURL:url];
    NSString* path = [[StringUtil videoCachePath] stringByAppendingPathComponent:fileName];
    return [NSURL fileURLWithPath:path];
}

- (void)exportVideoAtURL:(NSURL *)url withCompletion:(void (^)(BOOL finished))completion {
    NSURL *exportURL = [self exportURLOfVideoAtURL:url];
    
    //判断是否已经导出过
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportURL.relativePath]) {
        DDLogVerbose(@"nice, video at url(%@) has been exported!", exportURL);
        ExecuteBlock1IfNotNil(completion, YES);
        return;
    }
    
    NSString *quality = AVAssetExportPresetHighestQuality;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    if (![compatiblePresets containsObject:quality]) {
        DDLogError(@"oh no, AVAsset doesn't support %@ quality.", quality);
        ExecuteBlock1IfNotNil(completion, NO);
        return;
    }
    
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:avAsset presetName:quality];
    exportSession.outputURL = exportURL;
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch (exportSession.status) {
            case AVAssetExportSessionStatusFailed:
                DDLogError(@"Export failed, error = %@!", exportSession.error);
                break;
            case AVAssetExportSessionStatusCancelled:
                DDLogVerbose(@"Export canceled");
                break;
            case AVAssetExportSessionStatusCompleted:
                DDLogInfo(@"Export Successful!");
                break;
            default:
                break;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion != nil) {
                completion(exportSession.status == AVAssetExportSessionStatusCompleted);
            }
        });
    }];
}

#pragma mark - 获取时间节点

- (NSArray<NSDate *> *)dateSectionsInGroup:(ALAssetsGroup *)group filter:(BOOL (^)(ALAsset *asset))filter {
    NSMutableSet *dateSet = [NSMutableSet set];
    NSMutableSet *dateStringSet = [NSMutableSet set];
    
    [group setAssetsFilter:[ALAssetsFilter allAssets]];
    [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        if (asset != nil) {
            if (filter && filter(asset)) {
                return;
            }
            
            NSDate *date = [asset valueForProperty:ALAssetPropertyDate];
            NSString *yyyyMMdd = [DateUtil yyyyMMddStringWithDate:date];
            
            if (![dateStringSet containsObject:yyyyMMdd]) {
                [dateSet addObject:date];
                [dateStringSet addObject:yyyyMMdd];
            }
        }
    }];
    
    NSArray *dates = [dateSet.allObjects sortedArrayUsingComparator:^NSComparisonResult(NSDate *obj1, NSDate *obj2) {
        return [obj2 compare:obj1];
    }];
    return dates;
}

- (NSMutableArray<NSString *> *)yyyyMMddStringsInDates:(NSArray<NSDate *> *)dates {
    NSMutableArray<NSString *> *descriptions = [NSMutableArray array];
    for (NSDate *date in dates) {
        NSString *yyyyMMdd = [DateUtil yyyyMMddStringWithDate:date];
        [descriptions addObject:yyyyMMdd];
    }
    return descriptions;
}

- (NSMutableDictionary<NSString *, NSMutableArray<ALAsset *> *> *)assetsDictInGroup:(ALAssetsGroup *)group filter:(ZyxPhotoFilter)filter {
    NSMutableDictionary<NSString *, NSMutableArray<ALAsset *> *> *dict = [NSMutableDictionary dictionary];
    
    [group setAssetsFilter:[ALAssetsFilter allAssets]];
    [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        if (asset != nil) {
            if (filter && filter(asset)) {
                return;
            }
            
            NSDate *date = [asset valueForProperty:ALAssetPropertyDate];
            NSString *yyyyMMdd = [DateUtil yyyyMMddStringWithDate:date];
            
            NSMutableArray *assets = dict[yyyyMMdd];
            if (assets == nil) {
                assets = [NSMutableArray array];
                dict[yyyyMMdd] = assets;
            }
            [assets addObject:asset];
        }
    }];
    return dict;
}

#pragma mark - 保存数据到指定相册

- (void)addGroupNamed:(NSString *)name withSuccessBlock:(ZyxPhotoAddGroupSuccessHandler)successBlock failureBlock:(ZyxPhotoAddGroupFailHandler)failureBlock {
    if (name ==nil || name.length == 0) {
        DDLogError(@"could not add group with an empty name!");
        NSError *error = [NSError errorWithDomain:@"Photo" code:400 userInfo:@{@"msg": @"add group with empty name"}];
        ExecuteBlock2IfNotNil(failureBlock, name, error);
        return;
    }


    // 先判断有没有权限
    if (![DeviceUtil isPhotoAuthorized]) {
        DDLogError(@"oh no, photo is not authorized");
        NSError *error = [NSError errorWithDomain:@"Photo" code:400 userInfo:@{@"msg": @"not authorized"}];
        ExecuteBlock2IfNotNil(failureBlock, name, error);
        return;
    }
    
    // 再判断有没有对应的group
    __block ALAssetsGroup *theGroup = nil;
    kWeakself;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group == nil) {
                *stop = YES;
                if (theGroup == nil) {
                    NSLog(@"111111111");
                    dispatch_semaphore_signal(semaphore);
                }
            }
            
            NSString *groupName = [group valueForProperty:ALAssetsGroupPropertyName];
            if (groupName && [name isEqualToString:groupName]) {
                theGroup = group;
                DDLogInfo(@"yes, find group[%@]!", name);
                *stop = YES;
                NSLog(@"333333");
                dispatch_semaphore_signal(semaphore);
            }
        } failureBlock:^(NSError *error) {
            [weakself enumerateErrorHandler:error];
            DDLogError(@"oh no, find group[%@] failed!", name);
            ExecuteBlock2IfNotNil(failureBlock, name, nil);
            dispatch_semaphore_signal(semaphore);
        }];
    });
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"222222222222");
    if (theGroup != nil) {
        successBlock(theGroup);
        return;
    }
    
    // 创建相册
//#ifdef __IPHONE_8_0
//    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
//        [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:name];
//    } completionHandler:^(BOOL success, NSError *error) {
//        if (!success) {
//            DDLogError(@"create group(%@) failed", name);
//            ExecuteBlock2IfNotNil(failureBlock, name, error);
//            return;
//        }
//        
//        DDLogInfo(@"create group(%@) success", name);
//        [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
//            if (group == nil) {
//                return;
//            }
//            
//            NSString *groupName = [group valueForProperty:ALAssetsGroupPropertyName];
//            if ([name isEqualToString:groupName]) {
//                successBlock(group);
//                *stop = YES;
//            }
//        } failureBlock:nil];
//    }];
//#else
    [_assetsLibrary addAssetsGroupAlbumWithName:name resultBlock:^(ALAssetsGroup *group) {
        if (group == nil) {
            DDLogError(@"create group(%@) failed", name);
            ExecuteBlock2IfNotNil(failureBlock, name, nil);
        } else {
            DDLogInfo(@"create group(%@) success", name);
            ExecuteBlock1IfNotNil(successBlock, group);
        }
    } failureBlock:^(NSError *error) {
        failureBlock(name, error);
    }];
//#endif
}

- (void)saveImageAtPath:(NSString *)path toGroupNamed:(NSString *)group successBlock:(void (^)(void))successBlock failureBlock:(void (^)(NSError *error))failureBlock {
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    if (image == nil) {
        ExecuteBlock1IfNotNil(failureBlock, nil);
        return;
    }
    
    kWeakself;
    [_assetsLibrary writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
        [weakself addAssetWithURL:assetURL toGroupNamed:group successBlock:successBlock failureBlock:failureBlock];
    }];
}

- (void)saveImageAtPath:(NSString *)path toGroup:(ALAssetsGroup *)group successBlock:(void (^)(void))successBlock failureBlock:(void (^)(NSError *error))failureBlock {
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    if (image == nil) {
        NSError *error = [[NSError alloc] initWithDomain:@"XHC" code:404 userInfo:nil];
        ExecuteBlock1IfNotNil(failureBlock, error);
        return;
    }
    
    kWeakself;
    [_assetsLibrary writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
        [weakself addAssetWithURL:assetURL toGroup:group successBlock:successBlock failureBlock:failureBlock];
    }];
}

- (void)saveVideoAtURL:(NSURL *)url toGroup:(ALAssetsGroup *)group successBlock:(void (^)(void))successBlock failureBlock:(void (^)(NSError *error))failureBlock {
    if ([_assetsLibrary videoAtPathIsCompatibleWithSavedPhotosAlbum:url]) {
        kWeakself;
        [_assetsLibrary writeVideoAtPathToSavedPhotosAlbum:url completionBlock:^(NSURL *assetURL, NSError *error) {
            [weakself addAssetWithURL:assetURL toGroup:group successBlock:successBlock failureBlock:failureBlock];
        }];
    } else {
        DDLogWarn(@"video[%@] can not be saved!", url.absoluteString.lastPathComponent);
    }
}

- (void)addAssetWithURL:(NSURL *)url toGroupNamed:(NSString *)groupName successBlock:(void (^)(void))successBlock failureBlock:(void (^)(NSError *error))failureBlock {
    kWeakself;
    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group != nil) {
            NSString *groupName = [weakself nameOfGroup:group];
            if (![groupName isEqualToString:groupName]) {
                return;
            }
            
            [_assetsLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
                [group addAsset:asset];
                ExecuteBlockIfNotNil(successBlock);
            } failureBlock:^(NSError *error) {
                ExecuteBlock1IfNotNil(failureBlock, error);
            }];
        }
    } failureBlock:^(NSError *error) {
        ExecuteBlock1IfNotNil(failureBlock, error);
    }];
}

- (void)addAssetWithURL:(NSURL *)url toGroup:(ALAssetsGroup *)group successBlock:(void (^)(void))successBlock failureBlock:(void (^)(NSError *error))failureBlock {
    if (url == nil) {
        NSError *error = [NSError errorWithDomain:@"xhc" code:404 userInfo:@{@"msg":@"url is nil"}];
        ExecuteBlock1IfNotNil(failureBlock, error);
        return;
    }
    
    [_assetsLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
        [group addAsset:asset];
        ExecuteBlockIfNotNil(successBlock);
    } failureBlock:^(NSError *error) {
        ExecuteBlock1IfNotNil(failureBlock, error);
    }];
}

@end


@implementation ZyxGroupResourcesInfo

- (instancetype)initWithGroup:(ALAssetsGroup *)group filter:(ZyxPhotoFilter)filter {
    if (self = [super init]) {
        self.group = group;
        self.filter = filter;
        self.dateSections = [NSMutableArray array];
        self.dateSectionDescriptions = [NSMutableArray array];
        self.assetsDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)enumAssets {
    NSMutableSet *dateStringSet = [NSMutableSet set];
    
    [self.group setAssetsFilter:[ALAssetsFilter allAssets]];
    [self.group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        if (asset == nil) {
            return;
        }
        if (self.filter != nil && self.filter(asset)) {
            return;
        }
        
        NSDate *date = [asset valueForProperty:ALAssetPropertyDate];
        NSString *yyyyMMdd = [DateUtil yyyyMMddStringWithDate:date];
        
        if (![dateStringSet containsObject:yyyyMMdd]) {
            [_dateSections addObject:date];
            [_dateSectionDescriptions addObject:yyyyMMdd];
            [dateStringSet addObject:yyyyMMdd];
        }
        
        NSMutableArray *assets = _assetsDict[yyyyMMdd];
        if (assets == nil) {
            assets = [NSMutableArray array];
            _assetsDict[yyyyMMdd] = assets;
        }
        [assets addObject:asset];
    }];
}

@end
