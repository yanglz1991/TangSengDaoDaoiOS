//
//  QCConnectionManager.m
//  QCIM
//
//  Created by tt on 2019/11/23.
//

#import "QCConnectionManager.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>
#import "QCSDK.h"
#import "QCConnectPacket.h"
#import "QCConnackPacket.h"
#import "QCConst.h"
#import "QCData.h"
#import "QCPingPacket.h"
#import "QCSendackPacket.h"
#import "QCMessageDB.h"
#import "QCRecvPacket.h"
#import "QCBackoff.h"
#import "QCRetryManager.h"
#import "QCDB.h"
#import "QCSDK.h"
#import "QCDisconnectPacket.h"
#import "QCCMDManager.h"
#import "QCSecurityManager.h"
#import "QCReminderManager.h"
#import "QCChatManagerInner.h"
#import "QCConversationManagerInner.h"
#import "QCMessageQueueManager.h"


@interface QCConnectionManager ()<GCDAsyncSocketDelegate>


@property(nonatomic,strong) GCDAsyncSocket *ssocket;

/**
 *  用来存储所有添加j过的delegate
 *  NSHashTable 与 NSMutableSet相似，但NSHashTable可以持有元素的弱引用，而且在对象被销毁后能正确地将其移除。
 */
@property (strong, nonatomic) NSHashTable  *delegates;
/**
 *  delegateLock 用于给delegate的操作加锁，防止多线程同时调用
 */
@property (strong, nonatomic) NSLock  *delegateLock;

// 是否强制关闭连接
@property(nonatomic,assign) BOOL forceDisconnect;


// 解包的临时数据
@property(nonatomic,strong) NSMutableData *tempBufferData;
@property(nonatomic,strong) NSLock *tempBufferDataLock;
// 连接 condition
@property(nonatomic,strong) NSLock *connectStatusLock;
@property(nonatomic,assign) QCConnectStatus connectStatusInner;
@property(nonatomic,assign) QCReason reasonCodeInner;

// 心跳定时器
@property(nonatomic,strong) NSTimer *heartTimer;
// 最后一次收到的消息时间
@property(nonatomic) NSTimeInterval lastMsgTimeInterval;

// 重连退避算法
@property(nonatomic,strong) QCBackoff *reconnectBackoff;
@property(nonatomic,assign) int reconnectCount; // 重连次数，连接成功设置为0
@property(nonatomic,assign) bool isBackoffReconnect; // 是否在退避重连中

@property(nonatomic,assign) bool pullOfflineFinished; // 是否拉取离线完成

@property(nonatomic,strong) NSMutableArray<QCPacket*> *tempPackets; // 临时包（当没拉取离线完成前所有消息都存临时数组里，避免漏消息。）

@property(nonatomic,copy) NSString *deviceUUID;

@property(nonatomic,copy) void(^onConnectStatusChange)(QCConnectStatus status);

@end

@implementation QCConnectionManager

static QCConnectionManager *_instance;

static dispatch_queue_t _imsocketQueue;

+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
+ (QCConnectionManager*)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        _imsocketQueue = dispatch_queue_create("my.connection.queue", DISPATCH_QUEUE_SERIAL);
        _instance.delegates = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
        _instance.tempBufferData = [[NSMutableData alloc] init];
        _instance.connectStatusLock =[[NSLock alloc] init];
        _instance.tempBufferDataLock =[[NSLock alloc] init];
        _instance.tempPackets = [NSMutableArray array];
        _instance.reconnectBackoff = [QCBackoff createWithBuilder:^(QCBackoffBuilder *builder) {
            builder.base = 2; // 每次递增秒数
            builder.factor = 2; // 每次重连的系数 base*factor
            builder.jitter = 0;
            builder.cap = 60 * 1000; // 60s
        }];
        
    });
    return _instance;
}


