//
//  QCConversationView.m
//  QCCore
//
//  Created by tt on 2022/5/18.
//

#import "QCConversationView.h"
#import "QCCore.h"
#import "QCMessageListDataProviderImp.h"
#import "QCConversationListVM.h"
#import "QCConversationInputPanel.h"
#import "QCMessageListView+Position.h"
#import "QCLastImgView.h"
#import "QCConversationContextImpl.h"
#import "QCStickerManager.h"
#import "QCStickerGIFContentView.h"
#import "QCEmojiContentView.h"
#import "QCUserHandleVC.h"
#import "QCMultiplePanel.h"
#import "QCConversationListSelectVC.h"
#import "QCMergeForwardContent.h"
#import "QCScreenshotContent.h"
#import "QCConversationView+Robot.h"


@interface QCConversationView ()<QCConversationInputPanelDelegate,QCMultiplePanelDelegate>

@property(nonatomic,strong) QCConversation *currentConversation; // 当前最近会话
@property(nonatomic,strong) QCMessageListDataProviderImp *dataProvider;



@property(nonatomic,assign) NSTimeInterval lastTypingTime; // 最后一次typing时间


// ---------- 多选 ----------
@property(nonatomic,assign) BOOL multipleOn; // 是否开启多选
@property(nonatomic,strong) QCMultiplePanel *multiplePanel; // 多选面板

// ---------- 禁言 ----------
@property(nonatomic,strong) UIView *forbiddenView;
@property(nonatomic,strong) UILabel *forbiddenTitleLbl;
@property(nonatomic,strong) NSTimer *forbiddenTimer; // 禁言倒计时


@end

@implementation QCConversationView

- (instancetype)initWithFrame:(CGRect)frame channel:(QCChannel*)channel
{
    self = [super initWithFrame:frame];
    if (self) {
        self.channel = channel;
        
    }
    return self;
}

- (QCConversationVM *)conversationVM {
    if(!_conversationVM) {
        _conversationVM = [[QCConversationVM alloc] init];
        _conversationVM.channel = self.channel;
    }
    return _conversationVM;
}
-(void) viewDidLoad {
    [self setupUI];
    
    [self initRobot];

    [self initMessageListParam];

    [self.messageListView viewDidLoad];
    
    [self recoveryDraft]; // 恢复草稿如果有的话
    
    [self enableWrapLineMenus]; // 启用换行菜单
    
    [self addSubview:self.forbiddenView];
}

- (void)viewDidAppear {
    [self.input addKeyboardListen];
    
}


- (UIView *)inputParentView {
    if(!_inputParentView) {
        return self;
    }
    return _inputParentView;
}

-(void) menuDidHideMenu:(NSNotification *)notification {
    [self enableWrapLineMenus];
}
-(void) wrapLineMenu:(id)sender {
    [self.input inputInsertText:@"\n"];
}
// 启用换行菜单
-(void) enableWrapLineMenus{
    UIMenuItem *menuItem = [[UIMenuItem alloc]initWithTitle:LLang(@"换行") action:@selector(wrapLineMenu:)];
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    [menuController setMenuItems:[NSArray arrayWithObject:menuItem]];
    [menuController setMenuVisible:NO];
}


-(void) setupUI {
    
    [self addDelegates];
    
    [self addSubview:self.messageListView];
    // input需要在tableview后添加
    [self.inputParentView addSubview:self.input];
    
    // 安装表情贴图
    [[QCStickerManager shared] setupIfNeed];
    
    [self addSubview:self.topView];
    
}



