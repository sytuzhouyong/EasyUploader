//
//  QiniuResouresViewController.m
//  EasyUploader
//
//  Created by zhouyong on 17/7/26.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import "QiniuResouresViewController.h"
#import "LocalMainViewController.h"
#import "QiniuResourceContentViewController.h"
#import "PathView.h"
#import "ConfirmUploadPathToolView.h"

#define kContentInset   0

@interface QiniuResouresViewController ()

@property (nonatomic, strong) PathView *pathView;
@property (nonatomic, strong) UIView *contentView;  // 容纳多个contentVC的父 view
@property (nonatomic, strong) UIView *pathSelectView;

@property (nonatomic, strong) QiniuBucket *bucket;
@property (nonatomic, strong) NSMutableArray *paths;
@property (nonatomic, strong) NSMutableArray *contentVCs;
@property (nonatomic, assign) NSUInteger currentPathIndex;
@property (nonatomic, assign) BOOL isPathSelecting;

@end

@implementation QiniuResouresViewController

- (instancetype)initWithBucket:(QiniuBucket *)bucket paths:(NSArray *)paths {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.bucket = bucket;
        self.paths = [NSMutableArray array];
        self.contentVCs = [NSMutableArray array];
        self.isPathSelecting = NO;
    }
    return self;
}

- (instancetype)initWithBucket:(QiniuBucket *)bucket {
    return [self initWithBucket:bucket paths:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.bucket.name;
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tabBarController.tabBar.hidden = YES;

    [self addSubviews];
    self.currentPathIndex = self.paths.count - 1;
}

- (void)addSubviews {
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"上传" style:UIBarButtonItemStylePlain target:self action:@selector(uploadButtonClicked)];
    self.navigationItem.rightBarButtonItem = button;

    kWeakself;
    self.pathView = [[PathView alloc] initWithResourePaths:self.paths pathSelectHandler:^(NSUInteger index) {
        if (index == self.currentPathIndex) {
            return;
        }
        [weakself updateUIWhenEnterContentVCAtIndex:index];
    }];
    [self.view addSubview:self.pathView];
    [self.pathView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(self.view).offset(64);
        make.height.mas_equalTo(36);
    }];

    MASViewAttribute *attr = self.view.mas_bottom;

    if (self.isPathSelecting) {
        ConfirmUploadPathToolView *toolView = [ConfirmUploadPathToolView new];
        [self.view addSubview:toolView];
        [toolView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.equalTo(self.view);
            make.height.mas_equalTo(48);
        }];
        attr = toolView.mas_top;
    }

    self.contentView = [[UIView alloc] init];
    self.contentView.clipsToBounds = YES;
    [self.view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(self.pathView.mas_bottom);
        make.bottom.equalTo(attr);
    }];

    QiniuResourceContentViewController *vc = [[QiniuResourceContentViewController alloc] initWithBucket:self.bucket path:@"" parentVC:self];
    [self.contentView addSubview:vc.view];
    [vc.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(kContentInset, kContentInset, kContentInset, kContentInset));
    }];
}

- (void)setSelectPathFlag:(BOOL)isSelectPath {
    self.isPathSelecting = isSelectPath;
}

#pragma mark - Button Event

- (void)uploadButtonClicked {
    LocalMainViewController *vc = [[LocalMainViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:nav animated:YES completion:nil];
}

# pragma mark - Enter Content View

- (void)addNewContentVC:(UIViewController *)vc named:(NSString *)path {
    NSString *fixedPath = self.bucket.name;
    if (path.length != 0) {
        fixedPath = [path componentsSeparatedByString:@"/"].lastObject;
    }

    [_paths addObject:fixedPath];
    [self.pathView appendPath:fixedPath];
    [self.contentVCs addObject:vc];
}

- (NSInteger)haveEnteredConentVCNamed:(NSString *)path {
    __block NSInteger index = -1;
    [self.paths enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isEqualToString:path]) {
            index = idx;
            *stop = YES;
        }
    }];
    return index;
}

- (void)enterNewContentVCNamed:(NSString *)name {
    UIViewController *vc = [[QiniuResourceContentViewController alloc] initWithBucket:self.bucket path:name parentVC:self];
    vc.view.frame = CGRectOffset(CGRectInset(self.contentView.bounds, kContentInset, kContentInset), kWindowWidth, 0);
    [self.contentView addSubview:vc.view];
    // notice: must have a delay, because vc.view must has benn in view hierarchy
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateUIWhenEnterNewContentVC];
    });
}

- (void)enterContentVCNamed:(NSString *)name {
    // first judge whether have entered content vc
    NSInteger enteredIndex = [self haveEnteredConentVCNamed:name];
    // backward existed content vc
    if (enteredIndex != -1) {
        [self updateUIWhenEnterContentVCAtIndex:enteredIndex];
    }
    // enter new content vc
    else if (self.currentPathIndex == self.paths.count - 1) {
        [self enterNewContentVCNamed:name];
    }
    // backward not existed content vc
    else {
        NSUInteger location = self.currentPathIndex + 1;
        NSRange removeRange = NSMakeRange(location, _paths.count - location);
        [_paths removeObjectsInRange:removeRange];
        [self.contentVCs removeObjectsInRange:removeRange];
        [self.pathView removePathsInRange:removeRange];

        [self enterNewContentVCNamed:name];
    }
}

- (void)updateUIWhenEnterContentVCAtIndex:(NSUInteger)index {
    [self.pathView updateUIWhenSelectPathButtonChangedTo:index];

    UIViewController *dstVC = self.contentVCs[index];
    UIViewController *srcVC = self.contentVCs[self.currentPathIndex];
    // why could not add this code, or error animation with forwar case
//        [weakself.contentView bringSubviewToFront:dstVC.view];

    BOOL forward = index > self.currentPathIndex;
    CGRect dstVCBeginFrame = CGRectOffset(srcVC.view.frame, (forward ? 1 : -1) * kWindowWidth, 0);
    dstVC.view.frame = dstVCBeginFrame;

    [UIView animateWithDuration:0.5 animations:^{
        dstVC.view.frame = CGRectOffset(dstVC.view.frame, (forward ? -1 : 1) * kWindowWidth, 0);
        srcVC.view.frame = CGRectOffset(srcVC.view.frame, (forward ? -1 : 1) * kWindowWidth, 0);
    } completion:nil];

    self.currentPathIndex = index;
}

- (void)updateUIWhenEnterNewContentVC {
    [self updateUIWhenEnterContentVCAtIndex:self.paths.count-1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
