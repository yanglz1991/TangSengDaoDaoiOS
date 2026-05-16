//
//  QCGroupManagerDelegateImp.m
//  QCData
//
//  Created by tt on 2020/1/19.
//

#import "QCGroupManagerDelegateImp.h"
#import "QCDataSourceModel.h"
@implementation QCGroupManagerDelegateImp


// 创建群聊
- (void)groupManager:(nonnull QCGroupManager *)manager createGroup:(nonnull NSArray<NSString *> *)members object:(id _Nullable)object complete:(void (^ _Nullable)(NSString * groupNo,NSError *error))complete {
    
    NSMutableArray *names = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    [[QCAPIClient sharedClient] POST:@"group/create" parameters:@{@"members":members?:@[],@"member_names":names} model:QCGroupModel.class].then(^(QCGroupModel *groupModel){
        if(complete) {
            [weakSelf updateChannelInfoByGroupModel:groupModel];
            complete(groupModel.groupNo,nil);
            
            [QCSDK.shared.channelManager fetchChannelInfo:[QCChannel groupWithChannelID:groupModel.groupNo]];
        }
    }).catch(^(NSError *error){
        if(complete) {
            complete(nil,error);
        }
    });
}

// 添加群成员
- (void)groupManager:(nonnull QCGroupManager *)manager groupNo:(nonnull NSString *)groupNo membersOfAdd:(nonnull NSArray<NSString *> *)members object:(id _Nullable)object complete:(void (^ _Nullable)(NSError * __nullable))complete {
    NSMutableArray *names = [NSMutableArray array];
    [[QCAPIClient sharedClient] POST:[NSString stringWithFormat:@"groups/%@/members",groupNo] parameters:@{@"members":members?:@[],@"names":names}].then(^{
        if(complete) {
            complete(nil);
        }
    }).catch(^(NSError *error){
        if(complete) {
            complete(error);
        }
    });
}

// 删除群成员
- (void)groupManager:(nonnull QCGroupManager *)manager groupNo:(nonnull NSString *)groupNo membersOfDelete:(nonnull NSArray<NSString *> *)members object:(id _Nullable)object complete:(void (^ _Nullable)(NSError * __nullable))complete {
    NSMutableArray *names = [NSMutableArray array];
    [[QCAPIClient sharedClient] DELETE:[NSString stringWithFormat:@"groups/%@/members",groupNo] parameters:@{@"members":members?:@[],@"names":names}].then(^{
        if(complete) {
            complete(nil);
        }
    }).catch(^(NSError *error){
        if(complete) {
            complete(error);
        }
    });
}

// 同步群成员
//
// 修复禁言/角色变更等成员属性更新后，CMD memberUpdate 触发同步但 UI 不及时生效的问题：
// 旧实现里 addOrUpdateMembers 通过 dispatch_async 异步落库，但上层 finish 立即回调
// → QCGroupManager 紧接着 dispatch_async(main, post QCNOTIFY_GROUP_MEMBERUPDATE)
// → QCConversationVM.handleMemberUpdate 主线程同步查 DB。
// global_queue 调度通常慢于 main_queue 的下一轮 runloop，导致读先于写到达 FMDB dbQueue
// （serial），VM 拿到旧成员数据，禁言状态不生效，需强退冷启动才能从 DB 取到新值。
//
// 新实现：用 dispatch_group 跟踪所有写 DB 任务，所有写完成后才回调 complete → 发通知 → VM 查 DB
// 一定能拿到最新数据。
- (void)groupManager:(nonnull QCGroupManager *)manager syncMemebers:(nonnull NSString *)groupNo complete:(void (^ _Nullable)(NSInteger syncMemberCount,NSError * __nullable error))complete {
    NSInteger limit = 10000;
    __block NSInteger memberCount = 0;
    dispatch_group_t dbWriteGroup = dispatch_group_create();
    [self requestSyncMembers:groupNo limit:limit maxRetryCount:50 complete:^(NSArray<QCChannelMember *> *members, NSError *error) {
        if(error) {
            QCLogError(@"群[%@]同步成员失败！->%@",groupNo,error);
            return;
        }
        memberCount+= members.count;
        // 异步落库的同时用 dispatch_group 占位，finish 必须等本次写完才能放行
        dispatch_group_enter(dbWriteGroup);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[QCSDK shared].channelManager addOrUpdateMembers:members];
            dispatch_group_leave(dbWriteGroup);
        });

    } finish:^{
        // 等待所有分页的 DB 写入全部完成，再回调 complete。
        // 上层 QCGroupManager 收到 complete 后才发 QCNOTIFY_GROUP_MEMBERUPDATE 通知，
        // 此时 QCConversationVM.handleMemberUpdate 查 DB 必拿到最新成员（含最新 forbidden_expir_time）。
        dispatch_group_notify(dbWriteGroup, dispatch_get_main_queue(), ^{
            if(complete) {
                complete(memberCount,nil);
            }
        });
    }];
    
    
}

