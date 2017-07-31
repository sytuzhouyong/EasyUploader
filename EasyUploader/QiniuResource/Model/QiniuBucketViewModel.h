//
//  QiniuBucketViewModel.h
//  EasyUploader
//
//  Created by zhouyong on 17/7/28.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import <Foundation/Foundation.h>

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


