//
//  QCPongPacket.m
//  QCIM
//
//  Created by tt on 2019/11/27.
//

#import "QCPongPacket.h"
#import "QCConst.h"
#import "QCSDK.h"
@implementation QCPongPacket

-(QCPacketType) packetType {
    return WK_PONG;
}

- (QCPacket *)decode:(NSData *)body header:(QCHeader *)header {
    
    return nil;
}

- (NSData *)encode:(QCPacket *)packet {
    return nil;
}



- (NSString *)description{
    
    return [NSString stringWithFormat:@"PONG"];
}
@end
