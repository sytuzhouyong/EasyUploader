//
//  PathView.m
//  EasyUploader
//
//  Created by zhouyong on 25/08/2017.
//  Copyright © 2017 zhouyong. All rights reserved.
//

#import "PathView.h"
#import "PathButton.h"

#define kPathButtonTag  1000

@interface PathView ()

@property (nonatomic, strong) NSMutableArray<NSString *> *paths;
@property (nonatomic, assign) CGSize lastSize;
@property (nonatomic, assign) CGFloat offset;

@end

@implementation PathView

- (instancetype)initWithResourePaths:(NSArray<NSString *> *)paths pathSelectHandler:(PathSelectHandler)handler {
    if (self = [super initWithFrame:CGRectZero]) {
        self.paths = [NSMutableArray arrayWithArray:paths];
        self.handler = handler;
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

    kWeakself;
    [self.paths enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL *stop) {
        CGFloat width = [weakself insertButtonWithPath:path atIndex:idx];
        weakself.offset += width;
    }];
    
//    self.contentSize = CGSizeMake(x, self.bounds.size.height);
}

- (void)appendPath:(NSString *)path {
    [self.paths addObject:path];
    self.offset += [self insertButtonWithPath:path atIndex:self.paths.count - 1];
}

- (void)removePathsInRange:(NSRange)range {
    [self.paths removeObjectsInRange:range];
    for (NSUInteger i=0; i<range.length; i++) {
        PathButton *button = (PathButton *)[self viewWithTag:kPathButtonTag + range.location + i];
        self.offset -= [self widthOfPathButton:button isRoot:NO];
        [button removeFromSuperview];
    }
}

- (void)updateUIWhenSelectPathButtonChangedTo:(NSUInteger)index {
    for (NSUInteger i = index + 1; i < self.paths.count; i++) {
        UIButton *button = [self viewWithTag:kPathButtonTag + i];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    for (NSUInteger i = 0; i <= index; i++) {
        UIButton *button = [self viewWithTag:kPathButtonTag + i];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

- (CGFloat)insertButtonWithPath:(NSString *)path atIndex:(NSUInteger)index {
    BOOL isRoot = index == 0;
    PathButton *button = [PathButton buttonWithPath:path isRootPath:isRoot];
    button.tag = kPathButtonTag + index;
    CGFloat width = [self widthOfPathButton:button isRoot:isRoot];
    [self addSubview:button];

    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(self.offset);
        make.width.mas_equalTo(width);
        make.top.equalTo(self).offset(1);
        make.bottom.equalTo(self).offset(-1);
    }];

    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        ExecuteBlock1IfNotNil(self.handler, index);
    }];
    return width;
}

- (CGFloat)widthOfPathButton:(PathButton *)button isRoot:(BOOL)isRoot {
    NSString *path = [button titleForState:UIControlStateNormal];
    NSDictionary *dict = @{NSFontAttributeName:button.titleLabel.font};
    CGFloat width = floor([path sizeWithAttributes:dict].width);
    width += isRoot ? 10.0f : 20.0f;
    return width;
}

@end
