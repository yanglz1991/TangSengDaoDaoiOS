//
//  QCConversationModel.m
//  QCCore
//
//  Created by tt on 2019/12/22.
//

#import "QCConversationWrapModel.h"

@interface QCConversationWrapModel ()
@property(nonatomic,strong) QCConversation *c;
//@property(nonatomic,assign) NSInteger unreadCt;

@property(nonatomic,strong) QCChannelInfo *channelInfoInner;

@property(nonatomic,assign) BOOL notAllowLoadLocalChannelInfo; // 不允许再次加载本地频道数据

@property(nonatomic,strong) NSMutableArray<QCConversationWrapModel*> *children;

@property(nonatomic,strong) QCConversation *lastChildConversation; // 最新的子最近会话

@end

@implementation QCConversationWrapModel

-(instancetype) initWithConversation:(QCConversation*)conversation {
    self = [super init];
    if(self) {
        self.c = conversation;
//        self.unreadCt = conversation.unreadCount;
    }
    return self;
}

-(QCChannel*) channel {
    return self.c.channel;
}

- (QCChannel *)parentChannel {
    return self.c.parentChannel;
}

- (NSMutableArray<QCConversationWrapModel *> *)children {
    if(!_children) {
        _children = [NSMutableArray array];
    }
    return _children;
}

-(void) addOrUpdateChildren:(QCConversationWrapModel *)conversationWrapModel {
    NSInteger existIndex = -1;
    NSInteger i = 0;
    QCConversation *lastConversation = [conversationWrapModel getConversation];
    for (QCConversationWrapModel *c in self.children) {
        if([c.channel isEqual:conversationWrapModel.channel]) {
            existIndex = i;
        }
        if(c.lastMsgTimestamp>lastConversation.lastMsgTimestamp) {
            lastConversation = [c getConversation];
        }
        i++;
    }
    if(existIndex==-1) {
        [self.children addObject:conversationWrapModel];
    }else {
        [self.children replaceObjectAtIndex:existIndex withObject:conversationWrapModel];
    }
    self.lastChildConversation = lastConversation;
//    self.c = lastConversation;
    
    
}

-(QCConversationWrapModel*) getChildren:(QCChannel*)channel {
    for (QCConversationWrapModel *c in self.children) {
        if([c.channel isEqual:channel]) {
            return c;
        }
    }
    return nil;
}

- (QCChannelInfo*) channelInfo {
    if(!self.channelInfoInner && !self.notAllowLoadLocalChannelInfo) {// 防治cell大量刷新重复请求DB
        self.channelInfoInner = self.c.channelInfo;
        self.notAllowLoadLocalChannelInfo = true;
    }
    return self.channelInfoInner;
}

- (void)setChannelInfo:(QCChannelInfo *)channelInfo {
    _channelInfoInner = channelInfo;
    if(channelInfo) {
        self.c.mute = channelInfo.mute;
        self.c.stick = channelInfo.stick;
    }
}

-(void) startChannelRequest {
    __weak typeof(self) weakSelf = self;
    [[QCSDK shared].channelManager addChannelRequest:self.channel complete:^(NSError * _Nonnull error, bool notifyBefore) {
        if(notifyBefore) {
            self.notAllowLoadLocalChannelInfo = false;
            return;
        }
        if(error) {
            weakSelf.notAllowLoadLocalChannelInfo = true; // 请求报错不允许本地加载频道，因为本地根本没有
        }else {
            weakSelf.notAllowLoadLocalChannelInfo = false; // 这时本地有频道数据了。所以可以去本地加载
        }
    }];
}

-(void) cancelChannelRequest {
    [[QCSDK shared].channelManager cancelRequest:self.channel];
}

- (NSInteger)lastContentType {
    if(self.lastChildConversation) {
        return self.lastChildConversation.lastMessage.contentType;
    }
    if(self.c.lastMessage) {
        return self.c.lastMessage.contentType;
    }
    return 0;
}

- (NSInteger)lastMsgTimestamp {
    if(self.lastChildConversation) {
        return self.lastChildConversation.lastMsgTimestamp;
    }
    return self.c.lastMsgTimestamp;
}

- (NSString *)content {
    if(self.lastChildConversation) {
        return [self content:self.lastChildConversation];
    }
    return [self content:self.c];
}

-(NSString*) content:(QCConversation*)conversation {
    if(conversation.lastMessage) {
        if(conversation.lastMessage.remoteExtra.contentEdit) {
            return [conversation.lastMessage.remoteExtra.contentEdit conversationDigest];
        }
        return [conversation.lastMessage.content conversationDigest];
    }
    return @"";
}

- (NSArray<QCReminder *> *)simpleReminders {
    if(self.lastChildConversation) {
        return self.lastChildConversation.simpleReminders;
    }
    return self.c.simpleReminders;
}

- (BOOL)mute {
    return self.c.mute;
}
- (BOOL)stick {
    return self.c.stick;
}



- (NSInteger)unreadCount {
    
    return self.c.unreadCount;
}

- (void)setUnreadCount:(NSInteger)unreadCount {
    self.c.unreadCount = unreadCount;
}

- (QCMessage *)lastMessage {
    if(self.lastChildConversation) {
        return self.lastChildConversation.lastMessage;
    }
    return self.c.lastMessage;
}

- (NSString *)lastClientMsgNo {
    if(self.lastChildConversation) {
        return self.lastChildConversation.lastClientMsgNo;
    }
    return self.c.lastClientMsgNo;
}

-(void) setLastMessage:(QCMessage*) message {
    [self.c setLastMessage:message];
    QCConversationWrapModel *childConversationWrapModel = [self getChildren:message.channel];
    if(childConversationWrapModel) {
        [childConversationWrapModel.c setLastMessage:message];
    }
}

-(void) reloadLastMessage {
    [self.c reloadLastMessage];
}

-(void) setConversation:(QCConversation*) conversation {
    self.c = conversation;
}

-(QCConversation*) getConversation {
    return self.c;
}

- (QCConversationExtra *)remoteExtra {
    return self.c.remoteExtra;
}

- (void)setRemoteExtra:(QCConversationExtra *)remoteExtra {
    self.c.remoteExtra = remoteExtra;
}



-(NSDictionary*) extra {
    return self.c.extra;
}

@end
