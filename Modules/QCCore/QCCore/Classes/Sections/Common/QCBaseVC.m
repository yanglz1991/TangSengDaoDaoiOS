//
//  QCBaseVC.m
//  QCCore
//
//  Created by tt on 2019/12/1.
//

#import "QCBaseVC.h"
#import "UIBarButtonItem+WK.h"
#import "QCResource.h"
#import "QCApp.h"
#import "QCConstant.h"
#import "UIView+WK.h"
#import "QCNavTitleView.h"
#import "QCNavigationManager.h"
#import "QCLogs.h"
#import "QCCore.h"


@implementation QCFinishButton

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    
    if(enabled) {
        self.alpha = 1.0f;
    }else{
        self.alpha = 0.5f;
    }
}

@end

@interface QCBaseVC ()


@end

@implementation QCBaseVC


-(instancetype) initWithViewModel:(QCBaseVM*)vm{
    self = [super init];
    if (!self) return nil;
    self.baseVM = vm;
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [self langTitle];
    [self.view setBackgroundColor:[QCApp shared].config.backgroundColor];
//    [self.navigationController.navigationBar setTranslucent:NO];
    [self.view addSubview:self.navigationBar];
    
    if ([self.navigationController.viewControllers count] >= 2 ) {
        [self setupNavBack];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(langChange) name:QCNOTIFY_LANG_CHANGE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moduleChange) name:QCNOTIFY_MODULE_CHANGE object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)dealloc
{
    QCLogDebug(@"%s",__func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QCNOTIFY_LANG_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QCNOTIFY_MODULE_CHANGE object:nil];
}

-(void) langChange {
    [self viewConfigChange:QCViewConfigChangeTypeLang];
}
-(void) moduleChange {
    [self viewConfigChange:QCViewConfigChangeTypeModule];
}

- (QCNavigationBar *)navigationBar {
    if(!_navigationBar) {
        _navigationBar = [[QCNavigationBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f,QCScreenWidth, self.largeTitle?[QCApp shared].config.navHeight+15.0f:[QCApp shared].config.navHeight)];
        _navigationBar.largeTitle = self.largeTitle;
        __weak typeof(self) weakSelf = self;
        [_navigationBar setBackgroundColor:[QCApp shared].config.navBackgroudColor];
        _navigationBar.onBack = ^{
            [weakSelf backPressed];
        };
        [QCApp.shared.config setThemeStyleNavigation:_navigationBar];
    }
    return _navigationBar;
}
- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    self.navigationBar.title = title;

}

-(NSString*) langTitle {
    return nil;
}

-(void) backPressed {
    [[QCNavigationManager shared] popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self.navigationController.navigationBar setHidden:NO];
    [self.navigationController.navigationBar setBarTintColor:[QCApp shared].config.backgroundColor];
}


-(void) setupNavBack {
    [self.navigationBar setShowBackButton:YES];
}

- (void)leftBarButtonAction:(id)sender {
    UIViewController *v =
    [self.navigationController popViewControllerAnimated:YES];
    if (v == nil) {
        [self.view endEditing:YES];
        dispatch_after(
                       dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
                           [self dismissViewControllerAnimated:YES completion:NULL];
                       });
    }
}

-(UIImage*) getImageWithName:(NSString*)name {
    return [QCApp.shared loadImage:name moduleID:@"QCCore"];
//    return [[QCResource shared] resourceForImage:name podName:@"QCCore_images"];
}

-(CGFloat) getNavBottom {
    CGRect rectNav = self.navigationController.navigationBar.frame;
    return rectNav.origin.y + rectNav.size.height;
}

- (void)setRightView:(UIView *)rightView {
    self.navigationBar.rightView = rightView;
}

-(CGRect) visibleRect {
    
    return CGRectMake(0.0f, self.navigationBar.lim_bottom, self.view.lim_width, self.view.lim_height - self.navigationBar.lim_bottom);
}

- (QCFinishButton *)finishBtn {
    if(!_finishBtn) {
        _finishBtn = [[QCFinishButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 60.0f, 30.0f)];
        [_finishBtn setTitle:LLangC(@"完成",[QCBaseVC class]) forState:UIControlStateNormal];
        _finishBtn.layer.masksToBounds = YES;
        _finishBtn.layer.cornerRadius = 4.0f;
        _finishBtn.backgroundColor = [QCApp shared].config.themeColor;
        [[_finishBtn titleLabel] setFont:[[QCApp shared].config appFontOfSize:16.0f]];
    }
    return _finishBtn;
}



-(void) viewConfigChange:(QCViewConfigChangeType)type {
    if(type == QCViewConfigChangeTypeStyle) {
        [self.view setBackgroundColor:[QCApp shared].config.backgroundColor];
        [self.navigationBar setBackgroundColor:[QCApp shared].config.navBackgroudColor];
        if([QCApp shared].config.style == QCSystemStyleDark) {
            self.navigationBar.style = QCNavigationBarStyleDark;
        }else {
            self.navigationBar.style = QCNavigationBarStyleDefault;
        }
    }
    [QCApp.shared.config setThemeStyleNavigation:self.navigationBar];
   
}

#pragma mark - UITraitEnvironment

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    if (@available(iOS 13.0, *)) {
        UIUserInterfaceStyle mode = UITraitCollection.currentTraitCollection.userInterfaceStyle;
        if (mode == UIUserInterfaceStyleDark) {
            QCLogDebug(@"深色模式");
        } else if (mode == UIUserInterfaceStyleLight) {
            QCLogDebug(@"浅色模式");
        } else {
            QCLogDebug(@"未知模式");
        }
    }
    [self viewConfigChange:QCViewConfigChangeTypeStyle];
}

@end
