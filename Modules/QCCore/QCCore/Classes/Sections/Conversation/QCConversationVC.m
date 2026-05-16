//
//  QCConversationVC.m
//  QCCore
//
//  Created by tt on 2022/5/18.
//

#import "QCConversationVC.h"
#import "QCMessageListView.h"
#import "QCCore.h"
#import "QCMessageListDataProviderImp.h"
#import "QCConversationChannelHeader.h"
#import "QCConversationListVM.h"
#import "QCConversationView.h"
#import "NSString+WK.h"
#import "QCConversationView+Robot.h"
#import "QCMessageListView+Position.h"
#import <QCCore/QCCore-Swift.h>
#import "Svg.h"
#import "QCThemeUtil.h"
@interface QCConversationVC ()<QCChannelManagerDelegate>

@property(nonatomic,strong) QCConversationView *conversationView;

@property(nonatomic,strong) QCConversationChannelHeader *channelHeader;

@property(nonatomic,copy) videoCallSupportInvoke videocallInvoke; // 是否支持视频通话

@property(nonatomic,strong) UIButton *cancelMutipleBtn; // 取消多选的按钮

@property(nonatomic,strong) QCChannelInfo *channelInfo;

@property(nonatomic,assign) BOOL firstLoad; // 是否第一次加载

@property(nonatomic,strong) UIImageView *backgroundView;

@end

@implementation QCConversationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.firstLoad = true;
    [self.view addSubview:self.backgroundView];
    
    [self addDelegates];
    
    [self setupChatBackground];
    
    // 全局禁言：进入聊天页时提示一次
    [self showGlobalMuteTipIfNeed];
   
    self.videocallInvoke = [[QCApp shared] invoke:QCPOINT_VIDEOCALL_SUPPORT_FNC param:@{@"channel":self.channel,@"context":self.conversationView.conversationContext}];
    
  
    [self.navigationBar addSubview:self.channelHeader];
    [self.view addSubview:self.conversationView];
    [self.view bringSubviewToFront:self.navigationBar]; // 将导航栏放到最顶层
    
    __weak typeof(self) weakSelf = self;
    
    self.conversationView.channel = self.channel;
    self.conversationView.locationAtOrderSeq = self.locationAtOrderSeq;
    self.conversationView.conversationVM.onMemberUpdate = ^{
        [weakSelf refreshTitle];
        [weakSelf.conversationView setGroupForbiddenIfNeed];
        [weakSelf.conversationView syncRobot:[weakSelf getMemberRobotIDs]];
        QCChannelMember *memberOfMe = weakSelf.conversationView.conversationVM.memberOfMe;
        if(memberOfMe) {
            if(weakSelf.videocallInvoke!=nil) {
                [weakSelf showVideoCall:memberOfMe.status == QCMemberStatusNormal];
            }
        }
        
    };
    [self.conversationView viewDidLoad];
     
   
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if(!weakSelf) {
            return;
        }
        [weakSelf requestLoadChannelInfoIfNeed];
        [weakSelf markFlameMessages];
    });
    
    
    // 获取注入的顶部面板
   UIView *topPanel = [QCApp.shared invoke:QCPOINT_CONVERSATION_TOP_PANEL param:@{@"channel":self.channel,@"context":self.conversationView.conversationContext}];
    self.conversationView.topView.hidden = YES;
    self.conversationView.topView.lim_top = -self.conversationView.topView.lim_height;
    if(topPanel) {
        self.conversationView.topView.lim_height = topPanel.lim_height;
        [self.conversationView.topView addSubview:topPanel];
    }
}


-(void) addDelegates {
    [[QCSDK shared].channelManager addDelegate:self]; // 频道数据监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateChatBackground) name:QCNOTIFY_CHATBACKGROUND_CHANGE object:nil];
}
-(void) removeDelegates {
    [[QCSDK shared].channelManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QCNOTIFY_CHATBACKGROUND_CHANGE object:nil];
}


// 全局禁言：进入聊天页时若开启对应禁言则弹提示
-(void) showGlobalMuteTipIfNeed {
    QCAppRemoteConfig *rc = [QCApp shared].remoteConfig;
    if(!rc) {
        return;
    }
    NSString *tip = nil;
    if(self.channel.channelType == WK_GROUP && rc.disableGroupMessageOn) {
        tip = (rc.muteTextOfGroup && rc.muteTextOfGroup.length>0) ? rc.muteTextOfGroup : LLang(@"群聊禁言中");
    } else if((self.channel.channelType == WK_PERSON || self.channel.channelType == WK_CustomerService) && rc.disablePrivateMessageOn) {
        tip = (rc.muteTextOfPrivate && rc.muteTextOfPrivate.length>0) ? rc.muteTextOfPrivate : LLang(@"私聊禁言中");
    }
    if(tip) {
        [QCAlertUtil alert:tip];
    }
}

// 标记阅后即焚的消息（如果超时则删除）
-(void) markFlameMessages {
    NSArray<QCMessage*> *messages = [QCFlameManager.shared getMessagesOfNeedFlame];
    if(messages && messages.count>0) {
        NSMutableArray<QCMessageModel*> *messageModels = [NSMutableArray array];
        for (QCMessage *message in messages) {
            [messageModels addObject:[[QCMessageModel alloc] initWithMessage:message]];
        }
        [QCMessageManager.shared deleteMessages:messageModels];
    }
}

