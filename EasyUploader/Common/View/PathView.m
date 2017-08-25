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
    self.lastSize = self.bounds.size;

    UIFont *font = [UIFont systemFontOfSize:13];
    NSDictionary *dict = @{NSFontAttributeName:font};

    __block CGFloat x = 0;
    [self.paths enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL *stop) {
        CGFloat width = [path sizeWithAttributes:dict].width;
        width = floor(width + 0.5f);
        width += idx == 0 ? 10.0f : 20.0f;

        PathButton *button = [PathButton buttonWithPath:path isRootPath:idx == 0];
        [self addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(x);
            make.width.mas_equalTo(width);
            make.top.equalTo(self).offset(1);
            make.bottom.equalTo(self).offset(-1);
            x += width;
        }];
    }];
    
//    self.contentSize = CGSizeMake(x, self.bounds.size.height);
}

@end
