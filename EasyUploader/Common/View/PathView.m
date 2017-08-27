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
@property (nonatomic, assign) CGFloat offset;

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
    self.offset = 0;

    __block CGFloat x = 0;
    [self.paths enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL *stop) {
        BOOL isRoot = idx == 0;
        PathButton *button = [PathButton buttonWithPath:path isRootPath:isRoot];
        CGFloat width = [self widthOfPathButton:button isRoot:isRoot];
        [self addSubview:button];

        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(x);
            make.width.mas_equalTo(width);
            make.top.equalTo(self).offset(1);
            make.bottom.equalTo(self).offset(-1);
        }];
        x += width;
    }];
    self.offset = x;
    
//    self.contentSize = CGSizeMake(x, self.bounds.size.height);
}

- (void)appendPath:(NSString *)path {
    [self.paths addObject:path];
    path = [path substringToIndex:path.length - 1];

    BOOL isRoot = self.offset > 1.0f ? NO : YES;
    PathButton *button = [PathButton buttonWithPath:path isRootPath:isRoot];
    CGFloat width = [self widthOfPathButton:button isRoot:isRoot];
    [self addSubview:button];

    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(self.offset);
        make.width.mas_equalTo(width);
        make.top.equalTo(self).offset(1);
        make.bottom.equalTo(self).offset(-1);
    }];
    self.offset += width;
}


- (CGFloat)widthOfPathButton:(PathButton *)button isRoot:(BOOL)isRoot {
    NSString *path = [button titleForState:UIControlStateNormal];
    NSDictionary *dict = @{NSFontAttributeName:button.titleLabel.font};
    CGFloat width = floor([path sizeWithAttributes:dict].width);
    width += isRoot ? 10.0f : 20.0f;
    return width;
}

@end
