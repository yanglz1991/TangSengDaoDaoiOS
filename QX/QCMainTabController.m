//
//  QCMainTabController.m
//  QX
//
//  Created by tt on 2019/12/7.
//  Copyright © 2025 QX. All rights reserved.
//

#import "QCMainTabController.h"
#import <QCCore/QCCore.h>
#import <Lottie/Lottie.h>
#import "QCConversationListVC.h"
#import "QCContactsVC.h"
#import "QCMeVC.h"
@interface QCMainTabController ()<UITabBarControllerDelegate>

@property(nonatomic,strong) LOTAnimationView *currentLOTAnimationView;

@end

@implementation QCMainTabController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    // Do any additional setup after loading the view.
    [self.tabBar setBarTintColor:[UIColor whiteColor]];
    
    [[UITabBar appearance] setShadowImage:[[UIImage alloc]init]];
    [[UITabBar appearance] setBackgroundImage:[[UIImage alloc]init]];
    if (@available(iOS 13.0, *)) {
        [self.tabBar setBarTintColor:[UIColor systemBackgroundColor]];
        [self.tabBar setBackgroundColor:[UIColor systemBackgroundColor]];
    } else {
        [self.tabBar setBarTintColor:[UIColor whiteColor]];
        [self.tabBar setBackgroundColor:[UIColor whiteColor]];
    }

    // Tab 图标着色：选中态用主题蓝，未选中态用中性灰，PDF 走 Template 渲染由系统统一上色
    self.tabBar.tintColor = [QCApp shared].config.themeColor;
    if (@available(iOS 10.0, *)) {
        self.tabBar.unselectedItemTintColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    }

    [self setupChildVC:QCConversationListVC.class title:@"" andImage:@"HomeTab" andSelectImage:@"HomeTabSelected"];
    [self setupChildVC:QCContactsVC.class title:@"" andImage:@"ContactsTab" andSelectImage:@"ContactsTabSelected"];
    [self setupChildVC:QCMeVC.class title:@"" andImage:@"MeTab" andSelectImage:@"MeTabSelected"];

}

- (void)setupChildVC:(Class)vc title:(NSString *)title andImage:(NSString * )image andSelectImage:(NSString *)selectImage{
    
    UIViewController * vcInstall = [[vc alloc] init];
    //VC.view.backgroundColor = UIColor.whiteColor;
    vcInstall.tabBarItem.title = title;
    // 用 Template 渲染让系统按 tabBar.tintColor / unselectedItemTintColor 自动着色
    vcInstall.tabBarItem.image = [[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    vcInstall.tabBarItem.selectedImage = [[UIImage imageNamed:selectImage] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    vcInstall.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    [self addChildViewController:vcInstall];
}


-(void) dealloc {
    QCLogDebug(@"QCMainTabController dealloc");
}

#pragma mark - UITabBarControllerDelegate

static UIImpactFeedbackGenerator *impactFeedBack;
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
    if(!impactFeedBack) {
        impactFeedBack = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    }
    [impactFeedBack prepare];
    [impactFeedBack impactOccurred];
}

@end
