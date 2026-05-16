//
//  QCConversationListVC.m
//  WuKongBase
//
//  Created by tt on 2019/12/15.
//

#import "QCConversationListVC.h"
#import "QCConversationListVM.h"
#import "QCConversationListCell.h"
#import <WuKongBase/WuKongBase.h>
#import "QCResource.h"
#import "QCPopMenuView.h"
#import "QCGlobalSearchController.h"
#import "QCSearchbarView.h"
#import "QCGlobalSearchResultController.h"
#import "QCNetworkListener.h"
#import <WuKongIMSDK/WuKongIMSDK.h>
#import "QCTypingManager.h"
#import "QCTypingContent.h"
#import "QCConversationAddItem.h"
#import "QCConversationPasswordVC.h"
#import "QCConversationListTableView.h"
#import "QCConversationListHeaderView.h"
#import "QCOnlineStatusManager.h"
#import "QCMD5Util.h"
@interface QCConversationListVC ()<UITableViewDelegate,UITableViewDataSource,UISearchControllerDelegate,QCConnectionManagerDelegate,QCChannelManagerDelegate,QCConversationManagerDelegate,QCNetworkListenerDelegate,QCChatManagerDelegate,QCTypingManagerDelegate,SwipeTableViewCellDelegate,QCOnlineStatusManagerDelegate>
@property(nonatomic,copy) NSString *_title;
@property(nonatomic,strong)  QCConversationListTableView *tableView;

@property(nonatomic,strong) QCConversationListVM *conversationListVM;

@property(nonatomic,strong) NSLock *connectLock; // 连接锁

@property(nonatomic,strong) NSRecursiveLock *conversationLock; // 最近会话锁

@property(nonatomic, nonnull,strong) UIView *rightAddItem; // 右边按钮

@property(nonatomic,strong) UIView *networkErroView; // 网络错误视图
@property(nonatomic,strong) UILabel *warnLbl;


//@property(nonatomic,strong) QCSearchbarView *searchbarView;

@property(nonatomic,strong) QCConversationListHeaderView *tableHeader;

//@property(nonatomic,strong) UIView *tableHeaderBottomEmptyView;

@property(nonatomic,strong) NSTimer *refreshTimer; // 定时刷新table的定时器

@end

@implementation QCConversationListVC
-(instancetype) initWithTitle:(NSString*)title {
    self = [super init];
    if(self) {
        self._title = title;
    }
    return self;
}
-(instancetype) init{
    self = [super init];
    if (!self) return self;
    self._title = [QCApp shared].config.appName;
    _conversationListVM = [QCConversationListVM shared];
    [_conversationListVM reset];
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    self.connectLock = [[NSLock alloc] init];
    self.conversationLock = [[NSRecursiveLock alloc] init];
    [self addDelegates];
    
    // 加载最近会话列表数据
    __weak __typeof(self) weakSelf  = self;
    [_conversationListVM loadConversationList:^{
        if([weakSelf.conversationListVM hasConversationTop]) {
            [weakSelf.tableHeader.tableHeaderBottomEmptyView setBackgroundColor:[QCApp shared].config.backgroundColor];
        }else {
            [weakSelf.tableHeader.tableHeaderBottomEmptyView setBackgroundColor:[QCApp shared].config.cellBackgroundColor];
        }
        [weakSelf.tableView reloadData];
        [weakSelf refreshBadge];

    }];
    
//    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(timerRefreshTable) userInfo:nil repeats:YES];
//
    self.tableHeader.pcDeviceFlag = [QCOnlineStatusManager shared].pcDeviceFlag;
    self.tableHeader.showPCOnline = [QCOnlineStatusManager shared].pcOnline;
    
}

-(void) timerRefreshTable {
    [self refreshTableNoSort];
}

// 开启大标题模式
- (BOOL)largeTitle {
    return true;
}

-(void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}


// 设置自定义标题
-(void) setCustomTitle:(NSString*)title {
    self.navigationBar.title = title;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   
    [self refreshTitle];
    [self refreshTableNoSort];
    [self hiddenRightItem:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
   
    if(!self.refreshTimer) {
        self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(timerRefreshTable) userInfo:nil repeats:YES];
    }
}

