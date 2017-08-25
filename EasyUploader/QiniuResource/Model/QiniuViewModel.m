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

- (QiniuBucket *)bucketAtIndexPath:(NSIndexPath *)indexPath {
    return self.cellModels[indexPath.row].bucket;
}

- (NSUInteger)numberOfBuckets {
    return self.cellModels.count;
}

- (void)updateExpandStateAtIndexPath:(NSIndexPath *)indexPath; {
    QiniuBucketCellModel *cellModel = self.cellModels[indexPath.row];
    cellModel.expand = !cellModel.expand;
}

- (BOOL)isExpandAtIndexPath:(NSIndexPath *)indexPath {
    return self.cellModels[indexPath.row].expand;
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

- (QiniuResource *)resourceAtIndexPath:(NSIndexPath *)indexPath {
    return self.cellModels[indexPath.row].resource;
}

- (NSUInteger)numberOfResources {
    return self.cellModels.count;
}


- (void)updateExpandStateAtIndexPath:(NSIndexPath *)indexPath {
    self.cellModels[indexPath.row].expand = !self.cellModels[indexPath.row].expand;
}

- (BOOL)isExpandAtIndexPath:(NSIndexPath *)indexPath {
    return self.cellModels[indexPath.row].expand;
}


@end


