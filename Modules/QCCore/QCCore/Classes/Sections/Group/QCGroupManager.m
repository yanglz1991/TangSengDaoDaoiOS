//
//  QCGroupManager.m
//  QCCore
//
//  Created by tt on 2020/1/19.
//

#import "QCGroupManager.h"
#import "QCConstant.h"
#import "QCAPIClient.h"
#import "QCChannelUtil.h"
typedef void(^syncMemberComplete)(NSInteger count,NSError *error);

typedef void(^syncGroupComplete)(NSError *error,bool notifyBefore);

@interface QCGroupManager ()

@property(nonatomic,strong) NSMutableDictionary<NSString*,NSMutableArray*> *syncMembersRequestDict;

@property(nonatomic,strong) NSLock *syncMembersRequestLock;

// 标记某个 groupNo 的成员 sync 正在跑时，外部又发起了新的 syncMemebers 请求。
// 解决场景：旧 sync 用的是过期的 syncKey，已经在路上无法取消，新请求被合并到旧请求的 complete
// 字典中。等旧 sync 响应回来时其数据并不包含本次禁言/角色变更后的成员，VM 拿到旧数据 → UI 不生效。
// 因此在旧 sync 完成时，如发现此标志为 YES，立即用最新 syncKey 再发起一次拉取，保证最终一致性。
@property(nonatomic,strong) NSMutableSet<NSString*> *pendingResyncMembersSet;

@property(nonatomic,strong) NSMutableDictionary<NSString*,NSMutableArray*> *syncRequestDict;
@property(nonatomic,strong) NSLock *syncRequestLock;

@end

@implementation QCGroupManager

static QCGroupManager *_instance;
+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
+ (QCGroupManager *)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        _instance.syncMembersRequestLock = [[NSLock alloc] init];
        _instance.syncMembersRequestDict = [NSMutableDictionary dictionary];
        _instance.pendingResyncMembersSet = [NSMutableSet set];
        _instance.syncRequestDict = [NSMutableDictionary dictionary];
        _instance.syncRequestLock =[[NSLock alloc] init];
    });
    return _instance;
}


//- (NSLock *)syncMembersRequestLock {
//    if(!_syncMembersRequestLock) {
//        _syncMembersRequestLock = [[NSLock alloc] init];
//    }
//    return _syncMembersRequestLock;
//}


-(void) putSyncMemberRequest:(NSString*)groupNo complete:(syncMemberComplete) complete {
    if(!complete) {
        complete = ^(NSInteger count,NSError *error){};
    }
    @try {
        [self.syncMembersRequestLock lock];
        NSMutableArray *completes = self.syncMembersRequestDict[groupNo];
        if(!completes) {
            completes = [NSMutableArray array];
        }
        [completes addObject:complete];
        self.syncMembersRequestDict[groupNo] = completes;
    } @finally {
        [self.syncMembersRequestLock unlock];
    }
   
}

-(BOOL) hasSyncMemberReqeust:(NSString*)groupNo {
    [self.syncMembersRequestLock lock];
    NSArray *completes = self.syncMembersRequestDict[groupNo];
    [self.syncMembersRequestLock unlock];
    if(completes && completes.count>0) {
        return true;
    }
    return false;
}

-(void) putSyncRequest:(NSString*)groupNo complete:(syncGroupComplete) complete {
    if(!complete) {
        complete = ^(NSError *error,bool notifyBefore){};
    }
    @try {
        [self.syncRequestLock lock];
        NSMutableArray *completes = self.syncRequestDict[groupNo];
        if(!completes) {
            completes = [NSMutableArray array];
        }
        [completes addObject:complete];
        self.syncRequestDict[groupNo] = completes;
    } @finally {
        [self.syncRequestLock unlock];
    }
   
}

-(BOOL) hasSyncGroupRequest:(NSString*)groupNo {
    [self.syncRequestLock lock];
    NSArray *completes = self.syncRequestDict[groupNo];
    [self.syncRequestLock unlock];
    if(completes && completes.count>0) {
        return true;
    }
    return false;
}

-(void) removeSyncMemberReqeuest:(NSString*)groupNo {
     [self.syncMembersRequestLock lock];
    [self.syncMembersRequestDict removeObjectForKey:groupNo];
    [self.syncMembersRequestLock unlock];
}


