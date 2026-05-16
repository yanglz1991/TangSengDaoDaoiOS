//
//  QCOfflineConversation.m
//  QCIM
//
//  Created by tt on 2020/9/30.
//

#import "QCSyncConversationModel.h"
#import "QCCMDContent.h"
@interface QCSyncConversationModel ()

@property(nonatomic,strong) QCConversation *cvn;

@end

@implementation QCSyncConversationModel


- (QCConversation *)conversation {
    if(!_cvn) {
        _cvn = QCConversation.new;
        _cvn.channel = self.channel;
        _cvn.parentChannel = self.parentChannel;
        _cvn.mute = self.mute;
        _cvn.stick = self.stick;
        _cvn.lastMsgTimestamp = self.timestamp;
        _cvn.unreadCount = self.unread;
        _cvn.lastClientMsgNo = self.lastMsgClientNo;
        _cvn.lastMessageSeq = self.lastMsgSeq;
        _cvn.remoteExtra = self.remoteExtra;
        _cvn.version = self.version;
        
    }
    return _cvn;
}

@end

@implementation QCSyncConversationWrapModel



@end

@implementation QCCMDModel

+(QCCMDModel*) message:(QCMessage*)message{
    if([message.content isKindOfClass:[QCCMDContent class]]) {
        QCCMDContent *cmdContent = (QCCMDContent*)message.content;
        QCCMDModel *cmdModel = [QCCMDModel new];
        cmdModel.no = message.clientMsgNo;
        cmdModel.cmd = cmdContent.cmd;
        cmdModel.timestamp = message.timestamp;
        NSMutableDictionary *newParam = [NSMutableDictionary dictionary];
        if(cmdContent.param) {
            [newParam addEntriesFromDictionary:cmdContent.param];
        }
        if([self needCheckSign:cmdContent.cmd]) {
            if(![self checkSign:cmdContent]) {
                cmdModel.cmd = QCCMDSignError;
                return cmdModel;
            }
        }
        if(!newParam[@"channel_id"] || [newParam[@"channel_id"] isEqualToString:@""]) {
            if(message.channel && ![message.channel.channelId isEqualToString:@""]) {
                newParam[@"channel_id"] = message.channel.channelId;
                newParam[@"channel_type"] = @(message.channel.channelType);
            }
        }
        cmdModel.param = newParam;
        return cmdModel;
    }else {
        return [QCCMDModel new];
    }
   
}

// 是否需要校验sign
+(BOOL) needCheckSign:(NSString*)cmd {
    
    return true;
}

+(BOOL) checkSign:(QCCMDContent*)content {
//    [HBRSAHandler new];
    return true;
}


+(QCCMDModel*) cmdMessage:(QCCMDMessage*)cmdMessage {
    QCCMDModel *cmdModel = [QCCMDModel new];
    cmdModel.no = cmdMessage.clientMsgNo;
    cmdModel.cmd = cmdMessage.cmd;
    cmdModel.timestamp = cmdMessage.timestamp;
    return cmdModel;
}

@end
