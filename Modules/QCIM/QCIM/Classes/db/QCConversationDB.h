//
//  QCConversationDB.h
//  QCIM
//
//  Created by tt on 2019/11/29.
//

#import <Foundation/Foundation.h>
#import "QCConversation.h"
#import "QCDB.h"
NS_ASSUME_NONNULL_BEGIN
@class QCConversationAddOrUpdateResult;
@interface QCConversationDB : NSObject

+ (QCConversationDB *)shared;


/**
 添加或修改最近会话

 @param conversation <#conversation description#>
 */
-(void) addOrUpdateConversation:(QCConversation*)conversation;


/// 取代最近会话
/// @param conversations <#conversation description#>
-(void) replaceConversations:(NSArray<QCConversation*>*)conversations;


/// 添加最近会话信息
/// @param conversation <#conversation description#>
-(void) addConversation:(QCConversation*)conversation;


/// 恢复指定会话
/// @param channel <#channel description#>
/// @return 如果存在会话的会话则返回，不存在则返回nil
-(QCConversation*) recoveryConversation:(QCChannel*)channel;

/**
 查询指定频道的最近会话

 @param channel <#channel description#>
 @param db <#db description#>
 @return <#return value description#>
 */
-(QCConversation*) getConversationWithChannel:(QCChannel*)channel db:(FMDatabase*)db;

/// 查询指定频道的最近会话（包含is_deleted=1的频道）
/// @param channel 指定频道
/// @param db <#db description#>
-(QCConversation*) getConversationWithChannelInAll:(QCChannel*)channel db:(FMDatabase*)db;

/**
 查询频道类的最近会话数据

 @return <#return value description#>
 */
-(NSArray<QCConversation*>*) getConversationList;


/**
 获取最近会话

 @param channel 频道
 @return <#return value description#>
 */
-(QCConversation*) getConversation:(QCChannel*)channel;

// 通过频道集合获取最近会话集合
-(NSArray<QCConversation*>*) getConversations:(NSArray<QCChannel*> *)channels;


/**
 通过最后一条消息的客户端序号获取最近会话

 @param lastClientMsgNo 最后一条消息的编号
 @return <#return value description#>
 */
-(QCConversation*) getConversationWithLastClientMsgNo:(NSString*)lastClientMsgNo;



/// 获取会话最大数据版本号
-(long long) getConversationMaxVersion;


/// 获取同步key
-(NSString*) getConversationSyncKey;
/**
 更新最近会话

 @param conversation <#conversation description#>
 */
-(void) updateConversation:(QCConversation*)conversation;
/**
 更新最近会话

 @param conversation <#conversation description#>
 @param db <#db description#>
 */
-(void) updateConversation:(QCConversation*)conversation db:(FMDatabase*)db;


/**
 插入最近会话

 @param conversation <#conversation description#>
 @param db <#db description#>
 */
-(void) insertConversation:(QCConversation*)conversation db:(FMDatabase*)db;


/**
 清除指定频道的未读消息

 @param channel <#channel description#>
 */
-(void) clearConversationUnreadCount:(QCChannel*)channel;



/// 设置最近会话未读数
/// @param channel 频道
/// @param unread 未读数量
-(void) setConversationUnreadCount:(QCChannel*)channel unread:(NSInteger)unread;


/// 删除指定频道的最近会话
/// @param channel 频道对象
-(void) deleteConversation:(QCChannel*)channel;

/// 删除所有最近会话
-(void) deleteAllConversation;
/**
 更新最近会话的标题和头像

 @param channel <#channel description#>
 @param title <#title description#>
 @param avatar <#avatar description#>
 @param db <#db description#>
 */
-(void) updateConversation:(QCChannel*)channel title:(NSString*)title avatar:(NSString*) avatar db:(FMDatabase*)db;


//
///**
// 追加提醒
//
// @param reminder 提醒项
// @param channel 频道
// @return 追加后的z最近会话
// */
//-(QCConversation*) appendReminder:(QCReminder*) reminder channel:(QCChannel*)channel;
//
//
///**
// 移除某种类型的提醒
//
// @param type <#type description#>
// @param channel <#channel description#>
// @return <#return value description#>
// */
//-(QCConversation*) removeReminder:(QCReminderType)type channel:(QCChannel*)channel;
//
///**
//清除指定频道的所有提醒
//
// @param channel 频道
// @return <#return value description#>
// */
//-(QCConversation*) clearAllReminder:(QCChannel*)channel;
//
//
///**
// 清除指定频道指定类型的提醒
//
// @param channel 频道
// @param type 提醒类型
// @return <#return value description#>
// */
//-(QCConversation*) clearReminder:(QCChannel*)channel type:(NSInteger)type;
//

/**
 获取所有会话未读数量
 */
-(NSInteger) getAllConversationUnreadCount;


/// 更新频道预览的位置
/// @param browseTo <#browseTo description#>
/// @param channel <#channel description#>
-(void) updateBrowseTo:(uint32_t)browseTo forChannel:(QCChannel*)channel;

@end

// 最近会话添加或修改结果
@interface QCConversationAddOrUpdateResult : NSObject

@property(nonatomic,assign) BOOL insert;

@property(nonatomic,assign) BOOL modify; // 数据是否修改（添加或更新都为true）

@property(nonatomic,strong) QCConversation *conversation;

+(instancetype) initWithInsert:(BOOL)insert modify:(BOOL)modify conversation:(QCConversation*)conversation;
@end

NS_ASSUME_NONNULL_END
