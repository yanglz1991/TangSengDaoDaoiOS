//
//  QCSyncChannelMessageModel.h
//  QCIM
//
//  Created by tt on 2020/10/5.
//

#import <Foundation/Foundation.h>
#import "QCMessage.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCSyncChannelMessageModel : NSObject

@property(nonatomic,assign) uint32_t startMessageSeq; // 开始消息序列号
@property(nonatomic,assign) uint32_t endMessageSeq; // 结束消息序列号
@property(nonatomic,strong) NSArray<QCMessage*> *messages; // 消息集合

@end

NS_ASSUME_NONNULL_END
