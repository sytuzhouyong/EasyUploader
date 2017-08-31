//
//  QiniuViewModel.h
//  EasyUploader
//
//  Created by zhouyong on 17/7/28.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Qiniu Bucket

@interface QiniuBucketCellModel : NSObject

@property (nonatomic, strong) QiniuBucket *bucket;
@property (nonatomic, assign) BOOL expand;

- (instancetype)initWithBucket:(QiniuBucket *)bucket;

@end



@interface QiniuBucketViewModel : NSObject

@property (nonatomic, readonly, strong) NSMutableArray<QiniuBucketCellModel *> *cellModels;

- (instancetype)initWithBuckets:(NSArray *)buckets;

- (QiniuBucket *)bucketAtIndexPath:(NSIndexPath *)indexPath;
- (NSUInteger)numberOfBuckets;
- (BOOL)isExpandAtIndexPath:(NSIndexPath *)indexPath;
- (void)updateExpandStateAtIndexPath:(NSIndexPath *)indexPath;

@end

#pragma mark - Qiniu Resource

@interface QiniuResourceCellModel : NSObject

@property (nonatomic, strong) QiniuResource *resource;
@property (nonatomic, assign) BOOL expand;

- (instancetype)initWithResource:(QiniuResource *)resource;

@end


@interface QiniuResourceViewModel : NSObject

- (instancetype)initWithResources:(NSArray *)resources type:(QiniuResourceType)type;

- (QiniuResource *)resourceAtIndexPath:(NSIndexPath *)indexPath;
- (NSUInteger)numberOfResources;
- (BOOL)isExpandAtIndexPath:(NSIndexPath *)indexPath;
- (void)updateExpandStateAtIndexPath:(NSIndexPath *)indexPath;

@end