-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if(self.refreshTimer) {
        [self.refreshTimer invalidate];
        self.refreshTimer = nil;
    }
    
    [self hiddenRightItem:YES];
}


-(void) addDelegates {
    // 添加连接监听
    [[[QCSDK shared] connectionManager] addDelegate:self];
    // 频道信息监听
    [[[QCSDK shared] channelManager] addDelegate:self];
    // 最近会话监听
    [[[QCSDK shared] conversationManager] addDelegate:self];
    // 网络监听
    [[QCNetworkListener shared] addDelegate:self];
    // 消息监听
    [[QCSDK shared].chatManager addDelegate:self];
    // 正在输入...
    [[QCTypingManager shared] addDelegate:self];
    // 在线状态
    [[QCOnlineStatusManager shared] addDelegate:self];
}

-(void) removeDelegates {
    // 移除连接监听
    [[[QCSDK shared] connectionManager] removeDelegate:self];
    // 移除频道监听
    [[[QCSDK shared] channelManager] removeDelegate:self];
    // 移除最近会话监听
    [[[QCSDK shared] conversationManager] removeDelegate:self];
    // 网络监听
    [[QCNetworkListener shared] removeDelegate:self];
    // 移除消息监听
    [[QCSDK shared].chatManager removeDelegate:self];
    // 正在输入...
    [[QCTypingManager shared] removeDelegate:self];
    // 在线状态
    [[QCOnlineStatusManager shared] removeDelegate:self];
}

-(UIView*) rightAddItem {
    if (!_rightAddItem) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(rightAddPressed) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(0.0f , 5.0f, 32.0f, 32.0f);
        UIImage *img = [self imageName:@"ConversationList/Index/Add"];
        img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [button setImage:img forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor clearColor]];
        [button setTintColor:QCApp.shared.config.navBarButtonColor];
        _rightAddItem = [[UIView alloc] initWithFrame:CGRectMake(0.0f , 0.0f, 32.0f, 32.0f)];
        [_rightAddItem addSubview:button];
//        [button setBackgroundColor:[UIColor redColor]];
    }
    return _rightAddItem;
}

-(void) hiddenRightItem:(BOOL)hidden {
    UIView *rightItem = nil;
    if(!hidden) {
        rightItem = self.rightAddItem;
    }
    self.rightView = rightItem;
}

-(void) rightAddPressed {
    
    NSArray<QCConversationAddItem*> *items = [[QCApp shared] invokes:QCPOINT_CATEGORY_CONVERSATION_ADD param:nil];
    
    CGFloat statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    NSMutableArray *itemDicts = [NSMutableArray array];
    if(items && items.count>0) {
        for (QCConversationAddItem *item in items) {
            [itemDicts addObject:@{
                @"title":item.title?:@"",
                @"image": item.icon,
            }];
        }
    }
    [QCPopMenuView showWithItems:itemDicts width:140.0f triangleLocation:CGPointMake(QCScreenWidth-30, self.navigationController.navigationBar.lim_height + statusHeight-4.0f) action:^(NSInteger index) {
        QCConversationAddItem *item = [items objectAtIndex:index];
        if(item.onClick) {
            item.onClick();
        }
    }];
}

-(void) refreshTitle{
    QCConnectStatus status = [QCSDK shared].connectionManager.connectStatus;
    [self.connectLock lock];
    switch (status) {
        case QCConnecting:
            self._title = LLang(@"连接中");
            break;
        case QCPullingOffline:
            self._title = LLang(@"收取中");
            break;
        case QCConnected:
            self._title = [QCApp shared].config.appName;
            break;
        case QCDisconnected:
            self._title = LLang(@"已断开");
            break;
        default:
            break;
    }
//    if(self.tabBarController) {
//        self.tabBarController.title = self._title;
//    }
//    self.title = self._title;
    [self setCustomTitle:self._title];
    [self.connectLock unlock];
}