-(void) requestSyncMembers:(NSString*)groupNo limit:(NSInteger)limit  maxRetryCount:(NSInteger)maxRetryCount complete:(void(^)(NSArray<QCChannelMember*>*members,NSError *error))complete finish:(void(^)(void))finish{
    __weak typeof(self) weakSelf = self;
    NSString *syncKey = [[QCSDK shared].channelManager getMemberLastSyncKey:[[QCChannel alloc] initWith:groupNo channelType:WK_GROUP]];
    [[QCAPIClient sharedClient] GET:[NSString stringWithFormat:@"groups/%@/membersync",groupNo] parameters:@{@"version":syncKey?:@"",@"limit":@(limit)} model:QCGroupMemberModel.class].then(^(NSArray<QCGroupMemberModel*> *members){
        NSLog(@"同步到成员数量[%ld]",members.count);
        if(members && members.count>0) {
            NSMutableArray<QCChannelMember*> *channelMembers = [NSMutableArray array];
            for (QCGroupMemberModel *groupMember in members) {
                [channelMembers addObject:[groupMember toChannelMember]];
            }
            if(complete) {
                complete(channelMembers,nil);
            }
            if(members.count >= limit && maxRetryCount>0) {
                [weakSelf requestSyncMembers:groupNo limit:limit  maxRetryCount:maxRetryCount-1 complete:complete finish:finish];
            }else {
                if(finish) {
                    finish();
                }
            }
            if(maxRetryCount<=0) {
                QCLogError(@"同步群[%@]成员已超过最大次数！",groupNo);
            }
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                [[QCSDK shared].channelManager addOrUpdateMembers:channelMembers];
//                if(complete) {
//                    complete(channelMembers,nil);
//                }
//            });
        }else {
            if(finish) {
                finish();
            }
        }
    }).catch(^(NSError *error){
        NSLog(@"同步群成员失败！->%@",error);
        if(complete) {
            complete(nil,error);
        }
        if(finish) {
            finish();
        }
    });
}

-(void) groupManager:(QCGroupManager*)manager searchMembers:(NSString*)groupNo keyword:(NSString*)keyword page:(NSInteger)page  limit:(NSInteger)limit complete:(void(^__nullable)(NSError * __nullable error,NSArray<QCChannelMember*>*members))complete {
    [[QCAPIClient sharedClient] GET:[NSString stringWithFormat:@"groups/%@/members",groupNo] parameters:@{@"keyword":keyword?:@"",@"limit":@(limit),@"page":@(page)} model:QCGroupMemberModel.class].then(^(NSArray<QCGroupMemberModel*> *members){
        NSMutableArray<QCChannelMember*> *channelMembers = [NSMutableArray array];
        if(members && members.count>0) {
            for (QCGroupMemberModel *groupMember in members) {
                [channelMembers addObject:[groupMember toChannelMember]];
            }
        }
        if(complete) {
            complete(nil,channelMembers);
        }
    }).catch(^(NSError *error){
        if(complete) {
            complete(error,nil);
        }
    });
}

