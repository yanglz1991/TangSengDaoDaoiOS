//
//  QCConversationSettingVC.m
//  QCCore
//
//  Created by tt on 2020/1/20.
//

#import "QCConversationGroupSettingVC.h"
#import "UIView+WK.h"
#import "QCSettingMemberGridView.h"
#import "QCCore.h"
#import "QCConversationSettingVM.h"
#import "QCFormItemCell.h"
#import "QCResource.h"
#import "QCModelConvert.h"
#import "QCInputVC.h"
#import "QCGroupManager.h"
#import "QCMessageManager.h"
#import "QCAvatarUtil.h"
#import "QCUserAvatar.h"
#import "QCActionSheetView2.h"
#import "QCWebViewVC.h"
#import "QCMemberListVC.h"
#import "QCTextViewVC.h"
#import "QCOnlineBadgeView.h"

@interface QCConversationGroupSettingVC ()<QCConversationSettingDelegate,QCSettingMemberGridViewDelegate>


@property(nonatomic,strong) QCSettingMemberGridView *settingMemberGridView;
@property(nonatomic,strong) NSArray<QCChannelMember*> *topNMembers; // 前指定数量的成员
@property(nonatomic,assign) NSInteger limitMemberCount; // 现在的最多成员数量


@property(nonatomic,strong) UIView *headerView;



@end

@implementation QCConversationGroupSettingVC


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [QCConversationSettingVM new];
        self.viewModel.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    self.viewModel.channel = self.channel;
    self.viewModel.context = self.context;
    
    [super viewDidLoad];
    
    [[QCSDK shared].channelManager fetchChannelInfo:self.channel]; // 先同步一次
    
    
    
    if( [self.viewModel isManagerOrCreatorForMe]) {
        self.limitMemberCount = 20 - 2; // 减掉+和-的icon
    }else {
        self.limitMemberCount = 20 - 1;// 减掉+的icon
    }
    
    // 获取频道成员
//    self.topNMembers = [[QCSDK shared].channelManager getMembersWithChannel:self.channel limit:self.limitMemberCount];
//    if(self.topNMembers && self.topNMembers.count<self.limitMemberCount) {
//        self.memberCount = self.topNMembers.count;
//    } else {
//        self.memberCount =  [[QCSDK shared].channelManager getMemberCount:self.channel];
//    }
//    if(self.memberCount>self.limitMemberCount) {
//        self.hasMoreMember = true;
//    }
    

    [self requestTopNMembers:self.limitMemberCount];

    
    [self refreshMembers];
    if(self.viewModel.groupType == QCGroupTypeCommon) {
        // 如果需要，则同步成员
        [self.viewModel syncMembersIfNeed];
    }
    
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.tableView];

    
    // 监听群成员更新通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(memberUpdate) name:QCNOTIFY_GROUP_MEMBERUPDATE object:nil];
    
}


-(void) requestTopNMembers:(NSInteger)limitMemberCount {
    __weak typeof(self) weakSelf = self;
    NSInteger limit = limitMemberCount + 1;
    [[QCGroupManager shared] searchMembers:self.channel keyword:nil limit:limit complete:^(QCChannelMemberCacheType cacheType, NSArray<QCChannelMember *> * _Nonnull members) {
        if(members.count >= limit) {
            weakSelf.topNMembers = [members subarrayWithRange:NSMakeRange(0, members.count-1)];
        }else {
            weakSelf.topNMembers = members;
        }
        // 始终显示「查看更多群成员」入口，便于通过搜索快速查找群成员
        weakSelf.settingMemberGridView.hasMore = true;
        NSMutableArray<NSString*> *memberUIDs = [NSMutableArray array];
        if(weakSelf.topNMembers && weakSelf.topNMembers.count>0) {
            for (QCChannelMember *member in weakSelf.topNMembers) {
                [memberUIDs addObject:member.memberUid];
            }
            [weakSelf.viewModel onlineMembers:memberUIDs].then(^{
                [weakSelf refreshMembers];
            });
        }
        [weakSelf refreshMembers];
        [weakSelf reloadData];
    }];
}

