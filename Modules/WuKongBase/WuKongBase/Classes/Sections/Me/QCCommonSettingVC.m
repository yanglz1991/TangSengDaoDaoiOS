//
//  QCCommonSettingVC.m
//  WuKongBase
//
//  Created by tt on 2020/6/21.
//

#import "QCCommonSettingVC.h"
#import "QCCommonSettingVM.h"
#import "QCActionSheetView2.h"
@interface QCCommonSettingVC ()

@end

@implementation QCCommonSettingVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [QCCommonSettingVM new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LLang(@"通用");
}


- (void)viewConfigChange:(QCViewConfigChangeType)type {
    [super viewConfigChange:type];
    if(type == QCViewConfigChangeTypeLang) {
        self.title = LLang(@"通用");
        [self reloadData];
    }
   
}

#pragma mark - QCCommonSettingVMDelegate
- (void)dealloc
{
    QCLogDebug(@"QCCommonSettingVC dealloc!");
}

@end
