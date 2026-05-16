//
//  QCChannelManager.m
//  WuKongIMSDK
//
//  Created by tt on 2019/12/23.
//

#import "QCChannelManager.h"
#import "QCSDK.h"
#import "QCChannelInfoDB.h"
#import "QCChannelMemberDB.h"
#import "QCMediaUtil.h"
#import "QCChannelRequestQueue.h"
#import "QCMemoryCache.h"


@interface QCChannelManager ()

@property(nonatomic,strong) NSMutableDictionary *cacheDict;
@property(nonatomic,strong) NSLock *cacheDictLock;

/**
 *  用来存储所有添加j过的delegate
 *  NSHashTable 与 NSMutableSet相似，但NSHashTable可以持有元素的弱引用，而且在对象被销毁后能正确地将其移除。
 */
@property (strong, nonatomic) NSHashTable  *delegates;
/**
 *  delegateLock 用于给delegate的操作加锁，防止多线程同时调用
 */
@property (strong, nonatomic) NSLock  *delegateLock;

@property(nonatomic,strong) NSMutableDictionary<NSString*,NSMutableArray<QCChannelInfoBlock>*> *channelReqeusts;
@property(nonatomic,strong) NSLock *channelReqeustLock;

@property(nonatomic,strong) QCMemoryCache *channelMemberCache; // 频道成员内存缓存

@end

@implementation QCChannelManager


static QCChannelManager *_instance;
+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
+ (QCChannelManager *)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        [_instance setup];
    });
    return _instance;
}

-(void) setup {
   NSArray<QCChannelInfo*> *channelInfos = [[QCChannelInfoDB shared] queryAllConversationChannelInfos];
    if(channelInfos && channelInfos.count>0) {
        for (QCChannelInfo *channelInfo in channelInfos) {
            [self setCache:channelInfo];
        }
    }
    self.channelMemberCache = [[QCMemoryCache alloc] init];
    self.channelMemberCache.maxCacheNum = 100000;
}

-(QCTaskOperator*) fetchChannelInfo:(QCChannel*) channel completion:(QCChannelInfoBlock)channelInfoBlock {
    NSString *key = [NSString stringWithFormat:@"%@-%d",channel.channelId,channel.channelType];
    [self.channelReqeustLock lock];
    NSMutableArray<QCChannelInfoBlock> *blockArray =  self.channelReqeusts[key];
    [self.channelReqeustLock unlock];
    if(blockArray && blockArray.count>0) { // 如果有值，则是重复请求，不处理
        [blockArray addObject:^(QCChannelInfo* channelInfo){
            if(channelInfoBlock) {
                channelInfoBlock(channelInfo);
            }
        }];
        return nil;
    }
    blockArray = [NSMutableArray array];
    [blockArray addObject:^(QCChannelInfo* channelInfo){
        if(channelInfoBlock) {
            channelInfoBlock(channelInfo);
        }
    }];
    
    [self.channelReqeustLock lock];
    self.channelReqeusts[key] = blockArray;
    [self.channelReqeustLock unlock];
    
    __weak typeof(self) weakSelf = self;
   return [QCSDK shared].channelInfoUpdate(channel,^(NSError *error,bool notifyBefore){
        if(notifyBefore) {
            return;
        }
         [weakSelf.channelReqeustLock lock];
        NSArray<QCChannelInfoBlock> *allBlock =  weakSelf.channelReqeusts[key];
         [weakSelf.channelReqeusts removeObjectForKey:key];
         [weakSelf.channelReqeustLock unlock];
        if(allBlock && allBlock.count>0) {
            QCChannelInfo *channelInfo = [[QCChannelInfoDB shared] queryChannelInfo:channel];
            for (QCChannelInfoBlock channelInfoBlock in allBlock) {
                 channelInfoBlock(channelInfo);
            }
        }
    });
}

-(void) fetchChannelInfo:(QCChannel*) channel {
    [self fetchChannelInfo:channel completion:nil];
}