- (QCConversationListTableView *)tableView{
    if (!_tableView) {
        _tableView = [[QCConversationListTableView alloc] initWithFrame:[self visibleRect] style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
//        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        UIEdgeInsets separatorInset = _tableView.separatorInset;
        separatorInset.right          = 0;
        _tableView.separatorInset = separatorInset;
        _tableView.backgroundColor=[UIColor clearColor];
        _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(-0.1f, 0.0f, 0.0f, 0.0f);
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.sectionHeaderHeight = 0.0f;
        _tableView.sectionFooterHeight = 0.0f;
        
        _tableView.tableHeaderView = self.tableHeader;
        
        [_tableView registerClass:[QCConversationListCell class] forCellReuseIdentifier:@"QCConversationListCell"];
    }
    return _tableView;
}


#define networkErrorViewHeight 50.0f
-(QCConversationListHeaderView*) tableHeader {
    if(!_tableHeader) {
        _tableHeader = [[QCConversationListHeaderView alloc] init];
        _tableHeader.showPCOnline = [QCOnlineStatusManager shared].pcOnline;
        _tableHeader.backgroundColor = [UIColor clearColor];
//        _tableHeader.showEmpty = true;
//        [_tableHeader addSubview:self.searchbarView];

//        _tableHeader.lim_height = self.searchbarView.frame.size.height+20.0f;
        
//        self.tableHeaderBottomEmptyView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.searchbarView.lim_bottom+10.0f, QCScreenWidth, 10.0f)];
//        [self.tableHeaderBottomEmptyView setBackgroundColor:[UIColor whiteColor]];
//        [_tableHeader addSubview:self.tableHeaderBottomEmptyView];
    }
    return _tableHeader;
}

-(void) showNetworkError:(BOOL) show {
    self.tableHeader.showNetworkError = show;
    [self.tableView reloadData];
     
}

- (void)viewConfigChange:(QCViewConfigChangeType)type {
    [super viewConfigChange:type];
    [self.navigationBar setBackgroundColor:[QCApp shared].config.navBackgroudColor];
    if([QCApp shared].config.style == QCSystemStyleDark) {
        self.navigationBar.style = QCNavigationBarStyleDark;
    }else {
        self.navigationBar.style = QCNavigationBarStyleDefault;
    }
    [self.tableHeader viewConfigChange:type];
    [self refreshTable];
}

- (UIView *)networkErroView {
    if(!_networkErroView) {
        _networkErroView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, QCScreenWidth, networkErrorViewHeight)];
        UIImageView *warnIcon = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f, 0.0f, 26.0f, 26.0f)];
        [warnIcon setImage:[self imageName:@"ConversationList/Index/NetworkStatusFail"]];
        warnIcon.lim_top = _networkErroView.lim_height/2.0f - warnIcon.lim_height/2.0f;
        [_networkErroView addSubview:warnIcon];
        
         _warnLbl = [[UILabel alloc] init];
        [_warnLbl setText:LLang(@"当前网络不可用，请检查网络设置")];
        [_warnLbl setFont:[[QCApp shared].config appFontOfSize:16.0f]];
        [_warnLbl sizeToFit];
        _warnLbl.lim_top = _networkErroView.lim_height/2.0f - _warnLbl.lim_height/2.0f;
        _warnLbl.lim_left = warnIcon.lim_right + 20.0f;
        [_networkErroView addSubview:_warnLbl];
    }
    return _networkErroView;
}

#pragma mark -- QCOnlineStatusManagerDelegate

// 我的pc状态改变
- (void)onlineStatusManagerMyPCOnlineChange:(QCOnlineStatusManager *)manager status:(QCPCOnlineResp *)status {
    
    self.tableHeader.pcDeviceFlag = status.deviceFlag;
    self.tableHeader.showPCOnline = status.online;
    
    [self.tableView reloadData];
    
}

#pragma mark - QCTypingManagerDelegate

