//
//  QCMessageListDataProviderImp.m
//  WuKongBase
//
//  Created by tt on 2022/5/18.
//

#import "QCMessageListDataProviderImp.h"
#import "WuKongbase.h"
#import "QCMessageList.h"
#import "QCEndToEndEncryptHitContent.h"
#import "QCConversationListVM.h"
@interface QCMessageListDataProviderImp ()

@property(nonatomic,strong) QCChannel *channel;

@property(nonatomic,strong) QCMessageList *messageList;


@property(nonatomic,assign) NSInteger newMsgCount; // 新消息数量

@property(nonatomic,strong) id<QCConversationContext> conversationContextInner;



@end

@implementation QCMessageListDataProviderImp

-(instancetype) initWithChannel:(QCChannel*)channel conversationContext:(id<QCConversationContext>)conversationContext{
    self = [super init];
    if (self) {
        self.channel = channel;
        self.conversationContextInner = conversationContext;
    }
    return self;
}

- (id<QCConversationContext>)conversationContext {
    return self.conversationContextInner;
}


// 请求第一屏消息
-(void) pullFirst:(QCConversationPosition*)position complete:(void(^)(bool more))complete  {
    
    QCConversationWrapModel *model = [[QCConversationListVM shared] modelAtChannel:self.channel];
    uint32_t maxMessageSeq = 0;
    if(model && model.lastMessage && model.lastMessage.messageSeq>0) {
        maxMessageSeq = model.lastMessage.messageSeq;
    }
    
    
    if(position) {
        __weak typeof(self) weakSelf = self;
        [[QCSDK shared].chatManager pullAround:self.channel orderSeq:position.orderSeq maxMessageSeq:maxMessageSeq limit:[QCApp shared].config.eachPageMsgLimit complete:^(NSArray<QCMessage *> * _Nonnull messages, NSError * _Nonnull error) {
            [weakSelf.messageList clearMessages]; // 现清除原来的数据
            [weakSelf handleMessages:[weakSelf messagesToMessageModels:messages] insertFirst:false complete:complete];
        }];
    }else {
        __weak typeof(self) weakSelf = self;
       
        [[QCSDK shared].chatManager pullLastMessages:self.channel endOrderSeq:0 maxMessageSeq: maxMessageSeq limit:[QCApp shared].config.eachPageMsgLimit complete:^(NSArray<QCMessage *> * _Nonnull messages, NSError * _Nonnull error) {
            if(error) {
                QCLogError(@"获取第一屏消息失败！->%@",error);
                [[QCNavigationManager shared].topViewController.view showHUDWithHide:@"获取消息失败！"];
                return;
            }
            [weakSelf.messageList clearMessages]; // 现清除原来的数据
            [weakSelf handleMessages:[weakSelf messagesToMessageModels:messages] insertFirst:false complete:complete];
            
        }];
    }
}
-(NSArray<QCMessageModel*>*) messagesToMessageModels:(NSArray<QCMessage*>*) messages {
    NSMutableArray<QCMessageModel*> *messageModels = [NSMutableArray array];
    for (QCMessage *message in messages) {
        QCMessageModel *messageModel = [[QCMessageModel alloc] initWithMessage:message];
        [messageModels addObject:messageModel];
    }
    return messageModels;
}

// insertFirst 是否插入到数组最前
-(void) handleMessages:(NSArray<QCMessageModel*>*)messages insertFirst:(BOOL)insertFirst complete:(void(^)(bool more))complete{
//    bool hasMore = messages.count>=[QCApp shared].config.eachPageMsgLimit;
    bool hasMore = messages.count>=[QCApp shared].config.eachPageMsgLimit;
    if(messages && messages.count>0) {
        if(insertFirst) {
            [self.messageList insertMessages: [[messages reverseObjectEnumerator] allObjects]];
        }else{
            [self.messageList addMessages:messages];
        }
        
    }
    if(complete) {
        complete(hasMore);
    }
}

-(BOOL) hasEndToEndEncryptHitMessage {
    if(self.messageList.dates.count<=0) {
        return false;
    }
   NSString *date =  self.messageList.dates.firstObject;
    
   NSArray<QCMessageModel*> *messages =  [self.messageList messagesAtDate:date];
    if(messages && messages.count>0) {
        if([ messages[0].content isKindOfClass:[QCEndToEndEncryptHitContent class]]) {
            return true;
        }
    }
    return false;
}

