//
//  QCViewedManager.h
//  QCIM
//
//  Created by tt on 2022/8/17.
//

#import <Foundation/Foundation.h>
#import "QCMessage.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCFlameManager : NSObject

+ (QCFlameManager *)shared;

/**
  标记为已读
 */
-(void) didViewed:(NSArray<QCMessage*>*) messages;

/**
  获取需要焚烧的消息（阅后即焚）
 */
-(NSArray<QCMessage*>*) getMessagesOfNeedFlame;

@end

NS_ASSUME_NONNULL_END
