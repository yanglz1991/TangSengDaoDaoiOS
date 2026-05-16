//
//  QCSystemMessageHandler.m
//  WuKongBase
//
//  Created by tt on 2020/1/23.
//

#import "QCSystemMessageHandler.h"
#import <WuKongIMSDK/WuKongIMSDK.h>
#import "QCConstant.h"
#import "QCGroupManager.h"
#import "QCLogs.h"
#import "QCNavigationManager.h"
#import "QCApp.h"
#import <SDWebImage/SDWebImage.h>
#import "QCAvatarUtil.h"
#import "QCResource.h"
#import <AudioToolbox/AudioToolbox.h>
#import "QCLocalNotificationManager.h"
#import "QCTypingManager.h"
#import "WuKongBase.h"
#import "QCOnlineStatusManager.h"
#import "QCMySettingManager.h"
@interface QCSystemMessageHandler ()<QCChatManagerDelegate,QCConnectionManagerDelegate,QCCMDManagerDelegate>

@property(nonatomic,strong) dispatch_queue_t systemMessageHandlerQueue;

@end

@implementation QCSystemMessageHandler

static QCSystemMessageHandler *_instance = nil;

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone ];
    });
    return _instance;
}

+(instancetype) shared{
    if (_instance == nil) {
        _instance = [[super alloc]init];
    }
    return _instance;
}

- (dispatch_queue_t)systemMessageHandlerQueue {
    if(!_systemMessageHandlerQueue) {
        _systemMessageHandlerQueue  = dispatch_queue_create("demo.gcd.concurrent_queue", DISPATCH_QUEUE_CONCURRENT);
    }
    return _systemMessageHandlerQueue;
}

- (void)handle {
    [[QCSDK shared].chatManager removeDelegate:self];
    [[QCSDK shared].chatManager addDelegate:self];
    
    [[QCSDK shared].connectionManager removeDelegate:self];
    [[QCSDK shared].connectionManager addDelegate:self];
    
    [[QCSDK shared].cmdManager removeDelegate:self];
    [[QCSDK shared].cmdManager addDelegate:self];
    
    // 监听应用进入前台通知，主动检查设备状态
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkDeviceStatus) name:UIApplicationWillEnterForegroundNotification object:nil];
}

#pragma mark - QCConnectionManagerDelegate
// 踢出
//
// 服务端封禁链路：sendForceLogoutCMD（CMD 通道，携带 reason/match_type/match_value）
//                → 等 300ms
//                → QuitUserDevice（切断长连，触发本回调，reasonCode=WK_REASON_KICK，reason 通常为空）
// 因此 reasonCode==WK_REASON_KICK 可能对应：
//   a) 其他设备登录顶号（reason 为空，需要兜底文案"账号已在其他设备上登录"）
//   b) 账号 / IP / 设备被管理员封禁（真实文案由 forceLogout CMD 携带）
// 弱网下 Kick 包可能先于 CMD 到达，所以这里延迟 1.2s 再弹窗，期间若 forceLogout CMD
// 已经弹出了精确文案（banDialogShowing=YES），本回调直接跳过避免显示错误提示词。
- (void)onKick:(uint8_t)reasonCode reason:(NSString *)reason {
    if(reasonCode == WK_REASON_KICK || reasonCode == WK_REASON_IN_BLACKLIST) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 用户在 1.2s 等待期间，可能已通过 forceLogout CMD / checkstatus 弹窗点确认走完
            // immediatelyLogout（已退回登录页），此时不应再弹"账号已在其他设备上登录"覆盖。
            if(![QCApp shared].isLogined) {
                return;
            }
            // 已被 forceLogout CMD / checkstatus 兜底处理过，跳过 Kick 自身弹窗，避免错误提示词覆盖
            if([QCApp shared].banDialogShowing) {
                return;
            }
            NSString *tip;
            if(reason && reason.length > 0) {
                // 服务端给了具体 reason（如"IP 已被禁用"/"设备已被封禁"），优先使用
                tip = reason;
            } else if(reasonCode == WK_REASON_IN_BLACKLIST) {
                tip = LLang(@"您的账号已被封禁！");
            } else {
                // 真·其他设备登录顶号
                tip = LLang(@"账号已在其他设备上登录！");
            }
            [QCApp shared].banDialogShowing = YES;
            [self presentKickAlertWithTip:tip];
        });
        return;
    }

    // 非封禁/顶号场景（白名单等）走原同步路径
    NSString *tip;
    if(reasonCode == WK_REASON_NOT_IN_WHITELIST) {
        tip = LLang(@"您不在好友白名单内！");
    } else if(reason && reason.length > 0) {
        tip = reason;
    } else {
        tip = LLang(@"您的账号已被强制下线！");
    }
    [QCApp shared].banDialogShowing = YES;
    [self presentKickAlertWithTip:tip];
}

