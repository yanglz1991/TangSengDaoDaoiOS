//
//  QCMessageQueueManager.h
//  WuKongIMSDK
//
//  Created by tt on 2023/11/15.
//

#import <Foundation/Foundation.h>
#import "QCMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface QCMessageQueueManager : NSObject

+ (QCMessageQueueManager *)shared;

-(void) start;

-(void) stop;

- (void)sendMessage:(QCMessage *)message;

@end

NS_ASSUME_NONNULL_END
