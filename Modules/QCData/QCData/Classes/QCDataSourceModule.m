//
//  QCDataSourceModule.m
//  QCData
//
//  Created by tt on 2019/12/27.
//

#import "QCDataSourceModule.h"
#import "QCFileUploadTask.h"
#import "QCFileDownloadTask.h"
#import "QCGroupManagerDelegateImp.h"
#import "QCMessageManagerDelegateImp.h"
#import <QCIM/QCMOSContentConvertManager.h>
#import <QCIM/QCReminderDB.h>
#import "QCChannelDataManagerDelegateImp.h"

@QCModule(QCDataSourceModule)

@interface QCDataSourceModule ()

@end

@implementation QCDataSourceModule



-(NSString*) moduleId {
    return @"QCDataSource";
}

// 模块初始化
- (void)moduleInit:(QCModuleContext*)context{
    NSLog(@"【QCDataSource】模块初始化！");
    // 设置频道资料更新函数
    [self setChannelInfoUpdate];
    // 离线消息提供者
    [self setOfflineMessageProvider];
    // 设置同步会话提供者
    [self setSyncConversationProvider];
    // 最近会话扩展
    [self setSyncConversationExtraProvider];
    [self setUpdateConversationExtraProvider];
    // 设置同步频道消息提供者
    [self setSyncChannelMessageProvider];
    // 扩展消息同步提供者
    [self setSyncMessageExtraProvider];
    // 设置消息扩展同步提供者
    // 设置上传任务提供者
    [self setUploadTaskProvider];
     // 设置下载任务提供者
    [self setDownloadTaskProvider];
    // 机器人提供者
    [self setRobotProvider];
  
    // 提醒项目提供者
    [self setReminderProvider];

    // 消息已读上报提供者（私聊已读回执）
    [self setMessageReadedProvider];
    
    // 群相关接口
    [[QCGroupManager shared] setDelegate:[QCGroupManagerDelegateImp new]];
    // 消息管理
    [[QCMessageManager shared] setDelegate:[QCMessageManagerDelegateImp new]];
    
    [QCChannelDataManager.shared setDelegate:[QCChannelDataManagerDelegateImp new]];
    
}

// 消息已读提供者，对应付费模块中的 message/readed 接口
-(void) setMessageReadedProvider {
    [[[QCSDK shared] receiptManager] setMessageReadedProvider:^(QCChannel *channel, NSArray<QCMessage *> * _Nonnull messages, QCMessageReadedCallback  _Nonnull callback) {
        // 仅私聊上报已读，群聊不开启已读回执
        if(channel.channelType != WK_PERSON) {
            if(callback) {
                callback(nil);
            }
            return;
        }
        NSMutableArray<NSString*> *messageIDS = [NSMutableArray array];
        if(messages.count > 0) {
            for (QCMessage *message in messages) {
                [messageIDS addObject:[NSString stringWithFormat:@"%llu", message.messageId]];
            }
        }
        [[QCAPIClient sharedClient] POST:@"message/readed" parameters:@{
            @"channel_id": channel.channelId ?: @"",
            @"channel_type": @(channel.channelType),
            @"message_ids": messageIDS,
        }].then(^{
            if(callback) {
                callback(nil);
            }
        }).catch(^(NSError *err){
            QCLogError(@"消息已读未读上报失败！-> %@", err);
            if(callback) {
                callback(err);
            }
        });
    }];
}

// 模块启动
-(BOOL) moduleDidFinishLaunching:(QCModuleContext *)context{
    return true;
}


// 给狸猫SDK提供上传任务
-(void) setUploadTaskProvider {
    [[QCSDK shared].mediaManager setUploadTaskProvider:^id<QCTaskProto> _Nonnull(QCMessage * _Nonnull message) {
        return [[QCFileUploadTask alloc] initWithMessage:message];
    }];
    
}
// 给狸猫SDK提供下载任务
-(void) setDownloadTaskProvider {
    
    [[QCSDK shared].mediaManager setDownloadTaskProvider:^id<QCTaskProto> _Nonnull(QCMessage * _Nonnull message) {
        return [[QCFileDownloadTask alloc] initWithMessage:message];
    }];
}

  // 设置频道资料更新函数
