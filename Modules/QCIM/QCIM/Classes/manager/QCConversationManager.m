//
//  QCConversationManager.m
//  QCIM
//
//  Created by tt on 2019/11/29.
//

#import "QCConversationManager.h"
#import "QCDB.h"
#import "QCConversationDB.h"
#import "QCSDK.h"
#import "QCConversationUtil.h"
#import "QCMessageDB.h"
#import "QCReactionDB.h"
#import "QCReminderDB.h"
#import "QCConversationExtraDB.h"
@interface QCConversationManager ()
/**
 *  用来存储所有添加j过的delegate
 *  NSHashTable 与 NSMutableSet相似，但NSHashTable可以持有元素的弱引用，而且在对象被销毁后能正确地将其移除。
 */
@property (strong, nonatomic) NSHashTable  *delegates;
/**
 *  delegateLock 用于给delegate的操作加锁，防止多线程同时调用
 */
@property (strong, nonatomic) NSLock  *delegateLock;

@end

@implementation QCConversationManager


- (void)setSyncConversationProviderAndAck:(QCSyncConversationProvider)syncConversationProvider ack:(QCSyncConversationAck)syncConversationAck {
    _syncConversationProvider = syncConversationProvider;
    _syncConversationAck = syncConversationAck;
}

-(QCConversationAddOrUpdateResult*) addOrUpdateConversation:(QCConversation*)cs incUnreadCount:(NSInteger)unUnreadCount{
    __block BOOL isInsert = false;
    __block BOOL modify = false;
    __block QCConversation *blockConversation;
    [[QCDB sharedDB].dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        QCConversation *conversation =  [[QCConversationDB shared] getConversationWithChannelInAll:cs.channel db:db];
        if(conversation) {
            
            conversation.unreadCount +=unUnreadCount ;
            if([self needUpdate:cs old:conversation]) { // (cs.lastMessageInner.messageSeq应该是发送的消息) 当前最近会话的最后一条消息的messageSeq小于更新的messageSeq才更新
                conversation.lastClientMsgNo = cs.lastClientMsgNo;
                conversation.lastMsgTimestamp = cs.lastMsgTimestamp;
                conversation.lastMessageSeq = cs.lastMessageInner.messageSeq;
                conversation.lastMessageInner = cs.lastMessageInner;
    //                conversation.isDeleted = cs.isDeleted;
//                [conversation.reminderManager mergeReminders:cs.reminderManager.reminders];
                modify = true;
            }
            
            if(unUnreadCount>0) {
                modify = true;
            }
            if(modify) {
                [[QCConversationDB shared] updateConversation:conversation db:db];
            }
            blockConversation = conversation;
            isInsert = false;
        }else {
            cs.unreadCount = unUnreadCount;
            [[QCConversationDB shared] insertConversation:cs db:db];
             blockConversation = cs;
            isInsert = true;
            modify = true;
        }
    }];
    return [QCConversationAddOrUpdateResult initWithInsert:isInsert modify:modify conversation:blockConversation];
}

-(BOOL) needUpdate:(QCConversation*)newConversation old:(QCConversation*)oldConversation {
    if(!newConversation.lastMessageInner) {
        return false;
    }
    uint32_t newOrderSeq = newConversation.lastMessageInner.orderSeq;
    uint32_t oldOrderSeq = [[QCSDK shared].chatManager getOrderSeq:oldConversation.lastMessageSeq];
    if(newOrderSeq>oldOrderSeq) {
        return true;
    }
    return false;
}

- (void)addConversation:(QCConversation *)conversation {
    [[QCConversationDB shared] addConversation:conversation];
}

-(void) recoveryConversation:(QCChannel*)channel {
   QCConversation *conversation = [[QCConversationDB shared] recoveryConversation:channel];
    if(conversation) {
        [self callOnConversationDeleteDelegate:conversation.channel];
    }
}

- (QCConversation *)getConversation:(QCChannel *)channel {
    QCConversation *conversation = [[QCConversationDB shared] getConversation:channel];
    conversation.reminders = [[QCReminderDB shared] getWaitDoneReminder:conversation.channel];
    return conversation;
}

