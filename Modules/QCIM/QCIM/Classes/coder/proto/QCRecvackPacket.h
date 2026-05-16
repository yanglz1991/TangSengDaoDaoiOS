//
//  QCRecvackPacket.h
//  QCIM
//
//  Created by tt on 2019/11/30.
//

#import <Foundation/Foundation.h>
#import "QCPacket.h"
#import "QCPacketBodyCoder.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCRecvackPacket : QCPacket<QCPacketBodyCoder>

@property(nonatomic,assign) uint64_t messageId;
@property(nonatomic,assign) uint32_t messageSeq;

@end

NS_ASSUME_NONNULL_END
