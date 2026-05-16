//
//  QCMessageDB.h
//  WuKongIMSDK
//
//  Created by tt on 2019/11/29.
//

#import <Foundation/Foundation.h>
#import "QCMessage.h"
#import "QCSendackPacket.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCMessageDB : NSObject

+ (QCMessageDB *)shared;
/**
 保存消息

 @param messages 消息集合
 @return 返回去重了的消息集合
 */
-(NSArray<QCMessage*>*) saveMessages:(NSArray<QCMessage*>*)messages;


/// 保存或更新消息
/// @param messages <#messages description#>
-(NSArray<QCMessage*>*) replaceMessages:(NSArray<QCMessage*>*)messages;


/**
 获取频道中，从指定消息之前、指定数量的最新消息实体

 @param channel 频道
 @param oldestOrderSeq 截止的客户端排序号
 @param limit 消息数量限制
 @return 消息实体集合
 
 例如：  oldestOrderSeq为20，count为2，会返回oldestOrderSeq为19和18的WKMessage对象列表。
 */
//-(NSArray<QCMessage*>*) getMessages:(QCChannel*)channel oldestOrderSeq:(uint32_t)oldestOrderSeq limit:(int) limit;
//

/// 获取频道中，从指定消息之前、指定数量的最新消息实体
/// @param channel 查询指定频道
/// @param startOrderSeq 开始orderSeq
/// @param endOrderSeq 结束排序seq
/// @param limit 限制
/// @param pullMode 拉取模式
-(NSArray<QCMessage*>*) getMessages:(QCChannel*)channel startOrderSeq:(uint32_t)startOrderSeq endOrderSeq:(uint32_t)endOrderSeq  limit:(int) limit pullMode:(QCPullMode)pullMode;


/// 获取消息列表
/// @param channel 频道对象
/// @param keyword 关键字
-(NSArray<QCMessage*>*) getMessages:(QCChannel*)channel keyword:(NSString*)keyword limit:(int) limit;

/// 获取消息
/// @param messageSeq 偏移的messageSeq
/// @param limit 数据限制
-(NSArray<QCMessage*>*) getMessages:(uint32_t)messageSeq limit:(int)limit;


-(NSArray<QCMessage*>*) getDeletedMessagesWithChannel:(QCChannel*)channel minMessageSeq:(uint32_t)minMessageSeq maxMessageSeq:(uint32_t)maxMessageSeq;


/// 获取消息序号区间内已经被删除的消息的messageSeq
/// @param channel 频道
/// @param minMessageSeq 最小消息序号
/// @param maxMessageSeq 最大消息序号
-(NSArray<NSNumber*>*) getDeletedMessageSeqWithChannel:(QCChannel*)channel  minMessageSeq:(uint32_t)minMessageSeq maxMessageSeq:(uint32_t)maxMessageSeq;

/// 获取比messageSeq小并且已删除了的序号
/// @param channel 频道
/// @param messageSeq  消息序号
/// @param limit 最大数量
-(NSArray<NSNumber*>*) getDeletedLessThanMessageSeqWithChannel:(QCChannel*)channel  messageSeq:(uint32_t)messageSeq limit:(int)limit;

/// 获取比messageSeq大并且已删除了的序号
/// @param channel 频道
/// @param messageSeq  消息序号
/// @param limit 最大数量
-(NSArray<NSNumber*>*) getDeletedMoreThanMessageSeqWithChannel:(QCChannel*)channel  messageSeq:(uint32_t)messageSeq limit:(int)limit;

/**
 通过序列号获取消息
 
 @param clientSeqs <#clientSeqs description#>
 @return <#return value description#>
 */
-(NSArray<QCMessage*>*) getMessagesWithClientSeqs:(NSArray<NSNumber*>*)clientSeqs;


/// 通过客户端消息编号获取消息列表
/// @param clientMsgNos <#clientMsgNos description#>
-(NSArray<QCMessage*>*) getMessagesWithClientMsgNos:(NSArray*)clientMsgNos;

/**
 通过消息id集合获取消息
 */
-(NSArray<QCMessage*>*) getMessagesWithMessageIDs:(NSArray<NSNumber*>*)messageIDs;

/**
 通过客户端消息编号获取消息

 @param clientMsgNo 客户端消息编号
 @return <#return value description#>
 */
-(QCMessage*) getMessageWithClientMsgNo:(NSString*)clientMsgNo;
/**
 获取指定clientSeq的消息

 @param clientSeq 客户端序号
 @return <#return value description#>
 */
-(QCMessage*) getMessage:(uint32_t)clientSeq;


/// 通过消息序号查询消息
/// @param channel <#channel description#>
/// @param messageSeq <#messageSeq description#>
-(QCMessage*) getMessage:(QCChannel*)channel messageSeq:(uint32_t)messageSeq;



/// 通过排序号获取频道内指定消息
/// @param orderSeq <#orderSeq description#>
/// @param channel <#channel description#>
-(QCMessage*) getMessage:(QCChannel*)channel orderSeq:(uint32_t)orderSeq;


/// 获取小于指定orderSeq 有messageSeq的第一条消息
/// @param channel <#channel description#>
/// @param orderSeq <#orderSeq description#>
-(QCMessage*) getMessage:(QCChannel*)channel lessThanAndFirstMessageSeq:(uint32_t)orderSeq;