// 统一的 Kick 弹窗展示（onKick 内部使用）
- (void)presentKickAlertWithTip:(NSString *)tip {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LLang(@"提示") message:tip preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *okAction = [UIAlertAction actionWithTitle:LLang(@"好的") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[QCApp shared] logout];
        }];
        [alertController addAction:okAction];
        UIViewController *top = [QCNavigationManager shared].topViewController;
        if(top) {
            [top presentViewController:alertController animated:YES completion:nil];
        } else {
            // 拿不到顶层 VC（如冷启动期间）直接退出兜底
            [[QCApp shared] logout];
        }
    });
}

#pragma mark - QCChatManagerDelegate
bool needRemind = false; // 是否需要提醒
- (void)onRecvMessages:(QCMessage*)message left:(NSInteger)left {
    [[QCTypingManager shared] removeTypingByChannel:message.channel newMessage:message];
    dispatch_async(self.systemMessageHandlerQueue, ^{
        switch (message.contentType) {
            case WK_GROUP_MEMBERADD:  // 群成员添加
            case WK_GROUP_MEMBERREMOVE: // 群成员移除
            case WK_GROUP_MEMBERSCANJOIN: // 群成员扫码加入
            case WK_GROUP_TRANSFERGROUPER: // 群转让
                [self memberChange:message.channel];
                break;
            case WK_GROUP_MEMBERINVITE: // 群成员邀请
                [self handleGroupMemberInvite:message];
                break;
            case WK_GROUP_UPDATE: // 群基础数据更新
            case WK_GROUP_FORBIDDEN_ADD_FRIEND: // 群禁止加好友
            case WK_GROUP_UPGRADE: // 群升级
                [self handleGroupUpdate:message];
                break;
//            case WK_CMD: // 命令
//                [self handleCMD:message];
            default:
                break;
        }
    });
    if(message.header.showUnread) {
        if(![QCApp shared].currentChatChannel || ![[QCApp shared].currentChatChannel isEqual:message.channel]) {
            needRemind = true;
        }
    }
    
    // 按需显示本地通知
    [[QCLocalNotificationManager shared] showLocalNotificationIfNeed:message];
    
    
    if(left == 0) {
        if(needRemind) {
            needRemind = false;
            if(message.channelInfo) {
                if(message.channelInfo.mute) { // 免打扰不通知
                    return;
                }
                if(message.contentType == WK_GROUP_MEMBERADD && ![message.channelInfo settingForKey:QCChannelExtraKeyJoinGroupRemind defaultValue:YES]) {
                    return;
                }
            }
        
            [self remindUserIfNeed]; // 提醒收到消息如果需要
        }
    }else{
        needRemind = false;
    }
   
}

- (void)onSendack:(QCSendackPacket *)sendackPacket left:(NSInteger)left {
    if(sendackPacket.header.noPersist) {
        return;
    }
    [self playMessageSendOutSound];
}

#pragma mark - QCCMDManagerDelegate