// 获取机器人成员
-(NSArray<NSString*>*) getMemberRobotIDs {
    NSMutableArray *robots = [NSMutableArray array];
    for (QCChannelMember *channelMember in self.conversationView.conversationVM.members) {
        if(channelMember.robot) {
            [robots addObject:channelMember.memberUid];
        }
    }
    return robots;
}

-(void) requestLoadChannelInfoIfNeed{
    BOOL needFetch = false;
    self.channelInfo = [[QCChannelManager shared] getChannelInfo:self.channel];
    self.conversationView.conversationVM.channelInfo = self.channelInfo;
    if(self.channelInfo) {
        if(self.conversationView.conversationVM.groupType == QCGroupTypeSuper) {
            needFetch = true; // 超级群每次都获取channelInfo
        }
        __weak typeof(self) weakSelf  = self;
        lim_dispatch_main_async_safe(^{
            [weakSelf channelInfoLoadFinished];
        })
    }else {
        needFetch = true;
    }
    
    if(needFetch) {
        [[QCChannelManager shared] fetchChannelInfo:self.channel];
    }
}

- (void)dealloc {
    NSLog(@"%s",__func__);
    [self removeDelegates];
    [self markFlameMessages];
}

-(void) channelInfoLoadFinished {
    [self refreshTitle];
    [self.conversationView setGroupForbiddenIfNeed];
    if(self.channel.channelType == WK_PERSON && self.channelInfo.robot) {
        [self.conversationView syncRobot:@[self.channel.channelId]];
    }
    
    if(self.firstLoad) {
        self.firstLoad = false;
        QCGroupType groupType =  self.conversationView.conversationVM.groupType;
        if(groupType == QCGroupTypeCommon) { // 普通群
            [self commonGroupInit];
        }else if(groupType == QCGroupTypeSuper) { // 超级群
            [self superGroupInit];
        }
    }
    
    
}
// 超级群初始化
-(void) superGroupInit {
    [self refreshTitle];
}

// 普通群初始化
-(void) commonGroupInit {
    [self.conversationView.conversationVM requestMembers];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.conversationView viewWillDisappear:animated];
   
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.conversationView viewWillAppear];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.conversationView viewDidDisappear];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.conversationView viewDidAppear];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self.conversationView layoutSubviews];
    [self.conversationView.messageListView viewDidLayoutSubviewsOfPosition];
}

- (QCConversationView *)conversationView {
    if(!_conversationView) {
        CGFloat offset = self.navigationBar.lim_bottom;
        _conversationView = [[QCConversationView alloc] initWithFrame:CGRectMake(0.0f, offset, self.view.lim_width, self.view.lim_height - offset) channel:self.channel];
        __weak typeof(self) weakSelf = self;
        _conversationView.onMultiple = ^(BOOL on) {
            // 显示或隐藏 取消按钮
            weakSelf.navigationBar.showBackButton = !on;
            if(on) {
                [weakSelf.navigationBar addSubview:weakSelf.cancelMutipleBtn];
            }else{
                [weakSelf.cancelMutipleBtn removeFromSuperview];
            }
        };
    }
    return _conversationView;
}
-(void) refreshTitle {
    if(self.channelInfo) {
        
        self.channelHeader.channelInfo = self.channelInfo;
        // 群成员人数仅管理员/群主可见
        QCMemberRole myRole = self.conversationView.conversationVM.memberRole;
        BOOL isAdmin = (myRole == QCMemberRoleManager || myRole == QCMemberRoleCreator);
        if (self.channel.channelType != WK_GROUP || isAdmin) {
            self.channelHeader.memberCount = self.conversationView.conversationVM.memberCount;
        } else {
            self.channelHeader.memberCount = -1;
        }
        
        
        [self.channelHeader layoutSubviews];
        
        NSString *channelName = self.channelInfo.displayName;
        NSString *showChannelName = [channelName limitedStringForMaxBytesLength:20];
        if(showChannelName.length <channelName.length) {
            showChannelName = [NSString stringWithFormat:@"%@...",showChannelName];
        }
        [self.conversationView.input.textView internalTextView].placeholder=[NSString stringWithFormat:LLang(@"发送给 %@"),showChannelName];
       
    }
}

