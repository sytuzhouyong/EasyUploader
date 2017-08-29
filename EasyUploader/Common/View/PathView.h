//
//  PathView.h
//  EasyUploader
//
//  Created by zhouyong on 25/08/2017.
//  Copyright © 2017 zhouyong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^PathSelectHandler)(NSUInteger index);

@interface PathView : UIView

- (instancetype)initWithResourePaths:(NSArray<NSString *> *)paths pathSelectHandler:(PathSelectHandler)handler;
- (void)appendPath:(NSString *)path;
- (void)updateUIWhenSelectPathButtonChangedTo:(NSUInteger)index;
- (void)removePathsInRange:(NSRange)range;


@end
