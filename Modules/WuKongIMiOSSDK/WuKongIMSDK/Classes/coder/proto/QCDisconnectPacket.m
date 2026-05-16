//
//  QCDisconnectPacket.m
//  WuKongIMSDK
//
//  Created by tt on 2020/1/30.
//

#import "QCDisconnectPacket.h"
#import "QCConst.h"
#import "QCData.h"
#import "QCSDK.h"
@implementation QCDisconnectPacket



-(QCPacketType) packetType {
    return WK_DISCONNECT;
}

-(QCPacket*) decode:(NSData*) body header:(QCHeader*)header {
    return [self decodeLM:body header:header];
}

-(QCPacket*) decodeLM:(NSData*) body header:(QCHeader*)header {
    QCDisconnectPacket *packet = [QCDisconnectPacket new];
    QCDataRead *reader = [[QCDataRead alloc] initWithData:body];
    packet.reasonCode = [reader readUint8];
    packet.reason = [reader readString];
    return packet;
}

-(QCPacket*) decodeMOS:(NSData*) body header:(QCHeader*)header {
    QCDisconnectPacket *packet = [QCDisconnectPacket new];
    QCDataRead *reader = [[QCDataRead alloc] initWithData:body];
    [reader readUint8]; // login_type
    [reader readUint64]; // from_cust_id
    uint32_t status = [reader readUint32];
    if(status == 200 || status == 0) {
        packet.reasonCode = WK_REASON_SUCCESS;
    }else{
        packet.reasonCode = WK_REASON_AUTHFAIL;
    }
    
    packet.reason = @"";
    return packet;
}

-(NSData*) encode:(QCDisconnectPacket*)packet{
    return nil;
}

- (NSString *)description{
    
    return [NSString stringWithFormat:@"reasonCode:%hhu reason:%@",self.reasonCode,self.reason];
}


@end
