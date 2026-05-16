//
//  QCOnlineStatusManager.m
//  WuKongBase
//
//  Created by tt on 2020/8/29.
//

#import "QCOnlineStatusManager.h"
#import "QCAPIClient.h"
#import "QCApp.h"
#import "WuKongBase.h"
@class QCOnlineStatusResp;
@interface QCOnlineStatusManager ()<QCConnectionManagerDelegate>



/**
 *  用来存储所有添加j过的delegate
 *  NSHashTable 与 NSMutableSet相似，但NSHashTable可以持有元素的弱引用，而且在对象被销毁后能正确地将其移除。
 */
@property (strong, nonatomic) NSHashTable  *delegates;
/**
 *  delegateLock 用于给delegate的操作加锁，防止多线程同时调用
 */
@property (strong, nonatomic) NSLock  *delegateLock;

@property(nonatomic,strong) QCFriendAndMyDeviceOnlineStatusResp *friendAndMyDeviceOnlineStatusResp;

@end

@implementation QCOnlineStatusManager

static QCOnlineStatusManager *_instance = nil;

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
        _instance.needUpdate = YES;
        [[QCSDK shared].connectionManager addDelegate:_instance];
    }
    return _instance;
}

- (BOOL)pcOnline {
    if(self.friendAndMyDeviceOnlineStatusResp && self.friendAndMyDeviceOnlineStatusResp.pc) {
        return self.friendAndMyDeviceOnlineStatusResp.pc.online;
    }
    return false;
}
- (QCDeviceFlagEnum)pcDeviceFlag {
    if(self.friendAndMyDeviceOnlineStatusResp && self.friendAndMyDeviceOnlineStatusResp.pc) {
        return self.friendAndMyDeviceOnlineStatusResp.pc.deviceFlag;
    }
    return QCDeviceFlagEnumWeb;
}

-(void) setChannelOnline:(QCChannel*)channel online:(BOOL)online deviceFlag:(QCDeviceFlagEnum)deviceFlag{
    // online 只表示当前在线/离线的设备 如果mainDeviceFlag有值 则表示当前用户在线的主设备，
    if(online) {
        [[QCSDK shared].channelManager setChannelOnline:channel deviceFlag:deviceFlag];
    }else {
        [[QCSDK shared].channelManager setChannelOffline:channel deviceFlag:deviceFlag];
    }
   

    QCOnlineStatusResp *resp = [QCOnlineStatusResp new];
    resp.deviceFlag = deviceFlag;
    resp.online = online;
    resp.uid = channel.channelId;
    [self callOnlineStatusChangeDelegate:resp];
}

//- (void)setChannelOnline:(QCOnlineStatusResp *)status  {
//    
//    [self setChannelOnline:[QCChannel personWithChannelID:status.uid] online:status.online deviceFlag:status.deviceFlag];
//}

- (void)requestUpdateChannelOnlineStatusIfNeed {
    if(!self.needUpdate) {
        return;
    }
    __weak typeof(self) weakSelf  = self;
    // 查询所有在线频道
    NSArray<QCChannelInfo*> *allOnlineChannelInfos = [[QCChannelInfoDB shared] queryChannelOnlines];
    [[QCAPIClient sharedClient] GET:@"user/online" parameters:nil model:QCFriendAndMyDeviceOnlineStatusResp.class].then(^(QCFriendAndMyDeviceOnlineStatusResp* onlineStatusResp){
        weakSelf.needUpdate = false;
        weakSelf.friendAndMyDeviceOnlineStatusResp = onlineStatusResp;
        if(onlineStatusResp.friends && onlineStatusResp.friends.count>0) {
            for (QCOnlineStatusResp *resp in onlineStatusResp.friends) {
                QCChannel *channel = [[QCChannel alloc] initWith:resp.uid channelType:WK_PERSON];
                if(resp.online) {
                    [[QCSDK shared].channelManager setChannelOnline:channel deviceFlag:resp.deviceFlag];
                }else {
                    [[QCSDK shared].channelManager setChannelOffline:channel lastOffline:resp.lastOffline deviceFlag:resp.deviceFlag];
                }
            }
           
        }
       
        if(onlineStatusResp.pc) {
            weakSelf.pcOnline = onlineStatusResp.pc.online;
            weakSelf.muteOfApp = onlineStatusResp.pc.muteOfApp;
            [weakSelf callOnlineStatusChangeMyPCOnlineStatusDelegate:onlineStatusResp.pc];
        }else {
            weakSelf.pcOnline = false;
            weakSelf.muteOfApp = false;
        }
        if(allOnlineChannelInfos && allOnlineChannelInfos.count>0) {
            bool noNeedOffline = false; // 不需要离线
            for (QCChannelInfo *onlineChannelInfo in allOnlineChannelInfos) {
                if(onlineStatusResp.friends && onlineStatusResp.friends.count>0) {
                    for (QCOnlineStatusResp *resp in onlineStatusResp.friends) {
                        if([resp.uid isEqualToString:onlineChannelInfo.channel.channelId]) {
                            noNeedOffline = true;
                            continue;
                        }
                    }
                }
                if(!noNeedOffline) {
                    [[QCChannelInfoDB shared] updateChannelOnlineStatus:onlineChannelInfo.channel status:QCOnlineStatusOffline lastOffline:0 mainDeviceFlag:QCDeviceFlagEnumUnknown];
                }
            }
        }
    });
}

