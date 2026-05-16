//
//  QCMeInfoVC.m
//  QCCore
//
//  Created by tt on 2020/6/23.
//

#import "QCMeInfoVC.h"
#import "QCInputVC.h"
#import "QCActionSheetView2.h"
@interface QCMeInfoVC ()<QCMeInfoDelegate,QCChannelManagerDelegate>

@end

@implementation QCMeInfoVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [QCMeInfoVM new];
        self.viewModel.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avatarUpdate:) name:QCNOTIFY_USER_AVATAR_UPDATE object:nil];
    
    [QCSDK.shared.channelManager addDelegate:self];
}


- (NSString *)langTitle {
    return LLang(@"个人信息");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reloadData]; // TODO: 修改名字或short_no后刷新
}

- (void)dealloc {
    [QCSDK.shared.channelManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QCNOTIFY_USER_AVATAR_UPDATE object:nil];
}

-(void) avatarUpdate:(NSNotification*)noti {
    NSDictionary *data = noti.object;
    if(data && data[@"uid"] && [[QCApp shared].loginInfo.uid isEqualToString:data[@"uid"]]) {
        [self.tableView reloadData];
    }
}

#pragma mark - 委托
// 修改名字
- (void)meInfoVMUpdateName:(QCMeInfoVM *)vm {
    __weak typeof(self) weakSelf = self;
    QCInputVC *inputVC = [QCInputVC new];
    inputVC.title = LLang(@"修改名字");
    inputVC.maxLength = 10;
    inputVC.defaultValue = [QCApp shared].loginInfo.extra[@"name"];
    [inputVC setOnFinish:^(NSString * _Nonnull value) {
        [weakSelf updateName:value];
    }];
    [[QCNavigationManager shared] pushViewController:inputVC animated:YES];
}

// 更新名称
-(void) updateName:(NSString*)name {
    [self.viewModel updateInfo:@"name" value:name].then(^{
        [QCApp shared].loginInfo.extra[@"name"] = name;
        [[QCApp shared].loginInfo save];
        [[QCNavigationManager shared] popViewControllerAnimated:YES];
        // 更新下自己的频道
        [[QCChannelManager shared] fetchChannelInfo:[QCChannel personWithChannelID:[QCApp shared].loginInfo.uid]];
    }).catch(^(NSError *error){
         [[QCNavigationManager shared].topViewController.view showMsg:error.domain];
    });
}

// 更新性别
-(void) updateSex:(NSInteger) sex {
    __weak typeof(self) weakSelf = self;
    [self.viewModel updateInfo:@"sex" value:[NSString stringWithFormat:@"%ld",(long)sex]].then(^{
        [QCApp shared].loginInfo.extra[@"sex"] = @(sex);
        [[QCApp shared].loginInfo save];
        [weakSelf reloadData];
    }).catch(^(NSError *error){
         [[QCNavigationManager shared].topViewController.view showMsg:error.domain];
    });
}

// 更新短编码
-(void) updateShortNo:(NSString*)shortNo {
    [self.viewModel updateInfo:@"short_no" value:shortNo].then(^{
        [QCApp shared].loginInfo.extra[@"short_no"] = shortNo;
        [QCApp shared].loginInfo.extra[@"short_status"] = @(1);
        [[QCApp shared].loginInfo save];
        [[QCNavigationManager shared] popViewControllerAnimated:YES];
    }).catch(^(NSError *error){
         [[QCNavigationManager shared].topViewController.view showMsg:error.domain];
    });
}

// 修改性别
- (void)meInfoVMUpdateSex:(QCMeInfoVM *)vm {
    __weak typeof(self) weakSelf = self;
    QCActionSheetView2 *sheet = [QCActionSheetView2 initWithTip:nil];
    [sheet addItem:[QCActionSheetButtonItem2 initWithTitle:LLang(@"男") onClick:^{
        [weakSelf updateSex:1];
    }]];
    [sheet addItem:[QCActionSheetButtonItem2 initWithTitle:LLang(@"女") onClick:^{
        [weakSelf updateSex:0];
    }]];
    [sheet show];
}
// 修改短编码
-(void) meInfoVMUpdateShortNo:(QCMeInfoVM*)vm {
    __weak typeof(self) weakSelf = self;
    QCInputVC *inputVC = [QCInputVC new];
    inputVC.maxLength = 10;
    inputVC.title = [NSString stringWithFormat:LLang(@"修改%@号"),[QCApp shared].config.appName];
    inputVC.defaultValue = [QCApp shared].loginInfo.extra[@"short_no"];
    inputVC.placeholder = [NSString stringWithFormat:LLang(@"%@号只允许修改一次"),[QCApp shared].config.appName];
    [inputVC setOnFinish:^(NSString * _Nonnull value) {
        [weakSelf updateShortNo:value];
       
    }];
    [[QCNavigationManager shared] pushViewController:inputVC animated:YES];
}

#pragma mark -- QCChannelManagerDelegate

- (void)channelInfoUpdate:(QCChannelInfo *)channelInfo {
    if(channelInfo.channel.channelType != WK_PERSON) {
        return;
    }
    if(![channelInfo.channel.channelId isEqualToString:QCApp.shared.loginInfo.uid]) {
        return;
    }
    QCApp.shared.loginInfo.extra[@"name"] = channelInfo.name;
    [QCApp shared].loginInfo.extra[@"short_no"] = channelInfo.extra[@"short_no"];
    [QCApp shared].loginInfo.extra[@"sex"] = channelInfo.extra[@"sex"];
//    [[QCApp shared].loginInfo save];
    
    [self reloadData];
}

@end