-(void) setChannelInfoUpdate {
    
    
    [[QCSDK shared] setChannelInfoUpdate:^QCTaskOperator * (QCChannel * _Nonnull channel, QCChannelInfoCallback  _Nonnull callback) {
        
        NSURLSessionDataTask *sessionDataTask = [[QCAPIClient sharedClient] taskGET:[NSString stringWithFormat:@"channels/%@/%d",channel.channelId,channel.channelType] parameters:nil callback:^(NSError * _Nullable error, NSDictionary  *resultDict) {
            if(error) {
                QCLogError(@"获取频道信息失败！-> %@",error);
                callback(error,false);
                return;
            }
            QCChannelInfo *channelInfo  = [QCChannelUtil toChannelInfo2:resultDict];
            
            [[QCSDK shared].channelManager addOrUpdateChannelInfo:channelInfo];
            if(callback) {
                callback(nil,false);
            }
            
        }];
        return [QCTaskOperator cancel:^{
            if(sessionDataTask) {
                [sessionDataTask cancel];
            }
            
        } suspend:^{
            if(sessionDataTask) {
                [sessionDataTask suspend];
            }
        } resume:^{
            if(sessionDataTask) {
                [sessionDataTask resume];
            }
        }];
    }];
    
    
    return;
}

-(void) setUpdateConversationExtraProvider {
    [[QCSDK shared].conversationManager setUpdateConversationExtraProvider:^(QCConversationExtra * _Nonnull extra, QCUpdateConversationExtraCallback  _Nonnull callback) {
        [[QCAPIClient sharedClient] POST:[NSString stringWithFormat:@"conversations/%@/%d/extra",extra.channel.channelId,extra.channel.channelType] parameters:@{
            @"keep_message_seq": @(extra.keepMessageSeq),
            @"keep_offset_y":@(extra.keepOffsetY),
            @"draft": extra.draft?:@"",
        }].then(^(NSDictionary *result){
            int64_t version = [result[@"version"] longLongValue];
            callback(version,nil);
        }).catch(^(NSError *error){
            callback(0,error);
        });
    }];
}

// 最近会话扩展提供者
-(void) setSyncConversationExtraProvider {
    
    [[QCSDK shared].conversationManager setSyncConversationExtraProvider:^(long long version, QCSyncConversationExtraCallback  _Nonnull callback) {
        [[QCAPIClient sharedClient] POST:@"conversation/extra/sync" parameters:@{
            @"version": @(version),
        }].then(^(NSArray *results){
            NSMutableArray<QCConversationExtra*> *extras = [NSMutableArray array];
            if(results && results.count>0) {
                for (NSDictionary *extraDict in results) {
                    [extras addObject:[self toConversationExtra:extraDict]];
                }
            }
            callback(extras,nil);
        }).catch(^(NSError *error){
            callback(nil,error);
        });
    }];
    
}



// 设置最近会话提供者
-(void) setSyncConversationProvider {
    [[QCSDK shared].conversationManager setSyncConversationProviderAndAck:^(long long version, NSString * _Nonnull lastMsgSeqs, QCSyncConversationCallback  _Nonnull callback) {
        [[QCAPIClient sharedClient] POST:@"conversation/sync" parameters:@{
            @"version": @(version),
            @"device_uuid": [QCApp shared].loginInfo.deviceUUID,
            @"last_msg_seqs": lastMsgSeqs?:@"",
            @"msg_count":@([QCApp shared].config.eachPageMsgLimit),
        }].then(^(NSDictionary* dict){
            
            // ---------- conversation  ----------
            NSArray<NSDictionary*>* conversationDicts = dict[@"conversations"];
            NSMutableArray<QCSyncConversationModel*> *syncConversationModels = [NSMutableArray array];
            if(conversationDicts && conversationDicts.count>0) {
                for (NSDictionary *conversationDict in conversationDicts) {
                    [syncConversationModels addObject:[self toSyncConversationModel:conversationDict]];
                }
            }
            
            QCSyncConversationWrapModel *wrapModel = [[QCSyncConversationWrapModel alloc] init];
            wrapModel.conversations = syncConversationModels;
            callback(wrapModel,nil);
        }).catch(^(NSError *err){
            callback(nil,err);
        });
    } ack:^(uint64_t cmdVersion, void (^ _Nullable complete)(NSError * _Nullable)) {
        [[QCAPIClient sharedClient] POST:@"conversation/syncack" parameters:@{
            @"cmd_version":@(cmdVersion),
            @"device_uuid": [QCApp shared].loginInfo.deviceUUID,
        }].then(^{
            complete(nil);
        }).catch(^(NSError *error){
            complete(error);
        });
        
    }];
}