// 连接IM服务器
-(void) connect {
    // 设置当前连接信息
    [self.connectStatusLock lock];
    self.forceDisconnect = false;
    [self.connectStatusLock unlock];
    
    if(![QCSDK shared].options.hasLogin) {
        if( [QCSDK shared].options.connectInfoCallback) {
            [QCSDK shared].options.connectInfo =  [QCSDK shared].options.connectInfoCallback();
        }else {
            NSLog(@"没有获取到连接信息，请调用[[QCSDK shared] connectionManager] setConnectInfoCallback设置连接回调");
            return;
        }
        
    }
    
    if(![QCSDK shared].options.hasLogin) {
        NSLog(@"没有设置连接信息！");
        return;
    }
    if([[QCDB sharedDB] needSwitchDB:[QCSDK shared].options.connectInfo.uid]) {
        // 切换数据库
        [[QCDB sharedDB] switchDB:[QCSDK shared].options.connectInfo.uid];
    }
    
    // 连接到IM服务器
    [self onlyConnect];
   
}


-(void) onlyConnect {
    @synchronized (self.ssocket) {
         if(self.connectStatusInner == QCConnected ||  self.connectStatusInner == QCConnecting) {
              if([QCSDK shared].isDebug) {
                  NSLog(@"已建立连接或在连接中，不再执行连接！");
              }
              return;
          }
          
           // 拉取离线消息
          [self changeConnectStatus:QCPullingOffline];
        
           self.pullOfflineFinished = false; // 还没有拉取离线
          // 状态变为：连接中...
          [self changeConnectStatus:QCConnecting];
          
        if(self.ssocket) {
            self.ssocket.delegate = nil;
            self.ssocket = nil;
          }
          // 循环去拿连接地址，直到拿到地址
          [self loopGetAddrToConnect];
        
    }
}

-(void) loopGetAddrToConnect {
    if(![QCSDK shared].options.hasLogin) {
        return;
    }
    if(self.forceDisconnect) {
         [self changeConnectStatus:QCDisconnected];
        return;
    }
    // 开始建立socket连接
    if(self.getConnectAddr) {
        __weak typeof(self) weakSelf = self;
        self.getConnectAddr(^(NSString * _Nonnull addr) {
            if(!addr || [addr isEqualToString:@""]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [weakSelf loopGetAddrToConnect];
                });
                return;
            }
            NSArray *addrs = [addr componentsSeparatedByString:@":"];
            if(addrs.count>0) {
                [weakSelf connectSocket:addrs[0] port:[addrs[1] integerValue]];
            }
        });
    }else {
        [self connectSocket:[QCSDK shared].options.host port:[QCSDK shared].options.port];
    }
}

-(void) connectSocket:(NSString*)host port:(uint16_t)port {
    if ([QCSDK shared].isDebug) {
        NSLog(@"开始连接IM服务器 -> %@:%i",host,port);
    }
    self.ssocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_imsocketQueue];
    NSError *error=nil;
    [self.ssocket connectToHost:host onPort:port error:&error];
    if(error) {
        NSLog(@"连接IM服务器失败-> %@",error);
        // 状态变为：已断开
        [self changeConnectStatus:QCDisconnected];
    }
}



/// 同步会话和离线消息（离线消息目前认为是cmd消息）
/// @param finish 同步完成
-(void) syncConversations:(void(^)(NSError *error)) finish {
    if(![QCSDK shared].options.hasLogin) {
        finish([NSError errorWithDomain:@"未登录" code:0 userInfo:nil]);
        return;
    }
    if(![QCSDK shared].conversationManager.syncConversationProvider) {
        NSLog(@"警告：没有设置会话同步提供者！");
        finish([NSError errorWithDomain:@"警告：没有设置会话同步提供者！" code:404 userInfo:nil]);
        return;
    }
    
    // 同步会话
    long long version = [[QCConversationDB shared] getConversationMaxVersion];
    NSString *syncKey = [[QCConversationDB shared] getConversationSyncKey];
    [QCSDK shared].conversationManager.syncConversationProvider(version, syncKey, ^(QCSyncConversationWrapModel* _Nullable model, NSError * _Nullable error) {
        if(error) {
            // 如果拉取离线消息发生错误 则休息3秒再拉取
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                [self syncConversations:finish];
            });
            return;
        }
        if(model) {
           
            [[QCSDK shared].conversationManager handleSyncConversation:model];
        }
        if([QCSDK shared].isDebug) {
            NSLog(@"同步会话完成！");
        }
        [self finishedSyncConversation];
        
        finish(nil);
        
        [QCSDK shared].conversationManager.syncConversationAck(0, ^(NSError * _Nonnull error) {
            if(error) {
                NSLog(@"回执同步会话失败！->%@",error);
            }
            
        });
       
        [[QCSDK shared].reminderManager sync]; // 同步会话的提醒项(比如 有人@我 草稿 等等)
        
        [[QCSDK shared].conversationManager syncExtra]; // 同步最近会话扩展
        
         return;
    });
}


