//
//  SelectUploadPathToolView.h
//  EasyUploader
//
//  Created by zhouyong on 17/8/12.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SelectPathHandler) (NSString *path);

@interface SelectUploadPathToolView : UIView

@property (nonatomic, copy) SelectPathHandler selectPathHandler;
@property (nonatomic, copy) ButtonHandler uploadHandler;

- (instancetype)initWithFrame:(CGRect)frame uploadPath:(NSString *)path;

- (void)enableUploadButton:(BOOL)enable;
- (void)updatePath:(NSString *)path;

@end
