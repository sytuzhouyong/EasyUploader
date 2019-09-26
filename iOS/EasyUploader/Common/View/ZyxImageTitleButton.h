//
//  ZyxImageTitleButton.h
//  XingHomecloud
//
//  Created by zhouyong on 12/21/15.
//  Copyright © 2015 zte. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ZyxImageTitleButtonLayoutType) {
    ZyxImageTitleButtonLayoutTypeHorizontal,
    ZyxImageTitleButtonLayoutTypeVertical,
};

@interface ZyxImageTitleButton : UIButton


@property (nonatomic, assign) ZyxImageTitleButtonLayoutType layout;
@property (nonatomic, assign) CGFloat spacing;

@end