// 完成同步会话
-(void) finishedSyncConversation {
    if(self.tempPackets && self.tempPackets.count>0) {
        [self handlePackets:self.tempPackets];
    }
}
// 离线拉取完成
-(void) finishedPullOffline {
    if(self.tempPackets && self.tempPackets.count>0) {
        [self handlePackets:self.tempPackets];
    }
}

// 改变连接状态
-(void) changeConnectStatus:(QCConnectStatus) connectStatus {
    [self.connectStatusLock lock];
    self.connectStatusInner = connectStatus;
    [self.connectStatusLock unlock];
    // 调用状态改变
    [self connectStatusChange];
}

// 断开IM服务器
-(void) disconnect:(BOOL) force {
    [self.connectStatusLock lock];
    self.forceDisconnect = force;
    [self.connectStatusLock unlock];
    
    [self.ssocket disconnect];
    
}

-(void) logout {
    [self.connectStatusLock lock];
    self.forceDisconnect = true;
    [QCSDK shared].options.connectInfo =nil;
    [self.connectStatusLock unlock];
    
    [[QCSDK shared].channelManager removeChannelAllCache];
    
    [self.ssocket disconnect];
}

// 重连
-(void) reconnect {
    if([QCSDK shared].isDebug) {
        NSLog(@"开始重连...");
    }
    // t改变连接状态为断开
    [self changeConnectStatus:QCDisconnected];
    // 这里不能调用断开，调用断开会走重连然后onlyConnect就是进行连接，会建立两个连接从而进行互相踢
//    [self.ssocket disconnect];
    [self onlyConnect];
}
// 重连（支持退避算法）
-(void) backoffReconnect {
    if(self.isBackoffReconnect) {
        return;
    }
    self.isBackoffReconnect = true;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 获取下次重连时间（单位秒）
        long backoffTime = [weakSelf.reconnectBackoff backoff:weakSelf.reconnectCount];
        if([QCSDK shared].isDebug) {
            NSLog(@"%lu秒后进行重连.",backoffTime);
        }
         weakSelf.reconnectCount++;
        [NSThread sleepForTimeInterval:backoffTime];
        weakSelf.isBackoffReconnect = false;
        // 重连
        [weakSelf reconnect];
        
       
    });
}

#pragma mark ---  GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    [sock readDataWithTimeout:-1 tag:0];
    [self sendConnectPacket:[QCSDK shared].options.connectInfo.uid token:[QCSDK shared].options.connectInfo.token];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    [sock readDataWithTimeout:-1 tag:0];
    
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                                                                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length {
    
    NSLog(@"read has timed out...");
    return 0.0;
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err {
    NSLog(@"IM连接已断开 -> %@",err);
     self.tempBufferData = [[NSMutableData alloc] init]; // 清楚缓存数据
    // 状态变为：已断开
    [self changeConnectStatus:QCDisconnected];
    // 断开后停止心跳
    [self stopHeartbeat];
    if(!self.forceDisconnect) { // 如果不是强制断开，则开启g退避算法重连
        [self backoffReconnect];
    }else {
        if ([QCSDK shared].isDebug) {
            NSLog(@"已强制断开,不再重连！");
        }
    }
   
}

- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
    NSLog(@"didReadPartialDataOfLength--->%lu",(unsigned long)partialLength);
}


