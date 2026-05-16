//
//  QCMessageListDataProvider.h
//  Pods
//
//  Created by tt on 2022/5/18.
//

#ifndef QCMessageListDataProvider_h
#define QCMessageListDataProvider_h


#endif /* QCMessageListDataProvider_h */

#import <WuKongIMSDK/WuKongIMSDK.h>
#import "QCMessageModel.h"
#import "QCConversationContext.h"
#import "QCConversationPosition.h"

NS_ASSUME_NONNULL_BEGIN

@protocol QCMessageListDataProvider <NSObject>

// 请求第一屏消息
// @param position 定位消息的位置，为空则表示定位最新的消息
-(void) pullFirst:(QCConversationPosition * __nullable)position complete:(void(^)(bool more))complete;


// 日期数量
-(NSInteger) dateCount;

// 获取某个section的日期
-(NSString*) dateWithSection:(NSInteger)section;

- (NSArray<NSString *> *)dates; // 当前列表的所有日期

-(NSArray<QCMessageModel*>*) messagesAtDate:(NSString*)date; // 获取日期对应的消息

-(NSInteger) messageCount; // 消息数量

// 通过indexPath获取消息model
-(QCMessageModel*__nullable) messageAtIndexPath:(NSIndexPath*)indexPath;

// 通过section获取消息集合
-(NSArray<QCMessageModel*>*) messagesAtSection:(NSInteger)section;

// 最近会话上下文
-(id<QCConversationContext>) conversationContext;



@optional


// 通过clientMsgNo获取消息
-(QCMessageModel* __nullable) messageAtClientMsgNo:(NSString*)clientMsgNo;

// 通过流式编号获取消息
-(QCMessageModel*__nullable) messageAtStreamNo:(NSString*)streamNo;



// 通过orderSeq获取消息的indexpath
-(NSIndexPath*) indexPathAtOrderSeq:(uint32_t)orderSeq;

-(NSIndexPath*) indexPathAtClientMsgNo:(NSString*) clientMsgNo;
-(NSIndexPath*) indexPathAtMessageID:(uint64_t)messageID;

-(NSIndexPath*) indexPathAtStreamNo:(NSString*)streamNo;

// 获取包含有回复messageID的消息的消息
-(NSArray<NSIndexPath*>*) indexPathAtMessageReply:(uint64_t)messageID;
-(NSArray<QCMessageModel*>*) messagesAtMessageReply:(uint64_t)messageID;

-(void) insertMessage:(QCMessageModel*)message atIndex:(NSIndexPath*)indexPath;

-(NSIndexPath*) removeMessage:(QCMessageModel*) message sectionRemove:(BOOL*)sectionRemove;

// 添加消息
-(void) addMessage:(QCMessageModel*)message;
-(NSIndexPath*) removeMessage:(QCMessageModel*) message;



// 消息已读
-(void) didReaded:(NSArray<QCMessageModel*>*)messages;


// 上拉
-(void) pullup:(void(^)(bool more))complete;
// 下拉加载
-(void) pulldown:(void(^)(bool more))complete;

-(QCMessageModel*) lastMessage;

-(QCMessageModel*) firstMessage;



/**
 清除消息
 */
-(void) clearMessages;

-(NSArray<QCMessageModel*>*) getSelectedMessages; // 获取被选中的消息

-(void) cancelSelectedMessages; // 取消被选中的消息

-(NSArray<QCMessageModel*>*) getMessagesWithContentType:(NSInteger)contentType;


-(NSIndexPath*) replaceMessage:(QCMessageModel*)newMessage atClientMsgNo:(NSString*)clientMsgNo;

// -------------------- typing --------------------

- (BOOL)hasTyping;
-(NSIndexPath*) replaceTyping:(QCMessageModel*)message;
-(void) addTypingMessageIfNeed:(QCMessageModel*)messageModel; // 根据需要添加typing消息
@end

NS_ASSUME_NONNULL_END
