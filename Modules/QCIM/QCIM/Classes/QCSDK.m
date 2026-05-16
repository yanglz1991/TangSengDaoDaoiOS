//
//  QCSDK.m
//  QCIM
//
//  Created by tt on 2019/11/23.
//

#import "QCSDK.h"
#import "QCConnectionManager.h"
#import "QCConnectPacket.h"
#import "QCUnknownContent.h"
#import "QCMessageDB.h"
#import "QCSystemContent.h"
#import "QCCMDContent.h"
#import "QCTextContent.h"
#import "QCImageContent.h"
#import "QCVoiceContent.h"
@interface QCSDK()

@property(nonatomic,strong) NSMutableDictionary *messageContentDict;
@property(nonatomic,strong) NSLock *messageContentDictLock;

@property(nonatomic,copy) QCOfflineMessagePull offlineMessagePullInner;
@property(nonatomic,copy) QCOfflineMessageAck  offlineMessageAckInner;



@end

@implementation QCSDK

static QCSDK *_instance;


+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
+ (QCSDK *)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (NSMutableDictionary *)messageContentDict {
    if(!_messageContentDict) {
        _messageContentDict = [[NSMutableDictionary alloc] init];
        [_messageContentDict setObject:[QCTextContent class] forKey:[NSString stringWithFormat:@"%li",[QCTextContent contentType].longValue]];
        [_messageContentDict setObject:[QCImageContent class] forKey:[NSString stringWithFormat:@"%li",[QCImageContent contentType].longValue]];
        [_messageContentDict setObject:[QCVoiceContent class] forKey:[NSString stringWithFormat:@"%li",[QCVoiceContent contentType].longValue]];
        [_messageContentDict setObject:[QCCMDContent class] forKey:[NSString stringWithFormat:@"%li",[QCCMDContent contentType].longValue]];
        
    }
    return _messageContentDict;
}

- (NSLock *)messageContentDictLock {
    if(!_messageContentDictLock) {
        _messageContentDictLock = [[NSLock alloc] init];
    }
    return _messageContentDictLock;
}

- (QCOptions *)options {
    if(!_options) {
        _options = [[QCOptions alloc] init];
    }
    return _options;
}

- (void)setConnectURL:(NSString *)connectURL {
    _connectURL = connectURL;
    NSURL *connURL = [NSURL URLWithString:connectURL];
    self.options.host = [connURL host];
    NSLog(@"%@",[connURL port]);
    NSArray<NSString*> *connectArray =[connectURL componentsSeparatedByString:@":"];
    if(connectArray.count>=2) {
        self.options.port = [connectArray.lastObject intValue];
    }
    
    NSString *queryStr =  [connURL query];
    if(queryStr && ![queryStr isEqualToString:@""]) {
       NSArray<NSString*> *params = [queryStr componentsSeparatedByString:@"&"];
        if(params.count>0) {
            NSString *uid;
            NSString *token;
            NSString *name;
            NSString *avatar;
            for (NSString *param in params) {
                NSArray<NSString*> *keyValues = [param componentsSeparatedByString:@"="];
                if(keyValues.count==2) {
                   NSString *key = keyValues[0];
                   NSString *value = keyValues[1];
                    if([key isEqualToString:@"uid"]) {
                        uid = value;
                    }else if([key isEqualToString:@"token"]) {
                        token = value;
                    }else if([key isEqualToString:@"name"]) {
                        token = value;
                    }else if([key isEqualToString:@"avatar"]) {
                        token = value;
                    }
                }
            }
            if(uid && ![uid isEqualToString:@""] && token && ![token isEqualToString:@""]) {
                self.options.connectInfo = [QCConnectInfo initWithUID:uid token:token name:name avatar:avatar];
            }
        }
    }
}

-(QCConnectionManager*) connectionManager{
    if(!_connectionManager){
        _connectionManager =[QCConnectionManager sharedManager];
    }
    return _connectionManager;
}