-(void) removeSyncReqeuest:(NSString*)groupNo {
     [self.syncRequestLock lock];
    [self.syncRequestDict removeObjectForKey:groupNo];
    [self.syncRequestLock unlock];
}

-(void) executeSyncMemberComplete:(NSString*)groupNo syncMemberCount:(NSInteger)syncMemberCount error:(NSError*) error {
    @try {
         [self.syncMembersRequestLock lock];
        NSMutableArray *completes = self.syncMembersRequestDict[groupNo];
        if(completes) {
            for (syncMemberComplete complete in completes) {
                if(complete) {
                    complete(syncMemberCount,error);
                }
            }
        }
    } @finally {
         [self.syncMembersRequestLock unlock];
    }
    
}

-(void) executeSyncComplete:(NSString*)groupNo  error:(NSError*) error notifyBefore:(BOOL)notifyBefore{
    @try {
         [self.syncRequestLock lock];
        NSMutableArray *completes = self.syncRequestDict[groupNo];
        if(completes) {
            for (syncGroupComplete complete in completes) {
                if(complete) {
                    complete(error,notifyBefore);
                }
            }
        }
    } @finally {
         [self.syncRequestLock unlock];
    }
    
}

-(void) createGroup:(NSArray<NSString*>*)members object:(id)object complete:(void(^)(NSString* groupNo,NSError *error))complete {
    if(_delegate && [_delegate respondsToSelector:@selector(groupManager:createGroup:object:complete:)]) {
        [_delegate groupManager:self createGroup:members object:object complete:complete];
    }
}

-(void) syncGroupInfo:(NSString*)groupNo complete:(void(^__nullable)(NSError *error,bool notifyBefore))complete {
    if(_delegate && [_delegate respondsToSelector:@selector(groupManager:syncGroupInfo:complete:)]) {
        __weak typeof(self) weakSelf = self;
        if([self hasSyncGroupRequest:groupNo]) { // 有同步请求，则不再进行请求，最后只做回调
            [self putSyncRequest:groupNo complete:complete]; // 放入同步请求
        } else {
             [self putSyncRequest:groupNo complete:complete]; // 放入同步请求
            [_delegate groupManager:weakSelf syncGroupInfo:groupNo complete:^(NSError *error,bool notifyBefore){
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                   [weakSelf executeSyncComplete:groupNo error:error notifyBefore:notifyBefore]; // 执行同步返回方法
                    [weakSelf removeSyncReqeuest:groupNo]; // 移除同步方法
                });
            }];
        }
    }
}

-(NSURLSessionDataTask*) taskSyncGroupInfo:(NSString*)groupNo complete:(void(^__nullable)(NSError *error,bool notifyBefore))complete {
    if(_delegate && [_delegate respondsToSelector:@selector(taskGroupManager:syncGroupInfo:complete:)]) {
        __weak typeof(self) weakSelf = self;
        if([self hasSyncGroupRequest:groupNo]) { // 有同步请求，则不再进行请求，最后只做回调
            [self putSyncRequest:groupNo complete:complete]; // 放入同步请求
        } else {
             [self putSyncRequest:groupNo complete:complete]; // 放入同步请求
            return  [_delegate taskGroupManager:weakSelf syncGroupInfo:groupNo complete:^(NSError *error,bool notifyBefore){
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                   [weakSelf executeSyncComplete:groupNo error:error notifyBefore:notifyBefore]; // 执行同步返回方法
                    [weakSelf removeSyncReqeuest:groupNo]; // 移除同步方法
                });
            }];
        }
    }
    return nil;
}