-(void) updateChannelInfoByGroupModel:(QCGroupModel*)groupModel {
    QCChannelInfo *channelInfo = [[QCChannelInfo alloc] init];
    channelInfo.channel = [[QCChannel alloc] initWith:groupModel.groupNo channelType:WK_GROUP];
    channelInfo.name = groupModel.name;
    channelInfo.notice = groupModel.notice;
    channelInfo.mute = groupModel.mute;
    channelInfo.stick = groupModel.stick;
    channelInfo.showNick = groupModel.showNick;
    channelInfo.save = groupModel.save;
    channelInfo.forbidden = groupModel.forbidden;
    channelInfo.invite = groupModel.invite;
    channelInfo.receipt = groupModel.receipt;
    if(groupModel.avatar) {
        channelInfo.logo = groupModel.avatar;
    }else {
        channelInfo.logo = [NSString stringWithFormat:@"groups/%@/avatar",groupModel.groupNo];
    }
    [channelInfo setSettingValue:groupModel.forbiddenAddFriend forKey:QCChannelExtraKeyForbiddenAddFriend];
    [channelInfo setSettingValue:groupModel.screenshot forKey:QCChannelExtraKeyScreenshot];
    [channelInfo setSettingValue:groupModel.joinGroupRemind forKey:QCChannelExtraKeyJoinGroupRemind];
    [channelInfo setSettingValue:groupModel.revokeRemind forKey:QCChannelExtraKeyRevokeRemind];
    [channelInfo setSettingValue:groupModel.chatPwdOn forKey:QCChannelExtraKeyChatPwd];
    [channelInfo setSettingValue:groupModel.allowViewHistoryMsg forKey:QCChannelExtraKeyAllowViewHistoryMsg];
    
    [[QCSDK shared].channelManager addOrUpdateChannelInfo:channelInfo];
}

// 更新群信息
- (void)groupManager:(nonnull QCGroupManager *)manager syncGroupInfo:(nonnull NSString *)groupNo complete:(void (^ _Nullable)(NSError *error,bool notifyBefore))complete {
    __weak typeof(self) weakSelf = self;
    [[QCAPIClient sharedClient] GET:[NSString stringWithFormat:@"groups/%@",groupNo] parameters:nil model:QCGroupModel.class].then(^(QCGroupModel *groupModel){
        if(complete) {
            complete(nil,true);
        }
        [weakSelf updateChannelInfoByGroupModel:groupModel];
        if(complete) {
            complete(nil,false);
        }
    }).catch(^(NSError *error){
        if(complete) {
            complete(error,false);
        }
    });
}

- (NSURLSessionDataTask*)taskGroupManager:(nonnull QCGroupManager *)manager syncGroupInfo:(nonnull NSString *)groupNo complete:(void (^ _Nullable)(NSError *error,bool notifyBefore))complete {
    __weak typeof(self) weakSelf = self;
    return [[QCAPIClient sharedClient] taskGET:[NSString stringWithFormat:@"groups/%@",groupNo] parameters:nil model:QCGroupModel.class callback:^(NSError * _Nullable error, QCGroupModel *groupModel) {
        if(error) {
            if(complete) {
                complete(error,false);
            }
            return;
        }
        if(complete) {
            complete(nil,true);
        }
        [weakSelf updateChannelInfoByGroupModel:groupModel];
        if(complete) {
            complete(nil,false);
        }
    }];
}



- (void)groupManagerSetting:(nonnull QCGroupManager *)manager groupNo:(nonnull NSString *)groupNo settingKey:(QCGroupSettingKey)key on:(BOOL)on {
    NSString *keyStr = @"";
    switch (key) {
        case QCGroupSettingKeyMute:
            keyStr = @"mute";
            break;
        case QCGroupSettingKeyStick:
            keyStr = @"top";
            break;
        case QCGroupSettingKeySave:
            keyStr = @"save";
            break;
        case QCGroupSettingKeyShowNick:
            keyStr = @"show_nick";
            break;
        case QCGroupSettingKeyInvite:
            keyStr = @"invite";
            break;
        case QCGroupSettingKeyForbidden:
            keyStr = @"forbidden";
            break;
        case QCGroupSettingKeyForbiddenAddFriend:
            keyStr = @"forbidden_add_friend";
            break;
        case QCGroupSettingKeyScreenshot:
            keyStr = @"screenshot";
            break;
        case QCGroupSettingKeyRevokeRemind:
            keyStr = @"revoke_remind";
            break;
        case QCGroupSettingKeyJoinGroupRemind:
            keyStr = @"join_group_remind";
            break;
        case QCGroupSettingKeyChatPwdOn:
            keyStr = @"chat_pwd_on";
            break;
        case QCGroupSettingKeyReceipt:
            keyStr = @"receipt";
            break;
        case QCGroupSettingKeyAllowViewHistoryMsg:
            keyStr = @"allow_view_history_msg";
            break;
        case QCGroupSettingKeyFlame:
            keyStr = @"flame";
            break;
        default:
            break;
    }
    if([keyStr isEqualToString:@""]) {
        NSLog(@"key不能为空！");
        return;
    }
    // 调用群设置更新接口
    [self groupManagerSetting:manager groupNo:groupNo key:keyStr value:@(on?1:0)];
}