-(void) addChannelRequest:(QCChannel*)channel complete:(void(^_Nullable)(NSError *error,bool notifyBefore))complete{
    [[QCChannelRequestQueue shared] addRequest:channel complete:complete];
}

-(void) cancelRequest:(QCChannel*)channel {
    [[QCChannelRequestQueue shared] cancelRequest:channel];
}

-(QCChannelInfo*) getChannelInfo:(QCChannel*)channel {
//    NSLog(@"getChannelInfo---->%@",channel.channelId);
    QCChannelInfo *channelInfo = [self getCache:channel];
    if(!channelInfo) {
        channelInfo = [[QCChannelInfoDB shared] queryChannelInfo:channel];
        if(channelInfo) {
            [self setCache:channelInfo];
        }
    }
    return channelInfo;
}

-(QCChannelInfo*) getChannelInfoOfUser:(NSString*)uid {
    return [self getChannelInfo:[QCChannel personWithChannelID:uid]];
}

-(void) deleteChannelInfo:(QCChannel*) channel {
    if(!channel.channelId || [channel.channelId isEqualToString:@""]) {
        return;
    }
    
    QCChannelInfo *oldChannelInfo = [self getChannelInfo:channel];
    
    [self deleteCache:channel];
    // 删除频道的基础信息
    [[QCChannelInfoDB shared] deleteChannelInfo:channel];
    // 删除频道的成员数据
    [[QCChannelMemberDB shared] deleteMembers:channel];
    // 通知删除
    [self callChannelInfoDeleteDelegate:channel oldChannelInfo:oldChannelInfo];
    
}

- (NSMutableDictionary *)channelReqeusts {
    if(!_channelReqeusts) {
        _channelReqeusts = [NSMutableDictionary dictionary];
    }
    return _channelReqeusts;
}

- (NSLock *)channelReqeustLock {
    if(!_channelReqeustLock) {
        _channelReqeustLock = [[NSLock alloc] init];
    }
    return _channelReqeustLock;
}

-(void) addChannelInfo:(QCChannelInfo*) channelInfo {
    [[QCChannelInfoDB shared] saveChannelInfo:channelInfo];
    [self setCache:channelInfo];
    [self callChannelInfoUpdateDelegate:channelInfo oldChannelInfo:nil];
}

-(void) addOrUpdateChannelInfoIfNeed:(QCChannelInfo*) channelInfo {
   QCChannelInfo *existChannelInfo =  [self getChannelInfo:channelInfo.channel];
    if(existChannelInfo && existChannelInfo.version >= channelInfo.version) { // 如果存在并且版本号大于传入频道信息的版本号则不更新
        return;
    }
    if(existChannelInfo) {
        [self updateChannelInfo:channelInfo];
    }else {
        [self addChannelInfo:channelInfo];
    }
    
}
-(void) addOrUpdateChannelInfo:(QCChannelInfo*) channelInfo {
    QCChannelInfo *existChannelInfo =  [self getChannelInfo:channelInfo.channel];
    if(existChannelInfo) {
        [self updateChannelInfo:channelInfo];
    }else {
        [self addChannelInfo:channelInfo];
    }
}

-(void) updateChannelSetting:(QCChannel*)channel setting:(NSDictionary*)setting {
     QCChannelInfo *channelInfo =  [self getChannelInfo:channel];
    if(channelInfo) {
        for (NSString *key in setting.allKeys) {
            if([key isEqualToString:@"mute"]) { // 免打扰
                channelInfo.mute = [setting[key] boolValue];
            }
            if([key isEqualToString:@"stick"]) { // 置顶
                channelInfo.stick = [setting[key] boolValue];
            }
            if([key isEqualToString:@"show_nick"]) { // 置顶
                channelInfo.showNick = [setting[key] boolValue];
            }
            if([key isEqualToString:@"save"]) { // 保存
                channelInfo.save = [setting[key] boolValue];
            }
            if([key isEqualToString:@"invite"]) { // 确认邀请
                channelInfo.invite = [setting[key] boolValue];
            }
            if([key isEqualToString:@"flame"]) { // 阅后即焚
                channelInfo.flame = [setting[key] boolValue];
            }
            if([key isEqualToString:@"flame_second"] && setting[key] ) { // 阅后即焚
                channelInfo.flameSecond = [setting[key] integerValue];
            }
             [self updateChannelInfo:channelInfo];
        }
    }
}

