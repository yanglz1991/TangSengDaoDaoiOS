//
//  QCTypingManager.m
//  WuKongBase
//
//  Created by tt on 2020/8/13.
//

#import "QCTypingManager.h"
#import "QCTypingContent.h"
#import "QCApp.h"
@interface QCTypingManager ()
/**
 *  用来存储所有添加j过的delegate
 *  NSHashTable 与 NSMutableSet相似，但NSHashTable可以持有元素的弱引用，而且在对象被销毁后能正确地将其移除。
 */
@property (strong, nonatomic) NSHashTable  *delegates;
/**
 *  delegateLock 用于给delegate的操作加锁，防止多线程同时调用
 */
@property (strong, nonatomic) NSLock  *delegateLock;

@property(nonatomic,strong) NSMutableDictionary<QCChannel*,QCMessage*> *channelTypingMessageDict;

@property(nonatomic,strong) NSMutableDictionary<QCChannel*,dispatch_block_t> *cancelTypingBlockDict; // 取消输入中状态的的block

@property(nonatomic,assign) BOOL offTyping; // 是否关闭typing
@end

@implementation QCTypingManager

static QCTypingManager *_instance = nil;

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone ];
    });
    return _instance;
}

+(instancetype) shared{
    if (_instance == nil) {
        _instance = [[super alloc]init];
    }
    return _instance;
}

- (NSMutableDictionary<QCChannel *,QCMessage *> *)channelTypingMessageDict {
    if(!_channelTypingMessageDict) {
        _channelTypingMessageDict = [[NSMutableDictionary alloc] init];
    }
    return _channelTypingMessageDict;
}

- (NSMutableDictionary<QCChannel *,dispatch_block_t> *)cancelTypingBlockDict {
    if(!_cancelTypingBlockDict) {
        _cancelTypingBlockDict = [[NSMutableDictionary alloc] init];
    }
    return _cancelTypingBlockDict;
}

- (NSLock *)delegateLock {
    if (_delegateLock == nil) {
        _delegateLock = [[NSLock alloc] init];
    }
    return _delegateLock;
}

-(NSHashTable*) delegates {
    if (_delegates == nil) {
        _delegates = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return _delegates;
}

-(void) addDelegate:(id<QCTypingManagerDelegate>) delegate{
    [self.delegateLock lock];//防止多线程同时调用
    [self.delegates addObject:delegate];
    [self.delegateLock unlock];
}
- (void)removeDelegate:(id<QCTypingManagerDelegate>) delegate {
    [self.delegateLock lock];//防止多线程同时调用
    [self.delegates removeObject:delegate];
    [self.delegateLock unlock];
}

-(BOOL) hasTyping:(QCChannel*)channel {
    QCMessage *message = self.channelTypingMessageDict[channel];
    if(message) {
        return true;
    }
    return false;
}

- (void)addTypingByMessage:(QCMessage *)typingMessage {
    
//    QCMessage *typingMessage = [self convertMessageToTypingMessage:message];
    if( [typingMessage.fromUid isEqualToString:[QCApp shared].loginInfo.uid]) {
        return;
    }
    
    QCChannel *channel = typingMessage.channel;
    QCMessage *oldTypingMessage = self.channelTypingMessageDict[channel];
    self.channelTypingMessageDict[channel] = typingMessage;
    
    dispatch_block_t cancelTypingBlock = self.cancelTypingBlockDict[channel];
     if(cancelTypingBlock) {
         dispatch_block_cancel(cancelTypingBlock);
     }
     __weak typeof(self) weakSelf = self;
     cancelTypingBlock = dispatch_block_create(0, ^{
         [weakSelf removeTypingByChannel:channel newMessage:nil];
     });
     self.cancelTypingBlockDict[channel] = cancelTypingBlock;
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(),cancelTypingBlock);
    if(!oldTypingMessage) {
        [self callTypingAddDelegate:typingMessage];
    }
     
    
}