- (void)groupManagerSetting:(QCGroupManager *)manager groupNo:(NSString *)groupNo key:(NSString*)key value:(id)value {
    NSMutableDictionary *settingDict = [NSMutableDictionary dictionary];
    [settingDict setObject:value forKey:key];
    
    [[QCAPIClient sharedClient] PUT:[NSString stringWithFormat:@"groups/%@/setting",groupNo] parameters:settingDict].then(^{
//        if(settingDict[@"top"]) {
//            settingDict[@"stick"] = settingDict[@"top"];
//        }
//        QCChannel *channel = [[QCChannel alloc] initWith:groupNo channelType:WK_GROUP];
//        QCChannelInfo *channelInfo =  [[QCSDK shared].channelManager getChannelInfo:channel];
//        if(channelInfo) {
//            for (NSString *key in settingDict.allKeys) {
//                if([key isEqualToString:@"mute"]) { // 免打扰
//                    channelInfo.mute = [settingDict[key] boolValue];
//                }else if([key isEqualToString:@"stick"]) { // 置顶
//                    channelInfo.stick = [settingDict[key] boolValue];
//                } else if([key isEqualToString:@"show_nick"]) { // 置顶
//                    channelInfo.showNick = [settingDict[key] boolValue];
//                } else if([key isEqualToString:@"save"]) { // 保存
//                    channelInfo.save = [settingDict[key] boolValue];
//                } else if([key isEqualToString:@"invite"]) { // 确认邀请
//                    channelInfo.invite = [settingDict[key] boolValue];
//                }else if([key isEqualToString:@"forbidden"]) { // 禁言
//                    channelInfo.forbidden = [settingDict[key] boolValue];
//                }else if([key isEqualToString:@"receipt"]) { // 消息回执
//                    channelInfo.receipt = [settingDict[key] boolValue];
//                }else if([key isEqualToString:@"flame"]) { // 阅后即焚
//                    channelInfo.flame = [settingDict[key] boolValue];
//                }else {
//                    channelInfo.extra[key] = settingDict[key];
//                }
//            }
//            [[QCSDK shared].channelManager updateChannelInfo:channelInfo];
//        }
        
    });
}

-(AnyPromise*) groupSettingRemark:(QCGroupManager*)manager groupNo:(NSString*)groupNo remark:(NSString*)remark {
    // 调用群设置更新接口
  return  [[QCAPIClient sharedClient] PUT:[NSString stringWithFormat:@"groups/%@/setting",groupNo] parameters:@{@"remark":remark?:@""}].then(^{
        QCChannel *channel = [[QCChannel alloc] initWith:groupNo channelType:WK_GROUP];
        QCChannelInfo *channelInfo =  [[QCSDK shared].channelManager getChannelInfo:channel];
        if(channelInfo) {
            channelInfo.remark = remark;
            [[QCSDK shared].channelManager updateChannelInfo:channelInfo];
        }
    });
 
}

- (void)groupManagerUpdate:(nonnull QCGroupManager *)manager groupNo:(nonnull NSString *)groupNo attrKey:(nonnull NSString *)attrKey attrValue:(nonnull NSString *)attrValue complete:(nonnull void (^)(NSError * _Nullable))complete {
    [[QCAPIClient sharedClient] PUT:[NSString stringWithFormat:@"groups/%@",groupNo] parameters:@{attrKey:attrValue}].then(^{
        if(complete) {
            complete(nil);
        }
    }).catch(^(NSError *error){
        if(complete) {
            complete(error);
        }
    });
}
// 群成员更新
- (void)groupManager:(nonnull QCGroupManager *)manager didMemberUpdateAtGroup:(nonnull NSString *)groupNo forMemberUID:(nonnull NSString *)memberUID withAttr:(nonnull NSDictionary *)attr complete:(void (^ _Nullable)(NSError * _Nullable))complete {
    [[QCAPIClient sharedClient] PUT:[NSString stringWithFormat:@"groups/%@/members/%@",groupNo,memberUID] parameters:attr].then(^{
        if(complete) {
            complete(nil);
        }
    }).catch(^(NSError *error){
        if(complete) {
            complete(error);
        }
    });
}