-(void) setSyncChannelMessageProvider {
    
    [QCSDK.shared.chatManager setSyncChannelMessageProvider:^(QCChannel * _Nonnull channel, uint32_t startMessageSeq, uint32_t endMessageSeq, NSInteger limit, QCPullMode pullMode, QCSyncChannelMessageCallback  _Nonnull callback) {
        [[QCAPIClient sharedClient] POST:@"message/channel/sync" parameters:@{
            @"device_uuid": [QCApp shared].loginInfo.deviceUUID,
            @"channel_id":channel.channelId?:@"",
            @"channel_type": @(channel.channelType),
            @"start_message_seq": @(startMessageSeq),
            @"end_message_seq": @(endMessageSeq),
            @"limit": @(limit),
            @"pull_mode": @(pullMode),
        }].then(^(NSDictionary *dict){
            QCSyncChannelMessageModel *model = [QCSyncChannelMessageModel new];
            model.startMessageSeq = (uint32_t)[dict[@"start_message_seq"] unsignedLongLongValue];
            model.endMessageSeq = (uint32_t)[dict[@"end_message_seq"] unsignedLongLongValue];
            
            NSArray<NSDictionary*> *messageDicts = dict[@"messages"];
            if(messageDicts && messageDicts.count>0) {
                NSMutableArray *messages = [NSMutableArray array];
                for (NSDictionary *messageDict in messageDicts) {
                    [messages addObject:[QCMessageUtil toMessage:messageDict]];
                }
                model.messages = messages;
            }
            callback(model,nil);
            
        }).catch(^(NSError *err){
            callback(nil,err);
        });
    }];
}

// 设置离线消息提供者
-(void) setOfflineMessageProvider {
    // 离线消息提供者
    [[QCSDK shared] setOfflineMessageProvider:^(int limit, uint32_t messageSeq, QCOfflineMessageCallback  _Nonnull callback) {
        [[QCAPIClient sharedClient] POST:[NSString stringWithFormat:@"message/sync"] parameters:@{@"max_message_seq":@(messageSeq),@"limit":@(limit)}].then(^(NSArray<NSDictionary*>* messageDicts){
            NSMutableArray *messages = [[NSMutableArray alloc] init];
            if(messageDicts && messageDicts.count>0) {
                for (NSDictionary *messageDict  in messageDicts) {
                    @try {
                         QCMessage *message =  [QCMessageUtil toMessage:messageDict];
                         if(message) {
                            [messages addObject:message];
                         }
                    } @catch (NSException *exception) {
                        QCLogError(@"转换离线消息时出现异常-%@",exception);
                    }
                   
                }
                callback(messages,true,nil); // 这里不能判断返回数据小于limit(count>=limit)就没有更多了, 因为有可能服务器遇到解析不出消息里的payload而服务器会丢掉此消息 这样返回数据小于limit但是服务器还有离线消息
            }else {
                callback(messages,false,nil);
            }
        }).catch(^(NSError *err){
            QCLogError(@"拉取离线消息失败！-> %@",err);
            callback(nil,false,err);
        });
    } offlineMessagesAck:^(uint32_t messageSeq, void (^ _Nonnull complete)(NSError *error)) {
        [[QCAPIClient sharedClient] POST:[NSString stringWithFormat:@"message/syncack/%d",messageSeq] parameters:nil].then(^{
            if(complete) {
                complete(nil);
            }
        }).catch(^(NSError *err){
            QCLogError(@"离线消息回执失败！-> %@",err);
            if(complete) {
                complete(err);
            }
        });
    }];
}


-(void)  setSyncMessageExtraProvider {
//    __weak typeof(self) weakSelf = self;
    [[[QCSDK shared] chatManager] setSyncMessageExtraProvider:^(QCChannel * _Nonnull channel, long long extraVersion,NSInteger limit, QCSyncMessageExtraCallback  _Nonnull callback) {
        [[QCAPIClient sharedClient] POST:@"message/extra/sync" parameters:@{
            @"channel_id": channel.channelId?:@"",
            @"channel_type":@(channel.channelType),
            @"extra_version": @(extraVersion),
            @"limit": @(limit),
            @"source":[QCApp shared].loginInfo.deviceUUID?:@"",
        }].then(^(NSArray<NSDictionary*> *results){
            NSMutableArray<QCMessageExtra*> *messageExtras = [NSMutableArray array];
            for (NSDictionary *result in results) {
                [messageExtras addObject:[QCMessageUtil toMessageExtra:result channel:channel]];
            }
            callback(messageExtras,nil);
        }).catch(^(NSError *err){
            QCLogError(@"获取消息扩展失败！-> %@",err);
            callback(nil,err);
        });
    }];
}