-(void) insertEndToEndEncryptHitMessageIfNeed {
    if(self.channel.channelType != WK_PERSON) {
        return;
    }
    if([self hasEndToEndEncryptHitMessage]) {
        return;
    }
//    if(self.state && !self.state.signalOn) {
//        return;
//    }
    if(self.messageList.dates && self.messageList.dates.count>0) {
        NSString *date = self.messageList.dates.firstObject;
        NSMutableArray *messages = [NSMutableArray arrayWithArray:[self.messageList messagesAtDate:date]];
        [messages insertObject:[self newEndToEndEncryptHitMessage] atIndex:0];
        [self.messageList setMessages:messages forDate:date];
    }else {
        NSMutableArray *messages = [NSMutableArray arrayWithArray:@[[self newEndToEndEncryptHitMessage]]];
        [self.messageList setMessages:messages forDate:[self formatDate:[NSDate date]]];
    }
}

-(NSString*) formatDate:(NSDate*)date {
    return [QCTimeTool getTimeString:date format:@"yyyy-MM-dd" ];
}
-(QCMessageModel*) newEndToEndEncryptHitMessage {
    QCMessage *message = [QCMessage new];
    message.messageSeq = 1;
    message.content = [QCEndToEndEncryptHitContent new];
    NSNumber *contentType = [[message.content class] contentType];
    message.contentType = contentType.integerValue;
    return [[QCMessageModel alloc] initWithMessage:message];
}
- (QCMessageList *)messageList {
    if(!_messageList) {
        _messageList = [[QCMessageList alloc] init];
    }
    return _messageList;
}



#pragma mark -- QCMessageListDataProvider

- (void)clearMessages {
    [self.messageList clearMessages];
}

-(NSIndexPath*) replaceMessage:(QCMessageModel*)newMessage atClientMsgNo:(NSString*)clientMsgNo {
    
    return [self.messageList replaceMessage:newMessage atClientMsgNo:clientMsgNo];
}
- (NSArray<NSString *> *)dates {
    return self.messageList.dates;
}

- (NSArray<QCMessageModel *> *)messagesAtDate:(NSString *)date {
    return [self.messageList messagesAtDate:date];
}

-(NSArray<QCMessageModel*>*) getMessagesWithContentType:(NSInteger)contentType {
    return [self.messageList getMessagesWithContentType:contentType];
}

- (NSArray<QCMessageModel *> *)getSelectedMessages {
    return [self.messageList getSelectedMessages];
}

- (void)cancelSelectedMessages {
    [self.messageList cancelSelectedMessages];
}

-(void) addMessage:(QCMessageModel*)message {
    [self.messageList addMessage:message];
}
// 上拉加载
-(void) pullup:(void(^)(bool more))complete  {
    QCMessageModel *lastMessageModel = [self lastMessage];
//    QCMessageModel *firstMessageModel = [self firstMessageModel];
    uint32_t baseOrderSeq = 0;
    if(lastMessageModel) {
        if(lastMessageModel.contentType == WK_TYPING) {
            if(lastMessageModel.preMessageModel) {
                baseOrderSeq = lastMessageModel.preMessageModel.orderSeq;
            }
        }else{
            baseOrderSeq = lastMessageModel.orderSeq;
        }
        
    }
    __weak typeof(self) weakSelf = self;
    [[QCSDK shared].chatManager pullUp:self.channel startOrderSeq:baseOrderSeq limit:[QCApp shared].config.eachPageMsgLimit complete:^(NSArray<QCMessage *> * _Nonnull messages, NSError * _Nonnull error) {
        [weakSelf handleMessages:[self messagesToMessageModels:messages] insertFirst:false complete:complete];
    }];
}