-(void) addOrUpdateChannelInfos:(NSArray<QCChannelInfo*>*) channelInfos {
     NSArray<QCChannelInfo*> *oldChannelInfos = [[QCChannelInfoDB shared] addOrUpdateChannelInfos:channelInfos];
    if(channelInfos && channelInfos.count>0) {
        for (QCChannelInfo *channelInfo in channelInfos) {
            [self setCache:channelInfo];
            QCChannelInfo *oldChannelInfo;
            if(oldChannelInfos && oldChannelInfos.count>0) {
                for (QCChannelInfo *oldC in oldChannelInfos) {
                    if([oldC.channel isEqual:channelInfo.channel]) {
                        oldChannelInfo = oldC;
                        break;
                    }
                }
            }
            [self callChannelInfoUpdateDelegate:channelInfo oldChannelInfo:oldChannelInfo];
        }
       
    }
}

-(void) deleteMembers:(QCChannel*)channel {
    [self deleteMembersWithChannelFromCache:channel];
    [[QCChannelMemberDB shared] deleteMembers:channel];
}

-(void) addOrUpdateMembers:(NSArray<QCChannelMember*>*)members {
    if(!members || members.count == 0) {
        return;
    }
    QCChannel *channel = [QCChannel channelID:members[0].channelId channelType:members[0].channelType];
    [self deleteMembersWithChannelFromCache:channel];
    [[QCChannelMemberDB shared] addOrUpdateMembers:members];
}

-(NSArray<QCChannelMember*>*) getMembersWithChannel:(QCChannel*)channel {
   NSArray<QCChannelMember*> *members = [self getMembersWithChannelFromCache:channel];
    if(members && members.count>0) {
        return members;
    }
    members = [[QCChannelMemberDB shared] getMembersWithChannel:channel];
    

    [self setMembersForCache:channel members:members];
    
    return members;
}

-(NSArray<QCChannelMember*>*) getMembersWithChannel:(QCChannel*)channel limit:(NSInteger)limit {
    return [[QCChannelMemberDB shared] getMembersWithChannel:channel limit:limit];
}

-(NSInteger) getMemberCount:(QCChannel*)channel {
    return [[QCChannelMemberDB shared] getMemberCount:channel];
}



-(QCChannelMember*)getMember:(QCChannel*)channel uid:(NSString*)uid {
    QCChannelMember *member =  [self getMemberFromCache:channel uid:uid];
    if(member) {
        return member;
    }
    member =  [[QCChannelMemberDB shared] get:channel memberUID:uid];
    return member;
}

-(BOOL) isManager:(QCChannel*)channel memberUID:(NSString*)uid {
    QCChannelMember *member = [self getMember:channel uid:uid];
    if(!member) {
        return false;
    }
    if(member.role == QCMemberRoleCreator || member.role == QCMemberRoleManager) {
        return true;
    }
    return false;
}

- (NSString *)getMemberLastSyncKey:(QCChannel *)channel {
    return [[QCChannelMemberDB shared] getMemberLastSyncKey:channel];
}

-(void) updateChannelInfo:(QCChannelInfo*) channelInfo {
    QCChannelInfo *oldChannelInfo = [[QCChannelInfoDB shared] queryChannelInfo:channelInfo.channel];
    [[QCChannelInfoDB shared] updateChannelInfo:channelInfo];
    [self setCache:channelInfo];
    [self callChannelInfoUpdateDelegate:channelInfo oldChannelInfo:oldChannelInfo];
}

