//
//  QCMessageManager.h
//  WuKongBase
//
//  Created by tt on 2020/1/28.
//

#import <Foundation/Foundation.h>
#import "QCMessageModel.h"
NS_ASSUME_NONNULL_BEGIN
@class QCMessageManager;
@protocol QCMessageManagerDelegate <NSObject>


@optional


/**
 删除消息

 @param manager <#manager description#>
 @param messages 消息对象
 */
-(void) messageManager:(QCMessageManager*)manager deleteMessages:(NSArray<QCMessageModel*>*)messages;


/**
 清除指定频道的消息

 @param manager <#manager description#>
 @param channel 频道
 */
-(void) messageManager:(QCMessageManager*)manager clearMessages:(QCChannel*)channel;


/**
 撤回消息

 @param manager <#manager description#>
 @param message 需要撤回的消息对象
 */
-(void) messageManager:(QCMessageManager*)manager revokeMessage:(QCMessageModel*)message complete:(void(^__nullable)(NSError * __nullable error))complete;


/// 设置最近会话的未读数
/// @param manager <#manager description#>
/// @param channel 频道
/// @param messageSeq 最新消息的messageSeq (只有超大群需要)
/// @param complete <#complete description#>
-(void) messageManager:(QCMessageManager*) manager conversationSetUnread:(QCChannel*)channel unread:(NSInteger)unread messageSeq:(uint32_t)messageSeq complete:(void(^__nullable)(NSError * __nullable error))complete;


///  更新语音消息为已读
/// @param manager <#manager description#>
/// @param message 语音消息
/// @param complete <#complete description#>
-(void) messageManager:(QCMessageManager*) manager updateMessageVoiceReaded:(QCMessageModel*)message complete:(void(^__nullable)(NSError * __nullable error))complete;

//收藏单个表情
-(void) messageManager:(QCMessageManager*) manager collectExpressions:(QCMessageModel*)message;


@end


@interface QCMessageManager : NSObject

+ (QCMessageManager *)shared;

@property(nonatomic, strong) id<QCMessageManagerDelegate> delegate;


/**
 删除指定消息

 @param messages <#message description#>
 */
-(void) deleteMessages:(NSArray<QCMessageModel*>*)messages;


/**
 清除指定频道的消息

 @param channel <#channel description#>
 */
-(void) clearMessages:(QCChannel*)channel;


/// 设置最近会话的未读数
/// @param channel <#channel description#>
-(void) conversationSetUnread:(QCChannel*)channel unread:(NSInteger)unread  messageSeq:(uint32_t)messageSeq complete:(void(^__nullable)(NSError *__nullable error))complete;


/**
 撤回消息

 @param message <#message description#>
 */
-(void) revokeMessage:(QCMessageModel*)message complete:(void(^__nullable)(NSError *__nullable error))complete;


/// 更新语音消息为已读
/// @param message 语音消息
/// @param complete <#complete description#>
-(void) updateMessageVoiceReaded:(QCMessageModel*)message complete:(void(^__nullable)(NSError *__nullable error))complete;

/**
 收藏单个表情
 */
-(void) collectExpressions:(QCMessageModel*)message;

@end

NS_ASSUME_NONNULL_END