//socket接受消息
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
     if ([QCSDK shared].isDebug) {
        NSLog(@"读取到消息-> %@",data);
     }
    // 解包
    [self unpacket:data callback:^(NSArray<NSData *> *data) {
        NSLog(@"------------解包消息数量--------> %lu",(unsigned long)data.count);
        [self handlePacketData:data];
    }];
    
    [sock readDataWithTimeout:-1 tag:0];
}

// 发送连接包
-(void) sendConnectPacket:(NSString*)uid token:(NSString*)token{
    
    [[QCSecurityManager shared] generateDHPair];
    
    QCSDK.shared.options.protoVersion = QCDefaultProtoVersion;
    
    QCConnectPacket *connectPacket = [QCConnectPacket new];
    connectPacket.clientKey = [[QCSecurityManager shared] getDHPubKey];
    connectPacket.version = [QCSDK shared].options.protoVersion;
    connectPacket.deviceFlag = 0;
    connectPacket.deviceId = [self deviceUUID:uid];
    connectPacket.clientTimestamp = [[NSDate date] timeIntervalSince1970]*1000;
    connectPacket.uid = uid;
    connectPacket.token = token;
    [self sendPacket:connectPacket];
}

- (NSString *)deviceUUID:(NSString*) uid {
    if(!_deviceUUID) {
        if(uid && ![uid isEqualToString:@""]) {
            NSString *key = [NSString stringWithFormat:@"deviceUUIDv2:%@",uid];
            NSString *deviceUUID = [[NSUserDefaults standardUserDefaults] objectForKey:key];
            if(deviceUUID) {
                _deviceUUID = deviceUUID;
            }else {
                NSString *uuid = [NSString stringWithFormat:@"%@ios",[[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""]];
                [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:key];
                [[NSUserDefaults standardUserDefaults]  synchronize];
                _deviceUUID = uuid;
            }
        }
       
    }
    return _deviceUUID;
}

// 发送ping
-(void) sendPing{
     [self sendPacket:[QCPingPacket new]];
}

// 发送包
-(void) sendPacket:(QCPacket*)packet{
    NSData *data = [[QCSDK shared].coder encode:packet];
    [self writeData:data];
}

-(void) writeData:(NSData*) data {
    [self.ssocket writeData:data withTimeout:1 tag:0];
}

- (NSLock *)delegateLock {
    if (_delegateLock == nil) {
        _delegateLock = [[NSLock alloc] init];
    }
    return _delegateLock;
}

-(void) addDelegate:(id<QCConnectionManagerDelegate>) delegate{
    [self.delegateLock lock];//防止多线程同时调用
    [self.delegates addObject:delegate];
    [self.delegateLock unlock];
}
- (void)removeDelegate:(id<QCConnectionManagerDelegate>) delegate {
    [self.delegateLock lock];//防止多线程同时调用
    [self.delegates removeObject:delegate];
    [self.delegateLock unlock];
}

// 连接状态发生改变
-(void) connectStatusChange {
    if(self.connectStatusInner == QCConnected) {
        [[QCRetryManager shared] start];
        [QCMessageQueueManager.shared start];
    }else {
        [[QCRetryManager shared] stop];
        [[QCMessageQueueManager shared] stop];
    }
    if(self.onConnectStatusChange) {
        self.onConnectStatusChange(self.connectStatusInner);
    }
    [self callConnectStatusDelegate];
}
#pragma mark --- call delegate
- (void)callConnectStatusDelegate {
    [self.delegateLock lock];
    NSHashTable *copyDelegates =  [self.delegates copy];
    [self.delegateLock unlock];
    for (id delegate in copyDelegates) {//遍历delegates ，call delegate
        if(!delegate) {
            continue;
        }
        if ([delegate respondsToSelector:@selector(onConnectStatus:reasonCode:)]) {
            if (![NSThread isMainThread]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate onConnectStatus:self.connectStatusInner reasonCode:self.reasonCodeInner];
                });
            }else {
                 [delegate onConnectStatus:self.connectStatusInner reasonCode:self.reasonCodeInner];
            }
        }
    }
}
- (void)callKickDelegate:(QCDisconnectPacket*)disconnectPacket {
    [self callKickDelegate:disconnectPacket.reasonCode reason:disconnectPacket.reason];
}

