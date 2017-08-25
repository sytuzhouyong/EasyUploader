//
//  PathView.m
//  EasyUploader
//
//  Created by zhouyong on 25/08/2017.
//  Copyright © 2017 zhouyong. All rights reserved.
//

#import "PathView.h"
#import "PathButton.h"

@interface PathView ()

@property (nonatomic, strong) NSMutableArray<NSString *> *paths;
@property (nonatomic, assign) CGSize lastSize;

@end

@implementation PathView

- (instancetype)initWithResourePaths:(NSArray<NSString *> *)paths {
    if (self = [super initWithFrame:CGRectZero]) {
        self.paths = [NSMutableArray arrayWithArray:paths];
        self.lastSize = CGSizeZero;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (CGSizeEqualToSize(self.bounds.size, self.lastSize)) {
        return;
    }

    UIFont *font = [UIFont systemFontOfSize:13];
    NSDictionary *dict = @{NSFontAttributeName:font};

    BOOL root = YES;
    __block CGFloat x = 0;
    for (NSString *path in self.paths) {

        CGFloat width = [path sizeWithAttributes:dict].width;
        width += root ? 10.0f : 20.0f;

        PathButton *button = [PathButton buttonWithType:UIButtonTypeCustom isRootPath:root];
        [self addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(x);
            make.width.mas_equalTo(width);
            make.top.equalTo(self).offset(1);
            make.bottom.equalTo(self).offset(-1);
            x += width;
        }];

        root = NO;
    }
    
    self.contentSize = CGSizeMake(x, self.bounds.size.height);
}

@end
