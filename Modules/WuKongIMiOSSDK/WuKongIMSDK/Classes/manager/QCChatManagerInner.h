//
//  QCChatManagerInner.h
//  Pods
//
//  Created by tt on 2022/5/27.
//

#ifndef QCChatManagerInner_h
#define QCChatManagerInner_h


#endif /* QCChatManagerInner_h */


@interface QCChatManager ()


/**
 处理发送消息回执

 @param sendackArray <#sendackArray description#>
 */
-(void) handleSendack:(NSArray<QCSendackPacket*> *)sendackArray;


/**
 处理收到消息

 @param packets <#packets description#>
 */
-(void) handleRecv:(NSArray<QCRecvPacket*>*) packets;


/**
 处理消息 （流程： 保存消息-> 触发收到消息委托 -> 保存或更新最近会话 -> 触发最近会话委托）

 @param messages <#messages description#>
 */
-(void) handleMessages:(NSArray<QCMessage*>*) messages;


// 调用消息状态改变委托
//- (void)callMessageStatusChangeDelegate:(NSArray<QCMessageStatusModel*>*)statusModels;




/// 调用收到消息的委托
/// @param messages <#messages description#>
- (void)callRecvMessagesDelegate:(NSArray<QCMessage*>*)messages;

// 调用流式消息委托
- (void)callStreamDelegate:(NSArray<QCStream*>*)streams;

/// 获取所有消息存储之前的拦截器
-(NSArray<MessageStoreBeforeIntercept>*) getMessageStoreBeforeIntercepts;



@end