- (void)dealloc {
    // 销毁监听群成员更新通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QCNOTIFY_GROUP_MEMBERUPDATE object:nil];
}


// 群成员更新
-(void) memberUpdate {
    if(self.viewModel.groupType == QCGroupTypeSuper) {
        return;
    }
   self.topNMembers = [[QCChannelMemberDB shared] getMembersWithChannel:self.channel limit:self.limitMemberCount];
    self.viewModel.memberOfMe = nil; // 将我在群成员的数据置空，让其重新获取
    [self refreshMembers];
    [self reloadData];
}



#define memberGridViewTop 20.0f
-(void) refreshMembers {
    [self.settingMemberGridView reloadData];
    self.headerView.lim_height = [self.settingMemberGridView viewHeight] + memberGridViewTop;
    [self.tableView reloadData];
    
    // ponytail: 仅群管理/群主可见人数，普通成员只显示"聊天信息"
    if ([self.viewModel isManagerOrCreatorForMe]) {
        self.title = [NSString stringWithFormat:LLang(@"聊天信息(%lu)"),self.viewModel.memberCount];
    } else {
        self.title = LLang(@"聊天信息");
    }
}
//
//- (UITableView *)tableView{
//    if (!_tableView) {
//        _tableView = [[UITableView alloc] initWithFrame:[self visibleRect] style:UITableViewStyleGrouped];
//        _tableView.dataSource = self;
//        _tableView.delegate = self;
//        UIEdgeInsets separatorInset = _tableView.separatorInset;
//        separatorInset.right          = 0;
//        _tableView.separatorInset = separatorInset;
//        _tableView.backgroundColor=[UIColor clearColor];
//        _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(-0.1f, 0.0f, 0.0f, 0.0f); // TODO: 这里必须要-0.1 要不然滚动条不能滚到顶部 why？？
//        _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
//        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//        _tableView.sectionHeaderHeight = 0.0f;
//        _tableView.sectionFooterHeight = 0.0f;
//
//        _tableView.tableHeaderView = self.headerView;
//        _tableView.tableFooterView = [[UIView alloc] init];
//
//        [_tableView.tableHeaderView setBackgroundColor:[UIColor clearColor]];
//
//
//    }
//    return _tableView;
//}

- (UIView *)headerView {
    if(!_headerView) {
        _headerView = [[UIView alloc] init];
        _headerView.lim_width = self.view.lim_width;
        [_headerView addSubview:self.settingMemberGridView];
        self.settingMemberGridView.lim_top = memberGridViewTop;
    }
    return _headerView;
}

- (QCSettingMemberGridView *)settingMemberGridView {
    if(!_settingMemberGridView) {
        _settingMemberGridView = [QCSettingMemberGridView initWithMaxWidth:self.view.lim_width -  10.0f numberOfLine:5 hasMore:false];
        _settingMemberGridView.delegate = self;
        _settingMemberGridView.lim_left = 5.0f;
        __weak typeof(self) weakSelf = self;
        [_settingMemberGridView setOnMore:^{
            [weakSelf showMoreMembers];
        }];
    }
    return _settingMemberGridView;
}

-(void) showMoreMembers {
    
    QCMemberListVC *vc = [QCMemberListVC new];
    vc.channel = self.channel;
    [QCNavigationManager.shared pushViewController:vc animated:YES];
    
}

#pragma mark - QCSettingMemberGridViewDelegate

-(UIView*) settingMemberGridView:(QCSettingMemberGridView*)settingMemberGridView size:(CGSize)size atIndex:(NSInteger)index{
    if(index< self.topNMembers.count) {
        QCChannelMember *member = self.topNMembers[index];
        return [self memberAvatarView:size member:member];
    }
    if(index == self.topNMembers.count) {
        return [self memberAddOrSubView:size isSub:false];
    }
    if(index == self.topNMembers.count + 1) {
        return [self memberAddOrSubView:size isSub:true];
    }
    return nil;
}