-(void) setChannelOnline:(QCChannel*)channel deviceFlag:(QCDeviceFlagEnum)deviceFlag{
    QCChannelInfo *existChannelInfo =  [self getChannelInfo:channel];
    if(existChannelInfo) {
        QCChannelInfo *oldChannelInfo = [existChannelInfo copy];
        existChannelInfo.online = true;
        existChannelInfo.deviceFlag = deviceFlag;
        [[QCChannelInfoDB shared] updateChannelOnlineStatus:channel status:QCOnlineStatusOnline lastOffline:0 mainDeviceFlag:deviceFlag];
         [self callChannelInfoUpdateDelegate:existChannelInfo oldChannelInfo:oldChannelInfo];
    }
    
}

- (void)setChannelOnline:(QCChannel *)channel {
    [self setChannelOnline:channel deviceFlag:QCDeviceFlagEnumUnknown];
}

- (void)setChannelOffline:(QCChannel *)channel {
    [self setChannelOffline:channel lastOffline:[[NSDate date] timeIntervalSince1970]];
}

- (void)setChannelOffline:(QCChannel *)channel deviceFlag:(QCDeviceFlagEnum)deviceFlag{
    [self setChannelOffline:channel lastOffline:[[NSDate date] timeIntervalSince1970] deviceFlag:deviceFlag];
}

- (void)setChannelOffline:(QCChannel *)channel lastOffline:(NSTimeInterval)lastOffline {
    [self setChannelOffline:channel lastOffline:lastOffline deviceFlag:QCDeviceFlagEnumUnknown];
}

- (void)setChannelOffline:(QCChannel *)channel lastOffline:(NSTimeInterval)lastOffline deviceFlag:(QCDeviceFlagEnum)deviceFlag {
    QCChannelInfo *existChannelInfo =  [self getChannelInfo:channel];
    if(existChannelInfo) {
        QCChannelInfo *oldChannelInfo = [existChannelInfo copy];
        existChannelInfo.online = false;
        existChannelInfo.lastOffline =lastOffline;
        existChannelInfo.deviceFlag = deviceFlag;
       [[QCChannelInfoDB shared] updateChannelOnlineStatus:channel status:QCOnlineStatusOffline lastOffline:lastOffline mainDeviceFlag:deviceFlag];
        
        [self callChannelInfoUpdateDelegate:existChannelInfo oldChannelInfo:oldChannelInfo];
    }
}

-(void) updateChannelOnlineStatus:(QCChannel*)channel online:(BOOL)online {
    QCChannelInfo *existChannelInfo =  [self getChannelInfo:channel];
    if(existChannelInfo) {
        QCChannelInfo *oldChannelInfo = [existChannelInfo copy];
        
        existChannelInfo.online = online;
       [[QCChannelInfoDB shared] updateChannelInfo:existChannelInfo];
        
        [self callChannelInfoUpdateDelegate:existChannelInfo oldChannelInfo:oldChannelInfo];
    }
}

-(void) setCache:(QCChannelInfo*) channelInfo {
     [self.cacheDictLock lock];
     self.cacheDict[[self getCacheChannelKey:channelInfo.channel]] = channelInfo;
     [self.cacheDictLock unlock];
}

-(void) deleteCache:(QCChannel*)channel {
    [self.cacheDictLock lock];
    [self.cacheDict removeObjectForKey:[self getCacheChannelKey:channel]];
    [self.cacheDictLock unlock];
}

-(QCChannelMember*) getMemberFromCache:(QCChannel *)channel uid:(NSString *)uid {
    NSString *key = [NSString stringWithFormat:@"%@-%d",channel.channelId,channel.channelType];
    NSMutableArray<QCChannelMember*> *members =  [self.channelMemberCache getCache:key];
    if(!members||members.count<=0) {
        return nil;
    }
    for (QCChannelMember *member in members) {
        if([member.memberUid isEqualToString:uid]) {
            return member;
        }
    }
    return nil;
}