-(void) setReminderProvider {
    __weak typeof(self) weakSelf = self;
    [[QCSDK shared].reminderManager setReminderProvider:^(QCReminderCallback  _Nonnull callback) {
        NSMutableArray *channelIDs = [NSMutableArray array];
        NSArray<QCConversation*> *conversations = [[QCSDK shared].conversationManager getConversationList];
        if(conversations && conversations.count>0) {
            for (QCConversation *conversation in conversations) {
                if(conversation.channel.channelType == WK_GROUP) {
                    [channelIDs addObject:conversation.channel.channelId];
                }
            }
        }
        int64_t maxVersion = [[QCReminderDB shared] getMaxVersion];
        [[QCAPIClient sharedClient] POST:@"message/reminder/sync" parameters:@{
            @"version":@(maxVersion),
            @"limit": @(1000),
            @"channel_ids": channelIDs,
        }].then(^(NSArray *results){
            if(results && results.count>0) {
                NSMutableArray<QCReminder*> *reminders = [NSMutableArray array];
                for (NSDictionary *result in results) {
                    [reminders addObject:[weakSelf toReminder:result]];
                }
                callback(reminders,nil);
            }
        }).catch(^(NSError *error){
            callback(nil,error);
        });
    }];
    
    [[QCSDK shared].reminderManager setReminderDoneProvider:^(NSArray<NSNumber *> * _Nonnull ids, QCReminderDoneCallback  _Nonnull callback) {
        [[QCAPIClient sharedClient] POST:@"message/reminder/done" parameters:ids].then(^{
            callback(nil);
        }).catch(^(NSError *error){
            callback(error);
        });
    }];
}


-(void) setRobotProvider {
    __weak typeof(self) weakSelf = self;
    [[QCSDK shared].robotManager setSyncRobotProvider:^(NSArray<NSDictionary *> * _Nonnull robotVersionDicts, QCSyncRobotCallback  _Nonnull callback) {
        [[QCAPIClient sharedClient] POST:@"robot/sync" parameters:robotVersionDicts].then(^(NSArray<NSDictionary*>*results){
            NSMutableArray<QCRobot*> *robots = [NSMutableArray array];
            if(results && results.count>0) {
                for (NSDictionary *result in results) {
                    [robots addObject:[weakSelf toRobot:result]];
                }
            }
            callback(robots,nil);
        }).catch(^(NSError *error){
            callback(nil,error);
        });
    }];
}

-(QCRobot*) toRobot:(NSDictionary*)dict {
    QCRobot *robot = [QCRobot new];
    robot.robotID = dict[@"robot_id"]?:@"";
    robot.version = [dict[@"version"] longValue];
    robot.status = [dict[@"status"] integerValue];
    robot.inlineOn = dict[@"inline_on"]?[dict[@"inline_on"] boolValue]:false;
    robot.placeholder = dict[@"placeholder"]?:@"";
    robot.username = dict[@"username"]?:@"";
    NSArray<NSDictionary*> *menusDicts = dict[@"menus"];
    if(menusDicts && menusDicts.count>0) {
        NSMutableArray<QCRobotMenus*> *menusList = [NSMutableArray array];
        for (NSDictionary *menusDict in menusDicts) {
            QCRobotMenus *menus = [QCRobotMenus new];
            menus.cmd = menusDict[@"cmd"]?:@"";
            menus.remark = menusDict[@"remark"]?:@"";
            menus.type = menusDict[@"type"]?:@"";
            menus.robotID = robot.robotID;
            [menusList addObject:menus];
        }
        robot.menus = menusList;
    }
    return robot;
}