- (void)settingMemberGridView:(QCSettingMemberGridView *)settingMemberGridView didSelect:(NSInteger)index {
    if([self showMemberAddBtn] && index == self.topNMembers.count) {
        [self memberAddClick];
    }else if([self showMemberSubBtn] && index == self.topNMembers.count + 1) {
        [self memberSubClick];
    }else {
        QCChannelMember *member = self.topNMembers[index];
        [self membberAvatarClick:member];
    }
}


-(UIView*) memberAvatarView:(CGSize)size member:(QCChannelMember*)member {
    

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];

    
    // 用户头像
    QCUserAvatar *avatarView = [[QCUserAvatar alloc] initWithFrame:CGRectMake(0, 0, 54.0f,  54.0f)];
    [avatarView setUrl:[QCAvatarUtil getFullAvatarWIthPath:member.memberAvatar]];
    
    [view addSubview:avatarView];
    avatarView.lim_left = view.lim_width/2.0f - avatarView.lim_width/2.0f;
//    avatarView.backgroundColor = [UIColor orangeColor];
    
   
    
    // 去掉群聊-顶部人员列表的在线状态显示（绿点/刚刚/xx分钟）。
    // 保留原 onlineBadgeView 代码注释，方便后续恢复。
    /*
    QCOnlineBadgeView *onlineBadgeView = [QCOnlineBadgeView initWithTip:nil];
    [avatarView addSubview:onlineBadgeView];
    onlineBadgeView.hidden = YES;
    QCUserOnlineResp *onlineResp = [self.viewModel memberOnline:member.memberUid];
    if(onlineResp) {
        onlineBadgeView.hidden = NO;
        if(onlineResp.online) {
            onlineBadgeView.tip = nil;
        }else{
            if ([[NSDate date] timeIntervalSince1970] - onlineResp.lastOffline<60) {
                onlineBadgeView.tip = LLang(@"刚刚");
            }else if( onlineResp.lastOffline+60*60>[[NSDate date] timeIntervalSince1970]) {
                onlineBadgeView.tip =[NSString stringWithFormat:LLang(@"%0.0f分钟"),([[NSDate date] timeIntervalSince1970]-onlineResp.lastOffline)/60];
            }else {
                onlineBadgeView.hidden = YES;
            }
        }
    }
    if(onlineResp && onlineResp.online) {
        onlineBadgeView.lim_left = avatarView.lim_right - onlineBadgeView.lim_width - 12.0f;
    }else{
        onlineBadgeView.lim_left = avatarView.lim_right - onlineBadgeView.lim_width;
    }
   
    onlineBadgeView.lim_top = 0.0f;
    */

    // 名字
     UILabel *nameLbl = [UILabel new];
     if(member.memberRemark && ![member.memberRemark isEqualToString:@""]) {
          nameLbl.text = member.memberRemark;
     }else {
          nameLbl.text = member.memberName;
     }
    QCChannelInfo *memberChannelInfo = [[QCSDK shared].channelManager getChannelInfo:[[QCChannel alloc] initWith:member.memberUid channelType:WK_PERSON]];
    if(memberChannelInfo && memberChannelInfo.remark && ![memberChannelInfo.remark isEqualToString:@""]) {
        nameLbl.text = memberChannelInfo.remark; // 有好友备注，优先显示好友备注
    }

    nameLbl.font = [[QCApp shared].config appFontOfSize:12.0f];
    [nameLbl setTextColor:[QCApp shared].config.defaultTextColor];
     [nameLbl setTextAlignment:NSTextAlignmentCenter];
     nameLbl.lim_width = avatarView.lim_width;
     nameLbl.lim_height = 17.0f;
     [view addSubview:nameLbl];
     nameLbl.lim_top = avatarView.lim_bottom + 5.0f;
     nameLbl.lim_left = view.lim_width/2.0f - nameLbl.lim_width/2.0f;
    
    UIView *roleView = [self getRoleView:member.role];
    if(roleView) {
        [avatarView addSubview:roleView];
        roleView.lim_centerX_parent = avatarView;
        roleView.lim_top = avatarView.lim_height - roleView.lim_height;
    }
    return view;
}