// 退出群聊
- (void)groupManager:(QCGroupManager *)manager didGroupExit:(NSString *)groupNo complete:(void (^ _Nullable)(NSError * _Nullable))complete {
    [[QCAPIClient sharedClient] POST:[NSString stringWithFormat:@"groups/%@/exit",groupNo] parameters:nil].then(^{
        if(complete) {
            complete(nil);
        }
       }).catch(^(NSError *error){
           if(complete) {
               complete(error);
           }
           QCLogError(@"退出群聊失败！->%@",error);
       });
}

-(void) groupManager:(QCGroupManager*)manager didGroupDisband:(NSString*)groupNo complete:(void(^__nullable)(NSError *error))complete {
    [[QCAPIClient sharedClient] DELETE:[NSString stringWithFormat:@"groups/%@/disband",groupNo] parameters:nil].then(^{
        if(complete) {
            complete(nil);
        }
       }).catch(^(NSError *error){
           if(complete) {
               complete(error);
           }
           QCLogError(@"退出群聊失败！->%@",error);
       });
}

// 群成员设置为管理员
- (void)groupManager:(nonnull QCGroupManager *)manager groupNo:(nonnull NSString *)groupNo membersToManager:(nonnull NSArray<NSString *> *)members complete:(void (^ _Nullable)(NSError * _Nullable))complete {
    [[QCAPIClient sharedClient] POST:[NSString stringWithFormat:@"groups/%@/managers",groupNo] parameters:members].then(^{
           if(complete) {
               complete(nil);
           }
    }).catch(^(NSError *error){
        if(complete) {
          complete(error);
        }
        QCLogError(@"设置群管理员失败！->%@",error);
    });
}
// 将管理员设置为普通成员
- (void)groupManager:(nonnull QCGroupManager *)manager groupNo:(nonnull NSString *)groupNo managersToMember:(nonnull NSArray<NSString *> *)managers complete:(void (^ _Nullable)(NSError * _Nullable))complete {
    [[QCAPIClient sharedClient] DELETE:[NSString stringWithFormat:@"groups/%@/managers",groupNo] parameters:managers].then(^{
           if(complete) {
               complete(nil);
           }
    }).catch(^(NSError *error){
        if(complete) {
          complete(error);
        }
        QCLogError(@"设置为普通成员失败！->%@",error);
    });
}

// 群禁言
- (void)groupManager:(QCGroupManager *)manager group:(NSString *)groupNo forbidden:(BOOL)forbidden complete:(void (^)(NSError * _Nullable))complete {
    [[QCAPIClient sharedClient] POST:[NSString stringWithFormat:@"groups/%@/forbidden/%d",groupNo,forbidden?1:0] parameters:nil].then(^{
              // 设置成功后主动刷新频道信息
              QCChannel *channel = [[QCChannel alloc] initWith:groupNo channelType:WK_GROUP];
              [[QCSDK shared].channelManager fetchChannelInfo:channel];
              
              // 发送群成员更新通知，触发 UI 刷新禁言状态
              dispatch_async(dispatch_get_main_queue(), ^{
                  [[NSNotificationCenter defaultCenter] postNotificationName:QCNOTIFY_GROUP_MEMBERUPDATE object:@{@"group_no":groupNo}];
              });
              
              if(complete) {
                  complete(nil);
              }
       }).catch(^(NSError *error){
           if(complete) {
             complete(error);
           }
           QCLogError(@"设置为禁言失败！->%@",error);
       });
}

- (void)groupManager:(QCGroupManager *)manager group:(NSString *)groupNo forbiddenAddFriend:(BOOL)forbidden complete:(void (^)(NSError * _Nullable))complete {
    [[QCAPIClient sharedClient] POST:[NSString stringWithFormat:@"groups/%@/forbidden_add_friend/%d",groupNo,forbidden?1:0] parameters:nil].then(^{
              // 设置成功后主动刷新频道信息
              QCChannel *channel = [[QCChannel alloc] initWith:groupNo channelType:WK_GROUP];
              [[QCSDK shared].channelManager fetchChannelInfo:channel];
              
              // 发送群成员更新通知，触发 UI 刷新
              dispatch_async(dispatch_get_main_queue(), ^{
                  [[NSNotificationCenter defaultCenter] postNotificationName:QCNOTIFY_GROUP_MEMBERUPDATE object:@{@"group_no":groupNo}];
              });
              
              if(complete) {
                  complete(nil);
              }
       }).catch(^(NSError *error){
           if(complete) {
             complete(error);
           }
           QCLogError(@"设置为群内禁止加好友失败！->%@",error);
       });
}





@end
