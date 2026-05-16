//
//  QCConversationSettingVC.m
//  WuKongBase
//
//  Created by tt on 2020/1/20.
//

#import "QCConversationPersonSettingVC.h"
#import "UIView+WK.h"
#import "QCSettingMemberGridView.h"
#import "QCConversationSettingVM.h"
#import "QCResource.h"
#import "QCFormItemCell.h"
#import "QCAvatarUtil.h"
#import "QCUserAvatar.h"
#import "QCWebViewVC.h"
@interface QCConversationPersonSettingVC ()<QCConversationSettingDelegate,QCSettingMemberGridViewDelegate>


@property(nonatomic,strong) QCSettingMemberGridView *settingMemberGridView;


@property(nonatomic,strong) UIView *headerView;

@end

@implementation QCConversationPersonSettingVC

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
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [self refreshTable]; // 这个需要放在添加tableView的前面 要不然顶部会多出来距离
    
    [self.view addSubview:self.tableView];
}

- (NSString *)langTitle {
    return LLang(@"聊天详情");
}

-(void) refreshTable {
    [self.settingMemberGridView reloadData];
    self.headerView.lim_height = [self.settingMemberGridView viewHeight] + 20.0f;
    [self.tableView reloadData];
    
}

//
//- (UITableView *)tableView{
//    if (!_tableView) {
//        CGFloat safeBootom =0.0f;
//        CGFloat safeTop = 0.0f;
//        if (@available(iOS 11.0, *)) {
//            safeBootom =self.view.safeAreaInsets.bottom;
//            safeTop =  self.view.safeAreaInsets.top;
//
//        }
//        _tableView = [[UITableView alloc] initWithFrame:[self visibleRect] style:UITableViewStyleGrouped];
//        _tableView.dataSource = self;
//        _tableView.delegate = self;
//        UIEdgeInsets separatorInset = _tableView.separatorInset;
//        separatorInset.right          = 0;
//        _tableView.separatorInset = separatorInset;
//        _tableView.backgroundColor=[UIColor clearColor];
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
        self.settingMemberGridView.lim_top = 20.0f;
    }
    return _headerView;
}
- (QCSettingMemberGridView *)settingMemberGridView {
    if(!_settingMemberGridView) {
        _settingMemberGridView = [QCSettingMemberGridView initWithMaxWidth:self.view.lim_width -  10.0f numberOfLine:5];
        _settingMemberGridView.delegate = self;
        _settingMemberGridView.lim_left = 5.0f;
    }
    return _settingMemberGridView;
}


#pragma mark - QCSettingMemberGridViewDelegate

-(UIView*) settingMemberGridView:(QCSettingMemberGridView*)settingMemberGridView size:(CGSize)size atIndex:(NSInteger)index{
    if(index == 0) {
        return [self memberAvatarView:size];
    }
    if(index == 1) {
        return [self memberAddOrSubView:size isSub:false];
    }
    return nil;
}

- (void)settingMemberGridView:(QCSettingMemberGridView *)settingMemberGridView didSelect:(NSInteger)index {
    if([self showMemberAddBtn] && index == 1) {
        [self memberAddClick];
    }else {
        [self membberAvatarClick];
    }
}

// 成员头像点击
-(void) membberAvatarClick {
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    [paramDict setObject:self.channel.channelId?:@"" forKey:@"uid"];
    [[QCApp shared] invoke:QCPOINT_USER_INFO param:paramDict];
}

-(UIView*) memberAvatarView:(CGSize)size {
    
    QCUserAvatar *avatarView = [[QCUserAvatar alloc] initWithFrame:CGRectMake(0, 0, 54.0f,  54.0f)];
    [avatarView setUrl:[QCAvatarUtil getFullAvatarWIthPath:[QCAvatarUtil getFullAvatarWIthPath:self.viewModel.channelInfo.logo]]];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    [view addSubview:avatarView];
    avatarView.lim_left = view.lim_width/2.0f - avatarView.lim_width/2.0f;
    
    
     UILabel *nameLbl = [UILabel new];
    nameLbl.text = self.viewModel.channelInfo.name;
    if(self.viewModel.channelInfo.remark && ![self.viewModel.channelInfo.remark isEqualToString:@""]) {
        nameLbl.text = self.viewModel.channelInfo.remark; // 有好友备注，优先显示好友备注
    }
    
    nameLbl.font = [[QCApp shared].config appFontOfSize:12.0f];
    [nameLbl setTextColor:[QCApp shared].config.defaultTextColor];
     [nameLbl setTextAlignment:NSTextAlignmentCenter];
     nameLbl.lim_width = avatarView.lim_width;
     nameLbl.lim_height = 17.0f;
     [view addSubview:nameLbl];
     nameLbl.lim_top = avatarView.lim_bottom + 5.0f;
     nameLbl.lim_left = view.lim_width/2.0f - nameLbl.lim_width/2.0f;
    
    return view;
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
    return 2;
}

