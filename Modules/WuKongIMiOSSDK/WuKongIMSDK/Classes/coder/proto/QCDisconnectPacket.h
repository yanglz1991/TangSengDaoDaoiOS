//
//  QCDisconnectPacket.h
//  WuKongIMSDK
//
//  Created by tt on 2020/1/30.
//

#import <Foundation/Foundation.h>
#import "QCPacket.h"
#import "QCPacketBodyCoder.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCDisconnectPacket :  QCPacket<QCPacketBodyCoder>

// 原因代码
@property(nonatomic,assign) uint8_t reasonCode;
// 原因字符串
@property(nonatomic,copy) NSString *reason;

@end

NS_ASSUME_NONNULL_END
