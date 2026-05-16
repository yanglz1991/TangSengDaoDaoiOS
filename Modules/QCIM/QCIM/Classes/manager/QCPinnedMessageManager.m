//
//  QCPinnedMessageManager.m
//  QCIM
//
//  Created by tt on 2024/5/22.
//

#import "QCPinnedMessageManager.h"
#import "QCPinnedMessageDB.h"
#import "QCMessageDB.h"

@interface QCPinnedMessageManager ()

/**
 *  用来存储所有添加j过的delegate
 *  NSHashTable 与 NSMutableSet相似，但NSHashTable可以持有元素的弱引用，而且在对象被销毁后能正确地将其移除。
 */
@property (strong, nonatomic) NSHashTable  *delegates;
/**
 *  delegateLock 用于给delegate的操作加锁，防止多线程同时调用
 */
@property (strong, nonatomic) NSLock  *delegateLock;

@end

@implementation QCPinnedMessageManager


static QCPinnedMessageManager *_instance;
+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
+ (QCPinnedMessageManager *)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

-(NSArray<QCMessage*>*) getPinnedMessagesByChannel:(QCChannel*)channel {
    NSArray<QCPinnedMessage*> *pinnedMessages = [QCPinnedMessageDB.shared getPinnedMessagesByChannel:channel];
    if(pinnedMessages.count==0) {
        return nil;
    }
    NSMutableArray<NSNumber*> *messageIds = [NSMutableArray array];
    for (QCPinnedMessage *pinnedMessage in pinnedMessages) {
        [messageIds addObject:@(pinnedMessage.messageId)];
    }
   return [QCMessageDB.shared getMessagesWithMessageIDs:messageIds];
}

-(uint64_t) getMaxVersion:(QCChannel*)channel {
    
    return [QCPinnedMessageDB.shared getMaxVersion:channel];
}

-(void) deletePinnedByChannel:(QCChannel*)channel {
    [QCPinnedMessageDB.shared deletePinnedByChannel:channel];
    [self callOnDelegate:channel];
}

-(void) deletePinnedByMessageId:(uint64_t)messageId {
    QCPinnedMessage *pinnedMessage = [QCPinnedMessageDB.shared getPinnedMessageByMessageId:messageId];
    if(!pinnedMessage) {
        return;
    }
    [self callOnDelegate:pinnedMessage.channel];
}

-(void) addOrUpdatePinnedMessages:(NSArray<QCPinnedMessage*>*)messages {
    if(!messages || messages.count==0) {
        return;
    }
    
    NSMutableArray<QCChannel*> *channels = [NSMutableArray array];
    for (QCPinnedMessage *pinnedMessage in messages) {
        BOOL exist = false;
        for (QCChannel *channel in channels) {
            if([pinnedMessage.channel isEqual:channel]) {
                exist = true;
                break;
            }
        }
        if(!exist) {
            [channels addObject:pinnedMessage.channel];
        }
    }
    
    [QCPinnedMessageDB.shared addOrUpdatePinnedMessages:messages];
    
    for (QCChannel *channel in channels) {
        [self callOnDelegate:channel];
    }
    
}

-(BOOL) hasPinned:(uint64_t)messageId {
    
    return [QCPinnedMessageDB.shared hasPinned:messageId];
}

-(void) addDelegate:(id<QCPinnedMessageManagerDelegate>) delegate{
    [self.delegateLock lock];//防止多线程同时调用
    [self.delegates addObject:delegate];
    [self.delegateLock unlock];
}
- (void)removeDelegate:(id<QCPinnedMessageManagerDelegate>) delegate {
    [self.delegateLock lock];//防止多线程同时调用
    [self.delegates removeObject:delegate];
    [self.delegateLock unlock];
}


-(void) callOnDelegate:(QCChannel*)channel {
    [self.delegateLock lock];
    NSHashTable *copyDelegates =  [self.delegates copy];
    [self.delegateLock unlock];
    for (id delegate in copyDelegates) {//遍历delegates ，call delegate
        if(!delegate) {
            continue;
        }
        if ([delegate respondsToSelector:@selector(pinnedMessageChange:)]) {
            if (![NSThread isMainThread]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate pinnedMessageChange:channel];
                });
            }else {
                [delegate pinnedMessageChange:channel];
            }
        }
    }
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




@end
