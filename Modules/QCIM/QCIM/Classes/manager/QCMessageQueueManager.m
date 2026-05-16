//
//  QCMessageQueueManager.m
//  QCIM
//
//  Created by tt on 2023/11/15.
//

#import "QCMessageQueueManager.h"
#import "QCMessage.h"
#import "QCSendPacket.h"
#import "QCSDK.h"
#import "QCConnectionManager.h"

@interface QCMessageQueueManager ()

@property (nonatomic, strong) NSMutableArray<QCSendPacket*> *sendPackets;

@property(nonatomic,strong) NSTimer *timer;

@end

@implementation QCMessageQueueManager


static QCMessageQueueManager *_instance;
+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
+ (QCMessageQueueManager *)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}
- (NSMutableArray<QCSendPacket *> *)sendPackets {
    if(!_sendPackets) {
        _sendPackets = [NSMutableArray array];
    }
    return _sendPackets;
}

- (void)sendMessage:(QCMessage *)message {
    // 发送消息
    QCSendPacket *sendPacket = [QCSendPacket new];
    sendPacket.header.showUnread = message.header?message.header.showUnread:0;
    sendPacket.header.noPersist = message.header?message.header.noPersist:0;
    QCSetting *setting = message.setting;
    if(message.topic && ![message.topic isEqualToString:@""]) {
        setting.topic = true;
    }
    sendPacket.setting = setting;
    sendPacket.clientSeq = message.clientSeq;
    sendPacket.clientMsgNo = message.clientMsgNo;
    sendPacket.channelId = message.channel.channelId;
    sendPacket.channelType = message.channel.channelType;
    sendPacket.expire = message.expire;
    sendPacket.topic = message.topic;
    sendPacket.payload = message.content.encode;
    [self.sendPackets addObject:sendPacket];
    
   
}

-(void) start {
    if(self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    CGFloat delay = (double)QCSDK.shared.options.sendFrequency/1000.0f;
    NSLog(@"MessageQueue start delay: %0.2f",delay);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.timer = [NSTimer scheduledTimerWithTimeInterval:delay target:weakSelf selector:@selector(flushQueue) userInfo:nil repeats:YES];
    });
  
    
}

-(void) stop {
    NSLog(@"MessageQueue stop");
    [self.sendPackets removeAllObjects];
    if(self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

-(void) flushQueue {
    NSMutableData *sendPacketDatas;
    NSInteger sendPacketCount = 0;
    while (self.sendPackets.count>0) {
        if(!sendPacketDatas) {
            sendPacketDatas = [[NSMutableData alloc] init];
        }
        
        QCSendPacket *sendPacket = self.sendPackets.firstObject;
        [self.sendPackets removeObjectAtIndex:0];
        
        NSData *data = [[QCSDK shared].coder encode:sendPacket];
        [sendPacketDatas appendData:data];
        
        sendPacketCount++;
        if(sendPacketCount>=[QCSDK shared].options.sendMaxCountOfEach) {
            break;
        }
    }
    if(sendPacketDatas && sendPacketDatas.length>0) {
        [QCConnectionManager.sharedManager writeData:sendPacketDatas];
    }
}


@end
