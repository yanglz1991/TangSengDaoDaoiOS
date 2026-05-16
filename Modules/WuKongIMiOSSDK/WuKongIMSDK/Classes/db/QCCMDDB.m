//
//  QCCMDDB.m
//  WuKongIMSDK-WuKongIMSDK
//
//  Created by tt on 2020/11/21.
//

// 获取cmd消息表中最大的message_seq
#define SQL_CMD_MAX_MESSAGESEQ [NSString stringWithFormat:@"select max(message_seq) message_seq from cmd"]

// 保存或更新消息
#define SQL_CMD_REPLACE [NSString stringWithFormat:@"insert into %@(message_id,message_seq,client_msg_no,timestamp,cmd,param) values(?,?,?,?,?,?) ON CONFLICT(client_msg_no) DO UPDATE SET cmd=excluded.cmd,param=excluded.param",@"cmd"]

// 获取cmd列表
#define SQL_CMD_LIST [NSString stringWithFormat:@"select * from cmd where is_deleted=0"]

#define SQL_CMD_DELETE_WITH_IDS [NSString stringWithFormat:@"update cmd set is_deleted=1 where id in "]

#import "QCCMDDB.h"
#import "QCDB.h"
#import "QCMessage.h"
#import "QCCMDContent.h"

@implementation QCCMDMessage

-(BOOL) same:(QCCMDMessage*)cmdMessage {
    if(cmdMessage) {
        return [cmdMessage.cmd isEqualToString:self.cmd] && [cmdMessage.param isEqualToString:self.param];
    }
    return false;
}

+(QCCMDMessage*) fromMessage:(QCMessage*)message {
    QCCMDMessage *cmdMessage = [QCCMDMessage new];
    cmdMessage.clientMsgNo = message.clientMsgNo;
    cmdMessage.messageId = message.messageId;
    cmdMessage.messageSeq = message.messageSeq;
    cmdMessage.timestamp = message.timestamp;
    
    QCCMDContent *cmdContent = (QCCMDContent*)message.content;
    cmdMessage.cmd = cmdContent.cmd;
    if(cmdContent.param) {
        NSData *paramData =  [NSJSONSerialization dataWithJSONObject:cmdContent.param options:kNilOptions error:nil];
        NSString *paramStr = [[NSString alloc] initWithData:paramData encoding:NSUTF8StringEncoding];
        cmdMessage.param = paramStr;
    }
    return cmdMessage;
}

@end

@implementation QCCMDDB


static QCCMDDB *_instance;
+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
+ (QCCMDDB *)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

-(uint32_t) getMaxMessageSeq {
    __block uint32_t maxMessageSeq;
    __weak typeof(self) weakSelf = self;
    [[QCDB sharedDB].dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        maxMessageSeq = [weakSelf getMaxMessageSeq:db];
    }];
    return maxMessageSeq;
}


-(uint32_t) getMaxMessageSeq:(FMDatabase*) db {
    uint32_t maxMessageSeq = 0;
    FMResultSet *resultSet = [db executeQuery:SQL_CMD_MAX_MESSAGESEQ];
     if(resultSet.next) {
        maxMessageSeq =  (uint32_t)[resultSet unsignedLongLongIntForColumn:@"message_seq"];
     }
     [resultSet close];
    return maxMessageSeq;
}


-(void) replaceCMDMessages:(NSArray<QCCMDMessage*>*)messages {
    [[QCDB sharedDB].dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        for (QCCMDMessage *message in messages) {
            NSString *cmd = message.cmd?:@"";
            NSString *paramStr = message.param?:@"";
           
            [db executeUpdate:SQL_CMD_REPLACE,@(message.messageId),@(message.messageSeq),message.clientMsgNo?:@"",@(message.timestamp),cmd,paramStr];
        }
    }];
}

-(NSArray<QCCMDMessage*>*) queryAllCMDMessages {
    NSMutableArray *items = [NSMutableArray array];
    [[QCDB sharedDB].dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *resultSet = [db executeQuery:SQL_CMD_LIST];
        while (resultSet.next) {
            [items addObject:[self toCMDMessage:resultSet]];
        }
        [resultSet close];
        
    }];
    return items;
}

-(void) deleteCMDMessagesWithIDs:(NSArray<NSNumber*>*) ids {
    if(!ids || ids.count<=0) {
        return;
    }
    [[QCDB sharedDB].dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        [db executeUpdate:[NSString stringWithFormat:@"%@ (%@)",SQL_CMD_DELETE_WITH_IDS,[ids componentsJoinedByString:@","]]];
    }];
}

-(QCCMDMessage*) toCMDMessage:(FMResultSet*)resultSet {
    QCCMDMessage *cmdMessage = [QCCMDMessage new];
    cmdMessage.mid = [resultSet intForColumn:@"id"];
    cmdMessage.clientMsgNo = [resultSet stringForColumn:@"client_msg_no"];
    cmdMessage.messageId = [resultSet unsignedLongLongIntForColumn:@"message_id"];
    cmdMessage.messageSeq = (uint32_t)[resultSet unsignedLongLongIntForColumn:@"message_seq"];
    cmdMessage.timestamp = [resultSet intForColumn:@"timestamp"];
    cmdMessage.cmd = [resultSet stringForColumn:@"cmd"];
    cmdMessage.param = [resultSet stringForColumn:@"param"];
    return cmdMessage;
}


@end
