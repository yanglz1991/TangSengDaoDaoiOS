//
//  QCConversationDB.m
//  QCIM
//
//  Created by tt on 2019/11/29.
//

#import "QCConversationDB.h"
#import "QCDB.h"
#import "QCConversationUtil.h"
#define SQL_EXIST @"select count(*) cn from conversation where channel_id=? and channel_type=? and is_deleted=0"

#define SQL_GET_SELECT @"conversation.*,IFNULL(channel.stick,0) stick,IFNULL(channel.mute,0) mute,IFNULL(conversation_extra.browse_to,0) browse_to,IFNULL(conversation_extra.keep_message_seq,0) keep_message_seq,IFNULL(conversation_extra.keep_offset_y,0) keep_offset_y,IFNULL(conversation_extra.draft,'') draft,IFNULL(conversation_extra.version,0) extra_version"

#define SQL_GET [NSString stringWithFormat:@"select %@ from conversation left join channel on conversation.channel_id=channel.channel_id and conversation.channel_type=channel.channel_type left join conversation_extra on conversation.channel_id=conversation_extra.channel_id and conversation.channel_type=conversation_extra.channel_type   where conversation.channel_id=? and conversation.channel_type=? and conversation.is_deleted=0",SQL_GET_SELECT]

#define SQL_GET_WITH_CHANNELS [NSString stringWithFormat:@"select %@ from conversation left join channel on conversation.channel_id=channel.channel_id and conversation.channel_type=channel.channel_type left join conversation_extra on conversation.channel_id=conversation_extra.channel_id and conversation.channel_type=conversation_extra.channel_type   where conversation.is_deleted=0 and conversation.channel_id in ",SQL_GET_SELECT]

// 把channel里的stick和mute查询出来 为了防止排序conversation的时候去循环获取频道信息，最近会话过多会导致卡顿
#define SQL_GET_IN_ALL [NSString stringWithFormat:@"select %@ from conversation left join channel on conversation.channel_id=channel.channel_id and conversation.channel_type=channel.channel_type left join conversation_extra on conversation.channel_id=conversation_extra.channel_id and conversation.channel_type=conversation_extra.channel_type  where conversation.channel_id=? and conversation.channel_type=?",SQL_GET_SELECT]

#define SQL_ALL [NSString stringWithFormat:@"select %@ from conversation left join channel on conversation.channel_id=channel.channel_id and conversation.channel_type=channel.channel_type left join conversation_extra on conversation.channel_id=conversation_extra.channel_id and conversation.channel_type=conversation_extra.channel_type where conversation.is_deleted=0 order by conversation.last_msg_timestamp desc,conversation.id desc",SQL_GET_SELECT]

#define SQL_INSERT @"insert into conversation(channel_id,channel_type,parent_channel_id,parent_channel_type,avatar,last_client_msg_no,last_message_seq,last_msg_timestamp,unread_count,extra,version,is_deleted) values(?,?,?,?,?,?,?,?,?,?,?,?)"

#define SQL_REPLACE @"insert into conversation(channel_id,channel_type,parent_channel_id,parent_channel_type,avatar,last_client_msg_no,last_message_seq,last_msg_timestamp,unread_count,extra,version,is_deleted) values(?,?,?,?,?,?,?,?,?,?,?,?) ON CONFLICT(channel_id,channel_type) DO UPDATE SET parent_channel_id=excluded.parent_channel_id,parent_channel_type=excluded.parent_channel_type,last_client_msg_no=excluded.last_client_msg_no,last_message_seq=excluded.last_message_seq,last_msg_timestamp=excluded.last_msg_timestamp,unread_count=excluded.unread_count,version=excluded.version,is_deleted=excluded.is_deleted"

