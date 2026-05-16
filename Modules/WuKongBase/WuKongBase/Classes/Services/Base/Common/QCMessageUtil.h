//
//  QCMessageUtil.h
//  WuKongBase
//
//  Created by tt on 2020/10/12.
//

#import <Foundation/Foundation.h>
#import <WuKongIMSDK/WuKongIMSDK.h>
NS_ASSUME_NONNULL_BEGIN

@interface QCMessageUtil : NSObject

+(QCMessage*) toMessage:(NSDictionary*)messageDict;

+(QCMessageExtra*) toMessageExtra:(NSDictionary*)dataDict channel:(QCChannel*)channel;

+(QCReaction*) toReaction:(NSDictionary*)dataDict;

@end

NS_ASSUME_NONNULL_END
