//
//  QCMainTabController.m
//  TangSengDaoDao
//
//  Created by tt on 2019/12/7.
//  Copyright © 2019 xinbida. All rights reserved.
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
   
    [self setupChildVC:QCConversationListVC.class title:@"" andImage:@"HomeTab" andSelectImage:@"HomeTabSelected"];
    [self setupChildVC:QCContactsVC.class title:@"" andImage:@"ContactsTab" andSelectImage:@"ContactsTabSelected"];
    [self setupChildVC:QCMeVC.class title:@"" andImage:@"MeTab" andSelectImage:@"MeTabSelected"];

}

- (void)setupChildVC:(Class)vc title:(NSString *)title andImage:(NSString * )image andSelectImage:(NSString *)selectImage{
    
    UIViewController * vcInstall = [[vc alloc] init];
    //VC.view.backgroundColor = UIColor.whiteColor;
    vcInstall.tabBarItem.title = title;
    vcInstall.tabBarItem.image = [[UIImage imageNamed:image]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    vcInstall.tabBarItem.selectedImage = [[UIImage imageNamed:selectImage]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
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