// 更新最新消息
#define SQL_UPDATE_LASTMSG @"update conversation set last_client_msg_no=?,last_message_seq=?,last_msg_timestamp=?,unread_count=?,is_deleted=0 where channel_id=? and channel_type=?"
// 更新用户标题
#define SQL_UPDATE_TITLEANDAVATAR @"update conversation set title=?,avatar=? where channel_id=? and channel_type=?"
// 清空频道未读消息数量
#define SQL_CLEAR_UNREADCOUNT @"update conversation set unread_count=0 where channel_id=? and channel_type=?"
// 设置频道未读消息数量
#define SQL_SET_UNREADCOUNT @"update conversation set unread_count=? where channel_id=? and channel_type=?"
// 更新提醒字段
#define SQL_UPDATE_REMINDERS @"update conversation set reminders=? where channel_id=? and channel_type=?"
// 通过最后一条消息的编号获取消息
#define SQL_GET_WITH_LASTCLIENTMSGNO [NSString stringWithFormat:@"select %@ from conversation left join channel on conversation.channel_id=channel.channel_id and conversation.channel_type=channel.channel_type left join conversation_extra on conversation.channel_id=conversation_extra.channel_id and conversation.channel_type=conversation_extra.channel_type  where conversation.last_client_msg_no=? and conversation.is_deleted=0",SQL_GET_SELECT]
// 所有会话未读数量
#define SQL_GET_ALL_UNREADCOUNT @"select sum(unread_count) unreadCount from conversation where is_deleted=0"
// 删除最近会话
#define SQL_DELETE_CONVERSATION @"update conversation set is_deleted=1 where channel_id=? and channel_type=?"
// 删除所有最近会话
#define SQL_DELETE_ALL_CONVERSATION @"delete from conversation"
// 恢复最近会话
#define SQL_RECOVERY_CONVERSATION @"update conversation set is_deleted=0 where channel_id=? and channel_type=?"

//获取会话最大版本
#define SQL_MAX_VERSION @"select IFNULL(MAX(version),0) version from conversation where version <> ''"

// 获取同步key
#define SQL_SYNC_KEY @"select GROUP_CONCAT(channel_id||':'||channel_type||':'||last_msg_seq,'|') synckey from (select *,(select max(message_seq) from message where message.channel_id=conversation.channel_id and message.channel_type= conversation.channel_type and message.content_type<>0 and message.content_type<>? limit 1) last_msg_seq from conversation) cn where channel_id<>''"

// 更新预览至
#define SQL_UPDATE_BROWSETO @"update conversation set browse_to=? where channel_id=? and channel_type=?"

@implementation QCConversationDB

static QCConversationDB *_instance;
+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
+ (QCConversationDB *)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

-(void) addOrUpdateConversation:(QCConversation*)conversation{
    [[QCDB sharedDB].dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        bool exist = [self existConversation:conversation.channel db:db];
        if(exist) {
            [self updateConversation:conversation db:db];
        }else{
             [self insertConversation:conversation db:db];
        }
    }];
}

-(void) replaceConversations:(NSArray<QCConversation*>*)conversations {
    if(!conversations || conversations.count<=0) {
        return;
    }
   
    [[QCDB sharedDB].dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        for (QCConversation *conversation in conversations) {
            NSString *parentChannelID  = conversation.parentChannel?conversation.parentChannel.channelId:@"";
            uint8_t parentChannelType = conversation.parentChannel?conversation.parentChannel.channelType:0;
            NSString *extraStr = [self extraToStr:conversation.extra];
            [db executeUpdate:SQL_REPLACE,conversation.channel.channelId,@(conversation.channel.channelType),parentChannelID,@(parentChannelType),conversation.avatar?:@"",conversation.lastClientMsgNo?:@"",@(conversation.lastMessageSeq),@(conversation.lastMsgTimestamp),@(conversation.unreadCount),extraStr,@(conversation.version),@(conversation.isDeleted)];
        }
    }];
}

-(void) addConversation:(QCConversation*)conversation {
    [[QCDB sharedDB].dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        [self insertConversation:conversation db:db];
    }];
}

-(void) insertConversation:(QCConversation*)conversation db:(FMDatabase*)db{
    NSString *extraStr = [self extraToStr:conversation.extra];
    NSString *parentChannelID  = conversation.parentChannel?conversation.parentChannel.channelId:@"";
    uint8_t parentChannelType = conversation.parentChannel?conversation.parentChannel.channelType:0;
    [db executeUpdate:SQL_INSERT,conversation.channel.channelId,@(conversation.channel.channelType),parentChannelID,@(parentChannelType),conversation.avatar?:@"",conversation.lastClientMsgNo?:@"",@(conversation.lastMessageSeq),@(conversation.lastMsgTimestamp),@(conversation.unreadCount),@(conversation.version),extraStr,@(conversation.isDeleted)];
}

