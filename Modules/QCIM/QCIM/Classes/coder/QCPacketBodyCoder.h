//
//  QCPacketBodyCoder.h
//  QCIM
//
//  Created by tt on 2019/11/25.
//
#import "QCPacket.h"

@protocol QCPacketBodyCoder <NSObject>

-(QCPacket*) decode:(NSData*) body header:(QCHeader*)header;

-(NSData*) encode:(QCPacket*)packet;

@end
