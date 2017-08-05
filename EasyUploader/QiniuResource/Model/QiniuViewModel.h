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

- (BOOL)isExpandAtRow:(NSInteger)row;
- (void)updateExpandStateAtRow:(NSInteger)row;

@end

#pragma mark - Qiniu Resource

@interface QiniuResourceCellModel : NSObject

@property (nonatomic, strong) QiniuResource *resource;
@property (nonatomic, assign) BOOL expand;

- (instancetype)initWithResource:(QiniuResource *)resource;

@end


@interface QiniuResourceViewModel : NSObject

@property (nonatomic, readonly, strong) NSMutableArray<QiniuResourceCellModel *> *cellModels;

- (instancetype)initWithResources:(NSArray *)resources;

- (BOOL)isExpandAtRow:(NSInteger)row;
- (void)updateExpandStateAtRow:(NSInteger)row;

@end
