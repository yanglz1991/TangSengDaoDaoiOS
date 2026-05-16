//
//  QCConnackPacket.m
//  WuKongIMSDK
//
//  Created by tt on 2019/11/26.
//

#import "QCConnackPacket.h"
#import "QCConst.h"
#import "QCData.h"
#import "QCSDK.h"
@implementation QCConnackPacket


-(QCPacketType) packetType {
    return WK_CONNACK;
}

-(QCPacket*) decode:(NSData*) body header:(QCHeader*)header {
    return [self decodeLM:body header:header];
}

-(QCPacket*) decodeLM:(NSData*) body header:(QCHeader*)header {
    QCConnackPacket *packet = [QCConnackPacket new];
    QCDataRead *reader = [[QCDataRead alloc] initWithData:body];
    if(header.hasServerVersion) {
        packet.serverVersion = [reader readUint8];
        if(packet.serverVersion < QCSDK.shared.options.protoVersion) {
            QCSDK.shared.options.protoVersion = packet.serverVersion;
        }
    } else {
        QCSDK.shared.options.protoVersion = 0x2; // 降级到expire字段之前的0x2版本
    }
    NSLog(@"使用协议版本：%hhu",QCSDK.shared.options.protoVersion);
    packet.timeDiff = [reader readint64];
    packet.reasonCode = [reader readUint8];
    packet.serverKey = [reader readString];
    packet.salt = [reader readString];
   
    return packet;
}

-(NSData*) encode:(QCConnackPacket*)packet{
    return nil;
}

- (NSString *)description{
 
    return [NSString stringWithFormat:@"timeDiff:%lli reasonCode:%i",self.timeDiff,self.reasonCode];
}

@end