- (void)callKickDelegate:(uint8_t)reasonCode reason:(NSString*)reason {
    [self.delegateLock lock];
    NSHashTable *copyDelegates =  [self.delegates copy];
    [self.delegateLock unlock];
    for (id delegate in copyDelegates) {//遍历delegates ，call delegate
        if(!delegate) {
            continue;
        }
        if ([delegate respondsToSelector:@selector(onKick:reason:)]) {
            if (![NSThread isMainThread]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate onKick:reasonCode reason:reason];
                });
            }else {
                [delegate onKick:reasonCode reason:reason];
            }
        }
    }
}


-(void) unpacket:(NSData*)packetData  callback:(void(^) (NSArray<NSData*> *data))callback{
    [self.tempBufferDataLock lock];
    @try {
        [self.tempBufferData appendData:packetData];
        unsigned long lenBefore,lenAfter;
        NSMutableArray<NSData*> *dataList = [[NSMutableArray alloc] init];
        
        do {
            lenBefore = self.tempBufferData.length;
            self.tempBufferData = [self unpackOne:self.tempBufferData callback:^(NSData *data) {
                [dataList addObject:data];
            }];
            lenAfter = self.tempBufferData.length;
            if(lenAfter>0) {
                NSLog(@"有剩余未被解析的包->%lu",lenAfter);
            }
        } while (lenBefore != lenAfter && lenAfter >= 1);
        if (dataList.count > 0) {
            callback(dataList);
        }
    } @catch (NSException *exception) {
        NSLog(@"-------- 解包异常 -> %@",exception);
        [self backoffReconnect];
        
    } @finally {
         [self.tempBufferDataLock unlock];
    }
   
}

-(NSMutableData*) unpackOne:(NSMutableData*)packData callback:(void(^) (NSData *data))callback {
    return [self unpackOneLM:packData callback:callback];
}

// 解包
-(NSMutableData*) unpackOneLM:(NSMutableData*)packData callback:(void(^) (NSData *data))callback {
    uint8_t packetType;
    [QCDataRead numberHNMemcpy:&packetType src:[[packData subdataWithRange:NSMakeRange(0, 1)] bytes] count:1];
    packetType = packetType>>4;
    if(packetType == WK_PONG) {
        callback([packData subdataWithRange:NSMakeRange(0, 1)]);
        return [[NSMutableData alloc] initWithData:[packData subdataWithRange:NSMakeRange(1, packData.length-1)]];
    }
    
    NSUInteger length = packData.length;
   int fixedHeaderLength = 1;
    int pos = fixedHeaderLength;
    int digit;
    int remLength = 0;
    int multiplier = 1;
    bool hasLength = false; // 是否还有长度数据没读完
    bool remLengthFull = true; // 剩余长度的字节是否完整
    do {
        if (pos > length - 1) {
            // 这种情况出现了分包，并且分包的位置是长度部分的某个位置。
            remLengthFull = false;
            break;
        }
        [packData getBytes:&digit range:NSMakeRange(pos++, 1)];
        remLength += ((digit & 127) * multiplier);
        multiplier *= 128;
        hasLength = (digit & 0x80) != 0;
    } while (hasLength);
    
    if (!remLengthFull) {
        NSLog(@"包长度没有读出来");
        return packData;
    }
    int remLengthLength = pos - fixedHeaderLength; // 剩余长度的长度
    if (fixedHeaderLength + remLengthLength + remLength > length) {
        // 固定头的长度 + 剩余长度的长度 + 剩余长度 如果大于 总长度说明分包了
        NSLog(@"分包了...剩余长度：%d  当前长度：%lu",remLength,(unsigned long)length);
        return packData;
    }else {
        if (fixedHeaderLength + remLengthLength + remLength == length) {
            // 刚好一个包
            NSLog(@"刚好一个包");
            callback(packData);
            return [[NSMutableData alloc] init];
        } else {
            // 粘包  大于1个包
            int packetLength = fixedHeaderLength + remLengthLength + remLength;
           
            NSData *fullPackData = [packData subdataWithRange:NSMakeRange(0, packetLength)];
           
            callback(fullPackData);
            NSData *remPackData = [packData subdataWithRange:NSMakeRange(packetLength, length-packetLength)];
            
            NSLog(@"粘包  大于1个包，包长度:%i-%lu-%lu-%lu",packetLength,fullPackData.length,remPackData.length,length);
            
            return [[NSMutableData alloc] initWithData:remPackData];
        }
    }
}