-(void) clearConversationUnreadCount:(QCChannel*)channel {
    [[QCDB sharedDB].dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        [db executeUpdate:SQL_CLEAR_UNREADCOUNT,channel.channelId,@(channel.channelType)];
    }];
}

-(void) setConversationUnreadCount:(QCChannel*)channel unread:(NSInteger)unread {
    [[QCDB sharedDB].dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        [db executeUpdate:SQL_SET_UNREADCOUNT,@(unread),channel.channelId,@(channel.channelType)];
    }];
}

-(void) deleteConversation:(QCChannel*)channel {
    [[QCDB sharedDB].dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        [db executeUpdate:SQL_DELETE_CONVERSATION,channel.channelId?:@"",@(channel.channelType)];
    }];
}

-(void) deleteAllConversation {
    [[QCDB sharedDB].dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        [db executeUpdate:SQL_DELETE_ALL_CONVERSATION];
    }];
}


//-(QCConversation*) appendReminder:(QCReminder*) reminder channel:(QCChannel*)channel {
//    __block QCConversation *conversation;
//    [[QCDB sharedDB].dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
//        conversation = [self getConversationWithChannel:channel db:db];
//        if(conversation) {
//            [conversation.reminderManager appendReminder:reminder];
//            [db executeUpdate:SQL_UPDATE_REMINDERS,[self remindersToStr:conversation.reminderManager.reminders],channel.channelId,@(channel.channelType)];
//        }
//    }];
//    return conversation;
//}
//
//-(QCConversation*) removeReminder:(QCReminderType)type channel:(QCChannel*)channel {
//    __block QCConversation *conversation;
//    [[QCDB sharedDB].dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
//        conversation = [self getConversationWithChannel:channel db:db];
//        if(conversation) {
//            [conversation.reminderManager removeReminder:type];
//            [db executeUpdate:SQL_UPDATE_REMINDERS,[self remindersToStr:conversation.reminderManager.reminders],channel.channelId,@(channel.channelType)];
//        }
//    }];
//    return conversation;
//}
//
//-(QCConversation*) clearAllReminder:(QCChannel*)channel {
//    __block QCConversation *conversation;
//    [[QCDB sharedDB].dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
//        conversation = [self getConversationWithChannel:channel db:db];
//        if(conversation) {
//            [db executeUpdate:SQL_UPDATE_REMINDERS,@"",channel.channelId,@(channel.channelType)];
//            conversation.reminderManager.reminders = [NSMutableArray array];
//        }
//    }];
//    return conversation;
//}
//
//- (QCConversation *)clearReminder:(QCChannel *)channel type:(NSInteger)type {
//    __block QCConversation *conversation;
//    [[QCDB sharedDB].dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
//        conversation = [self getConversationWithChannel:channel db:db];
//        if(conversation) {
//            [self removeReminderForType:conversation.reminderManager.reminders type:type];
//            [db executeUpdate:SQL_UPDATE_REMINDERS,[self remindersToStr:conversation.reminderManager.reminders],channel.channelId,@(channel.channelType)];
//        }
//    }];
//    return conversation;
//}

-(NSInteger) getAllConversationUnreadCount {
    __block NSInteger unreadCount;
    [[QCDB sharedDB].dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *resultSet = [db executeQuery:SQL_GET_ALL_UNREADCOUNT];
        if(resultSet.next) {
           unreadCount = [resultSet intForColumn:@"unreadCount"];
        }
        [resultSet close];
    }];
    return unreadCount;
}

-(void) updateBrowseTo:(uint32_t)browseTo forChannel:(QCChannel*)channel {
    [[QCDB sharedDB].dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        [db executeUpdate:SQL_UPDATE_BROWSETO,@(browseTo),channel.channelId,@(channel.channelType)];
    }];
}

-(void) removeReminderForType:(NSMutableArray*)reminders type:(NSInteger)type {
    if(!reminders || reminders.count<=0) {
        return;
    }
    for (NSInteger i = reminders.count - 1; i >= 0; i--) { // 逆序删除 防止出错
         QCReminder *reminder = reminders[i];
        if (reminder.type == type) {
            [reminders removeObject:reminder];
        }
    }
}