- (void)cmdManager:(QCCMDManager *)manager onCMD:(QCCMDModel *)model {
    [self handleCMD:model.cmd param:model.param];
}

-(BOOL) alloPlayVoice {
    return YES;
}



// 群成员改变
-(void) memberChange:(QCChannel*)channel {
    QCChannelInfo *channelInfo = [QCSDK.shared.channelManager getChannelInfo:channel];
    if(channelInfo) {
        QCGroupType groupType = [QCChannelUtil groupType:channelInfo];
        
        if(groupType == QCGroupTypeSuper) {
            [QCSDK.shared.channelManager fetchChannelInfo:channel];
        }else  {
            [self syncMembers:channel];
        }
    }
}

-(void) syncMembers:(QCChannel*)channel {
    QCLogDebug(@"同步群成员！");
    [[QCGroupManager shared] syncMemebers:channel.channelId];
}
// 处理群聊邀请确认
-(void) handleGroupMemberInvite:(QCMessage*) message {
    // 判断是否存在邀请提醒，如果存在则在原来的count基础上累加
//   NSArray<QCReminder*> *reminders = [[QCSDK shared].reminderManager getReminders:QCReminderTypeMemberInvite channel:message.channel];
//    QCReminder *reminder;
//    if(reminders && reminders.count>0) {
//        reminder = reminders[0];
//    }
//    if(reminder && reminder.data &&  reminder.data[@"count"]) {
//        NSNumber *count = reminder.data[@"count"];
//        count = @(count.intValue+1);
//        [[QCSDK shared].conversationManager appendReminder:[QCReminder initWithType:QCReminderTypeMemberInvite text:[NSString stringWithFormat:LLang(@"[%d条进群申请]"),count.intValue] data:@{@"count":count}] channel:message.channel];
//    }else { // 如果不存在，则默认为1
//         [[QCSDK shared].conversationManager appendReminder:[QCReminder initWithType:QCReminderTypeMemberInvite text:LLang(@"[1条进群申请]") data:@{@"count":@(1)}] channel:message.channel];
//    }
   
}

// 处理群更新事件
-(void) handleGroupUpdate:(QCMessage*)message {
    QCLogDebug(@"处理群基础数据更新事件！");
    [[QCGroupManager shared] syncGroupInfo:message.channel.channelId complete:nil];
}

// 处理消息撤回
//-(void) handleMessageRevoke:(QCMessage*)message {
//    QCLogDebug(@" 处理消息撤回事件！");
//    QCSystemContent *sysmtemMessage =  (QCSystemContent*)message.content;
//    uint64_t messageId = 0;
//    NSString *messageIDStr;
//
//    QCMessage *revokeMessage; // 需要撤回的消息
//    if([QCSDK shared].options.proto == WK_PROTO_MOS) {
//        if(sysmtemMessage.content[@"client_msg_no"]) {
//            revokeMessage = [[QCMessageDB shared] getMessageWithClientMsgNo:sysmtemMessage.content[@"client_msg_no"]];
//        }
//    }else {
//        if(sysmtemMessage.content && sysmtemMessage.content[@"message_id"]) {
//            messageIDStr = sysmtemMessage.content[@"message_id"];
//
//        }
//        if(messageIDStr) {
//            NSDecimalNumber* formatter = [[NSDecimalNumber alloc] initWithString:messageIDStr]; // 这里需要用 NSDecimalNumber不要用NSNumberFormat NSNumberFormat数字太大会转换不正确
//            messageId =  [formatter unsignedLongLongValue];
//            revokeMessage = [[QCMessageDB shared] getMessageWithMessageId:messageId];
//        }
//    }
//   if(revokeMessage) {
//       [[QCSDK shared].chatManager revokeMessage:revokeMessage];
//   }
//
//
//}

