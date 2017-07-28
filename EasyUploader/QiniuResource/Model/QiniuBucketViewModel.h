//
//  QiniuBucketViewModel.h
//  EasyUploader
//
//  Created by zhouyong on 17/7/28.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QiniubucketCellModel : NSObject

@property (nonatomic, strong) QiniuBucket *bucket;
@property (nonatomic, assign) BOOL expand;

- (instancetype)initWithBucket:(QiniuBucket *)bucket;

@end



@interface QiniuBucketViewModel : NSObject

@property (nonatomic, readonly, strong) NSMutableArray<QiniubucketCellModel *> *cellModels;

- (instancetype)initWithBuckets:(NSArray *)buckets;

- (void)updateExpandStateAtRow:(NSInteger)row;

@end


