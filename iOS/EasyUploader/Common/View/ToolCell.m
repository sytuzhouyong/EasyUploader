//
//  ToolCell.m
//  EasyUploader
//
//  Created by zhouyong on 17/7/30.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "ToolCell.h"
#import "ZyxImageTitleButton.h"
//#import <SVGKit/SVGKit.h>

@implementation ToolCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        // 操作功能区view
        UIView *toolView = [self toolView];
        
        // 上方k固定的view
        UIView *topFixedView = [[UIView alloc] init];
        [self.contentView addSubview:topFixedView];
        [topFixedView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.equalTo(self.contentView);
            make.bottom.equalTo(toolView.mas_top);
        }];
        
//        SVGKImage *svgImage = [SVGKImage imageNamed:@"qiniu_bucket"];
//        UIImage *image = [UIImage imageWithSVGNamed:@"qiniu_bucket.svg" targetSize:CGSizeMake(24, 24) fillColor:[UIColor blueColor]];
//        imageView.image = svgImage.UIImage;
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = UIImageNamed(@"icon_bucket");
        [topFixedView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(topFixedView);
            make.leading.equalTo(topFixedView).offset(10);
            make.size.mas_equalTo(CGSize(28, 28));
        }];

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [button setImage:UIImageNamed(@"icon_arrow_down") forState:UIControlStateNormal];
        [button addTarget:self action:@selector(expandButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [topFixedView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(topFixedView);
            make.trailing.equalTo(topFixedView).offset(-5);
            make.size.mas_equalTo(CGSizeMake(44, 44));
        }];

        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor darkTextColor];
        label.textAlignment = NSTextAlignmentLeft;
        [topFixedView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(imageView.mas_trailing).offset(10);
            make.top.equalTo(imageView);
            make.bottom.equalTo(imageView);
            make.trailing.equalTo(button.mas_leading).offset(-10);
        }];

        self.iconImageView = imageView;
        self.label = label;
        self.button = button;
        self.toolView = toolView;

//        ShowBorder(toolView, greenColor);
//        ShowBorder(imageView, redColor);
//        ShowBorder(button, greenColor);
//        ShowBorder(label, yellowColor);
    }
    return self;
}

- (NSArray<ToolButtonInfo *> *)toolButtons {
    ToolButtonInfo *info =[[ToolButtonInfo alloc] initWithTitle:@"删除" imageName:@"icon_trash" handler:nil];
    return @[info];
}

- (void)updateExpandState:(BOOL)expand {
    if (!expand) {
        self.button.transform = CGAffineTransformIdentity;
    } else {
        self.button.transform = CGAffineTransformMakeRotation(-M_PI);
    }

    [self.toolView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(expand ? 44 : 0);
    }];
    [self.contentView updateConstraintsIfNeeded];
}

- (UIView *)toolView {
    if (_toolView != nil) {
        return _toolView;
    }
    
    UIView *view = [[UIView alloc] init];
    _toolView = view;
    view.clipsToBounds = YES;
    view.backgroundColor = RGB(0xEE, 0xEE, 0xEE);
    [self.contentView addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(0);
    }];

    NSArray *buttonInfos = [self toolButtons];
    NSUInteger count = buttonInfos.count;

    CGSize imageSize = CGSize(44, 40);
    CGFloat padding = (kWindowWidth - imageSize.width * count)  / (count + 1);

    for (NSInteger i=0; i<count; i++) {
        CGFloat x = (padding + imageSize.width) * i + padding;

        ToolButtonInfo *buttonInfo = buttonInfos[i];
        ZyxImageTitleButton *button = [ZyxImageTitleButton buttonWithType:UIButtonTypeCustom];
        [button setImage:UIImageNamed(buttonInfo.imageName) forState:UIControlStateNormal];
        [button setTitle:buttonInfo.title forState: UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:10];
        [button setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        button.layout = ZyxImageTitleButtonLayoutTypeVertical;
        button.spacing = 1;
        [view addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(imageSize);
            make.centerY.equalTo(view);
            make.leading.equalTo(view).offset(x);
        }];

        button.tag = kToolCellButtonTag + i;
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }

    return view;
}

- (void)expandButtonClicked:(UIButton *)button {
    ExecuteBlock1IfNotNil(self.expandHandler, button);
}


- (void)buttonClicked:(UIButton *)button {
    // 因为只有一个，所以是删除按钮
    ExecuteBlock1IfNotNil(self.deleteHandler, button);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end


@implementation ToolButtonInfo

- (instancetype)initWithTitle:(NSString *)title imageName:(NSString *)imageName handler:(ButtonHandler)handler {
    if (self = [super init]) {
        self.title = title;
        self.imageName = imageName;
        self.handler = handler;
    }
    return self;
}

@end

