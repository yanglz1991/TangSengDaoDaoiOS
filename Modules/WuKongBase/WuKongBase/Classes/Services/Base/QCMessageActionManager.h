//
//  QCMessageActionManager.h
//  WuKongBase
//
//  Created by tt on 2022/4/8.
//

#import <Foundation/Foundation.h>
#import <WuKongIMSDK/WuKongIMSDK.h>
NS_ASSUME_NONNULL_BEGIN

@interface QCMessageActionManager : NSObject

+ (QCMessageActionManager *)shared;

/**
 转发消息
 */
-(void) forwardMessages:(NSArray<QCMessage*>*)messages;

/**
 转发消息
 */
-(void) forwardContent:(QCMessageContent*)messageContent complete:(void(^__nullable)(void))complete;

/**
 发送消息给朋友
 */
-(void) sendContentToFriend:(QCMessageContent*)messageContent complete:(void(^__nullable)(void))complete;
@end

NS_ASSUME_NONNULL_END
