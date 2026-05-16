//
//  QCScreenPasswordSettingVC.m
//  QCCore
//
//  Created by tt on 2021/8/16.
//

#import "QCScreenPasswordSettingVC.h"

#import "QCScreenPasswordSettingVM.h"
#import "QCScreenPasswordSetVC.h"

@interface QCScreenPasswordSettingVC ()<QCScreenPasswordSettingVMDelegate>

@end

@implementation QCScreenPasswordSettingVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [QCScreenPasswordSettingVM new];
        self.viewModel.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LLang(@"解锁密码");
}


#pragma mark -- QCScreenPasswordSettingVMDelegate

- (void)screenPasswordSettingVMAutoLockDidClick:(QCScreenPasswordSettingVM *)vm {
    QCActionSheetView2 *sheet = [QCActionSheetView2 initWithTip:nil cancel:LLang(@"取消")];
    [sheet addItem:[self getTimeSheetItem:0]];
    [sheet addItem:[self getTimeSheetItem:1]];
    [sheet addItem:[self getTimeSheetItem:5]];
    [sheet addItem:[self getTimeSheetItem:30]];
    [sheet addItem:[self getTimeSheetItem:60]];
    
    [sheet show];
}

- (void)screenPasswordSettingVMChangeLockDidClick:(QCScreenPasswordSettingVM *)vm {
    QCScreenPasswordSetVC *vc = [QCScreenPasswordSetVC new];
    [[QCNavigationManager shared] replacePushViewController:vc animated:YES];
}

- (void)screenPasswordSettingVMCloseLockDidClick:(QCScreenPasswordSettingVM *)vm {
    [self.view showHUD];
    __weak typeof(self) weakSelf = self;
    [self.viewModel requestCloseLock].then(^{
        [weakSelf.view hideHud];
        [[QCApp shared].loginInfo.extra removeObjectForKey:@"lock_screen_pwd"];
        [[QCApp shared].loginInfo save];
        [[QCNavigationManager shared] popViewControllerAnimated:YES];
    }).catch(^(NSError *error){
        [weakSelf.view hideHud];
        [weakSelf.view showHUDWithHide:error.domain];
    });
}

-(QCActionSheetItem2*) getTimeSheetItem:(NSInteger)minute{
    
    __weak typeof(self) weakSelf = self;
    return [QCActionSheetButtonItem2 initWithTitle:[self.viewModel getLockTimeDesc:minute] onClick:^{
        [QCApp shared].loginInfo.extra[@"lock_after_minute"] = @(minute);
        [[QCApp shared].loginInfo save];
        
        [weakSelf reloadData];
        
        
        [weakSelf.viewModel requestSetLockAfterMinute].catch(^(NSError *error){
            [[QCNavigationManager shared].topViewController.view showHUDWithHide:error.domain];
        });
    }];
}


@end
