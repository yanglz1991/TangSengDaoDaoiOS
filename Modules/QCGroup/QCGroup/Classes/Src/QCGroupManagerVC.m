//
//  QCGroupManagerVC.m
//  QCCore
//
//  Created by tt on 2020/3/1.
//

#import "QCGroupManagerVC.h"
#import "QCGroupManagerVM.h"
#import "QCGroupManager.h"
#import "QCModelConvert.h"
#import "QCConversationGroupSettingVC.h"
@interface QCGroupManagerVC ()<QCGroupManagerVMDelegate,QCChannelManagerDelegate>


@end

@implementation QCGroupManagerVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel =  [[QCGroupManagerVM alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    self.viewModel.channel = self.channel;
    self.viewModel.delegate = self;
    [super viewDidLoad];
    
    // 监听群成员更新通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(memberUpdate) name:QCNOTIFY_GROUP_MEMBERUPDATE object:nil];
    // 监听频道数据变化
    [[QCSDK shared].channelManager addDelegate:self];
}

- (NSString *)langTitle {
    return LLang(@"群管理");
}


// 群成员更新
-(void) memberUpdate {
    [self reloadManagerAndCreators];
}

-(void) reloadManagerAndCreators {
    [self.viewModel reloadManagerAndCreators];
    [self reloadData];
    [self.tableView reloadData];
}

-(void) reloadChannelInfo {
    [self.viewModel reloadChannelInfo];
    [self reloadData];
    [self.tableView reloadData];
}

- (void)dealloc {
    // 销毁监听群成员更新通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QCNOTIFY_GROUP_MEMBERUPDATE object:nil];
      [[QCSDK shared].channelManager removeDelegate:self];
}

#pragma mark -  QCGroupManagerVMDelegate

-(void) didDeleteManager:(QCGroupManagerVM*)vm manager:(QCChannelMember*)manager {
    __weak typeof(self) weakSelf = self;
       UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LLang(@"提示") message:[NSString stringWithFormat:LLang(@"取消“%@”的管理员身份？"),manager.memberName] preferredStyle:UIAlertControllerStyleAlert];
       
       UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLang(@"取消") style:UIAlertActionStyleCancel handler:nil];
       UIAlertAction *okAction = [UIAlertAction actionWithTitle:LLang(@"好的") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[QCGroupManager shared] groupNo:weakSelf.channel.channelId managersToMember:@[manager.memberUid] complete:^(NSError * _Nonnull error) {
                if(error) {
                    [weakSelf.view showMsg:error.domain];
                    return;
                }
                [weakSelf reloadManagerAndCreators];
           }];
       }];
       [alertController addAction:cancelAction];
       [alertController addAction:okAction];
       
       [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didTransferGrouper:(QCGroupManagerVM *)vm {
    NSMutableArray<QCContactsSelect*> *contactsSelects = [NSMutableArray array];
    NSArray *members =  self.viewModel.members;
       for (QCChannelMember *member in members) {
           if([member.memberUid isEqualToString:[QCApp shared].loginInfo.uid]) { // 排除自己
                  continue;
           }
           if([member.memberUid isEqualToString:[QCApp shared].config.fileHelperUID]) { // 排除文件助手
                  continue;
           }
           if([member.memberUid isEqualToString:[QCApp shared].config.systemUID]) { // 系统
                  continue;
           }
           [contactsSelects addObject:[QCModelConvert toContactsSelect:member]];
       }
       __weak typeof(self) weakSelf = self;
       [[QCApp shared] invoke:QCPOINT_CONTACTS_SELECT param:@{@"on_finished":^(NSArray<NSString*>*uids){
           [QCAlertUtil alert:LLang(@"你将自动放弃群主身份。") buttonsStatement:@[LLang(@"取消"),LLang(@"好的")] chooseBlock:^(NSInteger buttonIdx) {
               if(buttonIdx == 1) {
                   [weakSelf.viewModel requestTransferGrouper:uids[0]].then(^{
                       [[QCNavigationManager shared] popToViewControllerClass:QCConversationGroupSettingVC.class animated:YES];
                   }).catch(^(NSError *error){
                       [[QCNavigationManager shared].topViewController.view showMsg:error.domain];
                   });
               }
           }];
          },@"data":contactsSelects,@"mode":@"single",@"title":LLang(@"选择新的群主")}];
}

#pragma mark -- QCChannelManagerDelegate

- (void)channelInfoUpdate:(QCChannelInfo *)channelInfo {
    if(![self.channel isEqual:channelInfo.channel]) {
           return;
    }
    [self reloadChannelInfo];
}

@end