-(UIView*) getRoleView:(QCMemberRole)role {
    
    NSString *roleName = @"";
    
    
    UIView *roleView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 15.0f)];
    roleView.layer.masksToBounds = YES;
    roleView.backgroundColor = QCApp.shared.config.cellBackgroundColor;
    
    UILabel *roleNameLbl = [[UILabel alloc] init];
    roleNameLbl.font = [QCApp.shared.config appFontOfSize:8.0f];
    [roleView addSubview:roleNameLbl];
    
    if(role == QCMemberRoleManager) {
        roleName = LLang(@"管理员");
        roleNameLbl.textColor = QCApp.shared.config.themeColor;
    }else if(role == QCMemberRoleCreator) {
        roleName = LLang(@"群主");
        roleNameLbl.textColor = [UIColor orangeColor];
    }else {
        return nil;
    }
    roleNameLbl.text = roleName;
    [roleNameLbl sizeToFit];
    
    CGFloat width = MAX(roleNameLbl.lim_width+4.0f, roleView.lim_width);
    roleView.lim_width = width;
    roleView.layer.cornerRadius = roleView.lim_height/2.0f;
    
    roleNameLbl.lim_centerX_parent = roleView;
    roleNameLbl.lim_centerY_parent = roleView;
    return roleView;
}

-(UIView*) memberAddOrSubView:(CGSize)size isSub:(BOOL) isSub {
     UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    QCImageView *imgView = [[QCImageView alloc] initWithFrame:CGRectMake(0, 0, 54.0f, 54.0f)];
    imgView.lim_left = view.lim_width/2.0f - imgView.lim_width/2.0f;
    if(isSub) {
        imgView.image = [self imageName:@"Conversation/Setting/MemberDelete"];
    }else {
        imgView.image = [self imageName:@"Conversation/Setting/MemberAdd"];
    }
   
    [view addSubview:imgView];
    return view;
}


-(NSInteger) numberOfSettingMemberGridView:(QCSettingMemberGridView*)settingMemberGridView {
    return (self.topNMembers?self.topNMembers.count:0) + ([self showMemberAddBtn]?1:0) + ([self showMemberSubBtn]?1:0);
}