-(void)  syncMemebers:(NSString*)groupNo complete:(syncMemberComplete)complete {
    if(!_delegate || ![_delegate respondsToSelector:@selector(groupManager:syncMemebers:complete:)]) {
        NSLog(@"[禁言追踪][QCGroupManager] syncMemebers no delegate, groupNo=%@", groupNo);
        return;
    }
    if([self hasSyncMemberReqeust:groupNo]) {
        NSLog(@"[禁言追踪][QCGroupManager] syncMemebers MERGED to running request, groupNo=%@ → mark pendingResync", groupNo);
        [self putSyncMemberRequest:groupNo complete:complete];
        [self.syncMembersRequestLock lock];
        [self.pendingResyncMembersSet addObject:groupNo];
        [self.syncMembersRequestLock unlock];
        return;
    }
    NSLog(@"[禁言追踪][QCGroupManager] syncMemebers START NEW request, groupNo=%@", groupNo);
    [self putSyncMemberRequest:groupNo complete:complete];
    __weak typeof(self) weakSelf = self;
    [_delegate groupManager:self syncMemebers:groupNo complete:^(NSInteger syncMemberCount,NSError *error){
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) self = weakSelf;
            if(!self) return;
            NSLog(@"[禁言追踪][QCGroupManager] syncMemebers FINISH groupNo=%@ count=%ld err=%@", groupNo, (long)syncMemberCount, error);
            [self executeSyncMemberComplete:groupNo syncMemberCount:syncMemberCount error:error];
            [self removeSyncMemberReqeuest:groupNo];

            [self.syncMembersRequestLock lock];
            BOOL needResync = [self.pendingResyncMembersSet containsObject:groupNo];
            if(needResync) {
                [self.pendingResyncMembersSet removeObject:groupNo];
            }
            [self.syncMembersRequestLock unlock];

            if(!error && syncMemberCount>0) {
                NSLog(@"[禁言追踪][QCGroupManager] post QCNOTIFY_GROUP_MEMBERUPDATE groupNo=%@", groupNo);
                [[NSNotificationCenter defaultCenter] postNotificationName:QCNOTIFY_GROUP_MEMBERUPDATE object:@{@"group_no":groupNo}];
            }

            if(needResync) {
                NSLog(@"[禁言追踪][QCGroupManager] pendingResync=YES, RE-SYNC groupNo=%@", groupNo);
                [self syncMemebers:groupNo complete:nil];
            }
        });
    }];
}

-(void)  syncMemebers:(NSString*)groupNo {
    if(_delegate && [_delegate respondsToSelector:@selector(groupManager:syncMemebers:complete:)]) {
        [self syncMemebers:groupNo complete:nil];
    }
}

-(void) searchMembers:(QCChannel*)channel keyword:(NSString*)keyword limit:(NSInteger)limit complete:(void(^)(QCChannelMemberCacheType cacheType,NSArray<QCChannelMember*>* members))complete {
    [self searchMembers:channel keyword:keyword page:1 limit:limit requestStrategy:QCRequestStrategyAll complete:complete];
}

-(void) searchMembers:(QCChannel*)channel keyword:(NSString * __nullable)keyword page:(NSInteger)page limit:(NSInteger)limit requestStrategy:(QCRequestStrategy)requestStrategy  complete:(void(^)(QCChannelMemberCacheType cacheType,NSArray<QCChannelMember*>*members))complete {
    
    BOOL needNetwork = false;
    BOOL needDB = false;
    
    if(requestStrategy == QCRequestStrategyAll) {
        needNetwork = true;
        needDB = true;
    }else if(requestStrategy == QCRequestStrategyOnlyDB) {
        needDB = true;
    }else if(requestStrategy == QCRequestStrategyOnlyNetwork) {
        needNetwork = true;
    }
    
    if(needDB) {
        [self searchMembersFromDB:channel keyword:keyword page:page limit:limit cacheType:QCChannelMemberCacheTypeDB complete:complete];
    }
    
    
    if(needNetwork) {
        __weak typeof(self) weakSelf = self;
        if(_delegate && [_delegate respondsToSelector:@selector(groupManager:searchMembers:keyword:page:limit:complete:)]) {
            [_delegate groupManager:self searchMembers:channel.channelId keyword:keyword page:page limit:limit complete:^(NSError * _Nullable error, NSArray<QCChannelMember *> * _Nonnull members) {
                if(!error) {
                    if(needDB) {
                        [[QCSDK shared].channelManager addOrUpdateMembers:members];
                        [weakSelf searchMembersFromDB:channel keyword:keyword page:page limit:limit cacheType:QCChannelMemberCacheTypeNetwork complete:complete];
                    }else {
                        if(complete) {
                            complete(QCChannelMemberCacheTypeNetwork,members);
                        }
                    }
                   
                    
                }
            }];
        }
    }
}

-(void) searchMembersFromDB:(QCChannel*)channel keyword:(NSString*)keyword page:(NSInteger)page limit:(NSInteger)limit cacheType:(QCChannelMemberCacheType)cacheType complete:(void(^)(QCChannelMemberCacheType cacheType,NSArray<QCChannelMember*>* members))complete {
    NSArray<QCChannelMember*> *members = [[QCChannelMemberDB shared] getMembersWithChannel:channel keyword:keyword page:page limit:limit];
    if(complete) {
        complete(cacheType,members);
    }
}

