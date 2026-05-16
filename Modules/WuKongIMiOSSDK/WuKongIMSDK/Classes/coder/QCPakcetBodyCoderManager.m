//
//  QCPakcetBodyManager.m
//  WuKongIMSDK
//
//  Created by tt on 2019/11/25.
//

#import "QCPakcetBodyCoderManager.h"
#import "QCConnectPacket.h"
#import "QCConnackPacket.h"
#import "QCSendPacket.h"
#import "QCSendackPacket.h"
#import "QCRecvPacket.h"
#import "QCRecvackPacket.h"
#import "QCDisconnectPacket.h"
#import "QCPingPacket.h"
#import "QCPongPacket.h"
@interface QCPakcetBodyCoderManager ()

@property(nonatomic,strong) NSMutableDictionary *bodyCoderDic;
@end



@implementation QCPakcetBodyCoderManager

-(instancetype) init {
    self = [super init];
    if(self) {
        self.bodyCoderDic = [[NSMutableDictionary alloc] init];
        // 注册连接包
        QCConnectPacket *connectPacket = [QCConnectPacket new];
        [self registerBodyCoder:[connectPacket header].packetType bodyCoder:connectPacket];
        // 连接回执
        QCConnackPacket *connackPacket = [QCConnackPacket new];
        [self registerBodyCoder:[connackPacket header].packetType bodyCoder:connackPacket];
        // 发送消息
        QCSendPacket *sendPacket = [QCSendPacket new];
        [self registerBodyCoder:[sendPacket header].packetType bodyCoder:sendPacket];
        // 收消息
        QCRecvPacket *recvPacket = [QCRecvPacket new];
        [self registerBodyCoder:[recvPacket header].packetType bodyCoder:recvPacket];
        // 发送消息回执
        QCSendackPacket *sendackPacket = [QCSendackPacket new];
        [self registerBodyCoder:[sendackPacket header].packetType bodyCoder:sendackPacket];
        // 收取消息回执
        QCRecvackPacket *recvackPacket = [QCRecvackPacket new];
        [self registerBodyCoder:[recvackPacket header].packetType bodyCoder:recvackPacket];
        // 断开连接
        QCDisconnectPacket *disconnectPacket = [QCDisconnectPacket new];
        [self registerBodyCoder:[disconnectPacket header].packetType bodyCoder:disconnectPacket];
        // ping
        QCPingPacket *pingPacket = [QCPingPacket new];
        [self registerBodyCoder:[pingPacket header].packetType bodyCoder:pingPacket];
        // pong
        QCPongPacket *pongPacket = [QCPongPacket new];
        [self registerBodyCoder:[pongPacket header].packetType bodyCoder:pongPacket];
    }
    return self;
}

-(void) registerBodyCoder:(QCPacketType)packetType bodyCoder:(id<QCPacketBodyCoder>)bodyCoder{
    [self.bodyCoderDic setObject:bodyCoder forKey:[NSString stringWithFormat:@"%i",packetType]];
}

-(id<QCPacketBodyCoder>) getBodyCoder:(QCPacketType)packetType{
    
    return [self.bodyCoderDic objectForKey:[NSString stringWithFormat:@"%i",packetType]];
}

@end