-(NSArray<QCConversation*>*) getConversations:(NSArray<QCChannel*>*)channels {
   NSArray<QCConversation*> *conversations = [[QCConversationDB shared] getConversations:channels];
    if(!conversations || conversations.count == 0) {
        return conversations;
    }
    
    NSDictionary<QCChannel*,NSArray<QCReminder*>*> *reminderDicts = [QCReminderDB.shared getWaitDoneReminders:channels];
    for (QCConversation *conversation in conversations) {
        if(reminderDicts) {
            conversation.reminders = reminderDicts[conversation.channel];
        }
    }
    return conversations;
}

- (QCConversationAddOrUpdateResult *)addOrUpdateConversation:(QCConversation *)cs {
    return [self addOrUpdateConversation:cs incUnreadCount:0];
}
//
//-(QCConversation*) appendReminder:(QCReminder*) reminder channel:(QCChannel*)channel {
//    QCConversation *conversation = [[QCConversationDB shared] appendReminder:reminder channel:channel];
//    if(conversation) {
//        // 调用委托
//        [self callOnConversationUpdateDelegate:conversation];
//    }
//    return conversation;
//}
//
//-(QCReminder*) getReminder:(QCReminderType)type channel:(QCChannel*)channel {
//    QCConversation *conversation = [[QCConversationDB shared] getConversation:channel];
//    if(conversation && conversation.reminderManager.reminders && conversation.reminderManager.reminders.count>0) {
//        for (QCReminder *reminder in conversation.reminderManager.reminders) {
//            if(reminder.type == type) {
//                return reminder;
//            }
//        }
//    }
//    return nil;
//}

-(void) clearConversationUnreadCount:(QCChannel*)channel {
    // 清除指定频道消息未读数
    [[QCConversationDB shared] clearConversationUnreadCount:channel];
    // 通知UI层
    [self callOnConversationUnreadCountUpdateDelegate:channel unreadCount:0];
}

-(void) setConversationUnreadCount:(QCChannel*)channel unread:(NSInteger)unread {
    // 设置指定频道消息未读数
       [[QCConversationDB shared] setConversationUnreadCount:channel unread:unread];
    // 通知UI层
       [self callOnConversationUnreadCountUpdateDelegate:channel unreadCount:unread];
}

-(void) deleteConversation:(QCChannel*)channel {
    // 删除z最近会话
    [[QCConversationDB shared] deleteConversation:channel];
    // 通知UI层
    [self callOnConversationDeleteDelegate:channel];
}
//
//-(void)  removeReminder:(QCReminderType) type channel:(QCChannel*)channel {
//    QCConversation *conversation = [[QCConversationDB shared] removeReminder:type channel:channel];
//    // 调用委托
//    if(conversation) {
//        [self callOnConversationUpdateDelegate:conversation];
//    }
//}
//
//-(void) clearAllReminder:(QCChannel*)channel {
//     QCConversation *conversation = [[QCConversationDB shared] clearAllReminder:channel];
//    // 调用委托
//    if(conversation) {
//        [self callOnConversationUpdateDelegate:conversation];
//    }
//}

//-(void) updateConversation:(QCChannel*)channel title:(NSString*)title avatar:(NSString*) avatar {
//    if(channel.channelType == WK_PERSON) {
//        // 获取收取人的用户信息
//        __block QCUserInfo *toUserInfo;
//        [QCSDK shared].userInfoProvider(channel.channelId, ^(QCUserInfo * _Nonnull userInfo) {
//            if(userInfo) {
//                
//            }
//        });
//    }
//}

-(NSArray<QCConversation*>*) getConversationList {
   NSArray<QCConversation*> *conversations =  [[QCConversationDB shared] getConversationList];
    if(conversations && conversations.count>0) {
       NSDictionary<QCChannel*,NSArray<QCReminder*>*> *reminderDict = [[QCReminderDB shared] getAllWaitDoneReminders];
        if(reminderDict) {
            for (QCConversation *conversation in conversations) {
                conversation.reminders = reminderDict[conversation.channel];
            }
        }
    }
    return conversations;
}