-(void) viewWillAppear {
    if(self.keepKeyboard) {
        [self.input becomeFirstResponder]; // 弹出键盘
        self.keepKeyboard = false;
    }
    // 截屏通知（已禁用：不再监听和发送「在聊天中截屏了」通知）
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidTakeScreenshot) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
    if(self.inputParentView != self) {
        [self.inputParentView addSubview:self.input];
    }
    
}
- (void)viewWillDisappear:(BOOL)animated {
    
    [self.input removeKeyboardListen];
    
    // 是否保持键盘弹起
    if(self.input.keyboardHeight>0) {
        self.keepKeyboard = true;
        [self.input endEditing:YES]; // 隐藏键盘
        
    }
    
    [self.messageListView viewWillDisappear];
    
    [self saveDraftOrKeepPosition];
    
    [self requestSetUnreadIfNeed];
    if(self.inputParentView != self) {
        [self.input removeFromSuperview];
    }
    
}
-(void) viewDidDisappear {
    // 截屏通知
    if(QCApp.shared.config.takeScreenshotOn) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationUserDidTakeScreenshotNotification object:nil];
    }
   
   
}

-(void) requestMembers {
    [self.conversationVM requestMembers];
}


- (void)dealloc {
    QCLogDebug(@"%s",__func__);
    [self destoryForbiddenTimer];
    [self removeDelegates];
}


-(void) showTopView:(BOOL)show animated:(BOOL)animated{
    if(!self.topView.hidden && show) {
        return;
    }
    if(self.topView.hidden && !show) {
        return;
    }
   
    if(show) {
        self.topView.alpha = 0.0f;
    }else {
        self.topView.alpha = 1.0f;
    }
    self.topView.hidden = NO;
    
    if(animated) {
        [UIView animateWithDuration:0.2f animations:^{
            if(show) {
                self.topView.lim_top = 0.0f;
                self.topView.alpha = 1.0f;
            }else {
                self.topView.lim_top = -self.topView.lim_height;
                self.topView.alpha = 0.0f;
            }
           
            [self layoutSubviews];
        } completion:^(BOOL finished) {
            self.topView.hidden = !show;
            [self.topView layoutSubviews];
        }];
    }else {
        if(show) {
            self.topView.lim_top = 0.0f;
            self.topView.alpha = 1.0f;
        }else {
            self.topView.lim_top = -self.topView.lim_height;
            self.topView.alpha = 0.0f;
        }
        self.topView.hidden = !show;
        [self layoutSubviews];
    }
    
}

-(void) addDelegates {
    // 长按菜单隐藏(长按菜单恢复到原来状态)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidHideMenu:) name:UIMenuControllerDidHideMenuNotification object:nil];
    // 远程配置更新（管理后台禁言开关变化）→ 立即刷新输入框禁言面板
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppRemoteConfigUpdate) name:QCNOTIFY_APP_REMOTE_CONFIG_UPDATE object:nil];
}

-(void) removeDelegates {
    // 移除长按菜单隐藏监听
    if(QCApp.shared.config.takeScreenshotOn) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QCNOTIFY_APP_REMOTE_CONFIG_UPDATE object:nil];
}

-(void) handleAppRemoteConfigUpdate {
    NSLog(@"[禁言追踪][QCConversationView] handleAppRemoteConfigUpdate channel=%@", self.channel.channelId);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setGroupForbiddenIfNeed];
    });
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.forbiddenView.lim_top = self.inputParentView.lim_height;
    self.multiplePanel.lim_top = self.inputParentView.lim_height;
    
    UIView *otherPanel;
    if(!self.forbiddenView.hidden) {
        [self bringSubviewToFront:self.forbiddenView];
        otherPanel  = self.forbiddenView;
    }else if(self.multiplePanel.superview){
        otherPanel = self.multiplePanel;
    }
    if(otherPanel) {
        self.input.lim_top = self.inputParentView.lim_height;
        otherPanel.lim_top = self.inputParentView.lim_height - otherPanel.lim_height;
        if(self.topView.hidden) {
            [self.messageListView adjustTableWithOffset:otherPanel.lim_height];
        }else {
            [self.messageListView adjustTableWithOffset:otherPanel.lim_height + self.topView.lim_height];
        }
        
    }else {
        if(self.input.hidden) {
            self.input.lim_top = self.inputParentView.lim_height;
        }else {
            self.input.lim_top = self.inputParentView.lim_height - self.input.lim_height;
        }
        if(self.tableOffsetY>0) {
            if(self.topView.hidden) {
                [self.messageListView adjustTableWithOffset:self.tableOffsetY];
            }else {
                [self.messageListView adjustTableWithOffset:self.tableOffsetY + self.topView.lim_height];
            }
            
        }else {
            if(self.topView.hidden) {
                [self.messageListView adjustTableWithOffset:self.input.lim_height];
            }else {
                [self.messageListView adjustTableWithOffset:self.input.lim_height+self.topView.lim_height];
            }
           
        }
        
    }
    
    if(!self.topView.hidden) {
        self.messageListView.lim_top = self.topView.lim_height;
        self.messageListView.lim_height = self.lim_height - self.topView.lim_height;
    } else {
        self.messageListView.lim_top = 0.0f;
        self.messageListView.lim_height = self.lim_height;
    }
