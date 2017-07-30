//
//  QiniuBucketViewModel.m
//  EasyUploader
//
//  Created by zhouyong on 17/7/28.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "QiniuBucketViewModel.h"



@interface QiniuBucketViewModel ()

@property (nonatomic, strong) NSMutableArray <QiniubucketCellModel *> *cellModels;

@end

@implementation QiniuBucketViewModel

- (instancetype)initWithBuckets:(NSArray *)buckets {
    if (self = [super init]) {
        self.cellModels = [NSMutableArray arrayWithCapacity:buckets.count];
        for (int i=0; i<buckets.count; i++) {
            [self.cellModels addObject:[[QiniubucketCellModel alloc] initWithBucket:buckets[i]]];
        }
    }
    return self;
}

- (void)updateExpandStateAtRow:(NSInteger)row {
    self.cellModels[row].expand = !self.cellModels[row].expand;
}

- (BOOL)isExpandAtRow:(NSInteger)row {
    return self.cellModels[row].expand;
}

@end


@implementation QiniubucketCellModel

- (instancetype)initWithBucket:(QiniuBucket *)bucket {
    if (self = [super init]) {
        self.bucket = bucket;
        self.expand = NO;
    }
    return self;
}

@end
