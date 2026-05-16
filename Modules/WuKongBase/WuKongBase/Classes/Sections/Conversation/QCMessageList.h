//
//  QCMessageList.h
//  WuKongBase
//
//  Created by tt on 2022/5/18.
//

#import <Foundation/Foundation.h>
#import "QCMessageModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCMessageList : NSObject

@property(nonatomic,strong) NSMutableArray<NSString*> *dates; // 消息日期

// 插入消息
-(void) insertMessages:(NSArray<QCMessageModel*>*)messages;

// 添加消息
-(void) addMessages:(NSArray<QCMessageModel*>*)messages;

-(void) addMessage:(QCMessageModel*)message;

// 清空消息
-(void) clearMessages;

-(NSArray<QCMessageModel*>*) messagesAtDate:(NSString*)date;

// 设置消息
-(void) setMessages:(NSArray<QCMessageModel*>*)messages forDate:(NSString*)date;

-(QCMessageModel*) lastMessage;

-(QCMessageModel*) firstMessage;

-(NSIndexPath*) indexPathAtOrderSeq:(uint32_t)orderSeq;

-(NSIndexPath*) indexPathAtClientMsgNo:(NSString*) clientMsgNo;

-(NSIndexPath*) indexPathAtStreamNo:(NSString*)streamNo;

-(NSIndexPath*) indexPathAtMessageID:(uint64_t)messageID;

// 获取包含有回复messageID的消息的消息
-(NSArray<NSIndexPath*>*) indexPathAtMessageReply:(uint64_t)messageID;
-(NSArray<QCMessageModel*>*) messagesAtMessageReply:(uint64_t)messageID;

-(void) insertMessage:(QCMessageModel*)message atIndex:(NSIndexPath*)indexPath;

-(NSIndexPath*) removeMessage:(QCMessageModel*) message;

// sectionRemove 表示 section是否整个都移除了
-(NSIndexPath*) removeMessage:(QCMessageModel*) message sectionRemove:(BOOL*)sectionRemove;


-(NSInteger) messageCount;

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