// 处理包数据
-(void) handlePacketData:(NSArray<NSData*>*)dataList {
    if(!dataList || dataList.count<=0) {
        return;
    }
    self.lastMsgTimeInterval = [[NSDate date] timeIntervalSince1970];
    NSMutableArray<QCPacket*> *packets = [NSMutableArray array];
    NSLog(@"包数量--->%lu",dataList.count);
    for (NSData *data in dataList) {
       QCPacket *packet =  [[QCSDK shared].coder decode:data];
        if(!packet) {
            NSLog(@"未解码到数据！->%@",data);
            continue;
        }
         NSLog(@"解码到包 -> %@",packet);
        if([packet header].packetType == WK_CONNACK) {
            QCConnackPacket *connackPacket = (QCConnackPacket*)packet;
            self.reasonCodeInner = connackPacket.reasonCode;
            if(connackPacket.reasonCode == WK_REASON_SUCCESS) {
                if([QCSDK shared].isDebug) {
                    NSLog(@"连接成功！-> %@",packet);
                }
                // 处理连接成功的逻辑
                [self handleConnected:connackPacket];
            }else {
                if([QCSDK shared].isDebug) {
                    NSLog(@"连接失败！-> %@",packet);
                }
                if(connackPacket.reasonCode == WK_REASON_AUTHFAIL) {
                    [self disconnect:YES];
                    [self callKickDelegate:connackPacket.reasonCode reason:@"认证失败！"];
                }else{
                    [self disconnect:NO];
                }
            }
            return;
        } else if([packet header].packetType == WK_DISCONNECT) { // 断开连接
            if([QCSDK shared].isDebug) {
                NSLog(@"收到断开连接的包！客户端将断开！");
            }
            QCDisconnectPacket *disconnectPacket = (QCDisconnectPacket*)packet;
            self.reasonCodeInner = disconnectPacket.reasonCode;
            [self disconnect:YES];
            [self callKickDelegate:disconnectPacket];
        } else {
            [packets addObject:packet];
        }
    }
    if(!self.pullOfflineFinished) { // 如果拉取消息未完成，则在线消息都存临时数组里
        [self.tempPackets addObjectsFromArray:packets];
        return;
    }
   
    if(self.tempPackets.count>0) {
        NSLog(@"有临时包,数量:%lu",(unsigned long)self.tempPackets.count);
        for (NSInteger i=0; i<self.tempPackets.count; i++) {
            QCPacket *tempPacket = self.tempPackets[i];
            [packets insertObject:tempPacket atIndex:i];
        }
        [self.tempPackets removeAllObjects];
    }
    [self handlePackets:packets];
   
}

-(void) handlePackets:(NSArray<QCPacket*>*)packets {
    NSDictionary<NSNumber*,NSArray<QCPacket*>*>* packetDict = [self packetGroup:packets];
    for (NSNumber *packetTypeNum in packetDict.allKeys) {
        NSArray<QCPacket*> *packetList = [packetDict objectForKey:packetTypeNum];
        switch (packetTypeNum.unsignedIntegerValue) {
            case WK_SENDACK:
                [[QCSDK shared].chatManager handleSendack:(NSArray<QCSendackPacket*> *)packetList];
                break;
            case WK_RECV:
                [[QCSDK shared].chatManager handleRecv:(NSArray<QCRecvPacket*> *)packetList];
                break;
            case  WK_PONG:
                break;
            default:
                NSLog(@"未知的数据包-->[%d]",packetTypeNum.unsignedIntValue);
                break;
        }
    }
}