//   
    [self.messageListView layoutConversationPositionBarView];
    
    [self adjustRobotMenusIfNeed];
        
}


// 用户截屏
-(void) userDidTakeScreenshot {
    // 已禁用「在聊天中截屏了」通知，不再向服务器发送截屏消息
//    [self.conversationContext sendMessage:QCScreenshotContent.new];
}

-(void) requestSetUnreadIfNeed {
    QCConversation *conversation = [[QCSDK shared].conversationManager getConversation:self.channel];
    if(!conversation) {
        return;
    }
    uint32_t messageSeq = 0;
    if(self.messageListView.lastMessage) {
        messageSeq = self.messageListView.lastMessage.messageSeq;
    }
    if(self.messageListView.browseToOrderSeq == 0 && self.messageListView.newMsgCount>0) { // lastMessageSeq为0 要么就是自己发送中的消息，要么就是本地插入的消息，此时
        [[QCMessageManager shared] conversationSetUnread:self.channel unread:0 messageSeq:messageSeq complete:nil];
    }else if(conversation.unreadCount != self.messageListView.newMsgCount) {
        [[QCMessageManager shared] conversationSetUnread:self.channel unread:self.messageListView.newMsgCount messageSeq:messageSeq complete:nil];
    }else if(self.messageListView.hasRecvMsg) {
        [[QCMessageManager shared] conversationSetUnread:self.channel unread:self.messageListView.newMsgCount messageSeq:messageSeq complete:nil];
    }
}

// 保存草稿或保持位置
-(void) saveDraftOrKeepPosition {
    QCConversation *conversation = self.currentConversation;
    if(conversation) {
        QCConversationExtra *extra = conversation.remoteExtra;
        NSString *text = [self.input inputText];
        if(![text isEqualToString:@""]) {
            extra.draft = text;
        }else {
            extra.draft = @"";
        }
        if(self.messageListView.keepPosition) {
            QCConversationPosition *position = self.messageListView.keepPosition;
            extra.keepMessageSeq = [[QCSDK shared].chatManager getMessageSeq:position.orderSeq];
            extra.keepOffsetY = position.offset;
        }else {
            extra.keepMessageSeq = 0;
            extra.keepOffsetY = 0;
        }
        conversation.remoteExtra = extra;
        [[QCSDK shared].conversationManager updateOrAddExtra:extra];
    }
    
}