- (void)typingAdd:(QCTypingManager *)manager message:(QCMessage *)message {
    if(message.fromUid && [message.fromUid isEqualToString:[QCApp shared].loginInfo.uid]) {
        return;
    }
    QCChannel *channel = message.channel;
    NSInteger index =  [self.conversationListVM indexAtChannel:channel];
    if(index!=-1) {
        QCConversationWrapModel *model = [self.conversationListVM modelAtIndex:index];
        if(model) {
            QCTypingContent *content = (QCTypingContent*)message.content;
            model.typing = YES;
            model.typer = content.typingName;
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    
}

- (void)typingRemove:(QCTypingManager *)manager message:(QCMessage *)message newMessage:(QCMessage *)newMessage{
    if(message.fromUid && [message.fromUid isEqualToString:[QCApp shared].loginInfo.uid]) {
        return;
    }
    QCChannel *channel = message.channel;
    NSInteger index =  [self.conversationListVM indexAtChannel:channel];
    if(index!=-1) {
        QCConversationWrapModel *model = [self.conversationListVM modelAtIndex:index];
        model.typing = NO;
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        
//        [self refreshTable];
    }
}

-(void) typingReplace:(QCTypingManager*)manager newmessage:(QCMessage*)newmessage oldmessage:(QCMessage*)oldmessage {
    [self typingAdd:manager message:newmessage];
}


#pragma mark - QCChatManagerDelegate

-(void) onMessageUpdate:(QCMessage*) message left:(NSInteger)left{
   
    NSInteger index = [self.conversationListVM indexAtChannel:message.channel];
    if(index!=-1) {
        QCConversationWrapModel *conversation = [self.conversationListVM modelAtIndex:index];
        if([conversation.lastClientMsgNo isEqualToString:message.clientMsgNo]) {
            [conversation setLastMessage:message];
        }
//
        QCConversationListCell *cell =  [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        [cell refreshWithModel:conversation];
    }
    
    if(left == 0 ) {
        [self refreshTable];
    }
}

#pragma mark - QCConnectionManagerDelegate

/**
 连接状态改变
 */
-(void) onConnectStatus:(QCConnectStatus)status reasonCode:(QCReason)reasonCode {
    [self refreshTitle];
}

#pragma mark - QCConversationManagerDelegate

// 更新最近会话
- (void)onConversationUpdate:(NSArray<QCConversation*>*)conversations{
    if(!conversations || conversations.count<=0) {
        return;
    }
//    for (QCConversation *conversation in conversations) {
//        if([QCApp shared].currentChatChannel && [conversation.channel isEqual:[QCApp shared].currentChatChannel]) {
//            conversation.unreadCount = 0;
//            break;
//        }
//    }
    if(conversations.count>1) { // 同时更新的会话大于1 则直接reloadData,等于1 则可以走insertRowsAtIndexPaths或moveRowAtIndexPath这样有动画效果 用户体验好
        for (QCConversation *conversation in conversations) {
            [self onlyAddOrUpdateConversation:conversation];
        }
        [self refreshTable];
        [self refreshBadge];
        return;
    }
   
   QCConversation *conversation = conversations[0];
    [self uiAddOrUpdateConversationForOne:conversation];
    [self refreshBadge];
    
}
// 单个会话添加或更新(大量会话不要使用此方法，容易卡顿)
-(void) uiAddOrUpdateConversationForOne:(QCConversation*)conversation {
    QCConversationWrapModel *newModel = [self.conversationListVM getRealShowConversationWrap:[[QCConversationWrapModel alloc] initWithConversation:conversation]];
    
    NSInteger oldIndex =[self.conversationListVM indexAtChannel:newModel.channel];
    if(oldIndex!=-1) {
        
        NSInteger insertPlace =  [self.conversationListVM findInsertPlace:newModel];
        if(oldIndex==insertPlace) {
            [self.conversationListVM replaceAtChannel:newModel atChannel:newModel.channel];
            QCConversationListCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:oldIndex inSection:0]];
            if(cell) {
                [cell refreshWithModel:newModel];
            }
            return;
        }
        
        if(oldIndex>self.conversationListVM.conversationCount || insertPlace>self.conversationListVM.conversationCount) {
            return;
        }
       
        [self.conversationListVM removeAtIndex:oldIndex];
        [self.conversationListVM insert:newModel atIndex:insertPlace];
        @try {
            [self.tableView beginUpdates];
            [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:oldIndex inSection:0] toIndexPath:[NSIndexPath indexPathForRow:insertPlace inSection:0]];
            [self.tableView endUpdates];
        } @catch (NSException *exception) { // moveRowAtIndexPath 有时会引起异常。原因还没找到
            QCLogError(@"moveRowAtIndexPath is error -> %@",exception);
            [self.tableView reloadData];
        }
       
        QCConversationListCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:insertPlace inSection:0]];
        if(cell) {
            [cell refreshWithModel:newModel];
        }
        
        
    }else {
        [self uiAddConversation:conversation];
    }
}