-(QCChatManager*) chatManager{
    if(!_chatManager){
        _chatManager =[QCChatManager new];
    }
    return _chatManager;
}

-(QCConversationManager*) conversationManager {
    if(!_conversationManager) {
        _conversationManager = [QCConversationManager new];
    }
    return _conversationManager;
}

-(QCChannelManager*) channelManager{
    if(!_channelManager){
        _channelManager =[QCChannelManager new];
    }
    return _channelManager;
}

-(QCPakcetBodyCoderManager*) bodyCoderManager{
    if(!_bodyCoderManager){
        _bodyCoderManager =[QCPakcetBodyCoderManager new];
    }
    return _bodyCoderManager;
}

- (QCMediaManager *)mediaManager {
    return  [QCMediaManager shared];
}

- (QCCMDManager *)cmdManager {
    if(!_cmdManager) {
        _cmdManager = [QCCMDManager new];
    }
    return _cmdManager;
}

- (QCReceiptManager *)receiptManager {
    return  [QCReceiptManager shared];
}

- (QCReactionManager *)reactionManager {
    return [QCReactionManager shared];
}

- (QCRobotManager *)robotManager {
    return [QCRobotManager shared];
}

- (QCReminderManager *)reminderManager {
    return [QCReminderManager shared];
}

- (QCFlameManager *)flameManager {
    return [QCFlameManager shared];
}

- (QCPinnedMessageManager *)pinnedMessageManager {
    return QCPinnedMessageManager.shared;
}


-(QCCoder*) coder{
    if(!_coder){
        _coder =[QCCoder new];
    }
    return _coder;
}

-(BOOL) isDebug{
    return self.options.isDebug;
}

- (NSString *)sdkVersion {
    return @"1.0.0";
}


-(void) registerMessageContent:(Class)cls {
    if (cls && [cls respondsToSelector:@selector(contentType)]) {
        NSNumber *contentType = [cls contentType];
        [self registerMessageContent:cls contentType:contentType.integerValue];
    } else {
        NSLog(@"Error: Class does not respond to contentType or is nil");
    }
}

-(void) registerMessageContent:(Class)cls contentType:(NSInteger)contentType {
    [self.messageContentDictLock lock];
    [self.messageContentDict setObject:cls forKey:[NSString stringWithFormat:@"%li",contentType]];
    [self.messageContentDictLock unlock];
}

-(Class) getMessageContent:(NSInteger)contentType {
    [self.messageContentDictLock lock];
    Class cls =  [self.messageContentDict objectForKey:[NSString stringWithFormat:@"%li",contentType]];
    if(cls) {
        [self.messageContentDictLock unlock];
        return cls;
    }
    if([self isSystemMessage:contentType]) { // 系统消息
         [self.messageContentDictLock unlock];
        return [QCSystemContent class];
    }
    [self.messageContentDictLock unlock];
    return [QCUnknownContent class];
}

- (QCMessageFileUploadTask *)getMessageFileUploadTask:(QCMessage *)message {
    return [self.mediaManager.taskManager get:[NSString stringWithFormat:@"%u",message.clientSeq]];
}
-(QCMessageFileDownloadTask*) getMessageDownloadTask:(QCMessage*)message {
     return [self.mediaManager.taskManager get:[NSString stringWithFormat:@"%u",message.clientSeq]];
}

-(BOOL) isSystemMessage:(NSInteger)contentType {
    return contentType >= 1000 && contentType<=2000;
}

-(void) setOfflineMessageProvider:(QCOfflineMessagePull) offlineMessagePull offlineMessagesAck:(QCOfflineMessageAck) offlineMessageAckCallback {
    self.offlineMessagePullInner = offlineMessagePull;
    self.offlineMessageAckInner = offlineMessageAckCallback;
}

- (QCOfflineMessagePull)offlineMessagePull {
    return self.offlineMessagePullInner;
}
- (QCOfflineMessageAck)offlineMessageAck {
    return self.offlineMessageAckInner;
}

@end