-(void) calcKeepPositionAndBrowseToOrderSeq {
    
    if(!self.currentConversation) {
        return;
    }
    
    NSInteger keepOffSetY = 0;
    uint32_t keepOrderSeq = 0;
    NSInteger newMsgCount = self.currentConversation.unreadCount;
    QCMessage *conversationLastMessage = self.currentConversation.lastMessage;
    if(newMsgCount>0) { // 有新消息，则定位到新消息第一条
        uint32_t lastMessageSeq = [[QCSDK shared].chatManager getOrNearbyMessageSeq:conversationLastMessage.orderSeq];
        if(lastMessageSeq>newMsgCount) {
            self.messageListView.browseToOrderSeq= [[QCSDK shared].chatManager getOrderSeq:lastMessageSeq - (uint32_t)newMsgCount];
            keepOrderSeq = self.messageListView.browseToOrderSeq;
            keepOffSetY = -120.0f;
        }
        
    }
    BOOL useKeep = false; // 是否使用保持的位置
    if(self.currentConversation.remoteExtra.keepMessageSeq>0) { // 有保持位置
        uint32_t kpOrderSeq = [[QCSDK shared].chatManager getOrderSeq:self.currentConversation.remoteExtra.keepMessageSeq];
        if(keepOrderSeq == 0 || kpOrderSeq < keepOrderSeq) {
            keepOrderSeq = kpOrderSeq;
            keepOffSetY = self.currentConversation.remoteExtra.keepOffsetY;
            useKeep = true;
        }
    }
    if(!useKeep && newMsgCount == 1) { // 如果只有一条新消息则使用预览orderSeq设置为最新的
        self.messageListView.browseToOrderSeq = self.currentConversation.lastMessage.orderSeq;
    }
    if(self.messageListView.browseToOrderSeq == 0) {
        self.messageListView.browseToOrderSeq = self.currentConversation.lastMessage.orderSeq;
    }
    if(keepOrderSeq>0) {
        self.messageListView.keepPosition =  [QCConversationPosition orderSeq:keepOrderSeq offset:(int)keepOffSetY];
    }
    
    if(self.locationAtOrderSeq!=0) { // 传过来的定位orderSeq最优先
        CGFloat offset = -self.input.lim_height - 40.0f;
        self.messageListView.needPositionReminder = true;
        self.messageListView.keepPosition = [QCConversationPosition orderSeq:self.locationAtOrderSeq offset:offset];
    }
}

-(void) initMessageListParam {
    self.messageListView.channel = self.channel;
    self.messageListView.dataProvider = self.messageListDataProviderImp;
    if(self.currentConversation) {
        self.messageListView.newMsgCount = self.currentConversation.unreadCount;
        self.messageListView.reminders = self.currentConversation.reminders;
        if(self.currentConversation.lastMessage) {
            if(self.currentConversation.lastMessage.isDeleted) {
                QCMessage *lastMsg = [[QCSDK shared].chatManager getLastMessage:self.channel];
                if(lastMsg) {
                    self.messageListView.lastMessage =  [[QCMessageModel alloc] initWithMessage:lastMsg];
                }
            }else {
                self.messageListView.lastMessage = [[QCMessageModel alloc] initWithMessage:self.currentConversation.lastMessage];
            }
            
        }
    }
    [self calcKeepPositionAndBrowseToOrderSeq]; // 计算保持位置
}

- (void)scrollToBottomOnMain:(BOOL)animation{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.messageListView scrollToBottom:animation];
        
    });
}


- (QCConversationContextImpl*)conversationContext {
    if(!_conversationContext) {
        _conversationContext = [[QCConversationContextImpl alloc] initWithChannel:self.channel conersationView:self conversationVM:self.conversationVM];
    }
    return _conversationContext;
}


-(QCMessageListDataProviderImp*) messageListDataProviderImp {
    if(!_dataProvider) {
        QCMessageListDataProviderImp *dataProvider = [[QCMessageListDataProviderImp alloc] initWithChannel:self.channel conversationContext:self.conversationContext];
        _dataProvider = dataProvider;
    }
    return _dataProvider;
}
- (QCConversation *)currentConversation {
    if(!_currentConversation) {
        _currentConversation = [[QCSDK shared].conversationManager getConversation:self.channel];
    }
    return _currentConversation;
}


- (QCConversationTopView *)topView {
    if(!_topView) {
        _topView = [[QCConversationTopView alloc] initWithFrame:CGRectMake(0.0, 0.0f, self.lim_width, 80.0f)];
        _topView.backgroundColor =[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.4f];
    }
    return _topView;
}