-(void) handleMessageEerase:(NSDictionary*)param {
   NSString *eraseType =  param[@"erase_type"]?:@"from";
    if([eraseType isEqualToString:@"from"]) {
        if(param[@"from_uid"]) {
            NSString *channelID = param[@"channel_id"];
            NSNumber *channelType = param[@"channel_type"];
            [[QCSDK shared].chatManager deleteMessage:param[@"from_uid"] channel:[QCChannel channelID:channelID channelType:channelType.intValue]];
        }
    }else {
        NSString *channelID = param[@"channel_id"];
        NSNumber *channelType = param[@"channel_type"];
        [[QCSDK shared].chatManager clearMessages:[QCChannel channelID:channelID channelType:channelType.intValue]];
    }
}

-(void) handleMessageRevokeCMD:(NSDictionary*)param {
    QCMessage *revokeMessage; // 需要撤回的消息
    uint64_t messageId = 0;
    NSString *messageIDStr;
    if(param[@"message_id"]) {
        messageIDStr = param[@"message_id"];
    }
    if(messageIDStr) {
        NSDecimalNumber* formatter = [[NSDecimalNumber alloc] initWithString:messageIDStr]; // 这里需要用 NSDecimalNumber不要用NSNumberFormat NSNumberFormat数字太大会转换不正确
        messageId =  [formatter unsignedLongLongValue];
        revokeMessage = [[QCMessageDB shared] getMessageWithMessageId:messageId];
    }
   if(revokeMessage) {
       if(![[QCChannelSettingManager shared] revokeRemind:revokeMessage.channel]) {
           [[QCMessageManager shared] deleteMessages:@[[[QCMessageModel alloc] initWithMessage:revokeMessage]]]; // 如果设置了不撤回不提醒则直接删除消息
       }else{
           [[QCSDK shared].chatManager syncMessageExtra:revokeMessage.channel complete:nil];
       }
   }
    
}

// 处理群更新事件
-(void) handleCMD:(QCMessage*)message {
    
    QCCMDContent *cmdContent = (QCCMDContent*)message.content;
    NSString *cmd = cmdContent.cmd;
    [self handleCMD:cmd param:cmdContent.param];
}

