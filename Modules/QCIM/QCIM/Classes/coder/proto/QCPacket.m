//
//  QCPacket.m
//  QCIM
//
//  Created by tt on 2019/11/25.
//

#import "QCPacket.h"
#import "QCConst.h"
@implementation QCPacket


-(QCPacketType) packetType {
    return 0;
}

-(QCHeader*) header {
    if(_header) {
        return _header;
    }
    _header = [QCHeader new];
    _header.packetType = [self packetType];
    return _header;
}



@end