- (QCMessageListView *)messageListView {
    if(!_messageListView) {
        __weak typeof(self) weakSelf = self;
        _messageListView = [[QCMessageListView alloc] initWithFrame:CGRectMake(0.0f,0.0f,self.lim_width, self.lim_height)];
        _messageListView.onContentViewClick = ^{
            [weakSelf.conversationContext endEditing];
        };
    }
    return _messageListView;
}


// 恢复草稿
-(void) recoveryDraft {
    if(!self.currentConversation) {
        return;
    }
    if([self hasDraft]) {
        [self.conversationContext inputSetText:self.currentConversation.remoteExtra.draft];
        self.keepKeyboard = true;
    }
}
-(BOOL) hasDraft {
    if(!self.currentConversation) {
        return false;
    }
    if(self.currentConversation.remoteExtra.draft && ![self.currentConversation.remoteExtra.draft isEqualToString:@""]) {
        return true;
    }
    return false;
}

-(void) sendTyping {
    QCLogDebug(@"输入中...");
    [self.conversationVM typing];
}


- (void)setMultipleOn:(BOOL)multipleOn {
    [self setMultipleOn:multipleOn selectedMessage:nil];
}

// 设置多选模式
-(void) setMultipleOn:(BOOL)multiple selectedMessage:(QCMessageModel * _Nullable)messageModel {
    // 先取消所有选中的
    [self.messageListView setMultipleOn:multiple selectedMessage:messageModel];
    
    __weak typeof(self) weakSelf = self;
    _multipleOn = multiple;
    if(multiple) {
        [self.input endEditing];
    }
    // 隐藏输入面板
    [self.input setHidden:multiple animation:YES animationBlock:^{
        [weakSelf showMultiplePanel:multiple];
    }];
    
    if(self.onMultiple) {
        self.onMultiple(multiple);
    }
   
}


// 是否显示多选面板
-(void) showMultiplePanel:(BOOL) show{
    if(show) {
        [self addSubview:self.multiplePanel];
        [self layoutSubviews];
    }else{
        [self.multiplePanel removeFromSuperview];
        [self layoutSubviews];
       
    }
}



- (QCMultiplePanel *)multiplePanel {
    if(!_multiplePanel) {
        CGFloat safeBottom;
        if (@available(iOS 11.0, *)) {
            safeBottom = [[UIApplication sharedApplication].keyWindow safeAreaInsets].bottom;
            _multiplePanel = [[QCMultiplePanel alloc] initWithFrame:CGRectMake(0.0f, QCScreenHeight, QCScreenWidth, self.input.contentViewMinHeight+safeBottom)];
            _multiplePanel.delegate = self;
            _multiplePanel.backgroundColor = [QCApp shared].config.cellBackgroundColor;
        }
    }
    return _multiplePanel;
}

// 禁言
-(UIView*) forbiddenView {
    if(!_forbiddenView) {
        CGFloat safeBootom =0.0f;
        if (@available(iOS 11.0, *)) {
            UIEdgeInsets safeArea = [[UIApplication sharedApplication] keyWindow].safeAreaInsets;
             safeBootom =safeArea.bottom;
            
        }
         CGFloat offsetHeight = safeBootom;
        CGFloat height = 50.0f;
        _forbiddenView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.lim_height, self.lim_width, height+safeBootom)];
        [_forbiddenView setBackgroundColor:[QCApp shared].config.cellBackgroundColor];
        _forbiddenView.hidden = YES;
        self.forbiddenTitleLbl = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 5.0f, _forbiddenView.lim_width - 20.0f, 34.0f)];
        self.forbiddenTitleLbl.font = [UIFont systemFontOfSize:15.0f];
        [self.forbiddenTitleLbl setTextColor:[UIColor grayColor]];
        [self.forbiddenTitleLbl setTextAlignment:NSTextAlignmentCenter];
        self.forbiddenTitleLbl.layer.borderWidth = 0.5f;
        self.forbiddenTitleLbl.layer.masksToBounds = YES;
        self.forbiddenTitleLbl.layer.cornerRadius = 6.0f;
        [self.forbiddenTitleLbl.layer setBorderColor:[QCApp shared].config.lineColor.CGColor];
        
        self.forbiddenTitleLbl.lim_top = (_forbiddenView.lim_height-safeBootom) /2.0f - self.forbiddenTitleLbl.lim_height/2.0f;
        [_forbiddenView addSubview:self.forbiddenTitleLbl];
    }
    return _forbiddenView;
}

