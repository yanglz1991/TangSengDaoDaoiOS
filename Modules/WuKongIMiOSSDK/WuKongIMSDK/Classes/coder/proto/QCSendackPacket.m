//
//  QCSendackPacket.m
//  WuKongIMSDK
//
//  Created by tt on 2019/11/27.
//

#import "QCSendackPacket.h"
#import "QCConst.h"
#import "QCData.h"
#import "QCSDK.h"
@implementation QCSendackPacket

-(QCPacketType) packetType {
    return WK_SENDACK;
}

-(QCPacket*) decode:(NSData*) body header:(QCHeader*)header {
    return [self decodeLM:body header:header];
}

-(QCPacket*) decodeLM:(NSData*) body header:(QCHeader*)header {
    QCSendackPacket *packet = [QCSendackPacket new];
    QCDataRead *reader = [[QCDataRead alloc] initWithData:body];
    packet.header = header;
    packet.messageId = [reader readUint64];
    packet.clientSeq = [reader readUint32];
    packet.messageSeq = [reader readUint32];
    packet.reasonCode = [reader readUint8];
    return packet;
}

-(NSData*) encode:(QCSendackPacket*)packet{
    return nil;
}

- (NSString *)description{
    
    return [NSString stringWithFormat:@"SENDACK clientSeq:%u  messageId:%llu messageSeq:%u reasonCode:%i",self.clientSeq,self.messageId,self.messageSeq,self.reasonCode];
}

@end
