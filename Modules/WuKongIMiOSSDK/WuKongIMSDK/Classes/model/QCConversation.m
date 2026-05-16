//
//  QCConversation.m
//  WuKongIMSDK
//
//  Created by tt on 2019/12/8.
//

#import "QCConversation.h"
#import "QCChannelManager.h"
#import "QCMessageDB.h"
#import "QCSDk.h"

@interface QCConversation ()

@property(nonatomic,strong) NSMutableArray<QCReminder*> *simpleReminderInners;

@end

@implementation QCConversation


-(QCChannelInfo*) channelInfo {
    return [[QCChannelManager shared] getChannelInfo:self.channel];
}


- (QCMessage *)lastMessage {
    if(!_lastMessage) {
        if(self.lastClientMsgNo && ![self.lastClientMsgNo isEqualToString:@""]) {
            _lastMessage = [[QCMessageDB shared] getMessageWithClientMsgNo:self.lastClientMsgNo];
        }
        
    }
    return _lastMessage;
}

-(QCMessage*)lastMessageInner {
    return _lastMessage;
}

- (void)setLastMessageInner:(QCMessage *)lastMessageInner {
    _lastMessage = lastMessageInner;
}

- (void)setReminders:(NSArray<QCReminder *> *)reminders {
    _reminders = reminders;
    NSMutableArray *newSimpleReminderArray = [NSMutableArray array];
    if(reminders&&reminders.count>0) {
        
        for (QCReminder *reminder  in reminders) {
            if(reminder.publisher && QCSDK.shared.options.connectInfo && [reminder.publisher isEqualToString:QCSDK.shared.options.connectInfo.uid]) {
                continue;
            }
            BOOL exist = false;
            NSInteger i = 0;
            for (QCReminder *simpleReminder in newSimpleReminderArray) {
                if(reminder.type == simpleReminder.type) {
                    exist = true;
                    break;
                }
                i++;
            }
            if(!exist) {
                [newSimpleReminderArray addObject:reminder];
            }else {
                newSimpleReminderArray[i] = reminder;
            }
           
        }
    }
    self.simpleReminderInners = newSimpleReminderArray;
}


- (NSArray<QCReminder *> *)simpleReminders {
    return self.simpleReminderInners;
}

- (QCConversationExtra *)remoteExtra {
    if(!_remoteExtra) {
        _remoteExtra = [[QCConversationExtra alloc] init];
        _remoteExtra.channel = self.channel;
    }
    return _remoteExtra;
}

-(void) reloadLastMessage {
    _lastMessage = [[QCMessageDB shared] getMessageWithClientMsgNo:self.lastClientMsgNo?:@""];
}



- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    QCConversation *conversation = [QCConversation allocWithZone:zone];
    conversation.channel = [self.channel copy];
    if(conversation.parentChannel) {
        conversation.parentChannel = [self.parentChannel copy];
    }
    if(self.avatar) {
        conversation.avatar = [self.avatar copy];
    }
    if(self.lastClientMsgNo) {
        conversation.lastClientMsgNo = [self.lastClientMsgNo copy];
    }
    conversation.lastMessageSeq = self.lastMessageSeq;
    conversation.lastMessage = self.lastMessage;
    conversation.lastMessageInner = self.lastMessageInner;
    conversation.lastMsgTimestamp = self.lastMsgTimestamp;
    conversation.unreadCount = self.unreadCount;
    conversation.simpleReminderInners = self.simpleReminderInners;
    conversation.reminders = self.reminders;
    conversation.extra = self.extra;
    conversation.version = self.version;
    conversation.mute = self.mute;
    conversation.stick = self.stick;
    conversation.remoteExtra = self.remoteExtra;
    
    return conversation;
}
@end
