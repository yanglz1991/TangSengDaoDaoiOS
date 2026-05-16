//
//  QCMessageStatusModel.h
//  WuKongIMBase
//
//  Created by tt on 2019/12/29.
//

#import <Foundation/Foundation.h>
#import "QCConst.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCMessageStatusModel : NSObject
// 消息唯一ID
@property(nonatomic,assign) uint32_t clientSeq;
// 消息状态
@property(nonatomic) QCMessageStatus status;

-(instancetype) initWithClientSeq:(uint32_t)clientSeq status:(QCMessageStatus)status;
@end

NS_ASSUME_NONNULL_END
