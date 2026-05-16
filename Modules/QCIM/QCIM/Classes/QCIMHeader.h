//
//  QCIMHeader.h
//  Pods
//
//  Created by tt on 2022/12/13.
//


#import <Foundation/Foundation.h>
#import "QCOptions.h"
#import "QCConnectionManager.h"
#import "QCCoder.h"
#import "QCPakcetBodyCoderManager.h"
#import "QCChatManager.h"
#import "QCPinnedMessageManager.h"
#import "QCMessageContent.h"
#import "QCConversationManager.h"
#import "QCChannelManager.h"
#import "QCMediaManager.h"
#import "QCMessageFileUploadTask.h"
#import "QCMessageFileDownloadTask.h"
#import "QCTaskManager.h"
#import "QCCMDManager.h"
#import "QCReceiptManager.h"
#import "QCTaskOperator.h"
#import "QCReactionManager.h"
#import "QCRobotManager.h"
#import "QCReminderManager.h"
#import "QCFlameManager.h"
#import "QCConst.h"


NS_ASSUME_NONNULL_BEGIN

/**
 频道资料回调

 @param error 错误
 */
typedef void (^QCChannelInfoCallback)(NSError * _Nullable error,bool notifyBefore);


/**
 离线消息回调

 @param messages 获取的离线消息
 @param more 是否还有更多消息
 @param error 错误信息
 */
typedef void(^QCOfflineMessageCallback)(NSArray<QCMessage*>* __nullable messages,bool more,NSError * __nullable error);

/**
 离线消息ack回调
 @param messageSeq 最后收到的消息序列号
 */

typedef void(^QCOfflineMessageAck)(uint32_t messageSeq,void(^complete)(NSError *error));


/**
 用户信息提供者 （第三方需要设置）

 */
typedef QCTaskOperator* _Nullable (^QCChannelInfoUpdate)(QCChannel *channel,QCChannelInfoCallback callback);


/**
 离线消息拉取

 @param limit <#limit description#>
 @param messageSeq <#messageSeq description#>
 @param callback <#callback description#>
 */
typedef void (^QCOfflineMessagePull)(int limit,uint32_t messageSeq,QCOfflineMessageCallback callback);

NS_ASSUME_NONNULL_END
