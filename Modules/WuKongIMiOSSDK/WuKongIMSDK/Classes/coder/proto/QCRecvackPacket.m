//
//  QCRecvackPacket.m
//  WuKongIMSDK
//
//  Created by tt on 2019/11/30.
//

#import "QCRecvackPacket.h"
#import "QCConst.h"
#import "QCData.h"
#import "QCSDK.h"
@implementation QCRecvackPacket

-(QCPacketType) packetType {
    return WK_RECVACK;
}

-(QCPacket*) decode:(NSData*) body header:(QCHeader*)header {
    
    return nil;
}

-(NSData*) encode:(QCRecvackPacket*)packet{
    return [self encodeLM:packet];
}

-(NSData*) encodeLM:(QCRecvackPacket*)packet{
    QCDataWrite  *writer = [[QCDataWrite alloc] init];
    // 消息ID
    [writer writeUint64:packet.messageId];
    //  消息序号
    [writer writeUint32:packet.messageSeq];
    return [writer toData];
}


@end
