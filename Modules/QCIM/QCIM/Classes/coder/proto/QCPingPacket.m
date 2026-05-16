//
//  QCPingPacket.m
//  QCIM
//
//  Created by tt on 2019/11/27.
//

#import "QCPingPacket.h"
#import "QCConst.h"
#import "QCData.h"
#import "QCSDK.h"
@implementation QCPingPacket

-(QCPacketType) packetType {
    return WK_PING;
}

- (QCPacket *)decode:(NSData *)body header:(QCHeader *)header {
    return nil;
}

- (NSData *)encode:(QCPingPacket *)packet {
   
    return nil;
}


@end