-(void) handleSyncConversation:(QCSyncConversationWrapModel*)model {
    
    NSArray<QCSyncConversationModel*> *syncConversations = model.conversations;
    // ########## 存储会话所有消息 ##########
    NSMutableArray *messages = [NSMutableArray array];
    if(syncConversations && syncConversations.count>0) {
        for (QCSyncConversationModel *syncConversationModel in syncConversations) {
            if(syncConversationModel.recents && syncConversationModel.recents.count>0) {
                [messages addObjectsFromArray:syncConversationModel.recents];
            }

        }
    }
    if(messages.count>0) {
        [[QCMessageDB shared] replaceMessages:messages];
    }
   
    // ########## 存储所有会话 ##########
    NSMutableArray<QCConversation*> *conversations = [NSMutableArray array];
    for (QCSyncConversationModel *syncConversationModel in syncConversations) {
        if(syncConversationModel.recents && syncConversationModel.recents.count>0) {
            [conversations addObject:syncConversationModel.conversation];
        }
        
    }

    if(conversations.count>0) {
        NSMutableArray<QCChannel*> *channels = [NSMutableArray array];
        for (QCConversation *conversation in conversations) {
            [channels addObject:conversation.channel];
        }
        NSDictionary *reminderDict = [[QCReminderDB shared] getWaitDoneReminders:channels];
        if(reminderDict) {
            for (QCConversation *conversation in conversations) {
                conversation.reminders = reminderDict[conversation.channel];
            }
        }
        [[QCConversationDB shared] replaceConversations:conversations];
        [self callOnConversationUpdateDelegates:conversations];
    }
    
    
}

-(void) syncExtra {
    if(!self.syncConversationExtraProvider) {
        NSLog(@"###########没有syncConversationExtraProvider###########");
        return;
    }
    int64_t version = [[QCConversationExtraDB shared] getMaxVersion];
    __weak typeof(self) weakSelf = self;
    self.syncConversationExtraProvider(version, ^(NSArray<QCConversationExtra *> * _Nullable extras, NSError * _Nullable error) {
        if(error) {
            NSLog(@"同步最近会话扩展失败！->%@",error);
            return;
        }
        [[QCConversationExtraDB shared] addOrUpdates:extras];
        [weakSelf updateConversationExtras:extras];
    });
}

-(void) updateOrAddExtra:(QCConversationExtra*)extra {
    if(!extra) {
        return;
    }
    
    [[QCConversationExtraDB shared] addOrUpdates:@[extra]];
    if(!self.updateConversationExtraProvider) {
        NSLog(@"###########没有updateConversationExtraProvider###########");
        return;
    }
    QCConversation *conversation = [[QCConversationDB shared] getConversation:extra.channel];
    if(!conversation) {
        return;
    }
    conversation.reminders = [[QCReminderDB shared] getWaitDoneReminder:conversation.channel];
    conversation.remoteExtra = extra;
    [self callOnConversationUpdateDelegate:conversation];
    
    self.updateConversationExtraProvider(extra, ^(int64_t version, NSError * _Nullable error) {
        if(error) {
            NSLog(@"更新最近会话扩展失败！->%@",error);
            return;
        }
        [[QCConversationExtraDB shared] updateVersion:extra.channel version:version];
    });
    
    
    
}

