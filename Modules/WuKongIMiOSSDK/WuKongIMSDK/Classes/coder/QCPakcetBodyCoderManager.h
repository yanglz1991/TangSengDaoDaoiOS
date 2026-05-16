//
//  QCPakcetBodyManager.h
//  WuKongIMSDK
//
//  Created by tt on 2019/11/25.
//

#import <Foundation/Foundation.h>
#import "QCPacketBodyCoder.h"
#import "QCConst.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCPakcetBodyCoderManager : NSObject


/**
 注册body解码者

 @param packetType 包类型
 @param bodyCoder 包编码者
 */
-(void) registerBodyCoder:(QCPacketType)packetType bodyCoder:(id<QCPacketBodyCoder>)bodyCoder;

/**
 获取body编码者

 @param packetType 包类型
 @return 返回包body编码者
 */
-(id<QCPacketBodyCoder>) getBodyCoder:(QCPacketType)packetType;
@end

NS_ASSUME_NONNULL_END