-(void) handleCMD:(NSString*)cmd param:(NSDictionary*)param {
    if([cmd isEqualToString:@"appconfigUpdate"]) { // 全局 app 配置变更（管理后台禁言开关等）
        QCLogDebug(@"处理 appconfigUpdate 命令，强制重新拉取远程配置！");
        NSLog(@"[禁言追踪][QCSystemMessageHandler] 收到 appconfigUpdate CMD");
        // 必须用 forceRequestConfig：requestConfig 内部有 requestSuccess 守卫，
        // 启动后第一次拉取成功就再也不会重新请求，导致后台改的全员禁言等开关
        // 必须强退冷启动才能生效（这就是用户报告的现象）。
        [[QCApp shared].remoteConfig forceRequestConfig:nil];
        return;
    }
    if([cmd isEqualToString:@"forceLogout"]) { // 管理后台触发的强制下线
        [self handleForceLogout:param];
        return;
    }
    if([cmd isEqualToString:QCCMDMemberUpdate]) { // 群成员更新（包含禁言 / 角色变更 / 群昵称等）
        QCLogDebug(@"处理群成员更新命令！");
        NSLog(@"[禁言追踪] 收到 memberUpdate CMD, param=%@", param);
        if(param&&param[@"group_no"]) {
            NSString *groupNo = param[@"group_no"];
            // 同步群成员，等 DB 写完之后再发 UI 刷新通知。
            //
            // 旧实现里 syncMemebers 启动后立即 dispatch_async post 一次通知 → VM.handleMemberUpdate
            // 在 DB 尚未写完时查到旧数据并缓存到 memberOfMe，导致禁言/角色变更不及时生效，
            // 后台进前台也无法触发刷新，必须强退冷启动从 DB 取新值（这就是用户报告的现象）。
            //
            // QCGroupManager.syncMemebers 完成回调内部本就会发一次 QCNOTIFY_GROUP_MEMBERUPDATE
            // （前提是 syncMemberCount > 0）。但为兜底「服务端返回 0 条增量」的边界情况，
            // 这里在 complete 中再补发一次通知，确保 UI 一定会收到刷新事件。
            [[QCGroupManager shared] syncMemebers:groupNo complete:^(NSInteger syncMemberCount, NSError * _Nullable error) {
                if(error) {
                    QCLogError(@"CMD memberUpdate 同步群成员失败！->%@", error);
                    return;
                }
                // 仅 syncMemberCount == 0 时补发；>0 时 QCGroupManager 内部已发，避免重复
                if(syncMemberCount > 0) {
                    return;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:QCNOTIFY_GROUP_MEMBERUPDATE object:@{@"group_no":groupNo}];
                });
            }];
        }
    }else if([cmd isEqualToString:QCCMDUnreadClear]) { // 清除未读数
         QCLogDebug(@"处理清除未读消息命令！");
        NSInteger unread = 0;
        if(param[@"unread"]) {
            unread = [param[@"unread"] integerValue];
        }
        QCChannel *channel = [[QCChannel alloc] initWith:param[@"channel_id"] channelType:[param[@"channel_type"] intValue]];
        [[QCSDK shared].conversationManager setConversationUnreadCount:channel unread:unread];
    }else if([cmd isEqualToString:QCCMDGroupAvatarUpdate] && param&&param[@"group_no"]) { // 群头像更新
         QCLogDebug(@"处理群头像更新！->%@",param[@"group_no"]);
        [[SDImageCache sharedImageCache] removeImageForKey:[QCAvatarUtil getGroupAvatar:param[@"group_no"]] withCompletion:nil];
        
        [QCApp.shared notifyChannelAvatarUpdate:[QCChannel channelID:param[@"group_no"] channelType:WK_GROUP]];
        
        // 主动拉取最新的频道信息，触发 channelInfo 更新回调，
        // 让会话列表 / 群设置 / 群成员列表等界面同步刷新群名和群头像。
        [[QCSDK shared].channelManager fetchChannelInfo:[[QCChannel alloc] initWith:param[@"group_no"] channelType:WK_GROUP]];
        
    } else if([cmd isEqualToString:QCCMDUserAvatarUpdate] && param&&param[@"uid"]) { // 用户头像更新
        QCLogDebug(@"处理用户头像更新！->%@",[QCAvatarUtil getAvatar:param[@"uid"]]);
        
        [[SDImageCache sharedImageCache] removeImageForKey:[QCAvatarUtil getAvatar:param[@"uid"]] withCompletion:nil];
        
        [QCApp.shared notifyChannelAvatarUpdate:[QCChannel channelID:param[@"uid"] channelType:WK_PERSON]];
        
        // 主动拉取最新的频道信息，触发 channelInfo 更新回调，
        // 让会话列表 / 群聊 / 联系人列表等界面同步刷新昵称和头像。
        [[QCSDK shared].channelManager fetchChannelInfo:[[QCChannel alloc] initWith:param[@"uid"] channelType:WK_PERSON]];
        
    } else if([cmd isEqualToString:QCCMDChannelUpdate]) { // 频道信息更新
        QCLogDebug(@"处理频道信息更新！");
        NSString *channelID = param[@"channel_id"];
        NSNumber *channelType = param[@"channel_type"];
        if(!channelID || !channelType) {
            return;
        }
        [[QCSDK shared].channelManager fetchChannelInfo:[[QCChannel alloc] initWith:channelID channelType:channelType.intValue]];
    }else if([cmd isEqualToString:QCCMDVoiceReaded]) { // 语音已读
        NSString *messageIDStr = param[@"message_id"];
        unsigned long long messageID = strtoull([messageIDStr UTF8String], NULL, 0);
        QCMessage *message = [[QCMessageDB shared] getMessageWithMessageId:messageID];
        if(message) {
            message.voiceReaded = true;
            [[QCSDK shared].chatManager updateMessageVoiceReaded:message];
        }
    }else if([cmd isEqualToString:QCCMDTyping]) { // 输入中
        [[QCTypingManager shared] addTypingByMessage:[[QCTypingManager shared] convertParamToTypingMessage:param]];
    }else if([cmd isEqualToString:QCCMDOnlineStatus]) { // 在线状态通知
       QCChannel *channel = [[QCChannel alloc] initWith:param[@"uid"] channelType:WK_PERSON];
        BOOL allOffline = false;
        if(param[@"all_offline"]) {
            allOffline = [param[@"all_offline"] integerValue];
        }
        QCDeviceFlagEnum mainDeviceFlag = QCDeviceFlagEnumUnknown;
        if(param[@"main_device_flag"]) {
                mainDeviceFlag =  [param[@"main_device_flag"] integerValue];
        }
        [[QCOnlineStatusManager shared] setChannelOnline:channel online:!allOffline deviceFlag:mainDeviceFlag];
        
        if(channel.channelType == WK_PERSON && [channel.channelId isEqualToString:[QCApp shared].loginInfo.uid]) {
            QCDeviceFlagEnum deviceFlag = QCDeviceFlagEnumAPP;
            if(param[@"device_flag"]) {
                deviceFlag = [param[@"device_flag"] integerValue];
            }
            if(deviceFlag != QCDeviceFlagEnumAPP && deviceFlag != QCDeviceFlagEnumUnknown) {
                QCPCOnlineResp *pcOnline = [QCPCOnlineResp new];
                pcOnline.online = [param[@"online"] boolValue];
                pcOnline.deviceFlag = deviceFlag;
                [QCOnlineStatusManager.shared callOnlineStatusChangeMyPCOnlineStatusDelegate:pcOnline];
            }
        }
      
        
        
    }else if([cmd isEqualToString:QCCMDMessageRevoke]) { // 消息撤回
        [self handleMessageRevokeCMD:param];
    }else if([cmd isEqualToString:QCCMDSyncMessageExtra]) { // 同步消息扩展数据
        
        QCChannel *channel = [[QCChannel alloc] initWith:param[@"channel_id"] channelType:[param[@"channel_type"] intValue]];
        [[QCSDK shared].chatManager syncMessageExtra:channel complete:nil];
        
    }else if([cmd isEqualToString:QCCMDSyncMessageReaction]) { // 同步消息回应
        
        QCChannel *channel = [[QCChannel alloc] initWith:param[@"channel_id"] channelType:[param[@"channel_type"] intValue]];
        [[QCSDK shared].reactionManager sync:channel];
        
    } else if([cmd isEqualToString:QCCMDMessageEerase]) { // 擦除消息
        [self handleMessageEerase:param];
    } else if([cmd isEqualToString:QCCMDSyncReminders]) { // 同步提醒项
        [[QCSDK shared].reminderManager sync];
    } else if([cmd isEqualToString:QCCMDSyncConversationExtra]) { // 同组最近会话扩展
        [[QCSDK shared].conversationManager syncExtra];
    }
}

