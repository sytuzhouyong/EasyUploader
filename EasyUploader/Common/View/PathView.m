//
//  PathView.m
//  EasyUploader
//
//  Created by zhouyong on 25/08/2017.
//  Copyright © 2017 zhouyong. All rights reserved.
//

#import "PathView.h"
#import "PathButton.h"

@implementation PathView

- (instancetype)initWithFrame:(CGRect)frame paths:(NSArray<NSString *> *)paths {
    if (self = [super initWithFrame:frame]) {
        BOOL root = YES;
        CGFloat x = 0;
        for (NSString *path in paths) {
            UIFont *font = [UIFont systemFontOfSize:13];
            NSDictionary *dict = @{NSFontAttributeName:font};

            CGFloat width = [path sizeWithAttributes:dict].width;
            width += root ? 10.0f : 20.0f;

            CGRect frame = CGRectMake(x, 0, 0, 0);
            PathButton *button = [[PathButton alloc] initWithFrame:frame isRootPath:root];

            root = NO;
        }
    }
    return self;
}

@end