-(void) updateConversation:(QCConversation*)conversation db:(FMDatabase*)db{
    [db executeUpdate:SQL_UPDATE_LASTMSG,conversation.lastClientMsgNo?:@"",@(conversation.lastMessageSeq),@(conversation.lastMsgTimestamp),@(conversation.unreadCount),conversation.channel.channelId,@(conversation.channel.channelType)];
}

-(void) updateConversation:(QCConversation*)conversation{
    [[QCDB sharedDB].dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        [self updateConversation:conversation db:db];
    }];
}

-(void) updateConversation:(QCChannel*)channel title:(NSString*)title avatar:(NSString*) avatar db:(FMDatabase*)db {
    [db executeUpdate:SQL_UPDATE_TITLEANDAVATAR,title?:@"",avatar?:@"",channel.channelId?:@"",@(channel.channelType)];
}


-(NSArray<QCConversation*>*) getConversationList {
    __block NSMutableArray<QCConversation*> *items = [NSMutableArray new];
    [[QCDB sharedDB].dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:SQL_ALL];
        while (result.next) {
           [items addObject:[self toConversation:result.resultDictionary]];
        }
        [result close];
    }];
    return items;
}

-(QCConversation*) getConversation:(QCChannel*)channel{
     __block QCConversation *conversation;
    [[QCDB sharedDB].dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result =[db executeQuery:SQL_GET,channel.channelId,@(channel.channelType)];
        if (result.next) {
            conversation =  [self toConversation:result.resultDictionary];
        }
        [result close];
    }];
    return conversation;
}

-(NSArray<QCConversation*>*) getConversations:(NSArray<QCChannel*> *)channels {
    if(!channels||channels.count == 0) {
        return nil;
    }
    NSMutableArray *channelIDs = [NSMutableArray array];
    for (QCChannel *channel in channels) {
        [channelIDs addObject:channel.channelId];
    }
    NSString *inquery = @"";
    for (NSInteger i=0; i<channelIDs.count; i++) {
        NSString *channelID = channelIDs[i];
        if(i == channels.count-1) {
            inquery = [NSString stringWithFormat:@"%@'%@'",inquery,channelID];
        }else {
            inquery = [NSString stringWithFormat:@"%@'%@',",inquery,channelID];
        }
        
    }
    __block NSMutableArray<QCConversation*> *conversations = [NSMutableArray array];
    [[QCDB sharedDB].dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *resultSet =  [db executeQuery:[NSString stringWithFormat:@"%@ (%@)",SQL_GET_WITH_CHANNELS,inquery]];
        while (resultSet.next) {
            QCConversation *conversation = [self toConversation:resultSet.resultDictionary];
            BOOL exist = false;
            for (QCChannel *channel in channels) {
                if([channel isEqual:conversation.channel]) {
                    exist = true;
                    break;
                }
            }
            if(exist) {
                [conversations addObject:conversation];
            }
        }
        [resultSet close];
    }];
    
    return conversations;
    
}


-(QCConversation*) recoveryConversation:(QCChannel*)channel {
     __block QCConversation *conversation;
    [[QCDB sharedDB].dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:SQL_GET_IN_ALL,channel.channelId,@(channel.channelType)];
        if (result.next) {
            conversation =  [self toConversation:result.resultDictionary];
        }
        [result close];
        if(conversation) {
            conversation.isDeleted = 0;
            [db executeUpdate:SQL_RECOVERY_CONVERSATION,channel.channelId,@(channel.channelType)];
        }
    }];
    return conversation;
}

-(QCConversation*) getConversationWithLastClientMsgNo:(NSString*)lastClientMsgNo {
     __block QCConversation *conversation;
    [[QCDB sharedDB].dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result =  [db executeQuery:SQL_GET_WITH_LASTCLIENTMSGNO,lastClientMsgNo?:@""];
        if (result.next) {
            conversation =  [self toConversation:result.resultDictionary];
        }
        [result close];
    }];
    return conversation;
}

-(QCConversation*) getConversationWithChannel:(QCChannel*)channel db:(FMDatabase*)db{
    FMResultSet *result =[db executeQuery:SQL_GET,channel.channelId,@(channel.channelType)];
    QCConversation *conversation;
    if (result.next) {
        conversation =  [self toConversation:result.resultDictionary];
    }
    [result close];
    return conversation;
}