-(void) deleteMembersWithChannelFromCache:(QCChannel*)channel {
    NSString *key = [NSString stringWithFormat:@"%@-%d",channel.channelId,channel.channelType];
    [self.channelMemberCache setCache:nil forKey:key];
}

-(NSArray<QCChannelMember*>*) getMembersWithChannelFromCache:(QCChannel *)channel {
    NSString *key = [NSString stringWithFormat:@"%@-%d",channel.channelId,channel.channelType];
    return  [self.channelMemberCache getCache:key];
}

-(void) setMembersForCache:(QCChannel*)channel members:(NSArray<QCChannelMember*>*)members {
    NSString *key = [NSString stringWithFormat:@"%@-%d",channel.channelId,channel.channelType];
    [self.channelMemberCache setCache:members forKey:key];
}



-(QCChannelInfo*) getCache:(QCChannel*)channel {
    [self.cacheDictLock lock];
    QCChannelInfo *channelInfo = [self.cacheDict objectForKey:[self getCacheChannelKey:channel]];
    [self.cacheDictLock unlock];
    return channelInfo;
}

-(void) removeChannelAllCache {
    [self.cacheDictLock lock];
    [self.cacheDict removeAllObjects];
    [self.cacheDictLock unlock];
}

-(NSString*) getCacheChannelKey:(QCChannel*)channel {
    return [NSString stringWithFormat:@"%@-%hhu",channel.channelId,channel.channelType];
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

-(NSMutableDictionary*) cacheDict {
    if(!_cacheDict) {
        _cacheDict = [[NSMutableDictionary alloc] init];
    }
    return _cacheDict;
}

-(NSLock*) cacheDictLock {
    if(!_cacheDictLock) {
        _cacheDictLock = [[NSLock alloc] init];
    }
    return _cacheDictLock;
}

-(void) addDelegate:(id<QCChannelManagerDelegate>) delegate{
    [self.delegateLock lock];//防止多线程同时调用
    [self.delegates addObject:delegate];
    [self.delegateLock unlock];
}
- (void)removeDelegate:(id<QCChannelManagerDelegate>) delegate {
    [self.delegateLock lock];//防止多线程同时调用
    [self.delegates removeObject:delegate];
    [self.delegateLock unlock];
}

- (void)callChannelInfoUpdateDelegate:(QCChannelInfo*)channelInfo oldChannelInfo:(QCChannelInfo*)oldChannelInfo{
    [self.delegateLock lock];
    NSHashTable *copyDelegates =  [self.delegates copy];
    [self.delegateLock unlock];
    for (id delegate in copyDelegates) {//遍历delegates ，call delegate
        
        if(delegate && [delegate respondsToSelector:@selector(channelInfoUpdate:)]) {
            if (![NSThread isMainThread]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                     [delegate channelInfoUpdate:channelInfo];
                });
            }else{
                [delegate channelInfoUpdate:channelInfo];
            }
        } else if (delegate && [delegate respondsToSelector:@selector(channelInfoUpdate:oldChannelInfo:)]) {
            if (![NSThread isMainThread]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                     [delegate channelInfoUpdate:channelInfo oldChannelInfo:oldChannelInfo];
                });
            }else{
                [delegate channelInfoUpdate:channelInfo oldChannelInfo:oldChannelInfo];
            }
            
        }
    }
}

- (void)callChannelInfoDeleteDelegate:(QCChannel*)channel oldChannelInfo:(QCChannelInfo*)oldChannelInfo{
    [self.delegateLock lock];
    NSHashTable *copyDelegates =  [self.delegates copy];
    [self.delegateLock unlock];
    for (id delegate in copyDelegates) {//遍历delegates ，call delegate
        if (delegate && [delegate respondsToSelector:@selector(channelInfoDelete:oldChannelInfo:)]) {
            if (![NSThread isMainThread]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                     [delegate channelInfoDelete:channel oldChannelInfo:oldChannelInfo];
                });
            }else{
                [delegate channelInfoDelete:channel oldChannelInfo:oldChannelInfo];
            }
        }
    }
}

@end