// 是否显示成员添加按钮
-(BOOL) showMemberAddBtn {
    return true;
}
// 是否显示成员删除按钮
-(BOOL) showMemberSubBtn {
    return [self.viewModel isManagerOrCreatorForMe];
}
// 成员头像点击
-(void) membberAvatarClick:(QCChannelMember*) member {
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    [paramDict setObject:member.memberUid?:@"" forKey:@"uid"];
    [paramDict setObject:member.extra[@"vercode"]?:@"" forKey:@"vercode"];
    [paramDict setObject:[[QCChannel alloc] initWith:member.channelId?:@"" channelType:member.channelType] forKey:@"channel"];
    [[QCApp shared] invoke:QCPOINT_USER_INFO param:paramDict];
}
-(void) memberAddClick {
    // 全局群聊禁言：禁止加群成员
    QCAppRemoteConfig *rc = [QCApp shared].remoteConfig;
    if(rc && rc.disableGroupMessageOn) {
        NSString *tip = (rc.muteTextOfGroup && rc.muteTextOfGroup.length>0) ? rc.muteTextOfGroup : LLang(@"群聊禁言中");
        [QCAlertUtil alert:tip];
        return;
    }
    NSMutableArray *disableUids = [NSMutableArray array];
    NSArray<QCChannelMember*> *members = [[QCSDK shared].channelManager getMembersWithChannel:self.channel];
    if(members) {
        for (QCChannelMember *member in members) {
            [disableUids addObject:member.memberUid];
        }
    }
    __weak typeof(self) weakSelf = self;
    [[QCApp shared] invoke:QCPOINT_CONTACTS_SELECT param:@{@"on_finished":^(NSArray<NSString*>*uids){
        
       NSArray<QCChannelMember*> *blacklistMembers = [[QCChannelMemberDB shared] getBlacklistMembersWithChannel:self.channel];
        if(blacklistMembers && blacklistMembers.count>0) {
            NSMutableArray *names = [NSMutableArray array];
            for (QCChannelMember *member in blacklistMembers) {
                for (NSString *uid in uids) {
                    if([uid isEqualToString:member.memberUid]) {
                        [names addObject:member.memberName];
                    }
                }
            }
            if(names.count>0) {
                NSString *tipContent = [NSString stringWithFormat:LLang(@"%@在群黑名单中"),[names componentsJoinedByString:@"、"]];
                [QCAlertUtil alert:tipContent];
                return;
            }
        }
        
        if(![weakSelf.viewModel isManagerOrCreatorForMe] && weakSelf.viewModel.channelInfo.invite) {
            [[QCNavigationManager shared] popViewControllerAnimated:YES];
            UIAlertController *alertController =   [UIAlertController alertControllerWithTitle:@"" message:LLang(@"群主或管理员已启用\"群聊邀请确认\"，邀请朋友进群可向群主或群管理员描述原因。") preferredStyle:UIAlertControllerStyleAlert];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = LLangW(@"说明邀请理由", weakSelf);
            }];
            [alertController addAction:[UIAlertAction actionWithTitle:LLang(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                       
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:LLang(@"发送") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf requestGroupMemberInvite:uids remark:alertController.textFields[0].text];
            }]];
            [[QCNavigationManager shared].topViewController presentViewController:alertController animated:YES completion:nil];
            return;
        }else {
            [[QCNavigationManager shared].topViewController.view showHUD];
            [[QCGroupManager shared] groupNo:weakSelf.channel.channelId membersOfAdd:uids object:nil complete:^(NSError * _Nonnull error) {
                [[QCNavigationManager shared].topViewController.view hideHud];
                if(error) {
                    [[QCNavigationManager shared].topViewController.view showMsg:error.domain];
                    return;
                }
                [[QCNavigationManager shared] popViewControllerAnimated:YES];
            }];
        }
    },@"disables":disableUids}];
}

-(void) requestGroupMemberInvite:(NSArray<NSString*>*)uids remark:(NSString*)remark{
    __weak typeof(self) weakSelf = self;
    [self.viewModel requestGroupMemberInvite:uids remark:remark].then(^{
        [[QCNavigationManager shared].topViewController.view showMsg:LLangW(@"已发送", weakSelf)];
        return;
    }).catch(^(NSError *error){
        [[QCNavigationManager shared].topViewController.view showMsg:error.domain];
        return;
    });
}