-(void) updateConversationExtras:(NSArray<QCConversationExtra*>*)converstionExtras {
    if(!converstionExtras || converstionExtras.count == 0) {
        return;
    }
    NSMutableArray *channels = [NSMutableArray array];
    NSMutableDictionary *conversationExtraDict = [NSMutableDictionary dictionary];
    for (QCConversationExtra *extra in converstionExtras) {
        [channels addObject:extra.channel];
        conversationExtraDict[extra.channel] = extra;
    }
    NSDictionary<QCChannel*,NSArray<QCReminder*>*> *reminderDict = [[QCReminderDB shared] getWaitDoneReminders:channels];
    NSArray<QCConversation*> *conversations = [[QCConversationDB shared] getConversations:channels];
    if(conversations && conversations.count>0) {
        for (QCConversation *conversation in conversations) {
            QCConversationExtra *extra = conversationExtraDict[conversation.channel];
            if(extra) {
                conversation.remoteExtra = extra;
            }
            if(reminderDict) {
                conversation.reminders = reminderDict[conversation.channel];
            }
        }
        [self callOnConversationUpdateDelegates:conversations];
    }
}


/**
 获取所有会话未读数量
 */
-(NSInteger) getAllConversationUnreadCount {
    return [[QCConversationDB shared] getAllConversationUnreadCount];
}

-(void) addDelegate:(id<QCConversationManagerDelegate>) delegate{
    [self.delegateLock lock];//防止多线程同时调用
    [self.delegates addObject:delegate];
    [self.delegateLock unlock];
}
- (void)removeDelegate:(id<QCConversationManagerDelegate>) delegate {
    [self.delegateLock lock];//防止多线程同时调用
    [self.delegates removeObject:delegate];
    [self.delegateLock unlock];
}

- (NSLock *)delegateLock {
    if (_delegateLock == nil) {
        _delegateLock = [[NSLock alloc] init];
    }
    return _delegateLock;
}

-(NSHashTable*) delegates {
    if (_delegates == nil) {
        _delegates = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return _delegates;
}


- (void)callOnConversationUpdateDelegate:(QCConversation *)conversation {
    [self callOnConversationUpdateDelegates:@[conversation]];
}

- (void)callOnConversationUpdateDelegates:(NSArray<QCConversation*>*)conversations {
    [self.delegateLock lock];
    NSHashTable *copyDelegates =  [self.delegates copy];
    [self.delegateLock unlock];
    for (id delegate in copyDelegates) {//遍历delegates ，call delegate
        if (delegate && [delegate respondsToSelector:@selector(onConversationUpdate:)]) {
            if (![NSThread isMainThread]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                   [delegate onConversationUpdate:conversations];
                });
            }else {
                [delegate onConversationUpdate:conversations];
            }
            
        }
    }
}

- (void)callOnConversationUnreadCountUpdateDelegate:(QCChannel*)channel unreadCount:(NSInteger)unreadCount{
    [self.delegateLock lock];
    NSHashTable *copyDelegates =  [self.delegates copy];
    [self.delegateLock unlock];
    for (id delegate in copyDelegates) {//遍历delegates ，call delegate
        if (delegate && [delegate respondsToSelector:@selector(onConversationUnreadCountUpdate:unreadCount:)]) {
            if (![NSThread isMainThread]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate onConversationUnreadCountUpdate:channel unreadCount:unreadCount];
                });
            }else {
                [delegate onConversationUnreadCountUpdate:channel unreadCount:unreadCount];
            }
            
        }
    }
}


- (void)callOnConversationDeleteDelegate:(QCChannel*)channel{
    [self.delegateLock lock];
    NSHashTable *copyDelegates =  [self.delegates copy];
    [self.delegateLock unlock];
    for (id delegate in copyDelegates) {//遍历delegates ，call delegate
        if (delegate && [delegate respondsToSelector:@selector(onConversationDelete:)]) {
            if (![NSThread isMainThread]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate onConversationDelete:channel];
                });
            }else {
                [delegate onConversationDelete:channel];
            }
        }
    }
}

- (void)callOnConversationAllDeleteDelegate{
    [self.delegateLock lock];
    NSHashTable *copyDelegates =  [self.delegates copy];
    [self.delegateLock unlock];
    for (id delegate in copyDelegates) {//遍历delegates ，call delegate
        if (delegate && [delegate respondsToSelector:@selector(onConversationAllDelete)]) {
            if (![NSThread isMainThread]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate onConversationAllDelete];
                });
            }else {
                [delegate onConversationAllDelete];
            }
            
        }
    }
}


@end
