//
//  ZyxPhotoCollectionViewCell.m
//  XingHomecloud
//
//  Created by zhouyong on 12/28/15.
//  Copyright © 2015 zhouyong. All rights reserved.
//

#import "ZyxPhotoCollectionViewCell.h"
#import "ZyxPhotoManager.h"

@interface ZyxPhotoCollectionViewCell ()

@property (nonatomic, strong) UIImageView *selectedStateImageView;
@property (nonatomic, strong) UIButton *playButton;

@end

@implementation ZyxPhotoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = self.bounds;
        [self.contentView addSubview:imageView];
        self.imageView = imageView;
        
        [self addSubview:self.playButton];
        [_playButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.size.mas_equalTo(CGSizeE(24));
        }];
        _playButton.enabled = NO;
        _playButton.hidden = YES;
        
        self.selected = NO;
    }
    return self;
}

- (void)configCellWithAsset:(ALAsset *)asset {
    UIImage *thumbnail = [kZyxPhotoManager imageInAsset:asset withType:ZyxImageTypeThumbnail];
    self.imageView.image = thumbnail;
    
    NSString *type = [asset valueForProperty:ALAssetPropertyType];
    self.playButton.hidden = ![type isEqualToString:ALAssetTypeVideo];
}

- (void)setMode:(ZyxImagePickerSelectionMode)mode {
    _mode = mode;
    
    if (_mode == ZyxImagePickerSelectionModeNone) {
        [_selectedStateImageView removeFromSuperview];
        return;
    }
    if (_selectedStateImageView != nil && _selectedStateImageView.superview != nil) {
        return;
    }
    
    [self.contentView addSubview:self.selectedStateImageView];
    [_selectedStateImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentView).offset(-4);
        make.bottom.equalTo(self.contentView).offset(-4);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
}

- (UIImageView *)selectedStateImageView {
    ReturnObjectIfNotNil(_selectedStateImageView);
    
    UIImageView *imageView = [UIImageView new];
    _selectedStateImageView = imageView;
    return imageView;
}

- (UIButton *)playButton {
    ReturnObjectIfNotNil(_playButton);
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    _playButton = button;
    [button setImage:UIImageNamed(@"icon_play") forState:UIControlStateNormal];
    return button;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    NSString *imageName = ImageNameOfSelectedState(selected);
    UIImage *image = [UIImage imageNamed:imageName];
    self.selectedStateImageView.image = image;
}

@end