-(void) memberSubClick {
    
    __weak typeof(self) weakSelf = self;
    
    QCMemberListVC *vc = [QCMemberListVC new];
    vc.title = LLang(@"删除群成员");
    vc.channel = self.channel;
    vc.edit = true;
    
    NSMutableArray<NSString*> *disableUsers = [NSMutableArray array];
    if(self.viewModel.memberOfMe.role == QCMemberRoleManager) {
        NSArray<QCChannelMember*> *members = [QCChannelMemberDB.shared getManagerAndCreator:self.channel];
        if(members && members.count>0) {
            for (QCChannelMember *member in members) {
                [disableUsers addObject:member.memberUid];
            }
        }
    }
    vc.hiddenUsers = @[QCApp.shared.loginInfo.uid];
    vc.disableUsers = disableUsers;
    vc.onFinishedSelect = ^(NSArray<NSString *> * _Nonnull uids) {
        [[QCGroupManager shared] groupNo:weakSelf.channel.channelId membersOfDelete:uids object:nil complete:^(NSError * _Nonnull error) {
            if(error) {
                [[QCNavigationManager shared].topViewController.view showMsg:error.domain];
                return;
            }
            [[QCNavigationManager shared] popViewControllerAnimated:YES];
        }];
    };
    [QCNavigationManager.shared pushViewController:vc animated:YES];
    
//    NSArray<QCChannelMember*> *members = [[QCSDK shared].channelManager getMembersWithChannel:self.channel];
//    if(members) {
//        NSMutableArray<QCContactsSelect*> *contactsSelects = [NSMutableArray array];
//        for (QCChannelMember *member in members) {
//            if(![[QCApp shared].loginInfo.uid isEqualToString:member.memberUid]) {
//                [contactsSelects addObject:[QCModelConvert toContactsSelect:member]];
//            }
//        }
//        [[QCApp shared] invoke:QCPOINT_CONTACTS_SELECT param:@{@"on_finished":^(NSArray<NSString*>*uids){
//            [[QCGroupManager shared] groupNo:self.channel.channelId membersOfDelete:uids object:nil complete:^(NSError * _Nonnull error) {
//                if(error) {
//                    [[QCNavigationManager shared].topViewController.view showMsg:error.domain];
//                    return;
//                }
//                [[QCNavigationManager shared] popViewControllerAnimated:YES];
//            }];
//        },@"data":contactsSelects,@"title":LLang(@"删除群成员")}];
//    }
   
}


#pragma mark - QCConversationSettingDelegate
// 群名点击
- (void)settingOnGroupNameClick:(QCConversationSettingVM *)vm {
    QCMemberRole roleOfMe = self.viewModel.memberOfMe.role;
    if(roleOfMe != QCMemberRoleManager && roleOfMe!=QCMemberRoleCreator) {
        [QCAlertUtil alert:LLang(@"只有群主或管理员才能修改")];
        return;
    }
    QCInputVC *inputVC = [QCInputVC new];
    inputVC.title = LLang(@"修改群名称");
    inputVC.maxLength = 10;
    inputVC.placeholder = LLang(@"群名称");
    inputVC.defaultValue = self.viewModel.channelInfo.name;
    [inputVC setOnFinish:^(NSString * _Nonnull value) {
        [[QCGroupManager shared] groupUpdate:self.channel.channelId attrKey:QCGroupAttrKeyName attrValue:value complete:^(NSError * _Nonnull error) {
            if(error) {
                [[QCNavigationManager shared].topViewController.view showMsg:error.domain];
                return;
            }
             [[QCNavigationManager shared] popViewControllerAnimated:YES];
        }];
       
    }];
    [[QCNavigationManager shared] pushViewController:inputVC animated:YES];
}
// 群公告点击
-(void) settingOnGroupNoticeClick:(QCConversationSettingVM*)vm {
    QCMemberRole roleOfMe = self.viewModel.memberOfMe.role;
    BOOL managerRole = roleOfMe == QCMemberRoleManager || roleOfMe==QCMemberRoleCreator;
//    if(!managerRole) {
//        [QCAlertUtil alert:LLang(@"只有群主或管理员才能修改")];
//        return;
//    }
    BOOL editable = managerRole;
    QCTextViewVC *textViewVC = [QCTextViewVC new];
    textViewVC.title = LLang(@"修改群公告");
    textViewVC.maxLength = 400;
    textViewVC.placeholder = [NSString stringWithFormat:LLang(@"群公告（最长输入%ld个字符）"),textViewVC.maxLength];
    textViewVC.editable = editable;
    textViewVC.defaultValue = self.viewModel.channelInfo.notice;
    if(!editable) {
        textViewVC.tip = LLang(@"----- 仅群主和管理员可编辑 -----");
    }
   
    [textViewVC setOnFinish:^(NSString * _Nonnull value) {
        [[QCGroupManager shared] groupUpdate:self.channel.channelId attrKey:QCGroupAttrKeyNotice attrValue:value complete:^(NSError * _Nonnull error) {
            if(error) {
                [[QCNavigationManager shared].topViewController.view showMsg:error.domain];
                return;
            }
             [[QCNavigationManager shared] popViewControllerAnimated:YES];
        }];
       
    }];
    [[QCNavigationManager shared] pushViewController:textViewVC animated:YES];
}
// 频道数据更新
-(void) settingOnChannelUpdate:(QCConversationSettingVM*)vm {
    [self.tableView reloadData];
}

