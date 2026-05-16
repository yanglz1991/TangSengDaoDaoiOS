//
//  QCConversationVM.m
//  QCCore
//
//  Created by tt on 2022/5/19.
//

#import "QCConversationVM.h"
#import "QCCore.h"

@interface QCConversationVM ()


@end

@implementation QCConversationVM

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addListeners];
    }
    return self;
}

- (void)dealloc {
    [self removeListeners];
}

- (NSArray<QCChannelMember *> *)getAllMembers {
    return [[QCSDK shared].channelManager getMembersWithChannel:self.channel];
}


- (QCChannelMember *)memberOfMe {
    if(!_memberOfMe) {
        _memberOfMe = [[QCChannelMemberDB shared] get:self.channel memberUID:[QCApp shared].loginInfo.uid];
    }
    return _memberOfMe;
}

-(QCGroupType) groupType {
    
    return  [QCChannelUtil groupType:self.channelInfo];
}


-(void) syncMembersIfNeed{
    if(self.channel.channelType == WK_GROUP) {
        [[QCGroupManager shared] syncMemebers:self.channel.channelId];
    }
   
}

-(void) typing {
    [[QCAPIClient sharedClient] POST:@"message/typing" parameters:@{
        @"channel_id": self.channel.channelId,
        @"channel_type":@(self.channel.channelType),
    }];
}
-(void) requestMembers {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        weakSelf.members = [weakSelf getAllMembers];
        weakSelf.memberOfMe = nil;
        lim_dispatch_main_async_safe(^{
            if(weakSelf.onMemberUpdate) {
                weakSelf.onMemberUpdate();
            }
        });
        
        [weakSelf syncMembersIfNeed];
    });
    
}

- (NSInteger)memberCount {
    if(self.groupType == QCGroupTypeSuper) {
        if(self.channelInfo && self.channelInfo.extra[@"member_count"]) {
            return [self.channelInfo.extra[@"member_count"] integerValue];
        }
    }else {
        NSArray<QCChannelMember*> *members = self.members;
        return members?members.count:0;
    }
    return 0;
}

- (QCMemberRole)memberRole {
    if(self.groupType == QCGroupTypeSuper) {
        if(self.channelInfo && self.channelInfo.extra[@"role"]) {
            return [self.channelInfo.extra[@"role"] integerValue];
        }
    }else {
        QCChannelMember *memberOfMe = self.memberOfMe;
        if(memberOfMe) {
            return  memberOfMe.role;
        }
    }
    return QCMemberRoleCommon;
}
- (NSInteger)forbiddenExpirTime {
    if(self.groupType == QCGroupTypeSuper) {
        if(self.channelInfo && self.channelInfo.extra[@"role"]) {
            return [self.channelInfo.extra[@"role"] integerValue];
        }
    }else {
        QCChannelMember *memberOfMe = self.memberOfMe;
        if(memberOfMe && memberOfMe.extra[@"forbidden_expir_time"]) {
            NSInteger forbiddenExpirTime = [memberOfMe.extra[@"forbidden_expir_time"] integerValue];
            return  forbiddenExpirTime;
        }
    }
    return 0;
}

-(void) addListeners {
    // 监听群成员更新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMemberUpdate) name:QCNOTIFY_GROUP_MEMBERUPDATE object:nil];
}

-(void) removeListeners {
    // 移除监听群成员更新
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QCNOTIFY_GROUP_MEMBERUPDATE object:nil];
}

-(void) handleMemberUpdate {
    __weak typeof(self) weakSelf = self;
    self.members = [self getAllMembers];
    weakSelf.memberOfMe = nil;
    QCChannelMember *me = self.memberOfMe;
    NSLog(@"[禁言追踪][QCConversationVM] handleMemberUpdate channel=%@ memberOfMe.uid=%@ forbidden_expir_time=%@",
          self.channel.channelId, me.memberUid, me.extra[@"forbidden_expir_time"]);
    lim_dispatch_main_async_safe(^{
        if(weakSelf.onMemberUpdate) {
            weakSelf.onMemberUpdate();
        }
    });
}



@end


