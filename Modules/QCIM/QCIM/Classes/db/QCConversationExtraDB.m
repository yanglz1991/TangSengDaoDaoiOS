//
//  QCConversationExtraDB.m
//  QCIM
//
//  Created by tt on 2022/4/23.
//

#import "QCConversationExtraDB.h"
#import "QCDB.h"


#define SQL_ADD_UPDATE [NSString stringWithFormat:@"insert into %@( channel_id,channel_type,browse_to,keep_message_seq,keep_offset_y,`draft`,`version`) values(?,?,?,?,?,?,?) ON CONFLICT(channel_id,channel_type) DO UPDATE SET browse_to=excluded.browse_to,keep_message_seq=excluded.keep_message_seq,keep_offset_y=excluded.keep_offset_y,draft=excluded.draft,version=excluded.version",@"conversation_extra"]

#define SQL_MAX_VERSION [NSString stringWithFormat:@"select max(version) max_version from %@",@"conversation_extra"]

#define SQL_UPDATE_VERSION [NSString stringWithFormat:@"update %@ set version=? where channel_id=? and channel_type=? ",@"conversation_extra"]

@implementation QCConversationExtraDB

static QCConversationExtraDB *_instance;
+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
+ (QCConversationExtraDB *)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

-(void) updateVersion:(QCChannel*)channel version:(int64_t)version {
    [[QCDB sharedDB].dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        [db executeUpdate:SQL_UPDATE_VERSION,@(version),channel.channelId,@(channel.channelType)];
    }];
}

-(void) addOrUpdates:(NSArray<QCConversationExtra*>*)extras {
    if(!extras || extras.count==0) {
        return;
    }
    [[QCDB sharedDB].dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        for (QCConversationExtra *extra in extras) {
            [db executeUpdate:SQL_ADD_UPDATE,extra.channel.channelId,@(extra.channel.channelType),@(0),@(extra.keepMessageSeq),@(extra.keepOffsetY),extra.draft?:@"",@(extra.version)];
        }
    }];
}

-(NSString*) extraToStr:(NSDictionary*)extra {
    NSString *extraStr = @"";
    if(extra) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:extra options:kNilOptions error:nil];
        extraStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return extraStr;
}
-(int64_t) getMaxVersion {
    __block int64_t maxVersion = 0;
    [[QCDB sharedDB].dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:SQL_MAX_VERSION];
        if(result.next) {
            maxVersion = [result longLongIntForColumn:@"max_version"];
        }
        [result close];
    }];
    return maxVersion;
}

@end