-(QCSyncConversationModel*) toSyncConversationModel:(NSDictionary*)dataDict {
    QCSyncConversationModel *model = [QCSyncConversationModel new];
    NSInteger  channelType = [dataDict[@"channel_type"] integerValue];
    NSString *channelID = dataDict[@"channel_id"];
    model.channel = [[QCChannel alloc] initWith:channelID channelType:channelType];
    
    if(model.channel.channelType == WK_COMMUNITY_TOPIC) {
        NSArray<NSString*> *parentChannels =  [model.channel.channelId componentsSeparatedByString:@"@"];
        if(parentChannels && parentChannels.count>0) {
            NSString *parentChannelID = parentChannels[0];
            if(parentChannelID && ![parentChannelID isEqualToString:@""]) {
                model.parentChannel = [QCChannel channelID:parentChannelID channelType:WK_COMMUNITY];
            }
        }
    }
    model.unread =[dataDict[@"unread"] integerValue];
    model.timestamp = [dataDict[@"timestamp"] doubleValue];
    model.lastMsgSeq = (uint32_t)[dataDict[@"last_msg_seq"] unsignedLongValue];
    model.lastMsgClientNo = dataDict[@"last_client_msg_no"];
    model.version = [dataDict[@"version"] longLongValue];
    model.stick = dataDict[@"stick"]?[dataDict[@"stick"] boolValue]:false;
    model.mute = dataDict[@"mute"]?[dataDict[@"mute"] boolValue]:false;
    
    if(dataDict[@"extra"]) {
        model.remoteExtra = [self toConversationExtra:dataDict[@"extra"]];
    }
    
    NSArray<NSDictionary*> *messageDicts = dataDict[@"recents"];
    if(messageDicts && messageDicts.count>0) {
        NSMutableArray *messages = [NSMutableArray array];
        for (NSDictionary *messageDict in messageDicts) {
            [messages addObject:[QCMessageUtil toMessage:messageDict]];
        }
        model.recents = messages.reverseObjectEnumerator.allObjects;
    }
    return model;
}

-(QCConversationExtra*) toConversationExtra:(NSDictionary*)dataDict {
    QCConversationExtra *extra = [[QCConversationExtra alloc] init];
    NSInteger  channelType = [dataDict[@"channel_type"] integerValue];
    NSString *channelID = dataDict[@"channel_id"];
    extra.channel = [[QCChannel alloc] initWith:channelID channelType:channelType];
    if(dataDict[@"keep_message_seq"]) {
        extra.keepMessageSeq = (uint32_t)[dataDict[@"keep_message_seq"] unsignedLongLongValue];
    }
    if(dataDict[@"keep_offset_y"]) {
        extra.keepOffsetY = [dataDict[@"keep_offset_y"] integerValue];
    }
    if(dataDict[@"draft"]) {
        extra.draft = [dataDict[@"draft"] stringValue];
    }
    if(dataDict[@"version"]) {
        extra.version = [dataDict[@"version"] longLongValue];
    }
   
    return extra;
}

-(QCReminder*) toReminder:(NSDictionary*)dataDict {
    QCReminder *reminder = [[QCReminder alloc] init];
    reminder.reminderID = [dataDict[@"id"] longLongValue];
    NSInteger  channelType = [dataDict[@"channel_type"] integerValue];
    NSString *channelID = dataDict[@"channel_id"];
    reminder.channel = [[QCChannel alloc] initWith:channelID channelType:channelType];
    
    if(dataDict[@"message_id"]) {
        NSDecimalNumber* messageIDNumber = [[NSDecimalNumber alloc] initWithString:dataDict[@"message_id"]];
        reminder.messageId = [messageIDNumber unsignedLongLongValue];
    }
    if(dataDict[@"message_seq"]) {
        reminder.messageSeq = (uint32_t)[dataDict[@"message_seq"] unsignedLongValue];
    }
    reminder.type = [dataDict[@"reminder_type"] integerValue];
    if(dataDict[@"text"]) {
        reminder.text = dataDict[@"text"];
    }
    if(dataDict[@"data"]) {
        reminder.data = dataDict[@"data"];
    }
    if(dataDict[@"is_locate"]) {
        reminder.isLocate = [dataDict[@"is_locate"] boolValue];
    }
    if(dataDict[@"version"]) {
        reminder.version = [dataDict[@"version"] longLongValue];
    }
    if(dataDict[@"done"]) {
        reminder.done = [dataDict[@"done"] boolValue];
    }
    if(dataDict[@"publisher"]) {
        reminder.publisher = dataDict[@"publisher"];
    }
    
    return reminder;
}



@end