-(void) uiAddConversation:(QCConversation*)conversation {
    QCConversationWrapModel *model = [[QCConversationWrapModel alloc] initWithConversation:conversation];
    NSInteger insertPlace = [self.conversationListVM insert:model];
    [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:insertPlace inSection:0] ] withRowAnimation:UITableViewRowAnimationFade];
}
// 删除最近会话
- (void)onConversationDelete:(QCChannel *)channel {
    [self.conversationListVM removeAtChannnel:channel];
    [self refreshTable];
    [self refreshBadge];
}

-(void) onlyAddOrUpdateConversation:(QCConversation*)conversation {
    QCConversationWrapModel *model =  [self.conversationListVM modelAtChannel:conversation.channel];
    if(model) {
        [model setConversation:conversation];
    }else {
        [self.conversationListVM insert:[[QCConversationWrapModel alloc] initWithConversation:conversation] atIndex:0];
    }
}
// 更新最近会话未读数
- (void)onConversationUnreadCountUpdate:(QCChannel*)channel unreadCount:(NSInteger)unreadCount {
    
    NSInteger index = [self.conversationListVM indexAtChannel:channel];
    if(index!=-1) {
        QCConversationListCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        if(cell) {
           QCConversationWrapModel *model = [self.conversationListVM modelAtIndex:index];
            model.unreadCount = unreadCount;
            [cell refreshWithModel:model];
            [cell layoutSubviews];
            [self refreshBadge];
        }
       
    }
}
// 删除所有最近会话
- (void)onConversationAllDelete {
    [self.conversationListVM removeAll];
    [self refreshTable];
    [self refreshBadge];
}


-(void) refreshBadge {
    NSInteger unreadCount = [self.conversationListVM getAllUnreadCount];
    if(unreadCount>0) {
        self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",(long)unreadCount];
    }else {
        self.tabBarItem.badgeValue = nil;
    }
    
}

#pragma mark - QCNetworkListenerDelegate

- (void)networkListenerStatusChange:(QCNetworkListener *)listener {
     [self showNetworkError:!listener.hasNetwork];
}

#pragma mark - QCChannelManagerDelegate

-(void) channelInfoUpdate:(QCChannelInfo *)channelInfo oldChannelInfo:(QCChannelInfo *)oldChannelInfo{
   //[self refreshTable];
    NSInteger index = [self.conversationListVM indexAtChannel:channelInfo.channel];
    if(index!= -1) {
        QCConversationWrapModel *oldModel = [self.conversationListVM modelAtIndex:index];
        QCConversation *conversation = [[oldModel getConversation] copy];
        conversation.mute = channelInfo.mute;
        conversation.stick = channelInfo.stick;
        if([self hasChange:channelInfo oldChannelInfo:oldChannelInfo]) {
            [self uiAddOrUpdateConversationForOne:conversation];
        }else{
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            
//            QCConversationListCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
//            if(cell) {
//                QCConversationWrapModel *model = [self.conversationListVM modelAtIndex:index];
//                [cell refreshWithModel:model];
//            }
        }
        [self resetHeaderBottomEmptyBackgroundColor];
    }
}