// 下拉加载
-(void) pulldown:(void(^)(bool more))complete {
    QCMessageModel *firstMessageModel = [self firstMessage];
    uint32_t baseOrderSeq = 0;
    if(firstMessageModel) {
        baseOrderSeq = firstMessageModel.orderSeq;
    }
    __weak typeof(self) weakSelf = self;
    [[QCSDK shared].chatManager pullDown:self.channel startOrderSeq:baseOrderSeq limit:[QCApp shared].config.eachPageMsgLimit complete:^(NSArray<QCMessage *> * _Nonnull messages, NSError * _Nonnull error) {
        [weakSelf handleMessages:[self messagesToMessageModels:messages] insertFirst:true complete:complete];
    }];
}


-(NSInteger) messageCount {
    
    return [self.messageList messageCount];
}

- (BOOL)hasTyping {
    return [self.messageList hasTyping];
}

- (NSIndexPath *)replaceTyping:(QCMessageModel *)message {
    return [self.messageList replaceTyping:message];
}


-(void) addTypingMessageIfNeed:(QCMessageModel*)messageModel {
    [self.messageList addTypingMessageIfNeed:messageModel];
}
-(NSIndexPath*) removeMessage:(QCMessageModel*) message {
    
    return [self.messageList removeMessage:message];
}

- (NSIndexPath *)removeMessage:(QCMessageModel *)message sectionRemove:(BOOL *)sectionRemove {
    return [self.messageList removeMessage:message sectionRemove:sectionRemove];
}

-(NSIndexPath*) indexPathAtMessageID:(uint64_t)messageID {
    return [self.messageList indexPathAtMessageID:messageID];
}

-(NSIndexPath*) indexPathAtStreamNo:(NSString*)streamNo {
    return [self.messageList indexPathAtStreamNo:streamNo];
}

-(NSArray<NSIndexPath*>*) indexPathAtMessageReply:(uint64_t)messageID {
    return [self.messageList indexPathAtMessageReply:messageID];
}

-(NSArray<QCMessageModel*>*) messagesAtMessageReply:(uint64_t)messageID {
    return [self.messageList messagesAtMessageReply:messageID];
}

-(NSIndexPath*) indexPathAtClientMsgNo:(NSString*) clientMsgNo {
    return [self.messageList indexPathAtClientMsgNo:clientMsgNo];
}

-(void) insertMessage:(QCMessageModel*)message atIndex:(NSIndexPath*)indexPath {
    [self.messageList insertMessage:message atIndex:indexPath];
}
- (QCMessageModel *)lastMessage {
    return [self.messageList lastMessage];
}

- (QCMessageModel *)firstMessage {
    return [self.messageList firstMessage];
}

-(NSIndexPath*) indexPathAtOrderSeq:(uint32_t)orderSeq {
    return [self.messageList indexPathAtOrderSeq:orderSeq];
}

- (NSInteger)dateCount {
    return self.messageList.dates.count;
}

- (NSString *)dateWithSection:(NSInteger)section {
    return self.messageList.dates[section];
}

- (void)didReaded:(NSArray<QCMessageModel *> *)messageModels {
    if(![QCSDK shared].receiptManager.messageReadedProvider) {
        return;
    }
    NSMutableArray<QCMessage*> *messages = [NSMutableArray array];
    for (QCMessageModel *messageModel in messageModels) {
        [messages addObject:messageModel.message];
    }
    [[QCSDK shared].receiptManager addReceiptMessages:self.channel messages:messages];
}

- (QCMessageModel *)messageAtIndexPath:(NSIndexPath *)indexPath {
    NSString *date = self.messageList.dates[indexPath.section];
    return [self.messageList messagesAtDate:date][indexPath.row];
}

-(QCMessageModel* __nullable) messageAtClientMsgNo:(NSString*)clientMsgNo {
   NSIndexPath *indexPath = [self indexPathAtClientMsgNo:clientMsgNo];
    if(!indexPath) {
        return nil;
    }
    return [self messageAtIndexPath:indexPath];
}

-(QCMessageModel*__nullable) messageAtStreamNo:(NSString*)streamNo {
    NSIndexPath *indexPath = [self indexPathAtStreamNo:streamNo];
     if(!indexPath) {
         return nil;
     }
    return [self messageAtIndexPath:indexPath];
}

- (NSArray<QCMessageModel *> *)messagesAtSection:(NSInteger)section {
    NSString *date = self.messageList.dates[section];
    return [self.messageList messagesAtDate:date];
}


@end