// 获取大于指定orderSeq 有messageSeq的第一条消息
-(QCMessage*) getMessage:(QCChannel*)channel moreThanAndFirstMessageSeq:(uint32_t)orderSeq;
/**
 通过消息ID获取消息

 @param messageId <#messageId description#>
 @return <#return value description#>
 */
-(QCMessage*) getMessageWithMessageId:(uint64_t)messageId;

/**
 更新消息通过发送回执消息
 
 @param sendackPackets <#sendackPackets description#>
 */
-(void) updateMessageWithSendackPackets:(NSArray<QCSendackPacket*> *)sendackPackets;


/**
 更新消息

 @param content 消息content内容
 @param status 消息状态
 @param extra 消息扩展数据
 @param clientSeq 消息客户端唯一编号
 */
-(void) updateMessageContent:(NSData*)content status:(QCMessageStatus)status extra:(NSDictionary*)extra clientSeq:(uint32_t)clientSeq;


/**
 更新语音消息已读状态

 @param voiceReaded 语音是否已读
 @param clientSeq 客户端唯一ID
 */
-(void) updateMessageVoiceReaded:(BOOL)voiceReaded clientSeq:(uint32_t)clientSeq;





/**
 更新消息扩展字段

 @param extra <#extra description#>
 @param clientSeq <#clientSeq description#>
 */
-(void) updateMessageExtra:(NSDictionary*) extra clientSeq:(uint32_t)clientSeq;
/**
 将上传中的消息状态更改为发送失败的状态
 */
-(void) updateMessageUploadingToFailStatus;


/// 获取所有等待发送的消息
-(NSArray<QCMessage*>*) getMessagesWaitSend;
/**
 更新消息状态

 @param status 消息状态
 @param clientSeq 消息clientSeq
 */
-(void) updateMessageStatus:(QCMessageStatus)status withClientSeq:(uint32_t)clientSeq;


/// 更新消息撤回状态
/// @param revoke <#revoke description#>
/// @param clientMsgNo <#clientMsgNo description#>
-(void) updateMessageRevoke:(BOOL)revoke clientMsgNo:(NSString*)clientMsgNo;

/**
 获取某个频道消息表中最大的message_seq

 @return <#return value description#>
 */
-(uint32_t) getMaxMessageSeq:(QCChannel*)channel;


/**
 删除消息
 
 @param message 消息对象
 */
-(void) deleteMessage:(QCMessage*)message;

-(void) deleteMessagesWithClientSeqs:(NSArray<NSNumber*>*)ids;

-(void) deleteMessagesWithMessageIDs:(NSArray<NSNumber*>*)messageIDs;

-(void) deleteMessagesWithMessageIDs:(NSArray<NSNumber*>*)messageIDs db:(FMDatabase*)db;

/**
  彻底将消息从数据库删除 （deleteMessage只是标记为删除）
 */
- (void)destoryMessage:(QCMessage *)message;

/**
  获取指定频道内指定发送者的消息集合
 */
-(NSArray<QCMessage*>*) getMessages:(NSString*)fromUID channel:(QCChannel*)channel;


/**
 清除指定频道的消息
 
 @param channel 频道
 */
-(void) clearMessages:(QCChannel*)channel;


/// 清除所有消息
-(void) clearAllMessages;

/// 清除指定maxMsgSeq以前的所有消息
///  @param channel 频道
///  @param maxMsgSeq 指定的messageSeq
///  @param isContain 清除的消息是否包含指定的maxMsgSeq
- (void) clearFromMsgSeq:(QCChannel*)channel maxMsgSeq:(uint32_t)maxMsgSeq isContain:(BOOL)isContain;
/**
 获取最后一条消息

 @param channel <#channel description#>
 @return <#return value description#>
 */
-(QCMessage*) getLastMessage:(QCChannel*)channel;


/// 获取指定偏移量的最新消息
/// @param channel <#channel description#>
/// @param offset <#offset description#>
-(QCMessage*) getLastMessage:(QCChannel*)channel offset:(NSInteger)offset;


/// 查询排序在指定message之前的消息数量
/// @param message <#message description#>
-(NSInteger) getOrderCountMoreThanMessage:(QCMessage*)message;

/**
  获取指定频道的最大扩展版本
 */
-(long long) getMessageExtraMaxVersion:(QCChannel*)channel;

/**
  获取需要焚烧的消息（阅后即焚）
 */
-(NSArray<QCMessage*>*) getMessagesOfNeedFlame;

/**
  获取消息最大ID
 */
-(long long) getMessageMaxID;

/// 更新消息为已查看
-(NSArray<QCMessage*>*) updateViewed:(NSArray<QCMessage*>*)messages;

/**
 获取指定messageSeq的周围第一条消息的messageSeq 0表示没有
 */
-(uint32_t) getChannelAroundFirstMessageSeq:(QCChannel*)channel messageSeq:(uint32_t)messageSeq;

-(QCMessageContent*) decodeContent:(NSInteger)contentType data:(NSData *)contentData db:(FMDatabase*)db;

// 保存流
-(void) saveOrUpdateStreams:(NSArray<QCStream*>*)streams;

// 获取流
-(NSArray<QCStream*>*) getStreams:(NSString*)streamNo;

// 获取过期消息
-(NSArray<QCMessage*>*) getExpireMessages:(NSInteger)limit;

@end

NS_ASSUME_NONNULL_END
