//
//  QCMePushSettingVC.m
//  WuKongBase
//
//  Created by tt on 2020/6/19.
//

#import "QCMePushSettingVC.h"

@interface QCMePushSettingVC ()<QCMePushSettingDelegate>

@end

@implementation QCMePushSettingVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [QCMePushSettingVM new];
        self.viewModel.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSString *)langTitle {
    return LLang(@"新消息通知");
}

#pragma mark - QCMePushSettingDelegate

- (void)mePushSettingVMRefreshTable:(QCMePushSettingVM *)vm {
    [self reloadData];
}

@end