-(BOOL) hasChange:(QCChannelInfo*)channelInfo oldChannelInfo:(QCChannelInfo*)oldChannelInfo {
    if(oldChannelInfo==nil) {
        return false;
    }
    if(channelInfo.stick != oldChannelInfo.stick) {
        return true;
    }
    if(channelInfo.mute != oldChannelInfo.mute) {
        return true;
    }
    if(![channelInfo.displayName isEqualToString:oldChannelInfo.displayName]) {
        return true;
    }
    return false;
}

#pragma mark-  UITableViewDataSource && UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 88.0f;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [_conversationListVM conversationCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    QCConversationListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QCConversationListCell" forIndexPath:indexPath];
    cell.swipeDelegate = self;
    
//    [cell setDisplaySeparator:YES];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    QCConversationListCell *conversationListCell = (QCConversationListCell*)cell;
    QCConversationWrapModel *conversationModel = [_conversationListVM conversationAtIndex:indexPath.row];
    if(conversationModel) {
        [conversationListCell refreshWithModel:conversationModel];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    QCConversationWrapModel *conversationModel = [_conversationListVM conversationAtIndex:indexPath.row];
    if(conversationModel) {
        [conversationModel cancelChannelRequest];
    }
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
     QCConversationWrapModel *conversationModel = [_conversationListVM conversationAtIndex:indexPath.row];
    // 防止重复点击
    QCChannel *channel = conversationModel.channel;
    static bool canSelect = true;
    if (canSelect){
        canSelect = false;
        dispatch_async(dispatch_get_main_queue(), ^{
            canSelect = true;
            
            NSString *chatPwd = [QCApp shared].loginInfo.extra[@"chat_pwd"];
            if(conversationModel.channelInfo && chatPwd && ![chatPwd isEqualToString:@""]) {
                __weak typeof(self) weakSelf = self;
                BOOL chatPwdOn = [conversationModel.channelInfo settingForKey:QCChannelExtraKeyChatPwd defaultValue:false];
                if(chatPwdOn) {
                    __block NSInteger errorCount = [self getChatPwdErrorCount:channel];
                    QCPwdKeyboardInputView *vw = [QCPwdKeyboardInputView new];
                    vw.remark = LLang(@"聊天密码");
                    [vw setFinishBlock:^(NSString * _Nonnull pwd) {
                        if([[self digestPwd:pwd] isEqualToString:chatPwd]) {
                            [weakSelf toConversation:conversationModel];
                            [weakSelf setChatPwdErrorCount:0 channel:channel];
                        }else {
                            errorCount++;
                            [weakSelf setChatPwdErrorCount:errorCount channel:channel];
                            if(errorCount >=3) {
                                [QCAlertUtil alert:LLang(@"连续错误次数太多，已删除该聊天记录！") title:LLangW(@"错误密码",weakSelf)];
                            }else{
                                [QCAlertUtil alert:[NSString stringWithFormat:LLang(@"还连续%ld次输入错误，将会清空该聊天记录！\n如果您忘记聊天密码，您可以重置聊天密码"),3- (long)errorCount] title:LLangW(@"错误密码",weakSelf)];
                            }
                           
                            if(errorCount>=3) {
                                [[QCMessageManager shared] clearMessages:conversationModel.channel];
                                [weakSelf setChatPwdErrorCount:0 channel:channel];
                            }
                        }
                        
                    }];
                    [vw setOtherButtonClickBlock:^(UIButton *btn) {
                        QCConversationPasswordVC *vc = [QCConversationPasswordVC new];
                        [[QCNavigationManager shared] pushViewController:vc animated:YES];
                    }];
                    [vw show];
                    return;
                }
            };
            [self toConversation:conversationModel];
        });
    }
    else
        return;
}

-(NSString*) digestPwd:(NSString*)pwd {
    return [QCMD5Util md5HexDigest:[NSString stringWithFormat:@"%@%@",pwd,[QCApp shared].loginInfo.uid]];
}

#pragma  mark -- SwipeTableViewCellDelegate

- (SwipeTableCellStyle)tableView:(UITableView *)tableView styleOfSwipeButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return SwipeTableCellStyleRightToLeft;
}