-(QCMessage*) convertParamToTypingMessage:(NSDictionary*)param {
    NSString *channelID = param[@"channel_id"];
    NSString *fromUID = param[@"from_uid"];
    NSString *fromName = param[@"from_name"];
    NSInteger channelType = [param[@"channel_type"] integerValue];
    
    QCMessage *typingMessage = [[QCMessage alloc] init];
    QCMessageHeader *header = [[QCMessageHeader alloc] init];
    header.showUnread = false;
    header.noPersist = YES;
    typingMessage.clientMsgNo = [[NSUUID UUID] UUIDString];
//    typingMessage.clientSeq = 1;
    typingMessage.header = header;
    typingMessage.messageId = 1234567;
//    typingMessage.messageSeq = message.messageSeq;
    typingMessage.timestamp = [[NSDate date] timeIntervalSince1970];
//    typingMessage.localTimestamp = message.localTimestamp;
    typingMessage.fromUid = fromUID;
    typingMessage.channel = [[QCChannel alloc] initWith:channelID channelType:channelType];
    
    QCTypingContent *content = [[QCTypingContent alloc] init];
    content.typingUID = fromUID;
    content.typingName = fromName;
    typingMessage.content = content;
    
    typingMessage.contentType = [QCTypingContent contentType].integerValue;
    return typingMessage;
}

- (NSArray<QCMessage *> *)getAllTypingMessages {
    
    return [self.channelTypingMessageDict allValues];
}

- (QCMessage *)getTypingMessage:(QCChannel *)channel {
    
    return self.channelTypingMessageDict[channel];
}


- (void)removeTypingByChannel:(QCChannel *)channel newMessage:(QCMessage*)newMessage{
    QCMessage *message = [self.channelTypingMessageDict objectForKey:channel];
    if(message) {
        [self.channelTypingMessageDict removeObjectForKey:channel];
        [self callTypingRemoveDelegate:message newMessage:newMessage];
    }
}

- (void)callTypingAddDelegate:(QCMessage*)message {
    [self.delegateLock lock];
    NSHashTable *copyDelegates =  [self.delegates copy];
    [self.delegateLock unlock];
    for (id delegate in copyDelegates) {//遍历delegates ，call delegate
        if(!delegate) {
            continue;
        }
        if ([delegate respondsToSelector:@selector(typingAdd:message:)]) {
            if (![NSThread isMainThread]) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [delegate typingAdd:self message:message];
                });
            }else {
                [delegate typingAdd:self message:message];
            }
        }
    }
}

- (void)callTypingReplaceDelegate:(QCMessage*)newmessage oldMessage:(QCMessage*)oldMessage {
    [self.delegateLock lock];
    NSHashTable *copyDelegates =  [self.delegates copy];
    [self.delegateLock unlock];
    for (id delegate in copyDelegates) {//遍历delegates ，call delegate
        if(!delegate) {
            continue;
        }
        if ([delegate respondsToSelector:@selector(typingReplace:newmessage:oldmessage:)]) {
            if (![NSThread isMainThread]) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [delegate typingReplace:self newmessage:newmessage oldmessage:oldMessage];
                });
            }else {
               [delegate typingReplace:self newmessage:newmessage oldmessage:oldMessage];
            }
        }
    }
}

- (void)callTypingRemoveDelegate:(QCMessage*)message newMessage:(QCMessage*)newMessage{
    [self.delegateLock lock];
    NSHashTable *copyDelegates =  [self.delegates copy];
    [self.delegateLock unlock];
    for (id delegate in copyDelegates) {//遍历delegates ，call delegate
        if(!delegate) {
            continue;
        }
        if ([delegate respondsToSelector:@selector(typingRemove:message:newMessage:)]) {
            if (![NSThread isMainThread]) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [delegate typingRemove:self message:message newMessage:newMessage];
                });
            }else {
                [delegate typingRemove:self message:message newMessage:newMessage];
            }
        }
    }
}

@end