// 是否显示成员添加按钮
-(BOOL) showMemberAddBtn {
    return true;
}
// 是否显示成员删除按钮
-(BOOL) showMemberSubBtn {
    return true;
}

-(void) memberAddClick {
    [[QCApp shared] invoke:QCPOINT_CONTACTS_SELECT param:@{@"on_finished":^(NSArray<NSString*>*uids){
        NSMutableArray *newUids = [NSMutableArray arrayWithArray:uids];
        [newUids insertObject:self.channel.channelId atIndex:0];
        [[QCNavigationManager shared].topViewController.view showHUD];
        [[QCGroupManager shared] createGroup:newUids object:nil complete:^(NSString * _Nonnull groupNo, NSError * _Nullable error) {
            [[QCNavigationManager shared].topViewController.view hideHud];
            if(error) {
                [[QCNavigationManager shared].topViewController.view showMsg:error.domain];
                return;
            }
            [[QCNavigationManager shared] popToRootViewControllerAnimated:YES];
        }];
    },@"disables":@[self.channel.channelId]}];
}




#pragma mark - QCConversationSettingDelegate

// 频道数据更新
-(void) settingOnChannelUpdate:(QCConversationSettingVM*)vm {
    [self.tableView reloadData];
}
// 清空消息
- (void)settingOnClearMessages:(QCConversationSettingVM *)vm {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"清空当前聊天消息？" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[QCMessageManager shared] clearMessages:self.channel];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)settingOnReport:(QCConversationSettingVM *)vm {
    QCWebViewVC *vc = [[QCWebViewVC alloc] init];
    vc.title = @"投诉";
    vc.url = [NSURL URLWithString:[QCApp shared].config.reportUrl];
    vc.channel = self.channel;
    [[QCNavigationManager shared] pushViewController:vc animated:YES];
}


-(void) settingOnBlacklist:(QCConversationSettingVM*)vm action:(bool) addOrRemove {
    if(addOrRemove) {
        [self addBlacklist];
    }else {
        [self removeBlacklist];
    }
}

-(void) addBlacklist {
    __weak typeof(self) weakSelf = self;
     QCActionSheetView2 *sheet = [QCActionSheetView2 initWithTip:LLang(@"加入黑名单，你将不再收到对方的消息。")];
    [sheet addItem:[QCActionSheetButtonItem2 initWithAlertTitle:LLangW(@"确认", weakSelf) onClick:^{
        [self.view showHUD];
        [weakSelf.viewModel addBlacklist].then(^{
            [weakSelf.view hideHud];
            QCChannel *channel = weakSelf.viewModel.channelInfo.channel;
            // 删除最近会很
            [[QCSDK shared].conversationManager deleteConversation:channel];
            // 修改频道为黑名单
            weakSelf.viewModel.channelInfo.status = QCChannelStatusBlacklist;
            [[QCSDK shared].channelManager updateChannelInfo:weakSelf.viewModel.channelInfo];
            [[QCNavigationManager shared] popToRootViewControllerAnimated:YES];
        }).catch(^(NSError *error){
            [weakSelf.view hideHud];
            [[[QCNavigationManager shared] topViewController].view showHUDWithHide:error.domain];
        });
    }]];
    [sheet show];
}

-(void) removeBlacklist {
    __weak typeof(self) weakSelf = self;
    [self.view showHUD];
    [weakSelf.viewModel deleteBlacklist].then(^{
        [weakSelf.view hideHud];
        // 修改频道为非黑名单
        QCChannel *channel = weakSelf.viewModel.channelInfo.channel;
         weakSelf.viewModel.channelInfo.status = QCChannelStatusNormal;
        [[QCSDK shared].channelManager updateChannelInfo:weakSelf.viewModel.channelInfo];
        // 恢复最近会话
        [[QCSDK shared].conversationManager recoveryConversation:channel];
        [[QCNavigationManager shared] popToRootViewControllerAnimated:YES];
    }).catch(^(NSError *error){
        [weakSelf.view hideHud];
        [[[QCNavigationManager shared] topViewController].view showHUDWithHide:error.domain];
    });
}

-(UIImage*) imageName:(NSString*)name {
    return [QCApp.shared loadImage:name moduleID:@"WuKongBase"];
//    return [[QCResource shared] resourceForImage:name podName:@"WuKongBase_images"];
}
@end