/**
 *  右滑cell时显示的button
 *
 *  @param indexPath cell的位置
 */
- (NSArray<SwipeButton *> *)tableView:(UITableView *)tableView rightSwipeButtonsAtIndexPath:(NSIndexPath *)indexPath {

    QCConversationWrapModel *conversationModel = [self.conversationListVM conversationAtIndex:indexPath.row];
    
    // ---------- 免打扰 ----------
    NSString *muteTitle;
    NSString *muteAnimationNamed;
    if(conversationModel.mute) {
        muteTitle = LLang(@"打开通知");
        muteAnimationNamed = @"Other/list_icon_sound_on";
    }else {
        muteTitle = LLang(@"关闭通知");
        muteAnimationNamed = @"Other/list_icon_sound_off";
    }
    
    SwipeButton *muteBtn = [self swipeButton:muteTitle backgroundColor:[UIColor colorWithRed:252.0f/255.0f green:174.0f/255.0f blue:66.0f/255.0f alpha:1.0f] animationNamed:muteAnimationNamed touchBlock:^{
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[QCChannelSettingManager shared] channel:conversationModel.channel mute:!conversationModel.mute];
        });
    }];
    
    // ---------- 置顶 ----------
    NSString *stickTitle;
    NSString *stickAnimationNamed;
    if(conversationModel.stick) {
        stickTitle = LLang(@"取消置顶");
        stickAnimationNamed = @"Other/list_icon_toppin";
    }else {
        stickTitle = LLang(@"置顶");
        stickAnimationNamed = @"Other/list_icon_toppin";
    }
    
    SwipeButton *stickBtn = [self swipeButton:stickTitle backgroundColor:[UIColor colorWithRed:37.0f/255.0f green:167.0f/255.0f blue:90.0f/255.0f alpha:1.0f] animationNamed:stickAnimationNamed touchBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[QCChannelSettingManager shared] channel:conversationModel.channel stick:!conversationModel.stick];
        });
    }];
    
    // ---------- 删除 ----------
    
    __weak typeof(self) weakSelf =  self;
    SwipeButton *deleteBtn = [self swipeButton:LLang(@"删除") backgroundColor:[UIColor redColor] animationNamed:@"Other/list_icon_delete" touchBlock:^{
        QCActionSheetView2 *sheet = [QCActionSheetView2 initWithTip:nil];
        [sheet addItem:[QCActionSheetButtonItem2 initWithTitle:LLang(@"清空聊天记录") onClick:^{
            QCConversationWrapModel *conversationModel = [weakSelf.conversationListVM conversationAtIndex:indexPath.row];
            [[QCMessageManager shared] clearMessages:conversationModel.channel];
        }]];
        [sheet addItem:[QCActionSheetButtonItem2 initWithTitle:LLang(@"确认删除") onClick:^{
            QCConversationWrapModel *conversationModel = [weakSelf.conversationListVM conversationAtIndex:indexPath.row];
            [weakSelf.conversationListVM removeConversationAtIndex:indexPath.row];
            [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            if(conversationModel) {
                [[QCSDK shared].conversationManager deleteConversation:conversationModel.channel];
            }
        }]];
        [sheet show];
    }];
    
    
    
    return @[deleteBtn,stickBtn,muteBtn];
}

- (NSArray<SwipeButton *> *)tableView:(UITableView *)tableView leftSwipeButtonsAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

-(SwipeButton*) swipeButton:(NSString*)title backgroundColor:(UIColor*)backgroundColor animationNamed:(NSString*)animationNamed touchBlock:(void(^)(void))touchBlock {
    SwipeButton *spBtn = [SwipeButton createSwipeButtonWithTitle:title font:14.0f textColor:[UIColor whiteColor] backgroundColor:backgroundColor image:[self imageName:@"ConversationList/Index/PlaceHo"] touchBlock:touchBlock];
    
    LOTAnimationView *spAnimationView = [LOTAnimationView animationNamed:animationNamed inBundle:[QCApp.shared resourceBundle:@"WuKongBase"]];
    spAnimationView.loopAnimation = NO;
    spAnimationView.contentMode = UIViewContentModeScaleAspectFit;
    [spBtn.imageView addSubview:spAnimationView];
    [spAnimationView play];
    
    return spBtn;
}


