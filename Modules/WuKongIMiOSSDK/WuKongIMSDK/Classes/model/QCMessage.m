//
//  QCMessage.m
//  WuKongIMSDK
//
//  Created by tt on 2019/11/27.
//

#import "QCMessage.h"
#import "QCChannelManager.h"
#import "QCMemoryCache.h"
#import "QCSDK.h"
#import "QCMessageDB.h"

@implementation QCMessageHeader

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.showUnread = false;
    }
    return self;
}

- (BOOL)noPersist {
    return _noPersist;
}

@end

@interface QCMessage ()
@property(nonatomic,assign) NSInteger contentTypeInner;
@property(nonatomic,strong) NSMutableArray<QCStream*> *streamsInner;
@end

@implementation QCMessage

- (QCMessageHeader *)header {
    if(!_header) {
        _header = [QCMessageHeader new];
    }
    return _header;
}
- (QCSetting *)setting {
    if(!_setting) {
        _setting = [QCSetting new];
    }
    return  _setting;
}

- (void)setContent:(QCMessageContent *)content {
    _content = content;
    _content.message = self;
}

-(QCChannelInfo*) channelInfo {
    return [[QCChannelManager shared] getChannelInfo:self.channel];
}

- (QCChannelInfo *)from {
    if(!_from) {
        _from = [[QCChannelManager shared] getChannelInfo:[[QCChannel alloc] initWith:self.fromUid channelType:WK_PERSON]];
    }
     return _from;
}

- (QCChannelMember *)memberOfFrom {
   
    return [[QCChannelManager shared] getMember:self.channel uid:self.fromUid];
}
- (BOOL)isSend {
    if(!self.fromUid || [self.fromUid isEqualToString:@""] || [self.fromUid isEqualToString:[QCSDK shared].options.connectInfo.uid]) {
        return true;
    }
    return false;
}

- (id<QCTaskProto>)task {
    return [[QCSDK shared].mediaManager.taskManager get:[NSString stringWithFormat:@"%u",self.clientSeq]];
}

- (NSMutableDictionary *)extra {
    if(!_extra) {
        _extra = [[NSMutableDictionary alloc] init];
    }
    return _extra;
}

- (QCMessageExtra *)remoteExtra {
    if(!_remoteExtra) {
        _remoteExtra = [[QCMessageExtra alloc] init];
    }
    return _remoteExtra;
}

- (NSInteger)contentType {
    if(_contentTypeInner !=0) {
        return _contentTypeInner;
    }
    return self.content.realContentType;
}

- (BOOL)streamOn {
    if(self.streamNo && ![self.streamNo isEqualToString:@""]) {
        return true;
    }
    return false;
}

- (void)setContentType:(NSInteger)contentType {
    _contentTypeInner = contentType;
}

-(BOOL) isEqual:(id)obj{
    if(self == obj) {
        return YES;
    }
    QCMessage *cm = (QCMessage*)obj;
    if(self.messageId == cm.messageId) {
        return YES;
    }
    
    return NO;
}

- (NSUInteger)hash {
    return [[NSString stringWithFormat:@"%llu",self.messageId] hash];
}




@end

@interface QCChannelMemberCache : NSObject

@end