-(void) setGroupForbidden:(BOOL)on title:(NSString*)title{
    [self.forbiddenView setHidden:!on];
    if(on) {
        self.forbiddenTitleLbl.text = title;
        [self.messageListView animateMessageWithBlock:^{
            [self layoutSubviews];
        }];
    }else {
        [self.messageListView animateMessageWithBlock:^{
            [self layoutSubviews];
        }];
    }
    
}

-(void) destoryForbiddenTimer {
    [self.forbiddenTimer invalidate];
    self.forbiddenTimer = nil;
}

-(void) setGroupForbidden:(BOOL)on{
    
    [self destoryForbiddenTimer];
   
    
    NSInteger forbiddenExpirTime = [self.conversationVM.memberOfMe.extra[@"forbidden_expir_time"] integerValue];
    if(on && forbiddenExpirTime>0) {
       
        NSInteger second = forbiddenExpirTime - [[NSDate date] timeIntervalSince1970];
        if(second<=0) {
            [self setGroupForbidden:on title:LLang(@"禁言中")];
            return;
        }
        NSString *forbidderStr = [self getForbidderStr];
        __weak typeof(self) weakSelf = self;
        self.forbiddenTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f repeats:YES block:^(NSTimer * _Nonnull timer) {
            NSString *forbiddeStr = [weakSelf getForbidderStr];
            if(![forbiddeStr isEqualToString:@""]) {
                [weakSelf setGroupForbidden:YES title:[weakSelf getForbidderStr]];
            }else {
                [timer invalidate];
                [weakSelf setGroupForbiddenIfNeed];
            }
            
        }];
        [self setGroupForbidden:on title:forbidderStr];
    }else {
        [self setGroupForbidden:on title:LLang(@"全员禁言中")];
    }
   
}

-(NSString*) getForbidderStr {
    NSInteger forbiddenExpirTime = [self.conversationVM.memberOfMe.extra[@"forbidden_expir_time"] integerValue];
    NSInteger second = forbiddenExpirTime - [[NSDate date] timeIntervalSince1970];
    if(second<=0) {
        return @"";
    }
    
   NSString *timeStr =  [QCTimeTool formatCountdownTime:forbiddenExpirTime];
    
    return [NSString stringWithFormat:LLang(@"禁言中（%@）"),timeStr];
}

-(BOOL) setGroupForbiddenIfNeed {
    // 全局禁言开关（管理后台一键禁言群聊 / 私聊）。无论身份都生效，群主和管理员也禁言。
    QCAppRemoteConfig *rc = [QCApp shared].remoteConfig;
    if(rc) {
        if(self.channel.channelType == WK_GROUP && rc.disableGroupMessageOn) {
            NSString *tip = (rc.muteTextOfGroup && rc.muteTextOfGroup.length>0) ? rc.muteTextOfGroup : LLang(@"全员禁言中");
            [self setGroupForbidden:YES title:tip];
            return true;
        }
        if((self.channel.channelType == WK_PERSON || self.channel.channelType == WK_CustomerService) && rc.disablePrivateMessageOn) {
            NSString *tip = (rc.muteTextOfPrivate && rc.muteTextOfPrivate.length>0) ? rc.muteTextOfPrivate : LLang(@"全员禁言中");
            [self setGroupForbidden:YES title:tip];
            return true;
        }
    }
    if(self.conversationVM.memberRole == QCMemberRoleCreator || self.conversationVM.memberRole == QCMemberRoleManager) {
        [self setGroupForbidden:NO];
        return true;
    }else {
        if(self.conversationVM.channelInfo) {
            NSInteger forbiddenExpirTime =  self.conversationVM.forbiddenExpirTime;
            BOOL forbidden = self.conversationVM.channelInfo.forbidden || forbiddenExpirTime > 0;
            [self setGroupForbidden:forbidden];
            return true;
        }
    }
    return false;
}