- (UIImageView *)backgroundView {
    if(!_backgroundView) {
        _backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _backgroundView.clipsToBounds = YES;
        _backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _backgroundView;
}

- (void)viewConfigChange:(QCViewConfigChangeType)type {
    [super viewConfigChange:type];
    if(type == QCViewConfigChangeTypeStyle) {
        [self setupChatBackground];
    }
}

-(void) setChatBackgroud:(UIImage*)img {
//    self.view.layer.contents = (id)img.CGImage;
    self.backgroundView.image = img;
}

-(BOOL) hasSetChatBackgroud {
    if(self.view.layer.contents) {
        return true;
    }
    return false;
}

-(void) setupChatBackground {
    if([self hasSetChatBackgroud]) {
        return;
    }
    [self updateChatBackground];
   
}

-(void) updateChatBackground {
    BOOL existChannelBg = [QCThemeUtil existChatBackground:self.channel];
    if(existChannelBg) {
       NSData *channelBgData = [QCThemeUtil getChatBackground:self.channel style:QCApp.shared.config.style];
        if(channelBgData) {
            [self setChatBackgroud:[UIImage imageWithData:channelBgData]];
            return;
        }
    }
    
    BOOL existDefaultBg = [QCThemeUtil existDefaultbackground];
    if(existDefaultBg) {
        NSData *defaultBgData = [QCThemeUtil getDefaultBackground:QCApp.shared.config.style];
         if(defaultBgData) {
             [self setChatBackgroud:[UIImage imageWithData:defaultBgData]];
             return;
         }
    }
    
    [self setChatBackgroud:[self imageName:@"Conversation/Index/ChatBg"]];
}

- (QCConversationChannelHeader *)channelHeader {
    if(!_channelHeader) {
        CGFloat leftSpace = 50.0f;
        CGFloat rightSpace = 10.0f;
        CGFloat statusBottom = [UIApplication sharedApplication].statusBarFrame.origin.y + [UIApplication sharedApplication].statusBarFrame.size.height;
       
        _channelHeader = [[QCConversationChannelHeader alloc] initWithFrame:CGRectMake(leftSpace, statusBottom, self.view.lim_width - leftSpace - rightSpace, self.navigationBar.lim_height - (statusBottom))];
        __weak typeof(self) weakSelf = self;
        [_channelHeader setOnInfo:^{
            [[QCApp shared] invoke:QCPOINT_CONVERSATION_SETTING param:@{@"channel":weakSelf.channel,@"context":weakSelf.conversationView.conversationContext}];
        }];
        
//        QCChannelMember *memberOfMe = weakSelf.conversationView.conversationVM.memberOfMe;
        BOOL showCall = false;
        if(self.videocallInvoke!=nil ) {
            showCall = true;
        }
        [self showVideoCall:showCall];
        
        [_channelHeader setOnVoiceCall:^{
            if(weakSelf.videocallInvoke) {
                weakSelf.videocallInvoke(weakSelf.channel,QCCallTypeAudio);
            }
        }];
        
        [_channelHeader setOnVideoCall:^{
            weakSelf.videocallInvoke(weakSelf.channel,QCCallTypeVideo);
        }];
//        [_channelHeader setBackgroundColor:[UIColor redColor]];
    }
    return _channelHeader;
}

-(void) showVideoCall:(BOOL) show {
    if(!show) {
        _channelHeader.voiceCallBtn.hidden = YES;
        _channelHeader.videoCallBtn.hidden = YES;
    }else {
        _channelHeader.voiceCallBtn.hidden = NO;
        if(self.channel.channelType == WK_GROUP) {
            _channelHeader.videoCallBtn.hidden = YES;
        }else{
            _channelHeader.videoCallBtn.hidden = NO;
        }
    }
    [_channelHeader layoutSubviews];
}


- (UIButton *)cancelMutipleBtn {
    if(!_cancelMutipleBtn) {
        CGFloat statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        _cancelMutipleBtn = [[UIButton alloc] initWithFrame:CGRectMake(10.0f, statusHeight, 0.0f, 0.0f)];
        [_cancelMutipleBtn setTitle:LLang(@"取消") forState:UIControlStateNormal];
        [_cancelMutipleBtn.titleLabel setFont:[[QCApp shared].config appFontOfSize:16.0f]];
        [_cancelMutipleBtn setTitleColor:[QCApp shared].config.defaultTextColor forState:UIControlStateNormal];
        [_cancelMutipleBtn sizeToFit];
        [_cancelMutipleBtn addTarget:self action:@selector(cancelMultiplePressed) forControlEvents:UIControlEventTouchUpInside];
        _cancelMutipleBtn.lim_top = (self.navigationBar.lim_height - statusHeight)/2.0f - _cancelMutipleBtn.lim_height/2.0f + statusHeight;
    }
    return _cancelMutipleBtn;
}

-(void) cancelMultiplePressed {
    [self.conversationView setMultipleOn:NO selectedMessage:nil];
}

-(UIImage*) imageName:(NSString*)name {
    return [QCApp.shared loadImage:name moduleID:@"QCCore"];
//    return [[QCResource shared] resourceForImage:name podName:@"QCCore_images"];
}

#pragma mark - QCChannelManagerDelegate
// 频道信息更新
-(void) channelInfoUpdate:(QCChannelInfo*)channelInfo oldChannelInfo:(QCChannelInfo * _Nullable)oldChannelInfo {
    if([self.channel isEqual:channelInfo.channel]) { // 更新的当前会话的信息
        self.channelInfo = channelInfo;
        self.conversationView.conversationVM.channelInfo = self.channelInfo;
        [self channelInfoLoadFinished];
        if(oldChannelInfo.flame!=channelInfo.flame) {
            [(id<QCConversationContext>)self.conversationView.conversationContext refreshInputView];
        }
    }
   
}
@end
