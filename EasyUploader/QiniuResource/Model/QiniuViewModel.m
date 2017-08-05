//
//  QiniuViewModel.m
//  EasyUploader
//
//  Created by zhouyong on 17/7/28.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "QiniuViewModel.h"

#pragma mark - QiniuBucket

@implementation QiniuBucketCellModel

- (instancetype)initWithBucket:(QiniuBucket *)bucket {
    if (self = [super init]) {
        self.bucket = bucket;
        self.expand = NO;
    }
    return self;
}

@end



@interface QiniuBucketViewModel ()

@property (nonatomic, strong) NSMutableArray <QiniuBucketCellModel *> *cellModels;

@end

@implementation QiniuBucketViewModel

- (instancetype)initWithBuckets:(NSArray *)buckets {
    if (self = [super init]) {
        self.cellModels = [NSMutableArray arrayWithCapacity:buckets.count];
        for (int i=0; i<buckets.count; i++) {
            [self.cellModels addObject:[[QiniuBucketCellModel alloc] initWithBucket:buckets[i]]];
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


#pragma mark - QiniuResource

@implementation QiniuResourceCellModel

- (instancetype)initWithResource:(QiniuResource *)resource {
    if (self = [super init]) {
        self.resource = resource;
        self.expand = NO;
    }
    return self;
}

@end


@interface QiniuResourceViewModel ()

@property (nonatomic, strong) NSMutableArray <QiniuResourceCellModel *> *cellModels;

@end

@implementation QiniuResourceViewModel

- (instancetype)initWithResources:(NSArray *)resources {
    if (self = [super init]) {
        self.cellModels = [NSMutableArray arrayWithCapacity:resources.count];
        for (int i=0; i<resources.count; i++) {
            [self.cellModels addObject:[[QiniuResourceCellModel alloc] initWithResource:resources[i]]];
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