-(void) onConnectStatus:(QCConnectStatus)status reasonCode:(QCReason)reasonCode{
    self.needUpdate = YES;
}


-(NSHashTable*) delegates {
    if (_delegates == nil) {
        _delegates = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return _delegates;
}

- (void)callOnlineStatusChangeDelegate:(QCOnlineStatusResp*)status {
    [self.delegateLock lock];
    NSHashTable *copyDelegates =  [self.delegates copy];
    [self.delegateLock unlock];
    for (id delegate in copyDelegates) {//遍历delegates ，call delegate
        if(!delegate) {
            continue;
        }
        if ([delegate respondsToSelector:@selector(onlineStatusManagerChange:status:)]) {
            if (![NSThread isMainThread]) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [delegate onlineStatusManagerChange:self status:status];
                });
            }else {
                [delegate onlineStatusManagerChange:self status:status];
            }
        }
    }
}

- (void)callOnlineStatusChangeMyPCOnlineStatusDelegate:(QCPCOnlineResp*)status {
    [self.delegateLock lock];
    NSHashTable *copyDelegates =  [self.delegates copy];
    [self.delegateLock unlock];
    for (id delegate in copyDelegates) {//遍历delegates ，call delegate
        if(!delegate) {
            continue;
        }
        if ([delegate respondsToSelector:@selector(onlineStatusManagerMyPCOnlineChange:status:)]) {
            if (![NSThread isMainThread]) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [delegate onlineStatusManagerMyPCOnlineChange:self status:status];
                });
            }else {
                [delegate onlineStatusManagerMyPCOnlineChange:self status:status];
            }
        }
    }
}

// 空表示不显示
- (NSString *)onlineStatusTip:(QCChannelInfo *)channelInfo {
    // 手机端不显示设备在线状态
    return nil;
}

-(NSString*) deviceName:(QCDeviceFlagEnum)deviceFlag {
    if(deviceFlag == QCDeviceFlagEnumPC) {
        return @"电脑";
    }
    if(deviceFlag == QCDeviceFlagEnumWeb) {
        return @"网页";
    }
    if(deviceFlag == QCDeviceFlagEnumAPP) {
        return @"手机";
    }
    return @"";
}

-(NSString*) onlineStatusDetailTip:(QCChannelInfo*)channelInfo {
    // 手机端不显示设备在线状态
    return nil;
}


-(void) addDelegate:(id<QCOnlineStatusManagerDelegate>) delegate{
    [self.delegateLock lock];//防止多线程同时调用
    [self.delegates addObject:delegate];
    [self.delegateLock unlock];
}
- (void)removeDelegate:(id<QCOnlineStatusManagerDelegate>) delegate {
    [self.delegateLock lock];//防止多线程同时调用
    [self.delegates removeObject:delegate];
    [self.delegateLock unlock];
}

- (void)dealloc
{
    [[QCSDK shared].connectionManager removeDelegate:self];
}
@end


@implementation QCFriendAndMyDeviceOnlineStatusResp

+ (QCModel *)fromMap:(NSDictionary *)dictory type:(ModelMapType)type {
    QCFriendAndMyDeviceOnlineStatusResp *resp = [QCFriendAndMyDeviceOnlineStatusResp new];
    
    if(dictory[@"pc"]) {
        resp.pc = [QCPCOnlineResp fromMap:dictory[@"pc"] type:type];
    }
    
    if(dictory[@"friends"]) {
        NSMutableArray<QCOnlineStatusResp*> *friends = [NSMutableArray array];
        for (NSDictionary *friendOnlineStatusDict in dictory[@"friends"]) {
            [friends addObject:[QCOnlineStatusResp fromMap:friendOnlineStatusDict type:type]];
        }
        resp.friends = friends;
    }
    
    return resp;
}

@end

@implementation QCPCOnlineResp

+ (QCPCOnlineResp * )fromMap:(NSDictionary *)dictory type:(ModelMapType)type {
    QCPCOnlineResp *resp = [QCPCOnlineResp new];
    resp.online = [dictory[@"online"] boolValue];
    if(dictory[@"device_flag"]) {
        resp.deviceFlag = [dictory[@"device_flag"] integerValue];
    }
    
    resp.muteOfApp = [dictory[@"mute_of_app"] boolValue];
    return resp;
}

@end

@implementation QCOnlineStatusResp

+ (QCOnlineStatusResp * _Nonnull)fromMap:(NSDictionary *)dictory type:(ModelMapType)type {
    QCOnlineStatusResp *resp = [[QCOnlineStatusResp alloc] init];
    resp.uid = dictory[@"uid"];
    resp.lastOffline = [dictory[@"last_offline"] integerValue];
    resp.online = [dictory[@"online"] boolValue];
    resp.deviceFlag = (QCDeviceFlagEnum)[dictory[@"device_flag"] integerValue];
    return resp;
}

@end
