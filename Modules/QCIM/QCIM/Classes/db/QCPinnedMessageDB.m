//
//  QCPinnedMessageDB.m
//  QCIM
//
//  Created by tt on 2024/5/22.
//

#import "QCPinnedMessageDB.h"
#import "QCDB.h"

// 根据频道查询
#define SQL_PINNED_MESSAGE_GET_WITH_CHANNEL [NSString stringWithFormat:@"select * from %@ where channel_id=? and channel_type=? and is_deleted=0",@"pinned_message"]

// 获取频道最大版本号
#define SQL_PINNED_MESSAGE_MAX_VERSION_WITH_CHANNEL [NSString stringWithFormat:@"select max(version) version from %@ where channel_id=? and channel_type=?",@"pinned_message"]

// 通过消息id获取置顶消息
#define SQL_PINNED_MESSAGE_GET_WITH_MESSAGEID [NSString stringWithFormat:@"select * from %@ where message_id=? and is_deleted=0",@"pinned_message"]

// 通过消息id获取置顶消息
#define SQL_PINNED_MESSAGE_HAS_WITH_MESSAGEID [NSString stringWithFormat:@"select count(*) cn from %@ where message_id=? and is_deleted=0",@"pinned_message"]

// 根据频道删除置顶消息
#define SQL_PINNED_MESSAGE_DELETE_WITH_CHANNEL [NSString stringWithFormat:@"update %@ set is_deleted=1 where channel_id=? and channel_type=?",@"pinned_message"]

// 根据消息id删除置顶消息
#define SQL_PINNED_MESSAGE_DELETE_WITH_MESSAGE_ID [NSString stringWithFormat:@"update %@ set is_deleted=1 where message_id=?",@"pinned_message"]

// 添加或更新置顶消息
#define SQL_PINNED_MESSAGE_ADD_OR_UPDATE [NSString stringWithFormat:@"insert into pinned_message( message_id,message_seq,channel_id,channel_type,version,is_deleted) values(?,?,?,?,?,?) ON CONFLICT(message_id) DO UPDATE SET version=excluded.version,is_deleted=excluded.is_deleted"]

@implementation QCPinnedMessageDB


static QCPinnedMessageDB *_instance;
+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
+ (QCPinnedMessageDB *)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

-(NSArray<QCPinnedMessage*>*) getPinnedMessagesByChannel:(QCChannel*)channel {
    
    __block NSMutableArray *pinnedMessages = [NSMutableArray array];
    [QCDB.sharedDB.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *resultSet = [db executeQuery:SQL_PINNED_MESSAGE_GET_WITH_CHANNEL,channel.channelId?:@"",@(channel.channelType)];
        while (resultSet.next) {
            [pinnedMessages addObject:[self toPinnedMessage:resultSet]];
        }
        [resultSet close];
    }];
    
    return pinnedMessages;
}

-(uint64_t) getMaxVersion:(QCChannel*)channel {
    __block uint64_t version = 0;
    [QCDB.sharedDB.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *resultSet = [db executeQuery:SQL_PINNED_MESSAGE_MAX_VERSION_WITH_CHANNEL,channel.channelId?:@"",@(channel.channelType)];
        if (resultSet.next) {
            version = [resultSet unsignedLongLongIntForColumn:@"version"];
        }
        [resultSet close];
    }];
    return version;
}

-(void) deletePinnedByChannel:(QCChannel*)channel {
    [QCDB.sharedDB.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
         [db executeUpdate:SQL_PINNED_MESSAGE_DELETE_WITH_CHANNEL,channel.channelId?:@"",@(channel.channelType)];
    }];
}

-(void) deletePinnedByMessageId:(uint64_t)messageId {
    [QCDB.sharedDB.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        [db executeUpdate:SQL_PINNED_MESSAGE_DELETE_WITH_MESSAGE_ID,@(messageId)];
    }];
}

-(void) addOrUpdatePinnedMessages:(NSArray<QCPinnedMessage*>*)messages {
    if(!messages || messages.count==0) {
        return;
    }
    [QCDB.sharedDB.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        for (QCPinnedMessage *message in messages) {
            [db executeUpdate:SQL_PINNED_MESSAGE_ADD_OR_UPDATE,@(message.messageId),@(message.messageSeq),message.channel.channelId?:@"",@(message.channel.channelType),@(message.version),@(message.isDeleted)];
        }
    }];
}

-(QCPinnedMessage*) getPinnedMessageByMessageId:(uint64_t)messageId {
    __block QCPinnedMessage *message;
    [QCDB.sharedDB.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *resultSet = [db executeQuery:SQL_PINNED_MESSAGE_GET_WITH_MESSAGEID,@(messageId)];
        if (resultSet.next) {
            message = [self toPinnedMessage:resultSet];
        }
        [resultSet close];
    }];
    return message;
}

-(BOOL) hasPinned:(uint64_t)messageId {
    __block BOOL has = false;
    [QCDB.sharedDB.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *resultSet = [db executeQuery:SQL_PINNED_MESSAGE_HAS_WITH_MESSAGEID,@(messageId)];
        if (resultSet.next) {
            has = [resultSet intForColumn:@"cn"]>0;
        }
        [resultSet close];
    }];
    return has;
}

-(QCPinnedMessage*) toPinnedMessage:(FMResultSet*)resultSet{
    QCPinnedMessage *msg = [QCPinnedMessage new];
    msg.messageId = [resultSet unsignedLongLongIntForColumn:@"message_id"];
    msg.messageSeq = (uint32_t)[resultSet longLongIntForColumn:@"message_seq"];
    
    NSString *channelId = [resultSet stringForColumn:@"channel_id"];
    int channelType = [resultSet intForColumn:@"channel_type"];
    
    QCChannel *channel = [QCChannel channelID:channelId channelType:channelType];
    msg.channel = channel;
    msg.isDeleted = [resultSet boolForColumn:@"is_deleted"];
    msg.version = [resultSet unsignedLongLongIntForColumn:@"version"];
    
    return msg;
}
@end