-(void) remindUserIfNeed {
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    if(state != UIApplicationStateActive) { //app在后台 不播铃声，因为WKLocalNotificationManager会播
        return;
    }
    if(QCOnlineStatusManager.shared.muteOfApp) { // app全局静音不做提醒
        return;
    }
    if([QCMySettingManager shared].newMsgNotice) { // 是否开启新消息提醒
        if([QCMySettingManager shared].voiceOn) {
            [self playSystemSound];
        }
        if([QCMySettingManager shared].shockOn) {
            // //震动
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
    }
   
}



// 播放系统声音
-(void)playSystemSound {
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
          static SystemSoundID messageSoundID = 0;
             if (messageSoundID == 0) {
                 NSBundle *b= [QCApp.shared resourceBundle:@"WuKongBase"];
                 NSString *path = [b pathForResource:@"newmsg" ofType:@"wav" inDirectory:@"Other"];
                 NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
                 AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &messageSoundID);
             }
         AudioServicesPlaySystemSound(messageSoundID);
     });
}

// 处理 forceLogout CMD：管理后台封禁用户/IP/设备时下发
//   match_type = user: 直接退出
//   match_type = device: 比对本机 device_id 一致才退出（精确）
//   match_type = ip:   直接退出（服务端已筛选目标 uid）
-(void) handleForceLogout:(NSDictionary*)param {
    if(!param) {
        return;
    }
    NSString *matchType  = param[@"match_type"]  ?: @"user";
    NSString *matchValue = param[@"match_value"] ?: @"";
    NSString *reason     = param[@"reason"];
    
    // 根据不同的封禁类型设置默认提示词
    if(!reason || reason.length == 0) {
        if([matchType isEqualToString:@"ip"]) {
            reason = LLang(@"您的IP地址已被封禁，无法继续使用！");
        } else if([matchType isEqualToString:@"device"]) {
            reason = LLang(@"您的设备已被封禁，无法继续使用！");
        } else {
            reason = LLang(@"您的账号已被管理员强制下线");
        }
    }

    // 仅 device 维度需要本机匹配
    if([matchType isEqualToString:@"device"] && matchValue.length > 0) {
        NSString *localDeviceId = [UIDevice getUUID];
        if(![matchValue isEqualToString:localDeviceId]) {
            return;
        }
    }
    // 防止短时间内重复弹窗（CMD 偶发重复）
    static BOOL forceLogoutTriggered = NO;
    static NSTimeInterval lastTriggerTime = 0;
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    
    // 如果距离上次触发超过30秒，重置状态
    if(forceLogoutTriggered && (currentTime - lastTriggerTime) > 30) {
        forceLogoutTriggered = NO;
    }
    
    if(forceLogoutTriggered) {
        return;
    }
    forceLogoutTriggered = YES;
    lastTriggerTime = currentTime;
    // 立即占位共享标志：之后到达的 onKick disconnect 包看到此标志会跳过自身弹窗，
    // 避免管理员封禁场景出现「您的IP已被封禁」与「账号已在其他设备上登录」两个提示重叠
    [QCApp shared].banDialogShowing = YES;

    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:LLang(@"账号已下线")
                                                                      message:reason
                                                               preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:LLang(@"我知道了")
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            [[QCApp shared] immediatelyLogout];
        }]];
        UIViewController *top = [QCNavigationManager shared].topViewController;
        if(top) {
            [top presentViewController:alert animated:YES completion:nil];
        } else {
            // 兜底：拿不到顶层 VC 时直接退出
            [[QCApp shared] immediatelyLogout];
        }
        
        // 设备封禁后重置触发状态，允许后续检查
        if([matchType isEqualToString:@"device"]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                forceLogoutTriggered = NO;
            });
        }
    });
}

// 播放消息发送成功的声音
-(void) playMessageSendOutSound {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
         static SystemSoundID soundID = 0;
        if (soundID == 0) {
            NSBundle *b=[QCApp.shared resourceBundle:@"WuKongBase"];
            
            NSString *path = [b pathForResource:@"sound_out" ofType:@"wav" inDirectory:@"Other"];
            if(path) {
                NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
                AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
            }
            
        }
        AudioServicesPlaySystemSound(soundID);
    });
}

#pragma mark - Device Status Check

// 主动检查设备状态
- (void)checkDeviceStatus {
    QCLogDebug(@"应用进入前台，检查设备状态");
    
    // 如果当前有连接，可能是网络恢复后的检查
    if([QCSDK shared].connectionManager.connectStatus == QCConnected) {
        // 延迟1秒后检查，避免过于频繁
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self performDeviceStatusCheck];
        });
    }
}

// 执行设备状态检查
- (void)performDeviceStatusCheck {
    // 这里可以向服务端发送一个状态检查请求
    // 或者依赖连接层面的踢出机制
    QCLogDebug(@"执行设备状态检查");
}

@end
