//
//  JGPBPhotoInfoView.h
//  JGPhotoBrowser
//
//  Created by Mei Jigao on 2018/6/11.
//  Copyright © 2018年 MeiJigao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JGPBPhotoInfoView : UIView

@property (nonatomic, copy) NSString *text;

/** iOS 11 SafeArea适配，用于iOS 11顶部、底部适配 */
@property (nonatomic, assign) UIEdgeInsets browserSafeAreaInsets;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