-(QCConversation*) getConversationWithChannelInAll:(QCChannel*)channel db:(FMDatabase*)db{
    FMResultSet *result =[db executeQuery:SQL_GET_IN_ALL,channel.channelId,@(channel.channelType)];
    QCConversation *conversation;
    if (result.next) {
        conversation =  [self toConversation:result.resultDictionary];
    }
    [result close];
    return conversation;
}

-(NSString*) extraToStr:(NSDictionary*)extra {
    NSString *extraStr = @"";
    if(extra) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:extra options:kNilOptions error:nil];
        extraStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return extraStr;
}


-(BOOL) existConversation:(QCChannel*)channel db:(FMDatabase*)db{
    FMResultSet *result = [db executeQuery:SQL_EXIST,channel.channelId,@(channel.channelType)];
    __block BOOL isExit=false;
    if(result.next){
        NSDictionary *resultDic = result.resultDictionary;
        isExit = [resultDic[@"cn"] integerValue]>0?YES:NO;
    }
    [result close];
    return isExit;
}

-(long long) getConversationMaxVersion {
    __block long long version =0;
    [[QCDB sharedDB].dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:SQL_MAX_VERSION];
        if(result.next){
            NSDictionary *resultDic = result.resultDictionary;
            version = [resultDic[@"version"] longLongValue];
        }
        [result close];
    }];
    return version;
}

-(NSString*) getConversationSyncKey {
    __block NSString *syncKey = @"";
    [[QCDB sharedDB].dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        
        FMResultSet *result = [db executeQuery:SQL_SYNC_KEY,@(WK_CMD)];
        if(result.next){
            NSDictionary *resultDic = result.resultDictionary;
            if(resultDic[@"synckey"] && ![resultDic[@"synckey"] isKindOfClass:[NSNull class]]) {
                syncKey = resultDic[@"synckey"];
            }
            
        }
        [result close];
    }];
    return syncKey;
}

-(QCConversation*) toConversation:(NSDictionary*)dict {
    QCConversation *conversation = [QCConversation new];
    conversation.channel = [[QCChannel alloc] initWith:dict[@"channel_id"] channelType:[dict[@"channel_type"] integerValue]];
    if(dict[@"parent_channel_id"] && ![dict[@"parent_channel_id"] isEqualToString:@""]) {
        conversation.parentChannel = [QCChannel channelID:dict[@"parent_channel_id"] channelType:[dict[@"parent_channel_type"] integerValue]];
    }
    conversation.avatar = dict[@"avatar"];
    conversation.lastClientMsgNo = dict[@"last_client_msg_no"];
    conversation.lastMessageSeq = [dict[@"last_message_seq"] unsignedIntValue];
    conversation.lastMsgTimestamp = [dict[@"last_msg_timestamp"] integerValue];
    conversation.unreadCount = [dict[@"unread_count"] integerValue];
    conversation.version = [dict[@"version"] longLongValue];
    conversation.mute = [dict[@"mute"] boolValue];
    conversation.stick = [dict[@"stick"] boolValue];
    NSString *extraStr = dict[@"extra"];
    __autoreleasing NSError *error = nil;
    NSDictionary *extraDictionary = [NSJSONSerialization JSONObjectWithData:[extraStr dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    if(!error) {
        conversation.extra = extraDictionary;
    }
    conversation.remoteExtra.channel = conversation.channel;
    if(dict[@"keep_message_seq"]) {
        conversation.remoteExtra.keepMessageSeq = [dict[@"keep_message_seq"] unsignedIntValue];
    }
    if(dict[@"keep_offset_y"]) {
        conversation.remoteExtra.keepOffsetY = [dict[@"keep_offset_y"] integerValue];
    }
    if(dict[@"draft"]) {
        conversation.remoteExtra.draft = dict[@"draft"];
    }
    if(dict[@"extra_version"]) {
        conversation.remoteExtra.version = [dict[@"extra_version"] longLongValue];
    }
    
    return conversation;
}

@end

@implementation QCConversationAddOrUpdateResult

+(instancetype) initWithInsert:(BOOL)insert modify:(BOOL)modify conversation:(QCConversation*)conversation {
    QCConversationAddOrUpdateResult *result = [QCConversationAddOrUpdateResult new];
    result.insert = insert;
    result.conversation = conversation;
    result.modify = modify;
    return result;
}

@end