- (void)settingOnTopNMembersUpdate:(QCConversationSettingVM *)vm {
    if(!self.settingMemberGridView.hasMore) {
        [self requestTopNMembers:self.limitMemberCount];
    }
    [self refreshMembers];
}

// 清空消息
- (void)settingOnClearMessages:(QCConversationSettingVM *)vm {
     __weak typeof(self) weakSelf = self;
    
    QCActionSheetView2 *actionSheetView = [QCActionSheetView2 initWithTip:nil];
    [actionSheetView addItem:[QCActionSheetButtonItem2 initWithAlertTitle:LLang(@"清空聊天记录") onClick:^{
        [[QCMessageManager shared] clearMessages:weakSelf.channel];
    }]];
    [actionSheetView show];

}
// 退出群聊
- (void)settingOnGroupExit:(QCConversationSettingVM *)vm {
    __weak typeof(self) weakSelf = self;
    QCActionSheetView2 *actionSheetView = [QCActionSheetView2 initWithTip:LLang(@"退出后不会通知群聊中其他成员，且不会再接收此群聊消息")];
      [actionSheetView addItem:[QCActionSheetButtonItem2 initWithAlertTitle:LLang(@"确定") onClick:^{
          [[QCGroupManager shared] didGroupExit:weakSelf.channel.channelId complete:^(NSError * _Nonnull error) {
              [[QCNavigationManager shared] popToRootViewControllerAnimated:YES];
               [[QCSDK shared].conversationManager deleteConversation: weakSelf.channel];
          }];
      }]];
      [actionSheetView show];
   
}

/**
 
 在群里的昵称
 @param vm <#vm description#>
 */
-(void) settingOnNickNameInGroup:(QCConversationSettingVM*)vm {
    if(!self.viewModel.memberOfMe) {
        return;
    }
    NSString *name = self.viewModel.memberOfMe.memberName;
    if(self.viewModel.memberOfMe.memberRemark && ![self.viewModel.memberOfMe.memberRemark isEqualToString:@""]) {
        name = self.viewModel.memberOfMe.memberRemark;
    }
    QCInputVC *inputVC = [QCInputVC new];
    inputVC.title = LLang(@"我在本群的昵称");
    inputVC.placeholder = LLang(@"在这里可以设置你在这个群里的昵称。这个昵称只会在此群内显示。");
    inputVC.defaultValue = name;
    inputVC.maxLength = 10;
    [inputVC setOnFinish:^(NSString * _Nonnull value) {
        [[QCGroupManager shared] didMemberUpdateAtGroup:self.channel.channelId forMemberUID:self.viewModel.memberOfMe.memberUid withAtrr:@{@"remark":value?:@""} complete:^(NSError * _Nonnull error) {
            if(error) {
                [[QCNavigationManager shared].topViewController.view showMsg:error.domain];
                return;
            }
             [[QCNavigationManager shared] popViewControllerAnimated:YES];
        }];
        
    }];
    [[QCNavigationManager shared] pushViewController:inputVC animated:YES];
}


- (void)settingOnReport:(QCConversationSettingVM *)vm {
    QCWebViewVC *vc = [[QCWebViewVC alloc] init];
    vc.title = LLang(@"投诉");
    vc.url = [NSURL URLWithString:[QCApp shared].config.reportUrl];
    vc.channel = self.channel;
    [[QCNavigationManager shared] pushViewController:vc animated:YES];
}


-(UIImage*) imageName:(NSString*)name {
    return [QCApp.shared loadImage:name moduleID:@"QCCore"];
}

@end
