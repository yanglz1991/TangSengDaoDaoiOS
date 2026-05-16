//
//  QCChannelRequestQueue.h
//  WuKongIMSDK
//
//  Created by tt on 2021/4/22.
//

#import <Foundation/Foundation.h>
#import "QCChannel.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCChannelRequestQueue : NSObject

+ (QCChannelRequestQueue *)shared;


-(void) addRequest:(QCChannel*)channel complete:(void(^)(NSError *error,bool notifyBefore))complete;

-(void) cancelRequest:(QCChannel*)channel;
@end

NS_ASSUME_NONNULL_END
