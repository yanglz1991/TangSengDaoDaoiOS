//
//  QCConversationManager.h
//  WuKongIMSDK
//
//  Created by tt on 2019/11/29.
//

#import <Foundation/Foundation.h>
#import "QCMessage.h"
#import "QCConversation.h"
#import "QCConversationDB.h"
#import "QCSyncConversationModel.h"
#import "QCConversationExtra.h"

@protocol QCConversationManagerDelegate;

NS_ASSUME_NONNULL_BEGIN

typedef void(^QCSyncConversationCallback)(QCSyncConversationWrapModel* __nullable model,NSError * __nullable error);

typedef void(^QCSyncConversationAck)(uint64_t cmdVersion,void(^ _Nullable complete)(NSError * _Nullable error));

// 同步会话返回 timestamp：最新会话的时间戳 lastMsgSeqs：客户端所有会话的最后一条消息序列号 格式： channelID:channelType:last_msg_seq|channelID:channelType:last_msg_seq
typedef void (^QCSyncConversationProvider)(long long version,NSString *lastMsgSeqs,QCSyncConversationCallback callback);


// 同步最近会话扩展
typedef void(^QCSyncConversationExtraCallback)(NSArray<QCConversationExtra*>* __nullable extras,NSError * __nullable error);
typedef void (^QCSyncConversationExtraProvider)(long long version,QCSyncConversationExtraCallback callback);
// 更新扩展
typedef void (^QCUpdateConversationExtraCallback)(int64_t version,NSError * __nullable error);
typedef void (^QCUpdateConversationExtraProvider)(QCConversationExtra *extra,QCUpdateConversationExtraCallback callback);



@interface QCConversationManager : NSObject

/**
 获取最近会话列表
 
 @return 最好会话对象集合
 */
-(NSArray<QCConversation*>*) getConversationList;


/// 添加最近会话信息
/// @param conversation <#conversation description#>
-(void) addConversation:(QCConversation*)conversation;

/**
 清除指定频道的未读消息
 
 @param channel <#channel description#>
 */
-(void) clearConversationUnreadCount:(QCChannel*)channel;


/// 设置未读数
/// @param channel 频道
/// @param unread 未读数量
-(void) setConversationUnreadCount:(QCChannel*)channel unread:(NSInteger)unread;



/// 恢复指定频道的会话
/// @param channel <#channel description#>
-(void) recoveryConversation:(QCChannel*)channel;



// 更新或添加扩展
-(void) updateOrAddExtra:(QCConversationExtra*)extra;

// 同步最近会话扩展
-(void) syncExtra;


/// 删除最近会话
/// @param channel 频道
-(void) deleteConversation:(QCChannel*)channel;



/// 获取指定频道的最近会话信息
/// @param channel <#channel description#>
-(QCConversation*) getConversation:(QCChannel*)channel;

-(NSArray<QCConversation*>*) getConversations:(NSArray<QCChannel*>*)channels;

/**
 添加最近会话委托
 
 @param delegate <#delegate description#>
 */
-(void) addDelegate:(id<QCConversationManagerDelegate>) delegate;


/**
 移除最近会话委托
 
 @param delegate <#delegate description#>
 */
-(void)removeDelegate:(id<QCConversationManagerDelegate>) delegate;

/**
 获取所有会话未读数量
 */
-(NSInteger) getAllConversationUnreadCount;

/**
 调用最近会话更新委托

 @param conversation <#conversation description#>
 */
- (void)callOnConversationUpdateDelegate:(QCConversation*)conversation;

/// 设置同步会话提供者
/// @param syncConversationProvider <#syncConversationProvider description#>
/// @param syncConversationAck <#syncConversationAck description#>
-(void) setSyncConversationProviderAndAck:(QCSyncConversationProvider) syncConversationProvider ack:(QCSyncConversationAck)syncConversationAck;



/// 同步最近会话
@property(nonatomic,copy,readonly) QCSyncConversationProvider syncConversationProvider;
@property(nonatomic,copy,readonly) QCSyncConversationAck syncConversationAck;

// 同步扩展提供者
@property(nonatomic,copy) QCSyncConversationExtraProvider syncConversationExtraProvider;
// 更新扩展提供者
@property(nonatomic,copy) QCUpdateConversationExtraProvider updateConversationExtraProvider;



@end


@protocol QCConversationManagerDelegate <NSObject>

@optional

/**
 最近会话更新
 */
- (void)onConversationUpdate:(NSArray<QCConversation*>*)conversations;

/**
 最近会话未读数更新
 
 @param channel 频道
 @param unreadCount 未读数量
 */
- (void)onConversationUnreadCountUpdate:(QCChannel*)channel unreadCount:(NSInteger)unreadCount;


/// 最近会话被删除
/// @param channel <#channel description#>
-(void) onConversationDelete:(QCChannel*)channel;


/// 所有最近会话删除
-(void) onConversationAllDelete;

@end


NS_ASSUME_NONNULL_END
