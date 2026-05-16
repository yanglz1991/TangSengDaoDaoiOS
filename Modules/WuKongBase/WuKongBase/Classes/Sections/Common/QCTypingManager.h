//
//  QCTypingManager.h
//  WuKongBase
//
//  Created by tt on 2020/8/13.
//

#import <Foundation/Foundation.h>
#import <WuKongIMSDK/WuKongIMSDK.h>
NS_ASSUME_NONNULL_BEGIN
@class QCTypingManager;
@protocol QCTypingManagerDelegate <NSObject>

@optional


/// 指定频道的typing增加
/// @param manager <#manager description#>
/// @param message 消息typing
-(void) typingAdd:(QCTypingManager*)manager message:(QCMessage*)message;


/// 指定频道的typing移除
/// @param manager <#manager description#>
/// @param message 消息typing
-(void) typingRemove:(QCTypingManager*)manager message:(QCMessage*)message newMessage:(QCMessage*)message;

-(void) typingReplace:(QCTypingManager*)manager newmessage:(QCMessage*)newmessage oldmessage:(QCMessage*)oldmessage;

@end

@interface QCTypingManager : NSObject

+ (QCTypingManager *)shared;


/// 添加typing 通过消息
/// @param message <#message description#>
-(void) addTypingByMessage:(QCMessage*)message;


/// 移除指定频道的typing
/// @param channel <#channel description#>
-(void) removeTypingByChannel:(QCChannel*)channel newMessage:(QCMessage * __nullable)message;



-(BOOL) hasTyping:(QCChannel*)channel;

/// 获取所有typing消息
-(NSArray<QCMessage*>*) getAllTypingMessages;


/// 获取指定频道的typing消息
/// @param channel <#channel description#>
-(QCMessage*) getTypingMessage:(QCChannel*) channel;

/**
 添加连接委托

 @param delegate <#delegate description#>
 */
-(void) addDelegate:(id<QCTypingManagerDelegate>) delegate;


/**
 移除连接委托

 @param delegate <#delegate description#>
 */
-(void)removeDelegate:(id<QCTypingManagerDelegate>) delegate;

-(QCMessage*) convertParamToTypingMessage:(NSDictionary*)param;

@end

NS_ASSUME_NONNULL_END