-(void) setChatPwdErrorCount:(NSInteger)count channel:(QCChannel*)channel{
    [[NSUserDefaults standardUserDefaults] setInteger:count forKey:[self chatPwdErrorKey:channel]];
}

-(NSInteger) getChatPwdErrorCount:(QCChannel*)channel {
    return [[NSUserDefaults standardUserDefaults] integerForKey:[self chatPwdErrorKey:channel]];
}
-(NSString*) chatPwdErrorKey:(QCChannel*)channel {
    return [NSString stringWithFormat:@"chatpwderror_%@_%@_%hhu",[QCApp shared].loginInfo.uid,channel.channelId,channel.channelType];
}

-(void) toConversation:(QCConversationWrapModel*)conversationModel {
    // 显示聊天UI
    [QCApp.shared pushConversation:conversationModel.channel];
}


//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"commitEditingStyle--");
//    [self.conversationListVM removeConversationAtIndex:indexPath.row];
//    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
//}
//- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return @"删除";
//}
//
//- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
//    __weak typeof(self) weakSelf = self;
//    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:LLang(@"删除") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//        QCActionSheetView2 *sheet = [QCActionSheetView2 initWithTip:nil];
//        [sheet addItem:[QCActionSheetButtonItem2 initWithTitle:LLang(@"清空聊天记录") onClick:^{
//            QCConversationWrapModel *conversationModel = [self.conversationListVM conversationAtIndex:indexPath.row];
//            [[QCMessageManager shared] clearMessages:conversationModel.channel];
//        }]];
//        [sheet addItem:[QCActionSheetButtonItem2 initWithTitle:LLang(@"确认删除") onClick:^{
//            QCConversationWrapModel *conversationModel = [self.conversationListVM conversationAtIndex:indexPath.row];
//            [weakSelf.conversationListVM removeConversationAtIndex:indexPath.row];
//            [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//            if(conversationModel) {
//                [[QCSDK shared].conversationManager deleteConversation:conversationModel.channel];
//            }
//        }]];
//        [sheet show];
//    }];
//    QCConversationWrapModel *conversationModel = [self.conversationListVM conversationAtIndex:indexPath.row];
//    UITableViewRowAction *action1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title: conversationModel.unreadCount>0?LLang(@"标为已读"):LLang(@"标为未读") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//            // 退出编辑模式
////        [self.tableView setEditing:NO animated:YES];
//        int unreadCount = conversationModel.unreadCount>0?0:1;
//        conversationModel.unreadCount = unreadCount;
//        [[QCConversationDB shared] setConversationUnreadCount:conversationModel.channel unread:unreadCount];
//        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationRight];
//
//    }];
//
//    return @[action,action1];
//}

-(void) refreshTableNoSort {
    [self refreshHeader];
    [self.tableView reloadData];
}

-(void) refreshTable {
    [self.conversationListVM sortConversationList];
    [self refreshHeader];
    [self.tableView reloadData];
}

-(void) refreshHeader {
    [self resetHeaderBottomEmptyBackgroundColor];
    [self.tableHeader layoutSubviews];
}

-(void) resetHeaderBottomEmptyBackgroundColor {
    if([self.conversationListVM hasConversationTop]) {
        [self.tableHeader.tableHeaderBottomEmptyView setBackgroundColor:[QCApp shared].config.backgroundColor];
    }else{
        [self.tableHeader.tableHeaderBottomEmptyView setBackgroundColor:[QCApp shared].config.cellBackgroundColor];
    }
}

-(UIImage*) imageName:(NSString*)name {
    return [QCApp.shared loadImage:name moduleID:@"WuKongBase"];
}
-(void) dealloc {
    NSLog(@"QCConversationListVC dealloc ....");
    [self removeDelegates];
}

@end
