//
//  QCDB.h
//  WuKongIMSDK
//
//  Created by tt on 2019/11/27.
//

#import <Foundation/Foundation.h>
#import <fmdb/FMDB.h>
#import "QCFMDatabaseQueue.h"
//消息表
#define TB_MESSAGE @"message"

#define TB_STREAM @"stream"

NS_ASSUME_NONNULL_BEGIN

@interface QCDB : NSObject

@property (nonatomic, strong) QCFMDatabaseQueue *dbQueue;

+ (QCDB *)sharedDB;

/**
 切换用户的数据库

 @param uid 用户uid
 */
-(void) switchDB:(NSString*)uid;

/**
 是否需要切换数据库

 @param uid <#uid description#>
 @return <#return value description#>
 */
-(BOOL) needSwitchDB:(NSString*)uid;

@end

NS_ASSUME_NONNULL_END