-( QCConnectStatus) connectStatus {
    return self.connectStatusInner;
}

// 处理连接成功的逻辑
-(void) handleConnected:(QCConnackPacket*)connackPacket{
    
    [[QCSecurityManager shared] generateAesKey:connackPacket.serverKey salt:connackPacket.salt];
   
    // 重连次数归0
    self.reconnectCount = 0;
    
    // 开始心跳
    [self startHeartbeat];
    
    // 开始拉取离线消息
     [self changeConnectStatus:QCPullingOffline];
    
    __weak typeof(self) weakSelf = self;
    [self syncConversations:^(NSError *error){
        weakSelf.pullOfflineFinished = true; // 离线拉取完成
        if(!error) {
            // 改变状态为已连接
            [weakSelf changeConnectStatus:QCConnected];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [[QCSDK shared].cmdManager pullCMDMessages]; // 开始拉取cmd消息
            });
        }else {
            if(error.code == 404) { // 没有syncConversationProvider
                // 改变状态为已连接
                [weakSelf changeConnectStatus:QCConnected];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    [[QCSDK shared].cmdManager pullCMDMessages]; // 开始拉取cmd消息
                });
            }else {
                NSLog(@"同步会话失败！-> %@",error);
            }
           
        }
    }];
    
}

// 包分组
-(NSDictionary<NSNumber*,NSArray<QCPacket*>*>*) packetGroup:(NSArray<QCPacket*>*)packets {
    if(!packets) {
        return [NSMutableDictionary dictionary];
    }
    NSMutableDictionary *packetDict = [NSMutableDictionary dictionary];
    for (QCPacket *packet in packets) {
       NSMutableArray<QCPacket*> *gpackets = packetDict[ @(packet.header.packetType)];
        if(!gpackets) {
            gpackets = [NSMutableArray array];
        }
        [gpackets addObject:packet];
        packetDict[ @(packet.header.packetType)] = gpackets;
    }
    return packetDict;
}


// 开始心跳
-(void) startHeartbeat {
    if(self.heartTimer){
        [self.heartTimer invalidate];
    }
    // 定时器必须在主线程才能执行
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.heartTimer = [NSTimer scheduledTimerWithTimeInterval:[QCSDK shared].options.heartbeatInterval
                                                           target:weakSelf
                                                         selector:@selector(checkAndSendHeartbeat)
                                                         userInfo:nil
                                                          repeats:YES];
    });
}

// 停止心跳
-(void) stopHeartbeat {
    [self.heartTimer invalidate];
    if([QCSDK shared].isDebug) {
        NSLog(@"心跳停止！");
    }
}

-(void) checkAndSendHeartbeat {
    //如果心跳停止时间大于心跳频率+1 那么认为心跳停止 心跳停止 进行重新连接
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    if (nowTime - self.lastMsgTimeInterval > [QCSDK shared].options.heartbeatInterval+1) {
        [self backoffReconnect];
        return;
    }
     [self sendPing];
}

- (void)wakeup:(NSTimeInterval)timeout complete:(void (^)(NSError * __nullable))complete {
    if(self.connectStatus == QCConnected) { //  如果已经连接则什么都不做直接回调
        if(complete) {
            complete(nil);
        }
        return;
    }
    
   __block BOOL hasComplete = false;
    self.onConnectStatusChange = ^(QCConnectStatus status) {
        if(status == QCConnected) {
            hasComplete = true;
            if(complete) {
                complete(nil);
            }
            return;
        }
    };
    // 连接IM
    [self connect];
    
    // 指定超时的时间内如果没有执行callback，就执行超时回调
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.onConnectStatusChange = nil;
        if(!hasComplete) {
            if(complete) {
                complete([NSError errorWithDomain:@"唤醒超时" code:408 userInfo:nil]);
            }
        }
    });
}


@end