-(void) groupNo:(NSString*)groupNo membersOfAdd:(NSArray<NSString*>*)members object:(id __nullable)object complete:(void (^ _Nullable)(NSError * _Nonnull))complete{
    if(_delegate && [_delegate respondsToSelector:@selector(groupManager:groupNo:membersOfAdd:object:complete:)]) {
        [_delegate groupManager:self groupNo:groupNo membersOfAdd:members object:object complete:complete];
    }
}

-(void) groupNo:(NSString*)groupNo membersOfDelete:(NSArray<NSString*>*)members object:(id __nullable)object complete:(void(^__nullable)(NSError *error))complete {
    if(_delegate && [_delegate respondsToSelector:@selector(groupManager:groupNo:membersOfDelete:object:complete:)]) {
        [_delegate groupManager:self groupNo:groupNo membersOfDelete:members object:object complete:complete];
    }
}

-(void) groupNo:(NSString*)groupNo membersToManager:(NSArray<NSString*>*)members complete:(void(^__nullable)(NSError *error))complete {
    if(_delegate && [_delegate respondsToSelector:@selector(groupManager:groupNo:membersToManager:complete:)]) {
        [_delegate groupManager:self groupNo:groupNo membersToManager:members complete:complete];
    }
}

- (void)groupNo:(NSString *)groupNo managersToMember:(NSArray<NSString *> *)managers complete:(void (^)(NSError * _Nonnull))complete {
    if(_delegate && [_delegate respondsToSelector:@selector(groupManager:groupNo:managersToMember:complete:)]) {
           [_delegate groupManager:self groupNo:groupNo managersToMember:managers complete:complete];
       }
}

- (void)groupSetting:(NSString *)groupNo settingKey:(QCGroupSettingKey)key on:(BOOL)on {
    if(_delegate && [_delegate respondsToSelector:@selector(groupManagerSetting:groupNo:settingKey:on:)]) {
        [_delegate groupManagerSetting:self groupNo:groupNo settingKey:key on:on];
    }
}

- (void)groupSetting:(NSString *)groupNo key:(NSString*)key value:(id)value {
    if(_delegate && [_delegate respondsToSelector:@selector(groupManagerSetting:groupNo:key:value:)]) {
        [_delegate groupManagerSetting:self groupNo:groupNo key:key value:value];
    }
}

- (AnyPromise*)groupRemark:(NSString *)groupNo remark:(NSString*)remark {
    if(_delegate && [_delegate respondsToSelector:@selector(groupSettingRemark:groupNo:remark:)]) {
       return [_delegate groupSettingRemark:self groupNo:groupNo remark:remark];
    }
    return nil;
}

- (void)groupUpdate:(NSString *)groupNo attrKey:(NSString *)attrKey attrValue:(NSString *)attrValue complete:(void(^)(NSError * __nullable error))complete{
    if(_delegate && [_delegate respondsToSelector:@selector(groupManagerUpdate:groupNo:attrKey:attrValue:complete:)]) {
        [_delegate groupManagerUpdate:self groupNo:groupNo attrKey:attrKey attrValue:attrValue complete:complete];
    }
}

-(void) didMemberUpdateAtGroup:(NSString*)groupNo forMemberUID:(NSString*)memberUID withAtrr:(NSDictionary*)attr complete:(void(^__nullable)(NSError *error))complete {
    if(_delegate && [_delegate respondsToSelector:@selector(groupManager:didMemberUpdateAtGroup:forMemberUID:withAttr:complete:)]) {
        [_delegate groupManager:self didMemberUpdateAtGroup:groupNo forMemberUID:memberUID withAttr:attr complete:complete];
    }
}

-(void) didGroupExit:(NSString*)groupNo complete:(void(^__nullable)(NSError *error))complete{
    if(_delegate && [_delegate respondsToSelector:@selector(groupManager:didGroupExit:complete:)]) {
        [_delegate groupManager:self didGroupExit:groupNo complete:complete];
    }
}

-(void) didGroupDisband:(NSString*)groupNo complete:(void(^__nullable)(NSError *error))complete{
    if(_delegate && [_delegate respondsToSelector:@selector(groupManager:didGroupExit:complete:)]) {
        [_delegate groupManager:self didGroupDisband:groupNo complete:complete];
    }
}


@end