#pragma mark - 输入框

-(QCConversationInputPanel*) input{
    if(!_input){
        _input = [[QCConversationInputPanel alloc] initWithConversationContext:self.conversationContext];
        _input.delegate = self;
        [_input updateAndLayoutTextViewRightView];
//        _input.conversationContext = self;
        _input.disableAutoTop = true;
        //        _input.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
//        [_input setBackgroundColor: ColorSessionMessageInputBar];
        
    }
    return _input;
}

#pragma mark -- QCConversationInputPanelDelegate

// 发送文本消息
- (void)inputPanelSend:(QCConversationInputPanel *)inputPanel text:(NSString*)text {

    [self layoutSubviews];
    [self.conversationContext sendTextMessage:text];
    [self.conversationContext hideMentionUsers];
    [self.conversationContext callConversationInputChangeDelegate];
    
    
}
// 发送消息
-(void) inputPanel:(QCConversationInputPanel *)inputPanel sendMessage:(QCMessageContent*)content {
   
    [self.conversationContext sendMessage:content];
}

- (void)inputPanelTyping:(QCConversationInputPanel *)inputPanel {
    if(self.editMessage) { // 编辑消息不发送typing消息
        return;
    }
    if( [[NSDate date] timeIntervalSince1970] - self.lastTypingTime > 5) {
         [self sendTyping];
         self.lastTypingTime = [[NSDate date] timeIntervalSince1970];
    }
   
}

// 面板弹起或收起
- (void)inputPanelUpOrDown:(QCConversationInputPanel *)inputPanel up:(BOOL)up{
    
    [self.messageListView stopScrollingAnimation];
    [self layoutSubviews];
    
   
    
//    [self adjustRobotMenusIfNeed];
    [self.conversationContext layoutMentionUserHandle];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(conversationView:inputPanelUpOrDown:)]) {
        [self.delegate conversationView:self inputPanelUpOrDown:up];
    }
   
}

// 输入框高度改变
- (void)inputPanelWillChangeHeight:(QCConversationInputPanel *)inputPanel height:(CGFloat)height duration:(NSTimeInterval)duration animationCurve:(int)animationCurve{
    
    [self.messageListView animateMessageWithBlock:^{
        [self layoutSubviews];
    }];
    
}


// 结束触发@
-(void) inputPanelMentionEnd:(QCConversationInputPanel *)inputPanel {
    if(self.channel.channelType == WK_PERSON) {
        return;
    }
    QCLogDebug(@"inputPanelMentionEnd");
    [self.conversationContext hideMentionUsers];
    
    
}

// @后面的输入字符
- (void)inputPanel:(QCConversationInputPanel *)inputPanel mentionSearch:(NSString *)keyword {
    if(self.channel.channelType == WK_PERSON) {
        return;
    }
    QCLogDebug(@"mentionSearch--%@",keyword);
    [self.conversationContext showMentionUsers:keyword];
}

- (void)inputPanel:(QCConversationInputPanel *)inputPanel textChange:(NSString *)text {
    [self.conversationContext callConversationInputChangeDelegate];
}



#pragma mark -- QCMultiplePanelDelegate


// 多选panel
- (void)multiplePanel:(QCMultiplePanel *)panel action:(QCMultipAction)action {
    if(action == QCMultipActionDelete) { // 删除
        NSArray *selectedMessages = [self.messageListView getSelectedMessages];
        if(selectedMessages && selectedMessages.count>0) {
            [[QCMessageManager shared] deleteMessages:selectedMessages];
            [self setMultipleOn:NO];
        }
    }else if(action == QCMultipActionForward) { // 逐条转发
        [self multipActionForward];
    }else if(action == QCMultipActionMergeForward) { // 合并转发
        [self multipActionMergeForward];
    }
}

// 逐条转发
-(void) multipActionForward {
    QCConversationListSelectVC *vc = [QCConversationListSelectVC new];
    vc.title = LLang(@"选择一个聊天");
    vc.viewModel.multiple = YES;
    NSArray *selectedMessages = [self.messageListView getSelectedMessages];
    __weak typeof(self) weakSelf = self;
    [vc setOnSelectChannels:^(NSArray<QCChannel *> * _Nonnull channels) {
        [[QCNavigationManager shared] popToViewController:weakSelf.lim_viewController animated:YES];
        for (QCChannel *channel in channels) {
            for (QCMessageModel *messageModel  in selectedMessages) {
                if([[QCApp shared] allowMessageForward:messageModel.contentType]) { // 如果允许转发则直接转发
                    if([weakSelf.channel isEqual:channel]) {
                        [weakSelf.conversationContext forwardMessage:messageModel.content];
                    }else{
                        [[QCSDK shared].chatManager forwardMessage:messageModel.content channel:channel];
                    }
                }else{ // 如果不允许转发，则将变成文本消息转发
                    QCTextContent *textContent = [[QCTextContent alloc] initWithContent:[messageModel.content conversationDigest]];
                    if([weakSelf.channel isEqual:channel]) {
                        [weakSelf.conversationContext forwardMessage:textContent];
                    }else{
                        [[QCSDK shared].chatManager forwardMessage:textContent channel:channel];
                    }
                }
            }
        }
        [[QCNavigationManager shared].topViewController.view showHUDWithHide:LLang(@"发送成功")];
        [weakSelf setMultipleOn:NO];
    }];
    [[QCNavigationManager shared] pushViewController:vc animated:YES];
}

// 合并转发
-(void) multipActionMergeForward {
    __weak typeof(self) weakSelf = self;
    QCConversationListSelectVC *vc = [QCConversationListSelectVC new];
    vc.title = LLang(@"选择一个聊天");
    vc.viewModel.multiple = YES;
    NSArray *selectedMessages = [self.messageListView getSelectedMessages];
    [vc setOnSelectChannels:^(NSArray<QCChannel *> * _Nonnull channels) {
        [[QCNavigationManager shared] popToViewController:weakSelf.lim_viewController animated:YES];

        NSMutableArray *msgs = [NSMutableArray array];
        NSMutableArray<NSDictionary*> *userDicts = [NSMutableArray array];
        for (QCMessageModel *messageModel  in selectedMessages) {
            [msgs addObject:messageModel.message];
            bool hasUser = false;
            for (NSDictionary *userDict in userDicts) {
                if([messageModel.fromUid isEqualToString:userDict[@"uid"]]) {
                    hasUser = true;
                    break;
                }
            }
            if(!hasUser) {
                NSString *name = messageModel.from?messageModel.from.name:@"";
                [userDicts addObject:@{@"uid":messageModel.fromUid?:@"",@"name":name}];
            }
        }
        [msgs sortUsingComparator:^NSComparisonResult(QCMessageModel  *obj1, QCMessageModel *obj2) {
            if(obj1.timestamp<obj2.timestamp) {
                return NSOrderedAscending;
            }
            if(obj1.timestamp == obj2.timestamp) {
                return NSOrderedSame;
            }
            return NSOrderedDescending;
        }];

        for (QCChannel *channel in channels) {
            QCMergeForwardContent *content = [QCMergeForwardContent msgs:msgs users:userDicts channelType:weakSelf.channel.channelType];
            if([weakSelf.channel isEqual:channel]) {
                [weakSelf.conversationContext sendMessage:content];
            }else {
                [[QCSDK shared].chatManager sendMessage:content channel:channel];
            }
        }

        [[QCNavigationManager shared].topViewController.view showHUDWithHide:LLang(@"发送成功")];
        [weakSelf setMultipleOn:NO];
    }];
    [[QCNavigationManager shared] pushViewController:vc animated:YES];
}

@end
